# Adapter: Shortcut

Queues are **workflow states**. Built for engineering teams, so the model needs the least
translation of any board here.

| Verb | API |
|---|---|
| fetch | `POST /api/v3/stories/search` with `workflow_state_id`, limit 5 |
| claim | `PUT /api/v3/stories/{id}` setting `owner_ids` and the claimed state |
| comment | `POST /api/v3/stories/{id}/comments` |
| move | `PUT /api/v3/stories/{id}` with `workflow_state_id` |

## Notes

- Resolve workflow state ids at init. They are per workflow, and a team may run several.
- One `PUT` sets owner and state, so claiming is effectively atomic.
- Story type — feature, bug, chore — is a useful signal the other boards lack. A chore rarely
  needs a regression test; a bug always does.
- Epics group stories. Read the epic before judging size: a story that looks small often
  carries its context there.
