#!/usr/bin/env bash
# Board adapter: Notion. Needs NOTION_TOKEN and board.settings.database_id.
#
# A query result gives properties and almost no content: the item body is a block tree, so
# fetch is followed by a children read for each item.
set -uo pipefail

_no() {
  local method="$1" path="$2" data="${3-}"
  local -a args=(-sf -X "$method" "https://api.notion.com/v1$path"
    -H "Authorization: Bearer ${NOTION_TOKEN:?NOTION_TOKEN is not set}"
    -H 'Notion-Version: 2022-06-28' -H 'Content-Type: application/json')
  [ -n "$data" ] && args+=(--data "$data")
  curl "${args[@]}"
}
_no_prop() { cr_get '.board.settings.status_property' 'Status'; }

board_fetch() {
  local limit="${1:-5}" db body ids out='[]' id page text
  db=$(cr_get '.board.settings.database_id' '')
  [ -n "$db" ] || { echo "board.settings.database_id is not set" >&2; return 1; }
  body=$(jq -nc --arg p "$(_no_prop)" --arg v "$(cr_get '.board.queues.ready' '')" --argjson n "$limit" \
    '{page_size:$n,filter:{property:$p,select:{equals:$v}}}')
  ids=$(_no POST "/databases/$db/query" "$body" | jq -r '.results[].id')
  [ -n "$ids" ] || { echo '[]'; return 0; }

  for id in $ids; do
    page=$(_no GET "/pages/$id")
    text=$(_no GET "/blocks/$id/children?page_size=50" \
      | jq -r '[.results[] | .. | .plain_text? // empty] | join("\n")')
    out=$(jq -c --argjson o "$out" --argjson p "$page" --arg b "$text" '$o + [{
        id: $p.id,
        title: ([$p.properties | to_entries[] | select(.value.type == "title") | .value.title[].plain_text] | join("")),
        body: $b,
        url: $p.url,
        labels: [],
        priority: "Medium"
      }]' <<<'null')
  done
  echo "$out"
}

board_claim() {
  local id="$1" me body
  me=$(_no GET /users/me | jq -r '.bot.owner.user.id // .id')
  body=$(jq -nc --arg p "$(_no_prop)" --arg s "$(cr_get '.board.queues.claimed' '')" --arg u "$me" \
    --arg pp "$(cr_get '.board.settings.assignee_property' 'Assignee')" \
    '{properties:{($p):{select:{name:$s}},($pp):{people:[{id:$u}]}}}')
  _no PATCH "/pages/$id" "$body" >/dev/null || return 1
  [ "$(_no GET "/pages/$id" | jq -r --arg p "$(_no_prop)" '.properties[$p].select.name')" = "$(cr_get '.board.queues.claimed' '')" ]
}

board_comment() {
  _no POST /v1/comments "$(jq -nc --arg i "$1" --arg t "$2" '{parent:{page_id:$i},rich_text:[{text:{content:$t}}]}')" >/dev/null 2>&1 \
    || _no POST /comments "$(jq -nc --arg i "$1" --arg t "$2" '{parent:{page_id:$i},rich_text:[{text:{content:$t}}]}')" >/dev/null
}

board_move() {
  local dest; dest=$(cr_get ".board.queues.$2" "")
  [ -n "$dest" ] || { echo "no status configured for queue '$2'" >&2; return 1; }
  _no PATCH "/pages/$1" "$(jq -nc --arg p "$(_no_prop)" --arg s "$dest" '{properties:{($p):{select:{name:$s}}}}')" >/dev/null
}
