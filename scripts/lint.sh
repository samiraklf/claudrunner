#!/usr/bin/env bash
# Run every check CI runs, in the same order, before a commit.
#
# Linter versions disagree: 0.11 passes code that older releases reject. CI pins the
# release below, and this script refuses to call a run clean with any other version.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

SHELLCHECK_VERSION="0.11.0"
fail=0
step() { echo; echo "== $1"; }

step "self test"
./scripts/selftest.sh | tail -1 || fail=1
[ "${PIPESTATUS[0]}" -eq 0 ] || fail=1

step "config"
./scripts/validate-config.sh || fail=1

step "private details"
./scripts/check-leaks.sh || fail=1

step "shellcheck ${SHELLCHECK_VERSION}"
if ! command -v shellcheck >/dev/null 2>&1; then
  echo "shellcheck is not installed"; fail=1
else
  have=$(shellcheck --version | awk '/^version:/{print $2}')
  if [ "$have" != "$SHELLCHECK_VERSION" ]; then
    echo "shellcheck ${have} is installed; CI uses ${SHELLCHECK_VERSION}. Results would not match."
    fail=1
  fi
  shellcheck -x scripts/*.sh scripts/lib/*.sh templates/cron/*.sh plugins/claudrunner/hooks/*.sh || fail=1
fi

echo
if [ "$fail" -eq 0 ]; then echo "lint passed"; else echo "lint FAILED"; fi
exit "$fail"
