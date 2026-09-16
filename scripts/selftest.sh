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
for f in scripts/*.sh scripts/lib/*.sh templates/cron/*.sh; do
  check "$f" bash -n "$f"
done

echo "every pack and adapter is documented"
for d in packs/*/; do
  check "$d" test -f "$d/pack.md"
done
for d in adapters/*/; do
  check "$d" test -f "$d/ADAPTER.md"
done
for d in hosts/*/; do
  check "$d" test -f "$d/HOST.md"
done

echo "board bindings define all four verbs"
for f in scripts/lib/board-*.sh; do
  name=$(basename "$f" .sh); name=${name#board-}
  missing=""
  for verb in board_fetch board_claim board_comment board_move; do
    grep -q "^$verb()" "$f" || missing="$missing $verb"
  done
  if [ -n "$missing" ]; then bad "$f is missing:$missing"; else ok "$f"; fi
  check "adapters/$name documented" test -f "adapters/$name/ADAPTER.md"
done

echo "workflow templates are valid yaml"
if python3 -c 'import yaml' 2>/dev/null; then
  for f in templates/github-actions/*.yml; do
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
