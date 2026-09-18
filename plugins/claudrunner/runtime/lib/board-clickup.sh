#!/usr/bin/env bash
# Board adapter: ClickUp. Needs CLICKUP_TOKEN and board.settings.list_id.
#
# Status names are lowercase in the API and title-case in the interface. Everything here
# lowercases before comparing, or the fetch silently returns nothing.
set -uo pipefail

_cu() {
  local method="$1" path="$2" data="${3-}"
  if [ -n "$data" ]; then
    curl -sf -X "$method" "https://api.clickup.com/api/v2$path" \
      -H "Authorization: ${CLICKUP_TOKEN:?CLICKUP_TOKEN is not set}" \
      -H 'Content-Type: application/json' --data "$data"
  else
    curl -sf -X "$method" "https://api.clickup.com/api/v2$path" \
      -H "Authorization: ${CLICKUP_TOKEN:?CLICKUP_TOKEN is not set}"
  fi
}
_cu_status() { cr_get ".board.queues.$1" "" | tr '[:upper:]' '[:lower:]'; }

board_fetch() {
  local limit="${1:-5}" list
  list=$(cr_get '.board.settings.list_id' '')
  [ -n "$list" ] || { echo "board.settings.list_id is not set" >&2; return 1; }
  _cu GET "/list/$list/task?statuses%5B%5D=$(_cu_status ready)&order_by=created&reverse=false" \
    | jq --argjson n "$limit" '[ .tasks[] | select((.assignees | length) == 0) | {
        id,
        title: .name,
        body: (.description // ""),
        url,
        labels: [ (.tags // [])[].name ],
        priority: (if .priority.priority == "urgent" then "Critical"
                   elif .priority.priority == "high" then "High"
                   elif .priority.priority == "low" then "Low"
                   else "Medium" end)
      } ] | .[0:$n]'
}

# One PUT sets assignee and status together, so the claim is atomic.
board_claim() {
  local id="$1" me body
  me=$(_cu GET /user | jq -r '.user.id')
  body=$(jq -nc --argjson u "$me" --arg s "$(_cu_status claimed)" '{assignees:{add:[$u]},status:$s}')
  _cu PUT "/task/$id" "$body" >/dev/null || return 1
  [ "$(_cu GET "/task/$id" | jq -r --arg u "$me" '[(.assignees // [])[] | select((.id|tostring) == $u)] | length')" = "1" ] \
    || { echo "claim contested on $id" >&2; return 1; }
}

board_comment() { _cu POST "/task/$1/comment" "$(jq -nc --arg t "$2" '{comment_text:$t}')" >/dev/null; }

board_move() {
  local dest; dest=$(_cu_status "$2")
  [ -n "$dest" ] || { echo "no status configured for queue '$2'" >&2; return 1; }
  _cu PUT "/task/$1" "$(jq -nc --arg s "$dest" '{status:$s}')" >/dev/null
}
