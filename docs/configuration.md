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

executor:
  mode: direct               # direct | container
  container:                 # only read when mode is container
    compose_file: docker-compose.test.yml
    service: test

board:
  adapter: github-issues     # or trello, jira, linear, none
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
  max_runs_per_day: 20
  max_runs_per_week: 100

review:
  second_vendor:
    enabled: false
    command: null            # a read-only CLI from another model vendor
```

## Fields worth thinking about

**`base_branch`** — not necessarily the repository's default branch. Many projects
integrate on a branch that is not what GitHub shows as default. Set it explicitly; the crew
never resolves it from `HEAD`.

**`project.host`** — where the branch is pushed and the change proposed. Independent of
your board: code on GitHub with work items in Jira is a normal combination.

**`executor.mode`** — `direct` is correct on a CI runner, which is already disposable.
Choose `container` when runs happen on a machine you care about.

**`policy.max_changed_lines`** — the real quality control. A large unattended diff does not
get reviewed properly by anyone, including you.

**`review.second_vendor`** — a reviewer from a different model vendor, read-only, on the
same diff. Two vendors disagreeing is a much stronger signal than one model checking
itself. It costs a second bill.

**`limits.max_runs_per_week`** — a stop on spend, not on ambition. Set it before the first
schedule, not after the first invoice.

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

## Two files that are not config

`.claudrunner/notes.md` — what the crew learned about your project and cannot cheaply
re-derive: scale-sensitive tables, slow paths, deliberate unconventional choices.

`.claudrunner/gotchas.md` — failure modes that have already happened here. Every review
reads it first. This file is how the crew becomes specifically good at your codebase.
