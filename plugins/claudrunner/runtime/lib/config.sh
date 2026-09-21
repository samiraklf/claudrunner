#!/usr/bin/env bash
# Config loading. The canonical file is .claudrunner/config.yml; everything downstream
# reads JSON, because jq is already required to parse the agent's run summary.
#
# Loader order: yq (either kind), then python with a YAML module, then ruby. When none
# works the message names the fix instead of failing obscurely.
set -uo pipefail

CR_CONFIG_FILE="${CR_CONFIG_FILE:-.claudrunner/config.yml}"

cr_config_json() {
  [ -f "$CR_CONFIG_FILE" ] || {
    echo "claudrunner: no config at $CR_CONFIG_FILE — run /claudrunner:init first" >&2
    return 1
  }
  # Two different tools are called yq: the Go one takes -o=json, the Python one prints JSON by
  # default and rejects -o. A cloud image may have either, so every reader is tried in turn and
  # its output checked, instead of trusting the first one found.
  local out
  if command -v yq >/dev/null 2>&1; then
    out=$(yq -o=json '.' "$CR_CONFIG_FILE" 2>/dev/null) && jq -e . >/dev/null 2>&1 <<<"$out" && { printf '%s' "$out"; return 0; }
    out=$(yq '.' "$CR_CONFIG_FILE" 2>/dev/null) && jq -e . >/dev/null 2>&1 <<<"$out" && { printf '%s' "$out"; return 0; }
  fi
  if python3 -c 'import yaml' 2>/dev/null; then
    python3 -c 'import sys,yaml,json; json.dump(yaml.safe_load(open(sys.argv[1])),sys.stdout)' "$CR_CONFIG_FILE"
    return
  fi
  if command -v ruby >/dev/null 2>&1; then
    ruby -ryaml -rjson -e 'puts JSON.dump(YAML.safe_load(File.read(ARGV[0])))' "$CR_CONFIG_FILE" 2>/dev/null && return 0
  fi
  echo "claudrunner: need yq, python3 with PyYAML, or ruby to read $CR_CONFIG_FILE" >&2
  echo "  install one:  pip install pyyaml   |   brew install yq   |   snap install yq" >&2
  return 1
}

# cr_get <jq path> [default] — read one value, with an optional default.
cr_get() {
  local path="$1" default="${2-}" value
  value=$(printf '%s' "$CR_CONFIG" | jq -r "$path // empty")
  [ -n "$value" ] && { printf '%s' "$value"; return 0; }
  [ -n "$default" ] && { printf '%s' "$default"; return 0; }
  return 0
}

cr_load() {
  command -v jq >/dev/null 2>&1 || { echo "claudrunner: jq is required" >&2; return 1; }
  CR_CONFIG=$(cr_config_json) || return 1
  export CR_CONFIG
}
