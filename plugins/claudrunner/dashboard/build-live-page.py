#!/usr/bin/env python3
"""Build the live status page that reads the board through the viewer's own claude.ai
connector, from the same page the local dashboard serves.

    build-live-page.py <config.json> <out.html>

config.json:
    {"title": "Mystorio Crew", "server": "Trello", "tool": "trelloReadCard",
     "board_url": "https://trello.com/b/...", "queues": {"ready": "...", "claimed": "...",
     "review": "...", "parked": "...", "filed": "...", "done": "..."}}

The page is published as a claude.ai artifact with the `mcp` capability, so it opens from
any device, refreshes itself, and never stores the board's content: every viewer reads it
with their own connector.
"""
import json
import re
import sys
from pathlib import Path

here = Path(__file__).resolve().parent
cfg = json.loads(Path(sys.argv[1]).read_text())
out = Path(sys.argv[2])
page = (here / "index.html").read_text()

# The artifact skeleton supplies doctype, html, head, body, charset and viewport.
for pattern in (r"<!doctype html>\n", r"<html[^>]*>\n", r"<head>\n", r"</head>\n", r"<body>\n",
                r"</body>\n", r"</html>\n?", r'<meta charset="utf-8">\n', r'<meta name="viewport"[^>]*>\n'):
    page = re.sub(pattern, "", page, count=1)
page = re.sub(r"<title>[^<]*</title>", f"<title>{cfg['title']}</title>", page, count=1)

# claude.ai stamps data-theme="light|dark" on the root; the scene's own day and night
# must not collide with it.
page = page.replace("data-theme", "data-sky").replace("dataset.theme", "dataset.sky")

adapter = """
// ---------------------------------------------------------------- live from the board
// This copy reads the board through the viewer's own claude.ai connector: nothing is
// published anywhere, and it works from any device where claude.ai is open.
const BOARD = %s;

function chip(text, title) { el('mode').textContent = text; el('mode').title = title || ''; }
let lastStamp = 0, parkedNow = 0;

function fromBoard(payload, stamp) {
  const nodes = (payload && payload.cards && payload.cards.nodes) || [];
  const q = BOARD.queues;
  const inList = name => nodes.filter(c => c.list && c.list.name === name);
  const short = c => ((c.webUrl || '').split('/c/')[1] || '').split('/')[0];
  const run = (c, phase, progress) => ({ id: '#' + short(c), title: c.name, phase, progress, board: 'trello' });
  const today = new Date().toDateString();
  const touchedToday = c => c.lastActivityAt && new Date(c.lastActivityAt).toDateString() === today;
  parkedNow = inList(q.parked).length;
  return {
    queue: inList(q.ready).length,
    retired_today: [...inList(q.review), ...inList(q.done)].filter(touchedToday).length,
    runs: [...inList(q.claimed).map(c => run(c, 'implementing', 0.4)),
           ...inList(q.review).map(c => run(c, 'review', 0.85))],
    fetched_at: new Date(stamp).toISOString(),
  };
}

function liveChip() {
  const stale = Date.now() - lastStamp > 120000;
  if (stale) return chip('STALE', 'The board has not answered for two minutes. Reload the page.');
  chip(parkedNow ? `LIVE · ${parkedNow} NEED YOU` : 'LIVE',
       'Read from your board at ' + new Date(lastStamp).toLocaleTimeString() + '. Refreshes every 30 seconds.');
}

const EMPTY = { queue: 0, retired_today: 0, runs: [] };
const DENIED = {
  server_not_connected: ['CONNECT ' + BOARD.server.toUpperCase(), 'Add ' + BOARD.server + ' in claude.ai Settings → Connectors, then reload.'],
  selection_required:   ['CHOOSE ' + BOARD.server.toUpperCase(), 'Pick which ' + BOARD.server + ' connector this page uses, then reload.'],
  needs_reauth:         ['RECONNECT ' + BOARD.server.toUpperCase(), 'Reconnect ' + BOARD.server + ' in claude.ai Settings → Connectors.'],
  not_in_manifest:      ['ALLOW ' + BOARD.server.toUpperCase(), 'Allow the ' + BOARD.server + ' connector for this page, then reload.'],
  consent_required:     ['ALLOW ' + BOARD.server.toUpperCase(), 'Allow the ' + BOARD.server + ' connector for this page, then reload.'],
  blocked_by_policy:    [BOARD.server.toUpperCase() + ' BLOCKED', 'Your organization blocks this connector.'],
  approval_required:    [BOARD.server.toUpperCase() + ' NEEDS APPROVAL', 'Your organization requires approval for this connector.'],
};

render(EMPTY, true);
chip('CONNECTING…');
(async () => {
  const mcp = window.claude && window.claude.use ? await window.claude.use('mcp') : null;
  if (!mcp) {
    chip('OPEN ON CLAUDE.AI', 'This page reads your board through your claude.ai connector, so it only works on claude.ai.');
    return;
  }
  mcp.watchTool(BOARD.server, BOARD.tool, { action: 'list_by_board', boardIdOrUrl: BOARD.url }, ev => {
    if (ev.type === 'data') {
      lastStamp = ev.result.cache ? ev.result.cache.storedAt : Date.now();
      render(fromBoard(ev.result.payload, lastStamp), true);
      liveChip();
      return;
    }
    const denied = DENIED[ev.error.code];
    if (denied) { render(EMPTY, true); chip(denied[0], denied[1]); return; }
    if (ev.error.code === 'tool_error') { chip('BOARD NOT FOUND', ev.error.message); return; }
    chip('STALE', 'The board did not answer: ' + ev.error.message);   // transient: keep what is shown
  }, { refetchInterval: 30000, cache: { staleTime: 20000 } });
  setInterval(() => { if (lastStamp) liveChip(); }, 15000);
})();
""" % json.dumps({"server": cfg["server"], "tool": cfg["tool"], "url": cfg["board_url"],
                   "queues": cfg["queues"]}, ensure_ascii=False)

start = page.index("// The simulation is for the demo")
end = page.index("poll(); setInterval(poll, POLL_MS);") + len("poll(); setInterval(poll, POLL_MS);")
page = page[:start] + adapter.strip() + page[end:]
out.write_text(page)
print(f"wrote {out}")
