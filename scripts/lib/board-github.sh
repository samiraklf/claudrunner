#!/usr/bin/env bash
# Board adapter: GitHub Issues. Four verbs, nothing else.
#
# Queue names are roles, never literal labels. The mapping lives in the config, because
# people rename labels and a crew that breaks when they do gets switched off.
set -uo pipefail

board_label() { cr_get ".board.queues.$1" ""; }

# fetch — ready items, oldest first, capped. Emits the shape every adapter must emit.
board_fetch() {
  local limit="${1:-5}" ready
  ready=$(board_label ready)
  gh issue list --label "$ready" --state open --limit "$limit" \
      --json number,title,body,url,labels \
    | jq '[ .[] | {
        id: (.number|tostring),
        title,
        body: (.body // ""),
        url,
        labels: [.labels[].name],
        priority: ([.labels[].name] | map(select(. == "Critical" or . == "High" or . == "Medium" or . == "Low")) | first // "Medium")
      } ]'
}

# claim — take the item, then verify. GitHub labels are not atomic: two runs can both
# add the label. The verify step is what stops one item becoming two pull requests.
board_claim() {
  local id="$1" ready claimed holders
  ready=$(board_label ready); claimed=$(board_label claimed)
  gh issue edit "$id" --add-label "$claimed" --remove-label "$ready" >/dev/null || return 1
  sleep 2
  holders=$(gh issue view "$id" --json labels | jq -r "[.labels[].name | select(. == \"$claimed\")] | length")
  [ "$holders" = "1" ] || { echo "claim contested on #$id, releasing" >&2; board_move "$id" ready; return 1; }
  return 0
}

board_comment() {
  local id="$1" text="$2"
  gh issue comment "$id" --body "$text" >/dev/null
}

# move — role in, label out. Every other queue label is removed, so an item is never
# in two queues at once.
board_move() {
  local id="$1" role="$2" dest role_i other
  dest=$(board_label "$role")
  [ -n "$dest" ] || { echo "no label configured for queue '$role'" >&2; return 1; }
  other=""
  for role_i in ready claimed review parked filed; do
    [ "$role_i" = "$role" ] && continue
    local l; l=$(board_label "$role_i")
    [ -n "$l" ] && other="$other --remove-label $l"
  done
  # shellcheck disable=SC2086
  gh issue edit "$id" --add-label "$dest" $other >/dev/null 2>&1 || \
    gh issue edit "$id" --add-label "$dest" >/dev/null
}
