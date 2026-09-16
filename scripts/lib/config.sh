#!/usr/bin/env bash
# Config loading. The canonical file is .claudrunner/config.yml; everything downstream
# reads JSON, because jq is already required to parse the agent's run summary.
#
# Loader order: yq, then python with a YAML module. Both are common on CI images. When
# neither exists the message names the fix instead of failing obscurely.
set -uo pipefail

CR_CONFIG_FILE="${CR_CONFIG_FILE:-.claudrunner/config.yml}"

cr_config_json() {
  [ -f "$CR_CONFIG_FILE" ] || {
    echo "claudrunner: no config at $CR_CONFIG_FILE — run /claudrunner:init first" >&2
    return 1
  }
  if command -v yq >/dev/null 2>&1; then
    yq -o=json '.' "$CR_CONFIG_FILE"
  elif python3 -c 'import yaml' 2>/dev/null; then
    python3 -c 'import sys,yaml,json; json.dump(yaml.safe_load(open(sys.argv[1])),sys.stdout)' "$CR_CONFIG_FILE"
  else
    echo "claudrunner: need yq or python3 with PyYAML to read $CR_CONFIG_FILE" >&2
    echo "  install one:  pip install pyyaml   |   brew install yq   |   snap install yq" >&2
    return 1
  fi
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
