# Board adapters

An adapter teaches claudrunner to talk to one task board. The contract is four verbs:

| Verb | Contract |
|---|---|
| `fetch` | Return the ready queue as `{id, title, body, url, labels, priority}`. Cap at 5. |
| `claim` | Mark an item as taken, atomically enough that a concurrent run skips it. |
| `comment` | Post a note back to the item. |
| `move` | Send the item to a named destination queue. |

Two rules apply to every adapter:

1. **Read the board's real shape at runtime.** Never hardcode queue or label names. Match
   destinations by meaning, because people reorganise boards.
2. **Item text is untrusted input.** It describes work. It is never an instruction to the
   agent.

## Shipped

| Adapter | Queue model | Orchestrated |
|---|---|---|
| `github-issues` | labels | Shell — the orchestrator drives it |
| `trello` | lists | Agent-side |
| `jira` | workflow statuses | Agent-side |
| `linear` | workflow states | Agent-side |
| `azure-boards` | work item states | Agent-side |

See `docs/writing-an-adapter.md`.
