#!/usr/bin/env bash
# Board adapter: Shortcut. Needs SHORTCUT_API_TOKEN.
# Queue roles map to workflow state ids under board.settings.states.<role>.
set -uo pipefail

_sc() {
  local method="$1" path="$2" data="${3-}"
  if [ -n "$data" ]; then
    curl -sf -X "$method" "https://api.app.shortcut.com$path" \
      -H "Shortcut-Token: ${SHORTCUT_API_TOKEN:?SHORTCUT_API_TOKEN is not set}" \
      -H 'Content-Type: application/json' --data "$data"
  else
    curl -sf -X "$method" "https://api.app.shortcut.com$path" \
      -H "Shortcut-Token: ${SHORTCUT_API_TOKEN:?SHORTCUT_API_TOKEN is not set}"
  fi
}
_sc_state() { cr_get ".board.settings.states.$1" ""; }

board_fetch() {
  local limit="${1:-5}" body
  body=$(jq -nc --argjson s "$(_sc_state ready)" '{workflow_state_id:$s,owner_id:null}')
  _sc POST /api/v3/stories/search "$body" | jq --argjson n "$limit" '[ .[] | {
      id: (.id|tostring),
      title: .name,
      body: (.description // ""),
      url: .app_url,
      labels: ([ (.labels // [])[].name ] + [.story_type]),
      priority: "Medium"
    } ] | .[0:$n]'
}

# One PUT sets owner and state, so the claim is atomic. Read it back anyway.
board_claim() {
  local id="$1" me body
  me=$(_sc GET /api/v3/member | jq -r '.id')
  body=$(jq -nc --arg u "$me" --argjson s "$(_sc_state claimed)" '{owner_ids:[$u],workflow_state_id:$s}')
  _sc PUT "/api/v3/stories/$id" "$body" >/dev/null || return 1
  [ "$(_sc GET "/api/v3/stories/$id" | jq -r --arg u "$me" '[(.owner_ids // [])[] | select(. == $u)] | length')" = "1" ] \
    || { echo "claim contested on $id" >&2; return 1; }
}

board_comment() { _sc POST "/api/v3/stories/$1/comments" "$(jq -nc --arg t "$2" '{text:$t}')" >/dev/null; }

board_move() {
  local dest; dest=$(_sc_state "$2")
  [ -n "$dest" ] || { echo "no state configured for queue '$2'" >&2; return 1; }
  _sc PUT "/api/v3/stories/$1" "$(jq -nc --argjson s "$dest" '{workflow_state_id:$s}')" >/dev/null
}
