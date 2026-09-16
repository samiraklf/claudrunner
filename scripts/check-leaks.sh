#!/usr/bin/env bash
# Guard against private details leaking into a public repository.
#
# This project was extracted from a private working setup. Nothing that identifies that
# setup — an employer, an internal service, a hostname, a person, a machine path — may
# appear here. This script fails the build when it does.
#
# Private patterns are NOT stored in this repository, because writing them here would be
# the leak. They come from:
#   - .namecheck        an untracked file, one extended regex per line (local use)
#   - $PRIVATE_PATTERN  an extended regex supplied by CI as a repository variable
#
# Some patterns below use a one-character bracket (B[y]) so the literal string they hunt
# for never itself appears in this file. They are ordinary extended regexes.
set -uo pipefail

fail=0
scan() { git ls-files -z | xargs -0 grep -InE "$1" -- 2>/dev/null; }
report() { echo "LEAK [$1]"; printf '%s\n' "$2"; fail=1; }

# 1 — Model attribution trailers. This project is authored by a person.
hits=$(scan 'Co-Authored-B[y]:.*(Claude|Anthropic|GPT|Copilot)|Cl[a]ude-Session:|Generated with \[?Cl[a]ude')
[ -n "$hits" ] && report "attribution trailer" "$hits"

# 2 — Absolute machine paths from someone's laptop or a server.
hits=$(scan '(/home/[a-z][a-z0-9_-]+/|/Users/[a-z][a-z0-9_-]+/|/var/lib/[a-z]+bot/)')
[ -n "$hits" ] && report "absolute machine path" "$hits"

# 3 — Email addresses. The licence holder's name is fine; addresses are not.
hits=$(scan '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}')
[ -n "$hits" ] && report "email address" "$hits"

# 4 — Private hosts. Public examples must use example.com or acme.test.
hits=$(scan 'https?://[A-Za-z0-9.-]+\.(internal|local|lan|corp)\b|\b(staging|sandbox|prod)\.[A-Za-z0-9-]+\.(com|io|net|dev)\b')
[ -n "$hits" ] && report "private hostname" "$hits"

# 5 — Locally configured patterns.
if [ -f .namecheck ]; then
  while IFS= read -r pat; do
    [ -z "$pat" ] && continue
    case "$pat" in \#*) continue ;; esac
    hits=$(scan "$pat")
    [ -n "$hits" ] && report "private pattern" "$hits"
  done < .namecheck
fi

# 6 — CI-supplied pattern.
if [ -n "${PRIVATE_PATTERN:-}" ]; then
  hits=$(scan "$PRIVATE_PATTERN")
  [ -n "$hits" ] && report "private pattern (ci)" "$hits"
fi

if [ "$fail" -ne 0 ]; then
  echo
  echo "Remove the lines above before this is published. Examples must use invented names."
  exit 1
fi
echo "clean: no private details found"
