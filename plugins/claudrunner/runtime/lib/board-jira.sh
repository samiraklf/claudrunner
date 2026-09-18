#!/usr/bin/env bash
# Board adapter: Jira Cloud. Needs JIRA_BASE_URL, JIRA_EMAIL and JIRA_API_TOKEN.
#
# Moves are workflow transitions, and a transition can be illegal from the current status.
# board.settings.transitions.<role> holds transition ids; the move verifies the id is
# available for that issue before using it, and says so plainly when no path exists.
set -uo pipefail

_jr() {
  local method="$1" path="$2" data="${3-}"
  local url="${JIRA_BASE_URL:?JIRA_BASE_URL is not set}$path"
  if [ -n "$data" ]; then
    curl -sf -u "${JIRA_EMAIL:?}:${JIRA_API_TOKEN:?}" -X "$method" "$url" \
      -H 'Content-Type: application/json' --data "$data"
  else
    curl -sf -u "${JIRA_EMAIL:?}:${JIRA_API_TOKEN:?}" -X "$method" "$url"
  fi
}

board_fetch() {
  local limit="${1:-5}" jql body
  jql=$(cr_get '.board.settings.jql' '')
  [ -n "$jql" ] || jql="project = $(cr_get '.board.settings.project' '') AND status = \"$(cr_get '.board.queues.ready' '')\" AND assignee IS EMPTY ORDER BY priority DESC, created ASC"
  body=$(jq -nc --arg jql "$jql" --argjson n "$limit" '{jql:$jql,maxResults:$n,fields:["summary","description","labels","priority"]}')
  _jr POST /rest/api/3/search "$body" | jq --arg base "${JIRA_BASE_URL%/}" '[ .issues[] | {
      id: .key,
      title: .fields.summary,
      body: (.fields.description | tostring),
      url: ($base + "/browse/" + .key),
      labels: (.fields.labels // []),
      priority: (.fields.priority.name // "Medium")
    } ]'
}

# Assignment is atomic in Jira. Assign first, read back, then transition.
board_claim() {
  local id="$1" me
  me=$(_jr GET /rest/api/3/myself | jq -r '.accountId')
  _jr PUT "/rest/api/3/issue/$id/assignee" "$(jq -nc --arg a "$me" '{accountId:$a}')" >/dev/null || return 1
  [ "$(_jr GET "/rest/api/3/issue/$id?fields=assignee" | jq -r '.fields.assignee.accountId')" = "$me" ] \
    || { echo "claim contested on $id" >&2; return 1; }
  board_move "$id" claimed
}

board_comment() {
  local body
  body=$(jq -nc --arg t "$2" '{body:{type:"doc",version:1,content:[{type:"paragraph",content:[{type:"text",text:$t}]}]}}')
  _jr POST "/rest/api/3/issue/$1/comment" "$body" >/dev/null
}

board_move() {
  local id="$1" role="$2" tid available
  tid=$(cr_get ".board.settings.transitions.$role" "")
  [ -n "$tid" ] || { echo "no transition configured for queue '$role'" >&2; return 1; }
  available=$(_jr GET "/rest/api/3/issue/$id/transitions" | jq -r --arg t "$tid" '[.transitions[] | select(.id == $t)] | length')
  [ "$available" = "1" ] || {
    echo "transition '$role' is not legal from $id's current status — left where it is" >&2
    return 1
  }
  _jr POST "/rest/api/3/issue/$id/transitions" "$(jq -nc --arg t "$tid" '{transition:{id:$t}}')" >/dev/null
}
