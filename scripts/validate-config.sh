#!/usr/bin/env bash
# Check .claudrunner/config.yml before anything runs on a schedule.
# Catches the misconfigurations that otherwise surface as a silent nightly no-op.
set -uo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/config.sh
source "$here/lib/config.sh"
cr_load || exit 1

fail=0
err() { echo "ERROR: $1"; fail=1; }
warn() { echo "warn:  $1"; }

[ "$(cr_get '.version' '')" = "1" ] || err "version must be 1"

for key in .project.name .project.base_branch .stack.commands.test .policy.autonomy; do
  [ -n "$(cr_get "$key" '')" ] || err "missing required key: ${key#.}"
done

autonomy=$(cr_get '.policy.autonomy' '')
case "$autonomy" in
  suggest|pr-only) ;;
  push)
    branch=$(cr_get '.policy.push_branch' '')
    [ -n "$branch" ] || err "autonomy 'push' requires policy.push_branch"
    ;;
  *) err "policy.autonomy must be suggest, pr-only or push (got '$autonomy')" ;;
esac

# The base branch must exist, and must never be a branch the crew is allowed to push to.
base=$(cr_get '.project.base_branch' '')
if [ -n "$base" ]; then
  git rev-parse -q --verify "origin/$base" >/dev/null 2>&1 || warn "origin/$base not found locally — fetch first"
  [ "$(cr_get '.policy.push_branch' '')" = "$base" ] && err "policy.push_branch must never equal project.base_branch"
fi

filtered=$(cr_get '.stack.commands.test_filter' '')
if [ -n "$filtered" ]; then
  case "$filtered" in *"{filter}"*) ;; *) err "stack.commands.test_filter must contain {filter}" ;; esac
else
  warn "no test_filter: every run pays for the full suite, which usually kills the time budget"
fi

if [ "$(cr_get '.board.adapter' 'none')" = "none" ] && [ "$(cr_get '.loops.fast.enabled' 'false')" = "true" ]; then
  err "the fast loop needs a board adapter"
fi

lines=$(cr_get '.policy.max_changed_lines' '600')
[ "$lines" -gt 2000 ] 2>/dev/null && warn "max_changed_lines is $lines — diffs that size do not get reviewed properly"

[ -n "$(cr_get '.limits.max_runs_per_week' '')" ] || warn "no limits.max_runs_per_week — set a spend stop before scheduling"

if [ "$(cr_get '.review.second_vendor.enabled' 'false')" = "true" ]; then
  [ -n "$(cr_get '.review.second_vendor.command' '')" ] || err "second_vendor is enabled but no command is set"
fi

[ "$fail" -eq 0 ] && echo "config ok"
exit "$fail"
