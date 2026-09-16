#!/usr/bin/env bash
# Board adapter: Azure Boards. Needs `az` with the devops extension and AZURE_DEVOPS_EXT_PAT.
#
# Area path is the routing key when one project feeds several repositories: it plays the
# role a repository label plays on other boards.
set -uo pipefail

_az_org()  { cr_get '.board.settings.organization' ''; }
_az_proj() { cr_get '.board.settings.project' ''; }
_az() { az boards "$@" --org "$(_az_org)" --project "$(_az_proj)" --output json 2>/dev/null; }

board_fetch() {
  local limit="${1:-5}" area wiql ids
  area=$(cr_get '.board.settings.area_path' '')
  wiql="SELECT [System.Id] FROM WorkItems WHERE [System.State] = '$(cr_get '.board.queues.ready' '')' AND [System.AssignedTo] = '' "
  [ -n "$area" ] && wiql="$wiql AND [System.AreaPath] UNDER '$area' "
  wiql="$wiql ORDER BY [Microsoft.VSTS.Common.Priority] ASC, [System.CreatedDate] ASC"

  ids=$(_az query --wiql "$wiql" | jq -r --argjson n "$limit" '[.[] | .id] | .[0:$n] | .[]')
  [ -n "$ids" ] || { echo '[]'; return 0; }

  local out='[]' item
  for id in $ids; do
    item=$(_az work-item show --id "$id" | jq --arg base "https://dev.azure.com/$(_az_org)/$(_az_proj)" '{
      id: (.id|tostring),
      title: .fields["System.Title"],
      body: (.fields["System.Description"] // ""),
      url: ($base + "/_workitems/edit/" + (.id|tostring)),
      labels: ((.fields["System.Tags"] // "") | split("; ") | map(select(. != ""))),
      priority: (if .fields["Microsoft.VSTS.Common.Priority"] == 1 then "Critical"
                 elif .fields["Microsoft.VSTS.Common.Priority"] == 2 then "High"
                 elif .fields["Microsoft.VSTS.Common.Priority"] == 4 then "Low"
                 else "Medium" end)
    }')
    out=$(jq -c --argjson i "$item" '. + [$i]' <<<"$out")
  done
  echo "$out"
}

# Assignee and state change in one patch, so the claim is atomic. Read it back anyway.
board_claim() {
  local id="$1" me
  me=$(az account show --output json 2>/dev/null | jq -r '.user.name')
  [ -n "$me" ] && [ "$me" != "null" ] || { echo "cannot resolve the runner identity from az" >&2; return 1; }
  _az work-item update --id "$id" --assigned-to "$me" --state "$(cr_get '.board.queues.claimed' '')" >/dev/null || return 1
  [ "$(_az work-item show --id "$id" | jq -r '.fields["System.AssignedTo"].uniqueName // ""')" = "$me" ] \
    || { echo "claim contested on $id" >&2; return 1; }
}

board_comment() {
  _az work-item update --id "$1" --discussion "$2" >/dev/null
}

board_move() {
  local dest; dest=$(cr_get ".board.queues.$2" "")
  [ -n "$dest" ] || { echo "no state configured for queue '$2'" >&2; return 1; }
  _az work-item update --id "$1" --state "$dest" >/dev/null
}
