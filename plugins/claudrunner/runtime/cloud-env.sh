#!/usr/bin/env bash
# Helpers for the one step of /claudrunner:init that only a person can do: creating the Claude
# Code cloud environment at claude.ai/code. Claude Code has no command or API that creates
# one, so init makes the manual part as short as possible.
#
#   cloud-env.sh copy <file>      put the setup script on the clipboard (prints it if it cannot)
#   cloud-env.sh open             open claude.ai/code in the browser
#   cloud-env.sh default          print the environment /remote-env last picked, or nothing
#   cloud-env.sh restore <id|"">  put that choice back as it was ("" removes it)
#
# /remote-env saves the picked environment as remote.defaultEnvironmentId in the user's
# settings. That is how init learns the id of the environment the user just created.
set -uo pipefail

settings="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"

case "${1:-}" in
  copy)
    file="${2:?usage: cloud-env.sh copy <file>}"
    [ -f "$file" ] || { echo "cloud-env: no such file: $file" >&2; exit 2; }
    for c in pbcopy "wl-copy" "xclip -selection clipboard" "xsel --clipboard --input" clip.exe; do
      command -v "${c%% *}" >/dev/null 2>&1 || continue
      # shellcheck disable=SC2086  # the options are meant to split
      if $c < "$file" 2>/dev/null; then echo "copied $file to the clipboard"; exit 0; fi
    done
    echo "cloud-env: no clipboard tool here; copy the script below by hand" >&2
    echo "----8<----"; cat "$file"; echo "----8<----"
    ;;
  open)
    url="https://claude.ai/code"
    for o in open xdg-open wslview explorer.exe; do
      command -v "$o" >/dev/null 2>&1 && { "$o" "$url" >/dev/null 2>&1 & echo "opened $url"; exit 0; }
    done
    echo "open $url in your browser"
    ;;
  default)
    [ -f "$settings" ] && jq -r '.remote.defaultEnvironmentId // empty' "$settings" 2>/dev/null
    exit 0
    ;;
  restore)
    [ "$#" -ge 2 ] || { echo "usage: cloud-env.sh restore <id|\"\">" >&2; exit 2; }
    id="$2"
    [ -f "$settings" ] || { [ -z "$id" ] && exit 0; echo '{}' > "$settings"; }
    if [ -n "$id" ]; then
      jq --arg id "$id" '.remote.defaultEnvironmentId = $id' "$settings" > "$settings.new"
    else
      jq 'del(.remote.defaultEnvironmentId) | if .remote == {} then del(.remote) else . end' "$settings" > "$settings.new"
    fi && mv "$settings.new" "$settings" && echo "restored your default cloud environment"
    ;;
  *) echo "usage: cloud-env.sh copy <file> | open | default | restore <id|\"\">" >&2; exit 2 ;;
esac
