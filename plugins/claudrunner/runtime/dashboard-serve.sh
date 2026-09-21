#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# Serve the status page from this machine and open it.
#
#   dashboard-serve.sh          start (or reuse) a server and print its address
#   dashboard-serve.sh --stop   stop it
#
# Needs one of python3 or node — whichever this machine already has. Nothing is installed.
set -uo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
state=".claudrunner/dashboard"
mkdir -p "$state"
pidfile="$state/.server.pid"; portfile="$state/.server.port"; loopfile="$state/.refresh.pid"

stop() {
  for f in "$pidfile" "$loopfile"; do
    [ -f "$f" ] && kill "$(cat "$f")" 2>/dev/null
    rm -f "$f"
  done
  rm -f "$portfile"
}
if [ "${1:-}" = "--stop" ]; then stop; echo "dashboard stopped"; exit 0; fi

# The local view only ever writes locally — never through the publisher, which in
# github-pages or server mode would push or upload on every refresh.
page="$here/dashboard/index.html"; [ -f "$page" ] || page="$here/../dashboard/index.html"
cp "$page" "$state/index.html"
# Where the crew runs decides where its status is. Runs on this machine leave records here;
# runs elsewhere — a cloud routine, CI — publish to a branch, and this page reads that.
where=local; branch=claudrunner-status
if [ -f .claudrunner/config.yml ]; then
  # shellcheck source=lib/config.sh
  source "$here/lib/config.sh"
  if cr_load 2>/dev/null; then
    where=$(cr_get '.dashboard.where' 'local'); branch=$(cr_get '.dashboard.branch' 'claudrunner-status')
  fi
fi
refresh() {
  # fetched_at says when this machine last looked, so the page can tell live from stale.
  # It is added here, on the copy this machine serves; the published status stays timeless.
  local now; now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  if [ "$where" = "branch" ] || [ "$where" = "github-pages" ]; then
    git fetch -q origin "$branch" 2>/dev/null
    if git show "origin/$branch:status.json" 2>/dev/null \
        | jq --arg t "$now" '. + {fetched_at: $t}' > "$state/status.json.new" 2>/dev/null \
        && [ -s "$state/status.json.new" ]; then
      mv "$state/status.json.new" "$state/status.json"; return
    fi
    rm -f "$state/status.json.new"
    # No status branch yet: no run has claimed a task. Say so, rather than show nothing.
    if ! git rev-parse -q --verify "origin/$branch" >/dev/null; then
      jq -n --arg t "$now" --arg b "$branch" \
        '{waiting: true, waiting_for: ("the first run to publish to the " + $b + " branch"),
          queue: 0, retired_today: 0, runs: [], fetched_at: $t}' > "$state/status.json"
      return
    fi
  fi
  # With no config yet the page still works: it shows its simulation instead.
  if "$here/claudrunner-status.sh" "$state/status.json.new" >/dev/null 2>&1; then
    jq --arg t "$now" '. + {fetched_at: $t}' "$state/status.json.new" > "$state/status.json" 2>/dev/null
  else
    rm -f "$state/status.json"
  fi
  rm -f "$state/status.json.new"
}
refresh

if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null && [ -f "$portfile" ]; then
  port=$(cat "$portfile")
else
  stop
  port=8787
  while (exec 3<>"/dev/tcp/127.0.0.1/$port") 2>/dev/null; do port=$((port + 1)); done
  if command -v python3 >/dev/null 2>&1; then
    nohup python3 -m http.server "$port" --bind 127.0.0.1 -d "$state" >/dev/null 2>&1 &
  elif command -v node >/dev/null 2>&1; then
    nohup node -e '
      const http = require("http"), fs = require("fs"), path = require("path");
      const root = process.argv[1], types = { ".html": "text/html", ".json": "application/json" };
      http.createServer((req, res) => {
        const file = path.join(root, decodeURIComponent(req.url.split("?")[0]) === "/" ? "index.html" : req.url.split("?")[0]);
        if (!file.startsWith(root)) { res.writeHead(403); return res.end(); }
        fs.readFile(file, (err, body) => {
          if (err) { res.writeHead(404); return res.end(); }
          res.writeHead(200, { "Content-Type": types[path.extname(file)] || "application/octet-stream" }); res.end(body);
        });
      }).listen(Number(process.argv[2]), "127.0.0.1");' "$(cd "$state" && pwd)" "$port" >/dev/null 2>&1 &
  else
    echo "dashboard: needs python3 or node to serve the page" >&2; exit 1
  fi
  echo $! > "$pidfile"; echo "$port" > "$portfile"
  # Do not hand out the address until something is actually listening on it.
  for _ in $(seq 1 50); do
    (exec 3<>"/dev/tcp/127.0.0.1/$port") 2>/dev/null && break
    sleep 0.1
  done
fi
# The refresh loop keeps the page live. Restart it whenever it is not running — a reused
# server whose loop died would otherwise show the same state forever.
if ! { [ -f "$loopfile" ] && kill -0 "$(cat "$loopfile")" 2>/dev/null; }; then
  ( while kill -0 "$(cat "$pidfile" 2>/dev/null)" 2>/dev/null; do
      sleep 20; refresh
    done ) >/dev/null 2>&1 &
  echo $! > "$loopfile"
fi

url="http://127.0.0.1:$port/"
echo "claudrunner dashboard: $url"
[ -n "${CLAUDRUNNER_NO_OPEN:-}" ] && exit 0   # tests and headless machines: print, do not open
for opener in xdg-open open; do
  command -v "$opener" >/dev/null 2>&1 && { "$opener" "$url" >/dev/null 2>&1 & break; }
done
