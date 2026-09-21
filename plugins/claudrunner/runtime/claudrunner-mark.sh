#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# Run records for a cycle the agent drives itself — a Claude Code routine, or a person
# running /claudrunner:triage by hand. The orchestrator writes these on its own; here the
# agent calls it, so the status page shows the work while it happens.
#
#   claudrunner-mark.sh start <triage|sweep> <items.json> [queue]   prints the run directory
#   claudrunner-mark.sh step <run dir> <item id> <step>
#   claudrunner-mark.sh finish <run dir> [summary.json]
#
# items.json is the claimed items, as the adapters return them:
#   [{"id": "...", "title": "...", "url": "..."}]
# queue is how many ready items are left behind after this run took its share.
# step is where one item is now: selecting | implementing | testing | review | shipping | done.
# Each one is published at once, so the status page follows every task while it happens.
set -uo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# A failed publish never stops the work, but it always says why: the reason is the only way
# to fix a status page that stays empty.
publish() {
  local log=".claudrunner/runs/publish.log"
  mkdir -p .claudrunner/runs
  "$here/publish-dashboard.sh" >"$log" 2>&1 && return 0
  echo "dashboard: publish failed (work continues): $(grep -v '^[[:space:]]*$' "$log" | tail -3 | tr '\n' ' ')" >&2
}

case "${1:-}" in
  start)
    mode="${2:?usage: claudrunner-mark.sh start <triage|sweep> <items.json> [queue]}"
    items="${3:?items.json is required}"
    case "$mode" in triage|sweep) ;; *) echo "unknown mode: $mode" >&2; exit 2 ;; esac
    jq -e 'type == "array"' "$items" >/dev/null 2>&1 || { echo "$items is not a JSON array" >&2; exit 2; }
    stamp=$(date -u +%Y%m%dT%H%M%SZ)
    run_dir=".claudrunner/runs/$mode-$stamp"
    mkdir -p "$run_dir"
    cp "$items" "$run_dir/input.json"
    [ -n "${4:-}" ] && printf '%s\n' "$4" > .claudrunner/runs/queue
    publish
    echo "$run_dir"
    ;;
  step)
    run_dir="${2:?usage: claudrunner-mark.sh step <run dir> <item id> <step>}"
    id="${3:?the item id is required}"; step="${4:?the step is required}"
    [ -f "$run_dir/input.json" ] || { echo "$run_dir is not a run started with claudrunner-mark.sh" >&2; exit 2; }
    case "$step" in selecting|implementing|testing|review|shipping|done) ;;
      *) echo "unknown step: $step (selecting|implementing|testing|review|shipping|done)" >&2; exit 2 ;; esac
    steps="$run_dir/steps.json"; [ -f "$steps" ] || echo '{}' > "$steps"
    jq --arg id "$id" --arg s "$step" '.[$id] = $s' "$steps" > "$steps.new" && mv "$steps.new" "$steps"
    publish
    echo "$id: $step"
    ;;
  finish)
    run_dir="${2:?usage: claudrunner-mark.sh finish <run dir> [summary.json]}"
    [ -f "$run_dir/input.json" ] || { echo "$run_dir is not a run started with claudrunner-mark.sh" >&2; exit 2; }
    if [ -n "${3:-}" ]; then
      jq -e . "$3" >/dev/null 2>&1 || { echo "$3 is not valid JSON" >&2; exit 2; }
      [ "$3" -ef "$run_dir/summary.json" ] || cp "$3" "$run_dir/summary.json"
    fi
    # The page treats a run with a result as finished.
    jq -n '{is_error: false, driven_by: "session"}' > "$run_dir/result.json"
    publish
    echo "finished $run_dir"
    ;;
  *) echo "usage: claudrunner-mark.sh start <triage|sweep> <items.json> [queue] | step <run dir> <item id> <step> | finish <run dir> [summary.json]" >&2; exit 2 ;;
esac
