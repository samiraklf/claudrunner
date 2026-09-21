#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# Write the dashboard's status.json from this repository's run records and its board.
#
# Safe to run from a timer. It reads; it never writes to the repository or the board.
#   claudrunner-status.sh [output path]
set -uo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/config.sh
source "$here/lib/config.sh"

out="${1:-.claudrunner/dashboard/status.json}"
mkdir -p "$(dirname "$out")"
cr_load || exit 1

runs_dir=".claudrunner/runs"

# A public page shows task numbers, not task titles, unless the config says otherwise.
where=$(cr_get '.dashboard.where' 'local')
default_titles=true
[ "$where" = "github-pages" ] && default_titles=false
show_titles=$(cr_get '.dashboard.show_titles' "$default_titles")
today=$(date -u +%Y-%m-%d)

# A run is "in the field" while its directory has an input file but no result yet. Every
# item it claimed is on the page, at the step the agent last recorded for it
# (claudrunner-mark.sh step); an item that reached "done" has left the field.
active='[]'; by_run='{}'   # by_run: tasks finished today, per run
if [ -d "$runs_dir" ]; then
  for d in "$runs_dir"/triage-*; do
    [ -d "$d" ] || continue
    [ -f "$d/input.json" ] || continue
    [ -f "$d/result.json" ] && continue
    stamp=$(basename "$d" | sed 's/^triage-//')
    started=$(date -u -d "${stamp:0:4}-${stamp:4:2}-${stamp:6:2}T${stamp:9:2}:${stamp:11:2}:${stamp:13:2}Z" \
      +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "$stamp")
    steps='{}'; [ -f "$d/steps.json" ] && steps=$(jq -c . "$d/steps.json" 2>/dev/null || echo '{}')
    n=$(jq --argjson st "$steps" '[.[] | select($st[.id // ""] == "done")] | length' "$d/input.json" 2>/dev/null || echo 0)
    by_run=$(jq -c --arg k "$(basename "$d")" --argjson n "$n" '.[$k] = $n' <<<"$by_run")
    active=$(jq -c --argjson a "$active" --arg s "$started" --argjson show "$show_titles" \
      --argjson st "$steps" --arg board "$(cr_get '.board.adapter' 'none')" \
      '{selecting: 0.1, implementing: 0.35, testing: 0.6, review: 0.8, shipping: 0.95} as $pct
       | $a + [ .[] | (.id // "?") as $id | ($st[$id] // "selecting") as $phase
                | select($phase != "done")
                | {id: ("#" + $id),
                   title: (if $show then (.title // "working") else ("Task #" + $id) end),
                   phase: $phase, progress: ($pct[$phase] // 0.4), started_at: $s, board: $board} ]' \
      "$d/input.json" 2>/dev/null || echo "$active")
  done
fi

# Retired today: what the runs that finished today say they shipped.
findings=0; fixed=0
if [ -d "$runs_dir" ]; then
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    n=$(jq '(.done // []) | length' "$f" 2>/dev/null || echo 0)
    by_run=$(jq -c --arg k "$(basename "$(dirname "$f")")" --argjson n "$n" '.[$k] = $n' <<<"$by_run")
  done < <(find "$runs_dir" -name summary.json -newermt "$today" 2>/dev/null)
fi

# A run in a fresh sandbox (a cloud routine) only has its own records. The publisher hands
# over the page it is replacing, so today's count carries on from the runs before this one.
# Counted per run, so publishing the same run again never counts its tasks twice.
prev="${CLAUDRUNNER_PREV_STATUS:-}"
if [ -n "$prev" ] && [ -f "$prev" ] && [ "$(jq -r '.day // ""' "$prev" 2>/dev/null)" = "$today" ]; then
  earlier=$(jq -c '.retired_by_run // {earlier: (.retired_today // 0)}' "$prev" 2>/dev/null || echo '{}')
  by_run=$(jq -c --argjson e "$earlier" '$e + .' <<<"$by_run")
fi
retired=$(jq '[.[]] | add // 0' <<<"$by_run")

# How many ready items a run left behind, when the run that took its share said so.
queue=0
[ -f "$runs_dir/queue" ] && queue=$(tr -dc '0-9' < "$runs_dir/queue")

# No timestamp in the output, only the day: the page does not use a time, and without one
# an unchanged state produces an identical file — so a publisher commits only real changes.
jq -n --argjson runs "$active" --argjson retired "$retired" --argjson by_run "$by_run" \
      --argjson findings "$findings" --argjson fixed "$fixed" --argjson queue "${queue:-0}" \
      --arg incept "$(git log --reverse --format=%cs 2>/dev/null | head -1)" --arg day "$today" \
  '{incept: $incept, day: $day, queue: $queue,
    retired_today: $retired, retired_by_run: $by_run, review: {findings: $findings, fixed: $fixed},
    runs: $runs, ticker: ["THE MACHINE WAITS."]}' > "$out"

echo "wrote $out"
