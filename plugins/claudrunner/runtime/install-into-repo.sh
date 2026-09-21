#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# Install claudrunner into the repository in the current directory, so that anything that
# opens this repository — a Claude Code routine in the cloud, CI, a teammate's laptop —
# has the crew without installing the plugin.
#
#   install-into-repo.sh <plugin root> [--with-commands | --local]
#
# Always:          the runtime the configured schedule needs, into .claudrunner/bin/.
# --with-commands: also the commands, skills and agents into .claude/, where Claude Code
#                  loads them in every session of this repository. A cloud routine cannot
#                  install plugins, so this is how the routine gets the crew.
# --local:         the crew only runs on this computer, where the plugin supplies the
#                  commands, skills and agents. All of .claudrunner/ goes into .gitignore,
#                  so nothing claudrunner writes is ever committed.
#
# Only what .claudrunner/config.yml needs is installed: the one board binding it uses, the
# sweep only when the slow loop is on, a sweep skill only for a scope it runs. Without a
# config everything is installed. What an earlier install put here and this one no longer
# needs is removed, using the list in .claudrunner/installed.txt.
#
# Everything installed here is meant to be committed. Only run records and the generated
# page are ignored. Files with other names are never touched.
set -uo pipefail

root="${1:?usage: install-into-repo.sh <plugin root> [--with-commands | --local]}"
with_commands=false; local_only=false
case "${2:-}" in
  --with-commands) with_commands=true ;;
  --local)         local_only=true ;;
  "") ;;
  *) echo "install-into-repo: unknown option ${2}" >&2; exit 2 ;;
esac
[ -d "$root/runtime" ] || { echo "install-into-repo: $root is not a claudrunner plugin root" >&2; exit 1; }
git rev-parse --show-toplevel >/dev/null 2>&1 || { echo "install-into-repo: run this inside a git repository" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "install-into-repo: jq is required" >&2; exit 1; }

# ---------------------------------------------------------------- what the config needs
cfg='{}'
if [ -f .claudrunner/config.yml ]; then
  # shellcheck source=lib/config.sh
  source "$root/runtime/lib/config.sh"
  cfg=$(cr_config_json) || exit 1
fi
get() { jq -r "$1 // empty" <<<"$cfg"; }
runs_on=$(get '.schedule.runs_on'); runs_on=${runs_on:-manual}
adapter=$(get '.board.adapter'); adapter=${adapter:-none}
via=$(get '.board.via'); via=${via:-api}
dashboard=$(get '.dashboard.where'); dashboard=${dashboard:-local}
slow=$(jq -r 'if .loops.slow.enabled == false then "off" else "on" end' <<<"$cfg")
scopes=$(jq -r '(.loops.slow.scopes // ["correctness","security","scale","tests"]) | join(" ")' <<<"$cfg")
full=false; [ "$cfg" = '{}' ] && full=true

want=()   # every path this install owns, relative to the repository root
add() { want+=("$1"); }

add .claudrunner/bin/lib/config.sh
add .claudrunner/bin/validate-config.sh
add .claudrunner/bin/claudrunner-status.sh
add .claudrunner/bin/claudrunner-mark.sh
add .claudrunner/bin/publish-dashboard.sh
[ "$dashboard" != none ] && add .claudrunner/bin/dashboard/index.html
case "$runs_on" in github-actions|cron|systemd) add .claudrunner/bin/claudrunner-run.sh ;; esac
$full && add .claudrunner/bin/claudrunner-run.sh
if $full; then
  for b in "$root"/runtime/lib/board-*.sh; do add ".claudrunner/bin/lib/$(basename "$b")"; done
elif [ "$adapter" != none ] && [ "$via" = api ]; then
  [ -f "$root/runtime/lib/board-$adapter.sh" ] && add ".claudrunner/bin/lib/board-$adapter.sh"
fi

if $with_commands; then
  add .claude/commands/claudrunner/triage.md
  add .claude/commands/claudrunner/status.md
  # The fast loop: pick up, build, review, ship.
  for s in work-a-card vk-review ship commit-message; do add ".claude/skills/$s"; done
  add .claude/agents/inspector.md
  add .claude/agents/deep-work.md
  if [ "$slow" = on ]; then
    add .claude/commands/claudrunner/sweep.md
    add .claude/skills/card-format
    case " $scopes " in *" security "*) add .claude/skills/security-sweep ;; esac
    case " $scopes " in *" scale "*)    add .claude/skills/scale-sweep ;; esac
  fi
fi

# ---------------------------------------------------------------- install
# Where a repository path comes from in the plugin.
source_of() {
  case "$1" in
    .claudrunner/bin/dashboard/index.html) echo "$root/dashboard/index.html" ;;
    .claudrunner/bin/*)                    echo "$root/runtime/${1#.claudrunner/bin/}" ;;
    .claude/commands/claudrunner/*)        echo "$root/commands/${1#.claude/commands/claudrunner/}" ;;
    .claude/skills/*)                      echo "$root/skills/${1#.claude/skills/}" ;;
    .claude/agents/*)                      echo "$root/agents/${1#.claude/agents/}" ;;
  esac
}

installed=()
for path in "${want[@]}"; do
  src=$(source_of "$path")
  case "$path" in
    .claude/skills/*)
      if [ -e "$path" ] && ! grep -q 'installed by claudrunner' "$path/SKILL.md" 2>/dev/null; then
        echo "skipped skill '${path#.claude/skills/}': this repository already has its own skill by that name" >&2
        continue
      fi
      rm -rf "$path" && mkdir -p "$(dirname "$path")" && cp -r "$src" "$path"
      # Mark the copy as ours, so a later install may refresh or remove it.
      printf '\n<!-- installed by claudrunner; refreshed by install-into-repo.sh -->\n' >> "$path/SKILL.md"
      ;;
    *)
      mkdir -p "$(dirname "$path")" && cp "$src" "$path"
      case "$path" in *.sh) chmod +x "$path" ;; esac
      ;;
  esac
  installed+=("$path")
done

# ---------------------------------------------------------------- remove what is no longer needed
# The previous list, or — for an install older than the list — everything claudrunner can
# install, which is only ever claudrunner's own file names.
previous=()
if [ -f .claudrunner/installed.txt ]; then
  mapfile -t previous < .claudrunner/installed.txt
else
  for f in "$root"/runtime/*.sh "$root"/runtime/lib/*.sh; do
    previous+=(".claudrunner/bin/${f#"$root/runtime/"}")
  done
  previous+=(.claudrunner/bin/dashboard/index.html)
  for f in "$root"/commands/*.md; do previous+=(".claude/commands/claudrunner/$(basename "$f")"); done
  for d in "$root"/skills/*/; do previous+=(".claude/skills/$(basename "$d")"); done
  for f in "$root"/agents/*.md; do previous+=(".claude/agents/$(basename "$f")"); done
fi
removed=0
for path in "${previous[@]}"; do
  [ -n "$path" ] && [ -e "$path" ] || continue
  printf '%s\n' "${installed[@]}" | grep -qxF "$path" && continue
  case "$path" in
    .claude/skills/*) grep -q 'installed by claudrunner' "$path/SKILL.md" 2>/dev/null || continue ;;
    .claudrunner/bin/*|.claude/commands/claudrunner/*|.claude/agents/*) ;;
    *) continue ;;   # never outside the places this script writes
  esac
  rm -rf "$path" && removed=$((removed + 1))
done
rmdir .claude/commands/claudrunner .claudrunner/bin/dashboard 2>/dev/null || true
printf '%s\n' "${installed[@]}" > .claudrunner/installed.txt

# The project profile used to be called notes.md.
[ -f .claudrunner/notes.md ] && [ ! -f .claudrunner/profile.md ] && mv .claudrunner/notes.md .claudrunner/profile.md

# ---------------------------------------------------------------- attribution settings
# Claude Code adds its own attribution line to commits and pull requests, and a session link
# in cloud sessions. The crew's work carries neither: it is the user's, or claudrunner's
# (authorship.author). A local-only setup keeps this out of git, in settings.local.json.
settings=.claude/settings.json
$local_only && settings=.claude/settings.local.json
mkdir -p .claude
[ -s "$settings" ] || echo '{}' > "$settings"
if merged=$(jq '. * {attribution: {commit: "", pr: "", sessionUrl: false}}' "$settings"); then
  printf '%s\n' "$merged" > "$settings"
else
  echo "WARNING: $settings is not valid JSON; left unchanged" >&2
fi

echo "installed ${#installed[@]} files the configuration needs (list: .claudrunner/installed.txt); removed $removed no longer needed"

# ---------------------------------------------------------------- what git should and should not keep
touch .gitignore
if $local_only; then
  grep -qxF ".claudrunner/" .gitignore || printf '%s\n' "# claudrunner runs on this computer only" ".claudrunner/" >> .gitignore
  grep -qxF ".claude/settings.local.json" .gitignore || printf '%s\n' ".claude/settings.local.json" >> .gitignore
  echo "done: .claudrunner/ is in .gitignore — nothing to commit"
  exit 0
fi
for line in ".claudrunner/runs/" ".claudrunner/dashboard/"; do
  grep -qxF "$line" .gitignore || printf '%s\n' "$line" >> .gitignore
done
# Nothing that was just installed may be ignored: a routine only sees what is committed.
ignored=$(git check-ignore "${installed[@]}" 2>/dev/null || true)
if [ -n "$ignored" ]; then
  echo "WARNING: .gitignore hides files the crew needs — a routine would not see them:" >&2
  printf '%s\n' "$ignored" | sed 's/^/  /' >&2
  exit 1
fi
echo "done: commit .claudrunner/ and .claude/ — a routine only sees what is committed"
