#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# The orchestrator. It holds every piece of power the agent does not get:
# fetching the work, claiming it, preparing the branch, and moving items afterwards.
#
# The agent receives a working tree, a task, and a tool allowlist. It never sees a
# credential, never chooses what to work on, and cannot move an item that was not handed
# to it — the move loop rejects any id absent from this run's input file.
#
#   claudrunner-run.sh triage   take ready work, implement, open a pull request
#   claudrunner-run.sh sweep    look for findings and file them
set -uo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/config.sh
source "$here/lib/config.sh"

mode="${1:?usage: claudrunner-run.sh triage|sweep}"
case "$mode" in triage|sweep) ;; *) echo "unknown mode: $mode" >&2; exit 2 ;; esac

cr_load || exit 1

base_branch=$(cr_get '.project.base_branch' 'main')
autonomy=$(cr_get '.policy.autonomy' 'pr-only')
max_items=$(cr_get '.loops.fast.max_items' '3')
max_turns=$(cr_get '.limits.max_turns' '150')
timeout_min=$(cr_get '.limits.run_timeout_minutes' '55')
adapter=$(cr_get '.board.adapter' 'github-issues')

stamp=$(date -u +%Y%m%dT%H%M%SZ)
run_dir=".claudrunner/runs/$mode-$stamp"
mkdir -p "$run_dir"

# One run at a time, per mode. A second run entering a live working tree corrupts both.
exec 9>"${TMPDIR:-/tmp}/claudrunner-$mode.lock"
flock -n 9 || { echo "a $mode run is already active — skipping"; exit 0; }

binding="$here/lib/board-$adapter.sh"
if [ "$adapter" = "none" ]; then
  [ "$mode" = "sweep" ] || { echo "triage needs a board adapter" >&2; exit 2; }
elif [ -f "$binding" ]; then
  # shellcheck source=/dev/null
  source "$binding"
  for verb in board_fetch board_claim board_comment board_move; do
    declare -F "$verb" >/dev/null || { echo "$binding does not define $verb" >&2; exit 2; }
  done
else
  echo "adapter '$adapter' has no shell binding — see adapters/$adapter/ADAPTER.md and run it" >&2
  echo "from the agent with /claudrunner:$mode instead." >&2
  exit 2
fi

# ---------------------------------------------------------------- fetch and claim
if [ "$mode" = "triage" ]; then
  board_fetch "$max_items" > "$run_dir/input.json"
  count=$(jq 'length' "$run_dir/input.json")
  if [ "$count" -eq 0 ]; then echo "nothing ready — exiting"; exit 0; fi

  claimed="[]"
  while read -r id; do
    if board_claim "$id"; then
      claimed=$(jq -c --arg id "$id" '. + [$id]' <<<"$claimed")
    fi
  done < <(jq -r '.[].id' "$run_dir/input.json")

  jq --argjson keep "$claimed" '[ .[] | select(.id as $i | $keep | index($i)) ]' \
    "$run_dir/input.json" > "$run_dir/input.tmp" && mv "$run_dir/input.tmp" "$run_dir/input.json"
  count=$(jq 'length' "$run_dir/input.json")
  [ "$count" -eq 0 ] && { echo "every candidate was claimed by another run — exiting"; exit 0; }
  echo "claimed $count item(s)"
fi

# ---------------------------------------------------------------- prepare the tree
git fetch --prune origin

# The base branch is explicit. Many projects integrate on a branch that is not the
# repository default, and resolving HEAD would silently target the wrong one.
git rev-parse -q --verify "origin/$base_branch" >/dev/null || {
  echo "FATAL: origin/$base_branch does not exist after fetch. Fix project.base_branch." >&2
  exit 1
}

# A run killed at its timeout leaves uncommitted work behind. That aborts the next
# checkout and silently kills every later run, so clean before starting, always.
git reset --hard -q
git clean -fdq --exclude=.claudrunner/runs
git checkout -q -B "claudrunner/$mode-$stamp" "origin/$base_branch"

# ---------------------------------------------------------------- run the agent
allowed='Read,Edit,Write,Skill,Agent,Glob,Grep,TodoWrite,BashOutput'
allowed="$allowed,Bash(git diff:*),Bash(git status:*),Bash(git log:*),Bash(git add:*)"
allowed="$allowed,Bash(git commit:*),Bash(git revert:*),Bash(git branch -m claudrunner/*)"
[ "$autonomy" != "suggest" ] && allowed="$allowed,Bash(git push:*),Bash(gh pr create:*)"

set +e
timeout "${timeout_min}m" claude -p "/claudrunner:$mode" \
  --permission-mode acceptEdits \
  --allowedTools "$allowed" \
  --max-turns "$max_turns" \
  --output-format json > "$run_dir/result.json"
agent_status=$?
set -e

if [ "$agent_status" -eq 124 ]; then
  echo "run hit the ${timeout_min}m ceiling and shipped nothing" >&2
fi
jq -e '.is_error == false' "$run_dir/result.json" >/dev/null 2>&1 || {
  echo "run failed"; jq -r '.result // "no result"' "$run_dir/result.json" 2>/dev/null
  # Items stay claimed on failure on purpose: a human sees what was in flight.
  exit 1
}
jq -r '"cost=\(.total_cost_usd) turns=\(.num_turns)"' "$run_dir/result.json"

# ---------------------------------------------------------------- move the items
[ "$mode" = "triage" ] || exit 0

# The last fenced JSON block in the agent's final message is the machine-read part.
summary=$(jq -r '.result' "$run_dir/result.json" \
  | awk '/^```json$/{buf="";f=1;next} /^```$/{f=0} f{buf=buf $0 "\n"} END{printf "%s", buf}')

if [ -z "$summary" ] || ! jq -e . >/dev/null 2>&1 <<<"$summary"; then
  echo "no valid summary block — items left claimed for a human to look at" >&2
  exit 1
fi
printf '%s' "$summary" > "$run_dir/summary.json"

in_input() { jq -e --arg id "$1" 'any(.[]; .id == $id)' "$run_dir/input.json" >/dev/null; }
pr=$(jq -r '.pr // empty' <<<"$summary")

for id in $(jq -r '.done[]?' <<<"$summary"); do
  in_input "$id" || { echo "refusing to move #$id: not in this run's input" >&2; continue; }
  board_move "$id" review && echo "#$id -> review"
  [ -n "$pr" ] && board_comment "$id" "claudrunner opened $pr"
done

# Every skipped item leaves with a disposition. An item with none is re-analyzed on
# every run, forever, and its note is posted again each time.
jq -c '.skipped[]?' <<<"$summary" | while read -r row; do
  id=$(jq -r '.id' <<<"$row")
  in_input "$id" || { echo "refusing to touch #$id: not in this run's input" >&2; continue; }
  reason=$(jq -r '.reason' <<<"$row")
  note=$(jq -r '.note // "no note given"' <<<"$row")
  case "$reason" in
    not-needed|better-approach) dest=review ;;   # a human closes it, the note is the evidence
    *)                          dest=parked ;;   # a human answers, then puts it back
  esac
  board_comment "$id" "claudrunner ($reason): $note"
  board_move "$id" "$dest" && echo "#$id -> $dest ($reason)"
done
