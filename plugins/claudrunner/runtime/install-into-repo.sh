#!/usr/bin/env bash
# Install claudrunner into the repository in the current directory, so that anything that
# opens this repository — a Claude Code routine in the cloud, CI, a teammate's laptop —
# has the crew without installing the plugin.
#
#   install-into-repo.sh <plugin root> [--with-commands]
#
# Always:          the runtime into .claudrunner/bin/ and the status page beside it.
# --with-commands: also the commands, skills and agents into .claude/, where Claude Code
#                  loads them in every session of this repository. A cloud routine cannot
#                  install plugins, so this is how the routine gets the crew.
#
# Everything installed here is meant to be committed. Only run records and the generated
# page are ignored. Existing files with other names are never touched.
set -uo pipefail

root="${1:?usage: install-into-repo.sh <plugin root> [--with-commands]}"
with_commands=false
[ "${2:-}" = "--with-commands" ] && with_commands=true
[ -d "$root/runtime" ] || { echo "install-into-repo: $root is not a claudrunner plugin root" >&2; exit 1; }
git rev-parse --show-toplevel >/dev/null 2>&1 || { echo "install-into-repo: run this inside a git repository" >&2; exit 1; }

# ---------------------------------------------------------------- the runtime
mkdir -p .claudrunner/bin/dashboard
cp -r "$root/runtime/." .claudrunner/bin/
cp "$root/dashboard/index.html" .claudrunner/bin/dashboard/index.html
chmod +x .claudrunner/bin/*.sh .claudrunner/bin/lib/*.sh
echo "installed the runtime into .claudrunner/bin/"

# ---------------------------------------------------------------- commands, skills, agents
if $with_commands; then
  mkdir -p .claude/commands/claudrunner .claude/skills .claude/agents
  # init and dashboard are for a person at a terminal with the plugin installed; the
  # routine only needs the unattended ones.
  for c in triage sweep status; do
    cp "$root/commands/$c.md" ".claude/commands/claudrunner/$c.md"
  done
  for dir in "$root"/skills/*/; do
    name=$(basename "$dir")
    if [ -e ".claude/skills/$name" ] && ! grep -q 'claudrunner' ".claude/skills/$name/SKILL.md" 2>/dev/null; then
      echo "skipped skill '$name': this repository already has its own skill by that name" >&2
      continue
    fi
    rm -rf ".claude/skills/$name" && cp -r "$dir" ".claude/skills/$name"
    # Mark the copy as ours, so a later install may refresh it.
    printf '\n<!-- installed by claudrunner; refreshed by install-into-repo.sh -->\n' >> ".claude/skills/$name/SKILL.md"
  done
  for a in "$root"/agents/*.md; do
    cp "$a" ".claude/agents/$(basename "$a")"
  done
  echo "installed commands into .claude/commands/claudrunner/, skills into .claude/skills/, agents into .claude/agents/"
fi

# ---------------------------------------------------------------- what git should and should not keep
touch .gitignore
for line in ".claudrunner/runs/" ".claudrunner/dashboard/"; do
  grep -qxF "$line" .gitignore || printf '%s\n' "$line" >> .gitignore
done
# Nothing that was just installed may be ignored: a routine only sees what is committed.
ignored=$(git check-ignore .claudrunner/bin/claudrunner-run.sh .claude/commands/claudrunner/triage.md 2>/dev/null || true)
if [ -n "$ignored" ]; then
  echo "WARNING: .gitignore hides files the crew needs — a routine would not see them:" >&2
  printf '%s\n' "$ignored" | sed 's/^/  /' >&2
  exit 1
fi
echo "done: commit .claudrunner/ and .claude/ — a routine only sees what is committed"
