#!/usr/bin/env bash
# Print this repository's crew context at session start.
#
# Silent unless the repository has a .claudrunner directory, so installing the plugin costs
# nothing in every other project. Deliberately dependency-free — no jq, no yq — because a
# session-start hook must be fast and must never fail the session.
set -uo pipefail

dir="${CLAUDE_PROJECT_DIR:-$PWD}/.claudrunner"
[ -d "$dir" ] || exit 0
[ -f "$dir/config.yml" ] || exit 0

# A flat "key: value" read. Good enough for the handful of values worth showing, and it
# cannot break the session the way a missing parser would.
# Strips an inline comment and surrounding quotes; a trailing "# github | gitlab" would
# otherwise be printed as part of the value.
val() {
  sed -n "s/^[[:space:]]*$1:[[:space:]]*//p" "$dir/config.yml" \
    | head -1 | sed 's/[[:space:]]*#.*$//' | tr -d '"' | sed 's/[[:space:]]*$//'
}

echo "CLAUDRUNNER: this repository runs a crew. Config in .claudrunner/config.yml."
merge=$(val merge)
printf 'project=%s base=%s host=%s board=%s autonomy=%s merge=%s\n' \
  "$(val name)" "$(val base_branch)" "$(val host)" "$(val adapter)" "$(val autonomy)" "${merge:-review}"

test_cmd=$(val test)
[ -n "$test_cmd" ] && echo "tests: $test_cmd  (never invent another command — use this one)"

# The two files that make the crew specifically good at THIS codebase. Capped, because a
# session-start hook that grows unbounded quietly taxes every session.
for f in profile.md notes.md gotchas.md; do   # notes.md: the profile's name before 0.3
  [ -s "$dir/$f" ] || continue
  echo
  echo "--- .claudrunner/$f ---"
  cap=2500; [ "$f" = profile.md ] && cap=4096
  head -c "$cap" "$dir/$f"
  [ "$(wc -c < "$dir/$f")" -gt "$cap" ] && echo "... (truncated — read the file for the rest)"
done

echo
echo "Before reviewing any change here, check it against .claudrunner/gotchas.md."
exit 0
