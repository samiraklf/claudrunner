#!/usr/bin/env bash
# The package's own test suite. Everything here is a defect that would otherwise reach a
# user as a broken install or a silently skipped run.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

fail=0
ok()   { echo "  ok   $1"; }
bad()  { echo "  FAIL $1"; fail=1; }

echo "manifests"
for f in .claude-plugin/marketplace.json plugins/*/.claude-plugin/plugin.json; do
  jq -e . "$f" >/dev/null 2>&1 && ok "$f" || bad "$f is not valid JSON"
done

echo "marketplace points at real plugins"
while read -r src; do
  [ -f "$src/.claude-plugin/plugin.json" ] && ok "$src" || bad "$src has no plugin.json"
done < <(jq -r '.plugins[].source' .claude-plugin/marketplace.json)

echo "front matter"
for f in plugins/*/skills/*/SKILL.md plugins/*/agents/*.md plugins/*/commands/*.md; do
  head -1 "$f" | grep -q '^---$' && ok "$f" || bad "$f has no front matter"
done

echo "skill names match their directory"
for f in plugins/*/skills/*/SKILL.md; do
  dir=$(basename "$(dirname "$f")")
  name=$(awk -F': *' '/^name:/{print $2; exit}' "$f")
  [ "$dir" = "$name" ] && ok "$dir" || bad "$f declares name '$name' in directory '$dir'"
done

echo "shell syntax"
for f in scripts/*.sh scripts/lib/*.sh templates/cron/*.sh; do
  bash -n "$f" 2>/dev/null && ok "$f" || bad "$f has a syntax error"
done

echo "every pack and adapter is documented"
for d in packs/*/; do
  [ "$d" = "packs/README.md/" ] && continue
  [ -f "$d/pack.md" ] && ok "$d" || bad "$d has no pack.md"
done
for d in adapters/*/; do
  [ -f "$d/ADAPTER.md" ] && ok "$d" || bad "$d has no ADAPTER.md"
done

echo "workflow templates are valid yaml"
if python3 -c 'import yaml' 2>/dev/null; then
  for f in templates/github-actions/*.yml; do
    python3 -c 'import sys,yaml; yaml.safe_load(open(sys.argv[1]))' "$f" 2>/dev/null \
      && ok "$f" || bad "$f is not valid YAML"
  done
else
  echo "  skip  no yaml module available"
fi

echo "no private details"
./scripts/check-leaks.sh >/dev/null 2>&1 && ok "leak check" || bad "leak check found something — run scripts/check-leaks.sh"

echo
[ "$fail" -eq 0 ] && echo "selftest passed" || echo "selftest FAILED"
exit "$fail"
