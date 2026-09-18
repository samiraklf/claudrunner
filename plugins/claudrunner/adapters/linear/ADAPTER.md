# Adapter: Linear

Queues are workflow states. The API is GraphQL and the model is clean, so this is the
simplest adapter after GitHub Issues.

## Queue mapping

| Queue | Typical state |
|---|---|
| ready | Todo, or a triage-complete state |
| claimed | In Progress |
| review | In Review |
| parked | Blocked |

Resolve state identifiers once at init and store them.

## Verbs

| Verb | GraphQL |
|---|---|
| fetch | `issues` filtered by team and state, ordered by priority |
| claim | `issueUpdate` setting assignee and state |
| comment | `commentCreate` |
| move | `issueUpdate` setting state |

## Notes

- Priority is numeric, where 1 is urgent. Do not sort ascending by accident.
- Sub-issues inherit context from their parent. Read the parent before judging size.

## Running it from the orchestrator

Shipped as `lib/board-linear.sh`, installed into your repo at `.claudrunner/bin/`, so the shell fetches, claims and moves. The agent
never holds the board credential.

| | |
|---|---|
| Credentials | `LINEAR_API_KEY` |
| Config | `board.settings.states.<role>` — workflow state ids, resolved once at init |

Set `board.adapter: linear` and map every queue role under `board.queues`.
`.claudrunner/bin/validate-config.sh` fails when a required setting is missing, so a half-configured
board is caught before the first scheduled run rather than at two in the morning.

