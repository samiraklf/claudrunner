#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# Write dashboard/status.json from this repository's run records and its board.
#
# Safe to run from a timer. It reads; it never writes to the repository or the board.
#   claudrunner-status.sh [output path]
set -uo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/config.sh
source "$here/lib/config.sh"

out="${1:-dashboard/status.json}"
cr_load || exit 1

runs_dir=".claudrunner/runs"
today=$(date -u +%Y-%m-%d)

# A run is "in the field" while its directory has an input file but no result yet.
active='[]'
if [ -d "$runs_dir" ]; then
  for d in "$runs_dir"/triage-*; do
    [ -d "$d" ] || continue
    [ -f "$d/input.json" ] || continue
    [ -f "$d/result.json" ] && continue
    stamp=$(basename "$d" | sed 's/^triage-//')
    started=$(date -u -d "${stamp:0:4}-${stamp:4:2}-${stamp:6:2}T${stamp:9:2}:${stamp:11:2}:${stamp:13:2}Z" \
      +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "$stamp")
    active=$(jq -c --argjson a "$active" --arg s "$started" \
      '$a + [ (.[0] // {}) | {id: ("#" + (.id // "?")), title: (.title // "working"), phase: "implementing", progress: 0.4, started_at: $s, board: "'"$(cr_get '.board.adapter' 'none')"'"} ]' \
      "$d/input.json" 2>/dev/null || echo "$active")
  done
fi

# Retired today: summaries written by runs that finished today.
retired=0; findings=0; fixed=0
if [ -d "$runs_dir" ]; then
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    retired=$(( retired + $(jq '(.done // []) | length' "$f" 2>/dev/null || echo 0) ))
  done < <(find "$runs_dir" -name summary.json -newermt "$today" 2>/dev/null)
fi

jq -n --argjson runs "$active" --argjson retired "$retired" \
      --argjson findings "$findings" --argjson fixed "$fixed" \
      --arg incept "$(git log --reverse --format=%cs 2>/dev/null | head -1)" \
  '{generated_at: (now | todateiso8601), incept: $incept, queue: 0,
    retired_today: $retired, review: {findings: $findings, fixed: $fixed},
    runs: $runs, ticker: ["THE MACHINE WAITS."]}' > "$out"

echo "wrote $out"
