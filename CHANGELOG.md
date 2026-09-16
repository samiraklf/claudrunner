# Changelog

## Unreleased

### Added
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
