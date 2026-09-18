# Adapter: Jira

Queues are statuses in a workflow, which means moves are transitions and a transition can
be rejected. Handle that.

## Queue mapping

| Queue | Typical status |
|---|---|
| ready | the ready-for-development status |
| claimed | in progress |
| review | in review |
| parked | blocked, or a needs-information status |

`init` reads the project's workflow and proposes the mapping. Store transition identifiers,
not status names.

## Verbs

| Verb | API |
|---|---|
| fetch | JQL search: project, status, unassigned or assigned to the runner, ordered by priority |
| claim | assign to the runner account, then transition to in-progress |
| comment | add comment |
| move | execute the transition, by id |

## Notes

- **A transition may be forbidden** from the current status. Read the available transitions
  for that issue before choosing, and report clearly when no path exists.
- Jira priority is a first-class field. Use it instead of labels.
- Custom fields vary per project. Never assume a field exists; read the create metadata.

## Running it from the orchestrator

Shipped as `lib/board-jira.sh`, installed into your repo at `.claudrunner/bin/`, so the shell fetches, claims and moves. The agent
never holds the board credential.

| | |
|---|---|
| Credentials | `JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` |
| Config | `board.settings.project` or `board.settings.jql`, and `board.settings.transitions.<role>` — transition ids, not status names |

Set `board.adapter: jira` and map every queue role under `board.queues`.
`.claudrunner/bin/validate-config.sh` fails when a required setting is missing, so a half-configured
board is caught before the first scheduled run rather than at two in the morning.

