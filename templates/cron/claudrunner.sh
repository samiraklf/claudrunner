#!/usr/bin/env bash
# Fast loop on a machine you already leave running.
#   */10 * * * * /path/to/claudrunner.sh triage >> /var/log/claudrunner.log 2>&1
#     0 2 * * *  /path/to/claudrunner.sh sweep  >> /var/log/claudrunner.log 2>&1
set -euo pipefail

REPO_DIR="${CLAUDRUNNER_REPO:?set CLAUDRUNNER_REPO to the repository path}"
BASE_BRANCH="${CLAUDRUNNER_BASE:-main}"
mode="${1:?usage: claudrunner.sh triage|sweep}"
stamp=$(date -u +%Y%m%dT%H%M%SZ)

# One run at a time. A second run entering the same working tree corrupts both.
exec 9>"/tmp/claudrunner-$mode.lock"
flock -n 9 || { echo "$stamp: a $mode run is already active, skipping"; exit 0; }

cd "$REPO_DIR"
git fetch --prune origin

# A run killed by a timeout leaves uncommitted work behind. That aborts the next
# checkout and silently kills every later run, so clean before starting.
git reset --hard -q
git clean -fdq
git checkout -B "claudrunner/$mode-$stamp" "origin/$BASE_BRANCH"

claude -p "/claudrunner:$mode" \
  --permission-mode acceptEdits \
  --max-turns 150 \
  --output-format json > "/tmp/claudrunner-$mode-$stamp.json"

jq -e '.is_error == false' "/tmp/claudrunner-$mode-$stamp.json" >/dev/null \
  || { echo "$stamp: $mode run failed"; jq -r '.result' "/tmp/claudrunner-$mode-$stamp.json"; exit 1; }
jq -r '"cost=\(.total_cost_usd) turns=\(.num_turns)"' "/tmp/claudrunner-$mode-$stamp.json"
