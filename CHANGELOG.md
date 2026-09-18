# Changelog

## Unreleased

### Changed
- The preview is an animated WebP in full colour, recorded at quarter speed and played back at
  full speed for smooth motion, at 1100px. The GIF stays as a fallback and is re-recorded too.
- The README's install steps moved from the bottom to a Quick start right under the preview,
  with the commands after it and a jump link at the top.
- The website got a design pass: search across every page (`/` or Ctrl+K), a light/dark switch
  that remembers your choice, copy buttons on commands, an "On this page" list and linkable
  headings on guides, previous and next links, SVG icons, a three-step "how it works", and a
  folding docs menu on phones. Keyboard focus is always visible, text meets WCAG AA contrast,
  and motion stops when the system asks for reduced motion.

## 0.1.14 — 2026-09-18

### Fixed
- Jira fetched tickets through `/rest/api/3/search`, which Atlassian retired; it now answers
  410 Gone, so a Jira board never handed the crew any work. Fetching uses
  `/rest/api/3/search/jql`. The self-test runs the real fetch against a stand-in Jira that
  refuses the old address.

## 0.1.13 — 2026-09-18

### Added
- A website at https://samiraklf.github.io/claudrunner/: a home page, eight guides written for
  what people search for (Jira, Trello, GitHub Issues and Linear to pull requests, an AI
  security scan, AI code review, a comparison and an FAQ), and every doc as a web page. Titles,
  descriptions, share images, a sitemap and structured data for search engines.
- The status page demo moved to https://samiraklf.github.io/claudrunner/demo/.

### Fixed
- `init` offered 5 task boards; it now offers all 11.

## 0.1.12 — 2026-09-18

### Fixed
- Speech bubbles guessed their width from the character count, so text spilled out: the
  *sent 4 seconds ago* line under Captain Latency's short lines, a long line from the Intern,
  and some robot chatter. Every bubble now measures its text and fits the longest line.

## 0.1.11 — 2026-09-18

### Changed
- The README opens with what claudrunner does, in the words people search for: an autonomous
  AI coding agent that finds bugs, fixes tickets from Jira, Trello, GitHub Issues, Linear and
  7 other boards, and opens the pull requests. A short table lists what it automates.
- The plugin and marketplace descriptions say the same, and list keywords.

### Fixed
- The README said 4 task boards; there are 11.

## 0.1.10 — 2026-09-18

### Changed
- The pep talk runs alongside the scene gags instead of waiting for them: the rope can fly
  while Crawler catches the dog's feature request.

### Added
- An animated preview of the status page at the top of the README, linked to the live demo.
  It shows the rope and Crawler's catch in the same shot.

## 0.1.9 — 2026-09-18

### Changed
- Rollback shouts as he runs to the rescue: *HERE I COME!*, *HOLD ON, BUDDY! I'M COMING!*
- The beach rescue has an ending. It used to stop dead as the dog ran back into the sea; now
  Rollback catches him, fetches the ball himself and throws it up the beach, and the dog
  walks on from where he stands instead of jumping back to the start of his walk.

## 0.1.8 — 2026-09-18

### Fixed
- On a portrait phone the scene was cropped to its middle, so most of the crew and the
  reviewer were off screen. Narrow screens now zoom to fit the crew instead, and the gags
  play where the screen can see them.
- The top bar ran off the edge of small phones and broke its labels on tablets. It wraps
  onto a second row now.

## 0.1.7 — 2026-09-18

### Fixed
- The reviewer's lines floated off to his left. They now sit centred over his head, and the
  opening line rides above the lasso he twirls.

## 0.1.6 — 2026-09-18

### Changed
- The rope is only as long as the way from his hand to the robot's head, so it lands nearly
  straight instead of hanging in a long loop.
- He shouts at every bonk: *WORK HARDER!*, *WORK FASTER!*, *BE SMARTER!* and more.

## 0.1.5 — 2026-09-18

### Changed
- The pep talk comes round every 15 seconds instead of once a minute. Scene gags wait for it
  to finish instead of losing their turn.

## 0.1.4 — 2026-09-18

### Changed
- The reviewer's rope is a real rope now: twisted strands, a lasso loop he twirls over his
  head, and a chain of points under gravity, so it sags, swings and whips on the throw and
  dangles as he reels it back in.

## 0.1.3 — 2026-09-18

### Changed
- The robots type on laptops instead of hammering at a bench, with the screen lighting their
  faces and what they type floating up now and then.

### Added
- The pep talk: the reviewer bonks each robot on the head with a rope, nearest first, and
  asks it, as a friend, to type faster. It aims at wherever each robot actually is. `R` starts it.

## 0.1.2 — 2026-09-18

### Fixed
- The city's big red aerial sat at a fixed spot while the buildings are generated, so it floated
  in front of a facade. It now stands on the roof of the tallest front building.

## 0.1.1 — 2026-09-18

### Fixed
- An installed plugin shipped only its agents, commands, hooks and skills. The dashboard, the
  orchestrator, the CI templates, the stack packs and the board adapters stayed behind in the
  repository, so nobody but us could set it up. Everything that must ship now lives inside
  `plugins/claudrunner/`, and `init` copies the runtime into the user's repository.
- Changing the scene in the middle of a gag let it play on in the new scene: the beach dog and
  its rescuer swam on across the moon. A scene change now stops the gag at once and clears it.
- A closed task drawer still cast its shadow, a grey strip down the right edge of every scene.

### Added
- A public demo of the status page at https://samiraklf.github.io/claudrunner/, redeployed
  whenever the page changes. It runs the built-in simulation and never shows real tasks.
- `init` asks where the status page should live: on this computer, on GitHub Pages (with an
  optional custom domain), on your own server (a subdomain or a path), or nowhere.
- `/claudrunner:dashboard` serves the page locally and opens it, with python3 or node —
  whichever the machine has.
- Runs publish the page when work starts and when it ends. On GitHub Pages it goes to its own
  `claudrunner-status` branch and commits only real changes; public pages show task numbers
  instead of titles unless told otherwise.
- nginx snippets for a subdomain and for a path.
- Three scenes on the status page — a rain-lit street, a rooftop under a signal, and a break
  room the crew occupies when the queue is empty — with deadpan one-liners and a figure that
  points when something is retired. The idle scene is the point: a crew with nothing to do
  should look like one from across the room.
- A status page: one self-contained HTML file, no build and no dependencies, that polls a
  `status.json` beside it. `scripts/claudrunner-status.sh` generates that file from the
  repository's own run records. When the feed is unreachable the page simulates and says so,
  so it is never blank and never presents invented numbers as real.
- Measured, with and without the plugin: review trigger 1.00 vs 0.00, no attribution
  trailer 1.00 vs 0.50, hostile item classified 1.00 vs 0.50, card format 1.00 vs 0.67,
  security pass 0.92 vs 0.92 after a regression was found and fixed.
- An eval suite: five cases that check the skills fire on real phrasing, that item text
  cannot give the agent orders, that a filed card carries its evidence, and that no
  attribution trailer appears even when one is requested. Each case runs with and without
  the plugin, so the report shows what the package actually changes.
- All eleven board adapters now run from the orchestrator. The agent never holds a board
  credential on any of them.
- A session-start hook that loads the repository's crew context — its commands, its notes
  and its gotchas catalog. Silent in repositories that do not use claudrunner, so
  installing the plugin costs nothing elsewhere.
- This repository's own `.claudrunner/gotchas.md` and `notes.md`, seeded with the four
  failure modes that have already happened here.
- Shell bindings for five more boards: GitLab Issues, Jira, Linear, Azure Boards and
  Trello. Six of eleven adapters now run from the orchestrator, so the agent never holds
  the board credential on those.
- The orchestrator resolves its binding by adapter name and refuses one that does not
  define all four verbs.
- The config validator checks the queue roles and each adapter's own required settings, so
  a half-configured board fails at validation instead of at two in the morning.
- The self test checks every binding defines fetch, claim, comment and move, and that each
  one has a documented adapter.
- Code hosts as a first-class choice, separate from the task board: GitHub, GitLab,
  Bitbucket Cloud and Azure Repos. Three verbs — push, propose, link — are the only part of
  the flow that is not plain git. `project.host` selects one.
- Six more board adapters: GitLab Issues, Asana, ClickUp, monday.com, Shortcut and Notion.
  Eleven in total.
- `docs/writing-a-host.md`; the self test and the config validator both check hosts.
- The orchestrator (`scripts/claudrunner-run.sh`): fetch, claim, prepare the tree, run the
  agent, move the items. The agent holds no credential and can only move items that were in
  its own input.
- GitHub Issues board binding with a contested-claim check, so one item cannot become two
  pull requests.
- `scripts/validate-config.sh` — catches the misconfigurations that otherwise show up as a
  silent nightly no-op.
- `scripts/selftest.sh` — the package's own test suite.
- A working `.claudrunner/config.yml`: the project runs on itself.
- `AGENTS.md`.

### Changed
- The CI templates call the orchestrator instead of the agent directly, and install the
  plugin rather than assuming it is present.

## 0.1.0

First skeleton: plugin and marketplace manifests, four commands, seven skills, two agents,
eight stack packs, four board adapters, three schedule targets, seven docs, and the CI
guard that keeps private details out.
