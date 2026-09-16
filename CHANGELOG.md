# Changelog

## Unreleased

### Added
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
