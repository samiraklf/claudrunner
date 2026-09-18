# Changelog

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
