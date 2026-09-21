#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
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

host=$(cr_get '.project.host' 'github')
case "$host" in
  github|gitlab|bitbucket|azure-repos) ;;
  *) err "project.host must be github, gitlab, bitbucket or azure-repos (got '$host')" ;;
esac

filtered=$(cr_get '.stack.commands.test_filter' '')
if [ -n "$filtered" ]; then
  case "$filtered" in *"{filter}"*) ;; *) err "stack.commands.test_filter must contain {filter}" ;; esac
else
  warn "no test_filter: every run pays for the full suite, which usually kills the time budget"
fi

adapter=$(cr_get '.board.adapter' 'none')
if [ "$adapter" = "none" ] && [ "$(cr_get '.loops.fast.enabled' 'false')" = "true" ]; then
  err "the fast loop needs a board adapter"
fi

# Each queue role the orchestrator moves items into must be mapped.
if [ "$adapter" != "none" ]; then
  for role in ready claimed review parked; do
    [ -n "$(cr_get ".board.queues.$role" '')" ] || err "board.queues.$role is not set"
  done
fi

# How the board is reached. "api": the shell adapters, with credentials in the environment.
# "connector": the agent uses the board's claude.ai connector — how a cloud routine reaches
# a board without keys. Then the agent finds the lists by name at run time.
via=$(cr_get '.board.via' 'api')
case "$via" in
  api) ;;
  connector)
    [ -n "$(cr_get '.board.connector.board' '')" ] || err "board.via is connector: set board.connector.board (the board's URL)" ;;
  *) err "board.via must be api or connector (got '$via')" ;;
esac

# How the crew tests its changes.
verify=$(cr_get '.verify.mode' 'auto')
case "$verify" in
  auto|here|ci) ;;
  *) err "verify.mode must be auto, here or ci (got '$verify')" ;;
esac

# Where the scheduled runs happen.
runs_on=$(cr_get '.schedule.runs_on' 'github-actions')
case "$runs_on" in
  routine|github-actions|cron|systemd|manual) ;;
  *) err "schedule.runs_on must be routine, github-actions, cron, systemd or manual (got '$runs_on')" ;;
esac

# Local-only installs keep every claudrunner file out of git, so nothing remote can see them.
commit_files=$(printf '%s' "$CR_CONFIG" | jq -r '.schedule.commit_files | if . == null then "" else tostring end')
case "$commit_files" in ''|true|false) ;; *) err "schedule.commit_files must be true or false (got '$commit_files')" ;; esac
if [ "$commit_files" = false ]; then
  case "$runs_on" in
    routine|github-actions) err "schedule.commit_files is false, but a $runs_on run only sees committed files" ;;
  esac
fi

# Adapter-specific settings, checked by name so a half-configured board fails here rather
# than at 02:00 with the queue silently empty. A connector finds its lists at run time.
[ "$via" = "connector" ] && adapter="connector:$adapter"
case "$adapter" in
  trello)
    for k in lists.ready lists.review lists.parked claim_label_id; do
      [ -n "$(cr_get ".board.settings.$k" '')" ] || err "board.settings.$k is not set"
    done
    # Trello ids are 24 hex characters. Anything else is a name or a placeholder, and
    # would only fail later, on the first scheduled run.
    for k in lists.ready lists.claimed lists.review lists.parked lists.filed claim_label_id; do
      v=$(cr_get ".board.settings.$k" '')
      [ -z "$v" ] || [[ "$v" =~ ^[0-9a-f]{24}$ ]] || err "board.settings.$k is '$v', not a Trello id (24 hex characters)"
    done ;;
  linear)
    for role in ready claimed review parked; do
      [ -n "$(cr_get ".board.settings.states.$role" '')" ] || err "board.settings.states.$role is not set"
    done ;;
  jira)
    [ -n "$(cr_get '.board.settings.jql' '')$(cr_get '.board.settings.project' '')" ] || err "jira needs board.settings.project or board.settings.jql"
    for role in claimed review parked; do
      [ -n "$(cr_get ".board.settings.transitions.$role" '')" ] || err "board.settings.transitions.$role is not set"
    done ;;
  shortcut)
    for role in ready claimed review parked; do
      [ -n "$(cr_get ".board.settings.states.$role" '')" ] || err "board.settings.states.$role is not set"
    done ;;
  asana)
    for role in ready claimed review parked; do
      [ -n "$(cr_get ".board.settings.sections.$role" '')" ] || err "board.settings.sections.$role is not set"
    done ;;
  clickup)
    [ -n "$(cr_get '.board.settings.list_id' '')" ] || err "board.settings.list_id is not set" ;;
  monday)
    for k in board_id status_column; do
      [ -n "$(cr_get ".board.settings.$k" '')" ] || err "board.settings.$k is not set"
    done ;;
  notion)
    [ -n "$(cr_get '.board.settings.database_id' '')" ] || err "board.settings.database_id is not set" ;;
  azure-boards)
    for k in organization project; do
      [ -n "$(cr_get ".board.settings.$k" '')" ] || err "board.settings.$k is not set"
    done ;;
esac

lines=$(cr_get '.policy.max_changed_lines' '600')
[ "$lines" -gt 2000 ] 2>/dev/null && warn "max_changed_lines is $lines — diffs that size do not get reviewed properly"

if [ "$(cr_get '.review.second_vendor.enabled' 'false')" = "true" ]; then
  [ -n "$(cr_get '.review.second_vendor.command' '')" ] || err "second_vendor is enabled but no command is set"
fi

where=$(cr_get '.dashboard.where' 'local')
case "$where" in
  local|none)
    [ "$where" = "local" ] && [ "$runs_on" = "routine" ] && \
      warn "runs happen in a cloud routine but dashboard.where is local: this computer never sees them — use branch"
    ;;
  branch) ;;
  github-pages)
    [ "$(cr_get '.dashboard.show_titles' 'false')" = "true" ] && \
      warn "dashboard.show_titles is true on a GitHub Pages site: anyone with the link can read your task titles"
    ;;
  server)
    if [ -z "$(cr_get '.dashboard.server.webroot' '')" ] && [ -z "$(cr_get '.dashboard.server.ssh_target' '')" ]; then
      err "dashboard.where is server: set dashboard.server.webroot or dashboard.server.ssh_target"
    fi
    ;;
  *) err "dashboard.where must be local, branch, github-pages, server or none (got '$where')" ;;
esac

[ "$fail" -eq 0 ] && echo "config ok"
exit "$fail"
