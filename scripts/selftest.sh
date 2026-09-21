#!/usr/bin/env bash
# The package's own test suite. Everything here is a defect that would otherwise reach a
# user as a broken install or a silently skipped run.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

fail=0
ok()  { echo "  ok   $1"; }
bad() { echo "  FAIL $1"; fail=1; }
# check <label> <command...> — one result line, and never a false pass.
check() { local label="$1"; shift; if "$@" >/dev/null 2>&1; then ok "$label"; else bad "$label"; fi; }

echo "manifests"
for f in .claude-plugin/marketplace.json plugins/*/.claude-plugin/plugin.json; do
  check "$f" jq -e . "$f"
done

echo "marketplace points at real plugins"
while read -r src; do
  check "$src" test -f "$src/.claude-plugin/plugin.json"
done < <(jq -r '.plugins[].source' .claude-plugin/marketplace.json)

echo "front matter"
for f in plugins/*/skills/*/SKILL.md plugins/*/agents/*.md plugins/*/commands/*.md; do
  if head -1 "$f" | grep -q '^---$'; then ok "$f"; else bad "$f has no front matter"; fi
done

echo "skill names match their directory"
for f in plugins/*/skills/*/SKILL.md; do
  dir=$(basename "$(dirname "$f")")
  name=$(awk -F': *' '/^name:/{print $2; exit}' "$f")
  if [ "$dir" = "$name" ]; then ok "$dir"; else bad "$f declares name '$name' in directory '$dir'"; fi
done

echo "shell syntax"
for f in scripts/*.sh plugins/claudrunner/runtime/*.sh plugins/claudrunner/runtime/lib/*.sh plugins/claudrunner/templates/cron/*.sh; do
  check "$f" bash -n "$f"
done

echo "every pack and adapter is documented"
for d in plugins/claudrunner/packs/*/; do
  check "$d" test -f "$d/pack.md"
done
for d in plugins/claudrunner/adapters/*/; do
  check "$d" test -f "$d/ADAPTER.md"
done
for d in plugins/claudrunner/hosts/*/; do
  check "$d" test -f "$d/HOST.md"
done

echo "board bindings define all four verbs"
for f in plugins/claudrunner/runtime/lib/board-*.sh; do
  name=$(basename "$f" .sh); name=${name#board-}
  missing=""
  for verb in board_fetch board_claim board_comment board_move; do
    grep -q "^$verb()" "$f" || missing="$missing $verb"
  done
  if [ -n "$missing" ]; then bad "$f is missing:$missing"; else ok "$f"; fi
  check "adapters/$name documented" test -f "plugins/claudrunner/adapters/$name/ADAPTER.md"
done

echo "jira fetch uses the search endpoint Atlassian still serves"
# Atlassian retired POST /rest/api/3/search; it now answers 410 Gone. A stand-in curl
# plays Jira: the old path fails the way the real one does, the new one returns an issue.
jira_fetch() (
  # shellcheck disable=SC2329  # called by the adapter sourced below, not from here
  curl() {
    local url=""; for a in "$@"; do case "$a" in http*) url="$a" ;; esac; done
    case "$url" in
      */rest/api/3/search/jql) echo '{"issues":[{"key":"API-7","fields":{"summary":"Fix the export","description":null,"labels":["bug"],"priority":{"name":"High"}}}],"isLast":true}' ;;
      *) return 22 ;;
    esac
  }
  export JIRA_BASE_URL=https://example.atlassian.net JIRA_EMAIL=a@b.c JIRA_API_TOKEN=t
  export CR_CONFIG='{"board":{"settings":{"project":"API"},"queues":{"ready":"Ready"}}}'
  # shellcheck source=/dev/null
  . plugins/claudrunner/runtime/lib/config.sh
  # shellcheck source=/dev/null
  . plugins/claudrunner/runtime/lib/board-jira.sh
  board_fetch 5
)
jira_out=$(jira_fetch 2>/dev/null)
check "jira fetch returns the ready issue" jq -e \
  '.[0].id == "API-7" and .[0].url == "https://example.atlassian.net/browse/API-7"' <<<"$jira_out"

echo "CI templates hand every board credential to the run"
# A board adapter that reads a credential the workflow never passes fails on its first
# scheduled run. Every variable the adapters read must reach both CI templates.
for var in $(grep -ohE '\$\{?[A-Z][A-Z0-9_]*(_TOKEN|_KEY|_PAT|_URL|_EMAIL|_HOST)\b' \
               plugins/claudrunner/runtime/lib/board-*.sh | tr -d '$\{' | sort -u); do
  for t in plugins/claudrunner/templates/github-actions/claudrunner-{triage,sweep}.yml; do
    check "$(basename "$t") passes $var" grep -q "$var: \${{ secrets.$var }}" "$t"
  done
done

echo "a routine-style run: install into a repo, record a run, publish it to the status branch"
# The whole path a Claude Code routine takes, in a throwaway repository with a local remote.
routine_test() (
  set -e
  plugin="$(pwd)/plugins/claudrunner"
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  git init -q --bare "$tmp/remote.git"
  git init -q -b main "$tmp/repo" && cd "$tmp/repo"
  git config user.name t && git config user.email t@t
  git remote add origin "$tmp/remote.git"
  git commit -q --allow-empty -m init && git push -q origin main
  mkdir -p .claudrunner
  cat > .claudrunner/config.yml <<'YML'
version: 1
project: {name: t, base_branch: main, host: github}
stack: {commands: {test: "true"}}
schedule: {runs_on: routine}
policy: {autonomy: pr-only}
board: {adapter: none}
dashboard: {where: branch}
YML
  "$plugin/runtime/install-into-repo.sh" "$plugin" --with-commands >/dev/null
  test -f .claude/commands/claudrunner/triage.md
  test -f .claude/skills/work-a-card/SKILL.md
  test -f .claude/agents/inspector.md
  test -x .claudrunner/bin/claudrunner-mark.sh
  jq -e '.attribution.sessionUrl == false' .claude/settings.json >/dev/null
  # a routine only sees what is committed
  [ -z "$(git check-ignore .claude/skills/ship/SKILL.md .claudrunner/bin/lib/config.sh || true)" ]
  echo '[{"id":"c1","title":"Fix the export","url":"https://example.test/c1"},{"id":"c2","title":"Add a filter","url":"https://example.test/c2"}]' > "$tmp/items.json"
  page() { git fetch -q origin claudrunner-status && git show origin/claudrunner-status:status.json; }
  mark=.claudrunner/bin/claudrunner-mark.sh
  run=$($mark start triage "$tmp/items.json" 4 | tail -1)
  page | jq -e '(.runs | length) == 2 and .runs[0].title == "Fix the export" and .runs[0].phase == "selecting" and .queue == 4' >/dev/null
  # every step of every task reaches the page while the run is still going
  $mark step "$run" c1 testing >/dev/null
  page | jq -e '.runs[0].phase == "testing" and .runs[0].progress > .runs[1].progress' >/dev/null
  $mark step "$run" c1 "done" >/dev/null
  page | jq -e '(.runs | length) == 1 and .runs[0].id == "#c2" and .retired_today == 1' >/dev/null
  # publishing the same run again never counts its finished task twice
  $mark step "$run" c2 review >/dev/null
  page | jq -e '.retired_today == 1 and .runs[0].phase == "review"' >/dev/null
  echo '{"done":["c1","c2"],"skipped":[]}' > "$run/summary.json"
  $mark finish "$run" "$run/summary.json" >/dev/null
  page | jq -e '(.runs | length) == 0 and .retired_today == 2' >/dev/null
)
# Not inside `if`: bash ignores set -e there, and every check would pass.
routine_test >/dev/null 2>&1; rc=$?
if [ "$rc" -eq 0 ]; then ok "install, record, publish, finish"; else bad "install, record, publish, finish"; fi

echo "install copies only what the configuration uses, and removes what it no longer needs"
selective_test() (
  set -e
  plugin="$(pwd)/plugins/claudrunner"
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  git init -q "$tmp/repo" && cd "$tmp/repo"
  mkdir -p .claudrunner .claude/skills/my-own
  echo "# mine" > .claude/skills/my-own/SKILL.md
  echo "- a fact" > .claudrunner/notes.md
  cat > .claudrunner/config.yml <<'YML'
schedule: {runs_on: routine}
board: {adapter: trello, via: api}
loops: {slow: {enabled: true, scopes: [security, correctness]}}
YML
  "$plugin/runtime/install-into-repo.sh" "$plugin" --with-commands >/dev/null
  test -f .claudrunner/bin/lib/board-trello.sh
  test ! -e .claudrunner/bin/lib/board-jira.sh          # another board's binding
  test ! -e .claudrunner/bin/claudrunner-run.sh         # a routine has no orchestrator
  test -d .claude/skills/security-sweep
  test ! -e .claude/skills/scale-sweep                  # a scope it does not run
  test -f .claude/commands/claudrunner/sweep.md
  test -f .claudrunner/profile.md && test ! -e .claudrunner/notes.md
  # narrower config: the connector needs no binding, no slow loop needs no sweep
  cat > .claudrunner/config.yml <<'YML'
schedule: {runs_on: routine}
board: {adapter: trello, via: connector}
loops: {slow: {enabled: false}}
YML
  "$plugin/runtime/install-into-repo.sh" "$plugin" --with-commands >/dev/null
  test ! -e .claudrunner/bin/lib/board-trello.sh
  test ! -e .claude/skills/security-sweep
  test ! -e .claude/commands/claudrunner/sweep.md
  test -f .claude/skills/my-own/SKILL.md                # never someone else's file
  test -f .claude/skills/ship/SKILL.md
)
# Not inside `if`: bash ignores set -e there, and every check would pass.
selective_test >/dev/null 2>&1; rc=$?
if [ "$rc" -eq 0 ]; then ok "selective install and cleanup"; else bad "selective install and cleanup"; fi

echo "a local-only install keeps every claudrunner file out of git"
local_test() (
  set -e
  plugin="$(pwd)/plugins/claudrunner"
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  git init -q "$tmp/repo" && cd "$tmp/repo"
  mkdir -p .claudrunner
  printf 'schedule: {runs_on: manual, commit_files: false}\nboard: {adapter: none}\n' > .claudrunner/config.yml
  "$plugin/runtime/install-into-repo.sh" "$plugin" --local >/dev/null
  test -x .claudrunner/bin/claudrunner-mark.sh          # a manual run still records its work
  test ! -e .claude                                    # the plugin supplies the rest
  # the only change git sees is the .gitignore line
  [ "$(git status --porcelain --untracked-files=all)" = "?? .gitignore" ]
)
local_test >/dev/null 2>&1; rc=$?
if [ "$rc" -eq 0 ]; then ok "local install, nothing to commit"; else bad "local install, nothing to commit"; fi

echo "config: a routine cannot run from files kept out of git"
# shellcheck disable=SC2329  # invoked through check below
routine_local() (
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  printf 'version: 1\nproject: {name: t, base_branch: main, host: github}\nstack: {commands: {test: "true"}}\npolicy: {autonomy: pr-only}\nboard: {adapter: none}\nschedule: {runs_on: routine, commit_files: false}\n' > "$tmp/c.yml"
  out=$(CR_CONFIG_FILE="$tmp/c.yml" plugins/claudrunner/runtime/validate-config.sh 2>&1)   # exits 1 on purpose
  grep -q "only sees committed files" <<<"$out"
)
check "routine with commit_files false is rejected" routine_local

echo "init learns the new cloud environment's id, then puts the user's default back"
cloud_env_test() (
  set -e
  h=plugins/claudrunner/runtime/cloud-env.sh
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  export CLAUDE_CONFIG_DIR="$tmp"
  echo '{"model":"x","remote":{"defaultEnvironmentId":"env_mine"}}' > "$tmp/settings.json"
  [ "$($h default)" = env_mine ]
  jq '.remote.defaultEnvironmentId = "env_new"' "$tmp/settings.json" > "$tmp/s" && mv "$tmp/s" "$tmp/settings.json"   # what /remote-env does
  [ "$($h default)" = env_new ]
  $h restore env_mine >/dev/null
  jq -e '.remote.defaultEnvironmentId == "env_mine" and .model == "x"' "$tmp/settings.json" >/dev/null
  $h restore "" >/dev/null                              # a user who had no default gets none back
  jq -e 'has("remote") | not' "$tmp/settings.json" >/dev/null
)
cloud_env_test >/dev/null 2>&1; rc=$?
if [ "$rc" -eq 0 ]; then ok "cloud environment id pickup and restore"; else bad "cloud environment id pickup and restore"; fi

echo "workflow templates are valid yaml"
if python3 -c 'import yaml' 2>/dev/null; then
  for f in plugins/claudrunner/templates/github-actions/*.yml; do
    check "$f" python3 -c 'import sys,yaml; yaml.safe_load(open(sys.argv[1]))' "$f"
  done
else
  echo "  skip  no yaml module available"
fi

echo "no private details"
check "leak check" ./scripts/check-leaks.sh

echo
if [ "$fail" -eq 0 ]; then echo "selftest passed"; else echo "selftest FAILED"; fi
exit "$fail"
