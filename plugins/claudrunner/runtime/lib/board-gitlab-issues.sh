#!/usr/bin/env bash
# Board adapter: GitLab Issues. Needs `glab` and GITLAB_TOKEN; GITLAB_HOST for self-managed.
#
# Scoped labels (status::ready) are mutually exclusive on GitLab's side, which makes the
# move atomic. Plain labels are not, so the claim is verified the same way GitHub's is.
set -uo pipefail

board_label() { cr_get ".board.queues.$1" ""; }
_gl_repo() { local r; r=$(cr_get '.board.settings.project' ''); [ -n "$r" ] && echo "-R $r"; }

board_fetch() {
  local limit="${1:-5}"
  # shellcheck disable=SC2046
  glab issue list $(_gl_repo) --label "$(board_label ready)" --per-page "$limit" -F json \
    | jq '[ .[] | {
        id: (.iid|tostring),
        title,
        body: (.description // ""),
        url: .web_url,
        labels: (.labels // []),
        priority: ((.labels // []) | map(select(. == "Critical" or . == "High" or . == "Medium" or . == "Low")) | first // "Medium")
      } ]'
}

board_claim() {
  local id="$1" claimed holders
  claimed=$(board_label claimed)
  # shellcheck disable=SC2046
  glab issue update "$id" $(_gl_repo) --label "$claimed" --unlabel "$(board_label ready)" >/dev/null || return 1
  sleep 2
  # shellcheck disable=SC2046
  holders=$(glab issue view "$id" $(_gl_repo) -F json | jq -r --arg c "$claimed" '[(.labels // [])[] | select(. == $c)] | length')
  [ "$holders" = "1" ] || { echo "claim contested on #$id, releasing" >&2; board_move "$id" ready; return 1; }
}

board_comment() {
  # shellcheck disable=SC2046
  glab issue note "$1" $(_gl_repo) --message "$2" >/dev/null
}

board_move() {
  local id="$1" role="$2" dest unlabel role_i l
  dest=$(board_label "$role"); [ -n "$dest" ] || { echo "no label for queue '$role'" >&2; return 1; }
  unlabel=""
  for role_i in ready claimed review parked filed; do
    [ "$role_i" = "$role" ] && continue
    l=$(board_label "$role_i"); [ -n "$l" ] && unlabel="$unlabel --unlabel $l"
  done
  # shellcheck disable=SC2046,SC2086
  glab issue update "$id" $(_gl_repo) --label "$dest" $unlabel >/dev/null
}
