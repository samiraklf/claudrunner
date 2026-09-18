#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# Run records for a cycle the agent drives itself — a Claude Code routine, or a person
# running /claudrunner:triage by hand. The orchestrator writes these on its own; here the
# agent calls it, so the status page shows the work while it happens.
#
#   claudrunner-mark.sh start <triage|sweep> <items.json> [queue]   prints the run directory
#   claudrunner-mark.sh finish <run dir> [summary.json]
#
# items.json is the claimed items, as the adapters return them:
#   [{"id": "...", "title": "...", "url": "..."}]
# queue is how many ready items are left behind after this run took its share.
set -uo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

publish() { "$here/publish-dashboard.sh" >/dev/null 2>&1 || echo "dashboard: publish failed (work continues)" >&2; }

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
  *) echo "usage: claudrunner-mark.sh start <triage|sweep> <items.json> [queue] | finish <run dir> [summary.json]" >&2; exit 2 ;;
esac
