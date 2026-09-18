# Configuration reference

`.claudrunner/config.yml`, written by `init` and safe to edit by hand.

```yaml
version: 1

project:
  name: acme-api
  base_branch: main          # what pull requests target; never pushed to directly
  host: github               # github | gitlab | bitbucket | azure-repos
  code_dir: .                # for a monorepo, the directory this crew owns

stack:
  pack: node                 # or python, dotnet, java, go, php, rust, generic
  commands:
    test: "npm test"
    test_filter: "npm test -- {filter}"
    lint: "npm run lint"
    format: "npm run format"
    build: "npm run build"
    setup: ""                # optional: prepares a bare checkout (dependencies, a database)

schedule:
  runs_on: routine           # routine | github-actions | cron | systemd | manual
  routines:                  # written by init: the routines it created, so it updates them later
    triage: ""
    sweep: ""

executor:
  mode: direct               # direct | container
  container:                 # only read when mode is container
    compose_file: docker-compose.test.yml
    service: test

board:
  adapter: github-issues     # or trello, jira, linear, none
  via: api                   # api: shell adapters + credentials | connector: the claude.ai connector
  connector:
    board: ""                # connector only: the board's URL
  queues:
    ready: "claudrunner:ready"
    claimed: "claudrunner:running"
    review: "claudrunner:in-review"
    parked: "claudrunner:needs-input"
    filed: "claudrunner:finding"

  # Adapter-specific settings. Only the keys your adapter needs.
  #   trello        settings.lists.<role> (list ids), settings.claim_label_id
  #   linear        settings.states.<role> (workflow state ids)
  #   jira          settings.project or settings.jql, settings.transitions.<role>
  #   azure-boards  settings.organization, settings.project, settings.area_path
  #   gitlab-issues settings.project (path or id)
  #   shortcut      settings.states.<role> (workflow state ids)
  #   asana         settings.sections.<role> (section gids)
  #   clickup       settings.list_id
  #   monday        settings.board_id, settings.status_column (the column id)
  #   notion        settings.database_id, settings.status_property
  settings: {}

loops:
  fast:
    enabled: true
    every: 10m
    max_items: 3
  slow:
    enabled: true
    schedule: nightly        # nightly | weekly
    scopes: [correctness, security, scale, tests]
    max_new_cards: 15

policy:
  autonomy: pr-only          # suggest | pr-only | push
  push_branch: null          # required only when autonomy is push
  allow_new_dependencies: false
  max_changed_lines: 600
  edit_ci: false             # may the crew change workflow files

limits:
  run_timeout_minutes: 55
  max_turns: 150

review:
  second_vendor:
    enabled: false
    command: null            # a read-only CLI from another model vendor

dashboard:
  where: local               # local | branch | github-pages | server | none
  domain: ""                 # github-pages: your own domain, e.g. crew.example.com
  show_titles: true          # github-pages defaults to false: public pages show task numbers only
  branch: claudrunner-status # github-pages: the branch Pages serves
  server:
    webroot: ""              # server, same machine: the folder your web server serves
    ssh_target: ""           # server, from CI: user@host:/path/ — key in CLAUDRUNNER_DASHBOARD_SSH_KEY
```

## Fields worth thinking about

**`base_branch`** — not necessarily the repository's default branch. Many projects
integrate on a branch that is not what GitHub shows as default. Set it explicitly; the crew
never resolves it from `HEAD`.

**`project.host`** — where the branch is pushed and the change proposed. Independent of
your board: code on GitHub with work items in Jira is a normal combination.

**`schedule.runs_on`** — `routine` runs in Anthropic's cloud on your Claude subscription: no
API key, no server, no CI minutes, and the shortest interval is one hour. `init` creates the
routines and installs the crew into the repository's `.claude/`, because a routine cannot
install plugins. `github-actions` needs an `ANTHROPIC_API_KEY` secret and is billed by the API.

**`board.via`** — `connector` lets the agent use the board's claude.ai connector: the natural
choice in a routine, with no keys to store. The trade-off is stated plainly: with `api` the
shell holds the board credential and the agent never sees it; with `connector` the agent
itself can reach the board. It is still told to touch only the cards it claimed.

**`stack.commands.setup`** — a routine starts from a bare checkout every time. Put what the
tests need (installing dependencies, starting a database) in one script and point this at it.

**`executor.mode`** — `direct` is correct on a CI runner, which is already disposable.
Choose `container` when runs happen on a machine you care about.

**`policy.max_changed_lines`** — the real quality control. A large unattended diff does not
get reviewed properly by anyone, including you.

**`review.second_vendor`** — a reviewer from a different model vendor, read-only, on the
same diff. Two vendors disagreeing is a much stronger signal than one model checking itself.

**`dashboard.where`** — where the status page lives. `local` is opened with
`/claudrunner:dashboard`. `branch` publishes the status to a `claudrunner-status` branch and
`/claudrunner:dashboard` shows it live — the way to watch a routine or CI on a private
repository. `github-pages` publishes the same branch as a public site. `server` copies
the page into a folder, or uploads it over SSH from CI. See the hosting guide in the plugin's
`templates/hosting/`.

**`dashboard.show_titles`** — on a public page, titles often name customers, bugs and
security issues. GitHub Pages therefore shows task numbers unless you turn titles on.

## Credentials, by adapter

Never in this file. The orchestrator reads them from the environment, and the agent never
sees them.

| Adapter | Environment |
|---|---|
| `github-issues` | `GH_TOKEN` |
| `gitlab-issues` | `GITLAB_TOKEN`, plus `GITLAB_HOST` when self-managed |
| `jira` | `JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` |
| `linear` | `LINEAR_API_KEY` |
| `azure-boards` | `AZURE_DEVOPS_EXT_PAT` |
| `trello` | `TRELLO_API_KEY`, `TRELLO_TOKEN` |
| `shortcut` | `SHORTCUT_API_TOKEN` |
| `asana` | `ASANA_TOKEN` |
| `clickup` | `CLICKUP_TOKEN` |
| `monday` | `MONDAY_TOKEN` |
| `notion` | `NOTION_TOKEN` |

## Two files that are not config

`.claudrunner/notes.md` — what the crew learned about your project and cannot cheaply
re-derive: scale-sensitive tables, slow paths, deliberate unconventional choices.

`.claudrunner/gotchas.md` — failure modes that have already happened here. Every review
reads it first. This file is how the crew becomes specifically good at your codebase.
