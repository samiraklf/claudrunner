#!/usr/bin/env bash
# Board adapter: Asana. Needs ASANA_TOKEN.
# Queue roles map to section gids under board.settings.sections.<role>.
set -uo pipefail

_as() {
  local method="$1" path="$2" data="${3-}"
  if [ -n "$data" ]; then
    curl -sf -X "$method" "https://app.asana.com/api/1.0$path" \
      -H "Authorization: Bearer ${ASANA_TOKEN:?ASANA_TOKEN is not set}" \
      -H 'Content-Type: application/json' --data "$data"
  else
    curl -sf -X "$method" "https://app.asana.com/api/1.0$path" \
      -H "Authorization: Bearer ${ASANA_TOKEN:?ASANA_TOKEN is not set}"
  fi
}
_as_section() { cr_get ".board.settings.sections.$1" ""; }

board_fetch() {
  local limit="${1:-5}" sec
  sec=$(_as_section ready); [ -n "$sec" ] || { echo "board.settings.sections.ready is not set" >&2; return 1; }
  _as GET "/tasks?section=$sec&limit=$limit&opt_fields=name,notes,permalink_url,assignee,tags.name" \
    | jq '[ .data[] | select(.assignee == null) | {
        id: .gid,
        title: .name,
        body: (.notes // ""),
        url: .permalink_url,
        labels: [ (.tags // [])[].name ],
        priority: "Medium"
      } ]'
}

board_claim() {
  local id="$1" me
  me=$(_as GET /users/me | jq -r '.data.gid')
  _as PUT "/tasks/$id" "$(jq -nc --arg a "$me" '{data:{assignee:$a}}')" >/dev/null || return 1
  [ "$(_as GET "/tasks/$id?opt_fields=assignee" | jq -r '.data.assignee.gid // ""')" = "$me" ] \
    || { echo "claim contested on $id" >&2; return 1; }
  board_move "$id" claimed
}

board_comment() { _as POST "/tasks/$1/stories" "$(jq -nc --arg t "$2" '{data:{text:$t}}')" >/dev/null; }

board_move() {
  local dest; dest=$(_as_section "$2")
  [ -n "$dest" ] || { echo "no section configured for queue '$2'" >&2; return 1; }
  _as POST "/sections/$dest/addTask" "$(jq -nc --arg t "$1" '{data:{task:$t}}')" >/dev/null
}
