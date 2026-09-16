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
