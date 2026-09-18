#!/usr/bin/env bash
# Board adapter: monday.com. Needs MONDAY_TOKEN, board.settings.board_id and
# board.settings.status_column (the column id, which is not its title).
set -uo pipefail

_mo() {
  curl -sf https://api.monday.com/v2 \
    -H "Authorization: ${MONDAY_TOKEN:?MONDAY_TOKEN is not set}" \
    -H 'Content-Type: application/json' -H 'API-Version: 2024-01' --data "$1"
}
_mo_board()  { cr_get '.board.settings.board_id' ''; }
_mo_column() { cr_get '.board.settings.status_column' 'status'; }

board_fetch() {
  local limit="${1:-5}" q
  q=$(jq -nc --arg b "$(_mo_board)" --arg c "$(_mo_column)" --arg v "$(cr_get '.board.queues.ready' '')" --argjson n "$limit" \
    '{query:"query($b:ID!,$c:String!,$v:String!,$n:Int!){boards(ids:[$b]){items_page(limit:$n,query_params:{rules:[{column_id:$c,compare_value:[$v],operator:any_of}]}){items{id name url column_values{id text}}}}}",variables:{b:$b,c:$c,v:$v,n:$n}}')
  _mo "$q" | jq '[ .data.boards[0].items_page.items[] | {
      id,
      title: .name,
      body: ([ .column_values[] | select(.id | test("text|description|long_text")) | .text ] | map(select(. != null)) | join("\n")),
      url,
      labels: [],
      priority: ([ .column_values[] | select(.id | test("priority")) | .text ] | first // "Medium")
    } ]'
}

# One mutation sets person and status together.
board_claim() {
  local id="$1" me q vals
  me=$(_mo '{"query":"{me{id}}"}' | jq -r '.data.me.id')
  vals=$(jq -nc --arg c "$(_mo_column)" --arg s "$(cr_get '.board.queues.claimed' '')" --arg u "$me" \
    '{($c):{label:$s},person:{personsAndTeams:[{id:($u|tonumber),kind:"person"}]}} | tostring')
  q=$(jq -nc --arg b "$(_mo_board)" --arg i "$id" --arg v "$vals" \
    '{query:"mutation($b:ID!,$i:ID!,$v:JSON!){change_multiple_column_values(board_id:$b,item_id:$i,column_values:$v){id}}",variables:{b:$b,i:$i,v:$v}}')
  [ -n "$(_mo "$q" | jq -r '.data.change_multiple_column_values.id // empty')" ]
}

board_comment() {
  local q; q=$(jq -nc --arg i "$1" --arg b "$2" '{query:"mutation($i:ID!,$b:String!){create_update(item_id:$i,body:$b){id}}",variables:{i:$i,b:$b}}')
  _mo "$q" >/dev/null
}

board_move() {
  local dest q; dest=$(cr_get ".board.queues.$2" "")
  [ -n "$dest" ] || { echo "no status configured for queue '$2'" >&2; return 1; }
  q=$(jq -nc --arg b "$(_mo_board)" --arg i "$1" --arg c "$(_mo_column)" --arg v "$(jq -nc --arg s "$dest" '{label:$s}' | jq -c 'tostring' | tr -d '"')" \
    '{query:"mutation($b:ID!,$i:ID!,$c:String!,$v:JSON!){change_column_value(board_id:$b,item_id:$i,column_id:$c,value:$v){id}}",variables:{b:$b,i:$i,c:$c,v:$v}}')
  _mo "$q" >/dev/null
}
