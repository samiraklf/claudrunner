#!/usr/bin/env bash
# Board adapter: Trello. Needs TRELLO_API_KEY and TRELLO_TOKEN.
# Queue roles map to list ids under board.settings.lists.<role>.
#
# Trello has no claim primitive, so a label stands in and is verified by re-reading.
set -uo pipefail

_tr_auth() { echo "key=${TRELLO_API_KEY:?TRELLO_API_KEY is not set}&token=${TRELLO_TOKEN:?TRELLO_TOKEN is not set}"; }
_tr_list() { cr_get ".board.settings.lists.$1" ""; }

board_fetch() {
  local limit="${1:-5}" list
  list=$(_tr_list ready); [ -n "$list" ] || { echo "board.settings.lists.ready is not set" >&2; return 1; }
  curl -sf "https://api.trello.com/1/lists/$list/cards?$(_tr_auth)" \
    | jq --argjson n "$limit" '[ .[] | {
        id,
        title: .name,
        body: (.desc // ""),
        url: .shortUrl,
        labels: [ (.labels // [])[].name ],
        priority: ([ (.labels // [])[].name ] | map(select(. == "Critical" or . == "High" or . == "Medium" or . == "Low")) | first // "Medium")
      } ] | .[0:$n]'
}

board_claim() {
  local id="$1" label holders
  label=$(cr_get '.board.settings.claim_label_id' '')
  [ -n "$label" ] || { echo "board.settings.claim_label_id is not set" >&2; return 1; }
  curl -sf -X POST "https://api.trello.com/1/cards/$id/idLabels?value=$label&$(_tr_auth)" >/dev/null || return 1
  sleep 2
  holders=$(curl -sf "https://api.trello.com/1/cards/$id?$(_tr_auth)" | jq -r --arg l "$label" '[(.idLabels // [])[] | select(. == $l)] | length')
  [ "$holders" = "1" ] || { echo "claim contested on $id" >&2; return 1; }
}

board_comment() {
  curl -sf -X POST "https://api.trello.com/1/cards/$1/actions/comments?$(_tr_auth)" \
    --data-urlencode "text=$2" >/dev/null
}

board_move() {
  local dest; dest=$(_tr_list "$2")
  [ -n "$dest" ] || { echo "no list configured for queue '$2'" >&2; return 1; }
  curl -sf -X PUT "https://api.trello.com/1/cards/$1?idList=$dest&$(_tr_auth)" >/dev/null
}
