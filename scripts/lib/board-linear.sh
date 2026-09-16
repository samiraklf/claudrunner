#!/usr/bin/env bash
# Board adapter: Linear. Needs LINEAR_API_KEY.
# Queue roles map to workflow state ids under board.settings.states.<role>.
set -uo pipefail

_ln_state() { cr_get ".board.settings.states.$1" ""; }
_ln() { curl -sf https://api.linear.app/graphql -H "Authorization: ${LINEAR_API_KEY:?LINEAR_API_KEY is not set}" \
          -H 'Content-Type: application/json' --data "$1"; }

board_fetch() {
  local limit="${1:-5}" state q
  state=$(_ln_state ready); [ -n "$state" ] || { echo "board.settings.states.ready is not set" >&2; return 1; }
  q=$(jq -nc --arg s "$state" --argjson n "$limit" '{query:"query($s:ID!,$n:Int!){issues(first:$n,filter:{state:{id:{eq:$s}}},orderBy:updatedAt){nodes{identifier id title description url priorityLabel labels{nodes{name}}}}}",variables:{s:$s,n:$n}}')
  _ln "$q" | jq '[ .data.issues.nodes[] | {
      id: .id,
      title,
      body: (.description // ""),
      url,
      labels: [ .labels.nodes[].name ],
      priority: (.priorityLabel // "Medium")
    } ]'
}

# Assignment and state move in one mutation, so the claim is atomic. Read it back anyway.
board_claim() {
  local id="$1" me q
  me=$(_ln '{"query":"{viewer{id}}"}' | jq -r '.data.viewer.id')
  q=$(jq -nc --arg id "$id" --arg s "$(_ln_state claimed)" --arg u "$me" '{query:"mutation($id:String!,$s:String!,$u:String!){issueUpdate(id:$id,input:{stateId:$s,assigneeId:$u}){success}}",variables:{id:$id,s:$s,u:$u}}')
  [ "$(_ln "$q" | jq -r '.data.issueUpdate.success')" = "true" ] || return 1
  q=$(jq -nc --arg id "$id" '{query:"query($id:String!){issue(id:$id){assignee{id}}}",variables:{id:$id}}')
  [ "$(_ln "$q" | jq -r '.data.issue.assignee.id')" = "$me" ] || { echo "claim contested on $id" >&2; return 1; }
}

board_comment() {
  local q; q=$(jq -nc --arg id "$1" --arg b "$2" '{query:"mutation($id:String!,$b:String!){commentCreate(input:{issueId:$id,body:$b}){success}}",variables:{id:$id,b:$b}}')
  _ln "$q" >/dev/null
}

board_move() {
  local dest q; dest=$(_ln_state "$2")
  [ -n "$dest" ] || { echo "no state configured for queue '$2'" >&2; return 1; }
  q=$(jq -nc --arg id "$1" --arg s "$dest" '{query:"mutation($id:String!,$s:String!){issueUpdate(id:$id,input:{stateId:$s}){success}}",variables:{id:$id,s:$s}}')
  [ "$(_ln "$q" | jq -r '.data.issueUpdate.success')" = "true" ]
}
