#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# Build the status page and put it wherever dashboard.where says it lives.
#
#   local         .claudrunner/dashboard/ — /claudrunner:dashboard serves it
#   github-pages  the claudrunner-status branch, which GitHub Pages serves
#   branch        the same branch, without Pages: /claudrunner:dashboard reads it. For private
#                 repositories, and for runs in the cloud that have no disk you can open
#   server        a folder on this machine (webroot), or another one over SSH (ssh_target)
#   none          nothing
#
# Safe to call at every run's start and end: it only commits or copies when the page changed.
set -uo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/config.sh
source "$here/lib/config.sh"
cr_load || exit 1

where=$(cr_get '.dashboard.where' 'local')
[ "$where" = "none" ] && exit 0

page=""
for candidate in "$here/dashboard/index.html" "$here/../dashboard/index.html"; do
  [ -f "$candidate" ] && { page="$candidate"; break; }
done
[ -n "$page" ] || { echo "publish-dashboard: index.html not found beside $here" >&2; exit 1; }

build=$(mktemp -d)
trap 'rm -rf "$build"' EXIT
cp "$page" "$build/index.html"
branch=$(cr_get '.dashboard.branch' 'claudrunner-status')
# The page on the branch is the one being replaced: hand it to the status builder, so a
# fresh sandbox carries on today's count instead of starting from zero.
if [ "$where" = "github-pages" ] || [ "$where" = "branch" ]; then
  git fetch -q origin "$branch" 2>/dev/null
  git show "origin/$branch:status.json" > "$build/.previous.json" 2>/dev/null || rm -f "$build/.previous.json"
fi
CLAUDRUNNER_PREV_STATUS="$build/.previous.json" "$here/claudrunner-status.sh" "$build/status.json" >/dev/null || exit 1
rm -f "$build/.previous.json"
domain=$(cr_get '.dashboard.domain' '')

case "$where" in
  local)
    mkdir -p .claudrunner/dashboard
    cp "$build/index.html" "$build/status.json" .claudrunner/dashboard/
    ;;

  github-pages|branch)
    if [ "$where" = "github-pages" ]; then
      [ -n "$domain" ] && printf '%s\n' "$domain" > "$build/CNAME"
      touch "$build/.nojekyll"
    fi
    tree=$(mktemp -d)
    if git rev-parse -q --verify "origin/$branch" >/dev/null; then
      git worktree add -q --detach "$tree" "origin/$branch" || exit 1
    else
      # First publish: an orphan branch that holds nothing but the page. It gets a throwaway
      # local name, deleted afterwards — a named local branch left behind by a failed push
      # would make every later first-publish fail with "branch already exists".
      scratch="claudrunner-status-publish-$$"
      git worktree add -q --detach "$tree" || exit 1
      git -C "$tree" checkout -q --orphan "$scratch"
      git -C "$tree" rm -rfq . >/dev/null 2>&1
    fi
    cp -a "$build/." "$tree/"
    git -C "$tree" add -A
    if ! git -C "$tree" diff --cached --quiet; then
      name=$(git config user.name || true); email=$(git config user.email || true)
      git -C "$tree" -c user.name="${name:-claudrunner}" -c user.email="${email:-claudrunner@$(hostname)}" \
        commit -qm "status: update the dashboard" && git -C "$tree" push -q origin "HEAD:$branch"
    fi
    git worktree remove --force "$tree"
    if [ -n "${scratch:-}" ]; then git branch -D "$scratch" >/dev/null 2>&1; fi
    ;;

  server)
    webroot=$(cr_get '.dashboard.server.webroot' '')
    target=$(cr_get '.dashboard.server.ssh_target' '')
    if [ -n "$webroot" ]; then
      mkdir -p "$webroot" && cp "$build/index.html" "$build/status.json" "$webroot/"
    elif [ -n "$target" ]; then
      key="${CLAUDRUNNER_DASHBOARD_SSH_KEY:-}"
      ssh_cmd="ssh -o StrictHostKeyChecking=accept-new"
      [ -n "$key" ] && ssh_cmd="$ssh_cmd -i $key"
      rsync -q -e "$ssh_cmd" "$build/index.html" "$build/status.json" "$target"
    else
      echo "publish-dashboard: set dashboard.server.webroot or dashboard.server.ssh_target" >&2; exit 1
    fi
    ;;

  *) echo "publish-dashboard: unknown dashboard.where '$where'" >&2; exit 1 ;;
esac
exit 0
