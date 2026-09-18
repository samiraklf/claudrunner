# Adapter: ClickUp

Queues are **statuses** on a list. Statuses are per space or per list, and teams rename them
constantly, so read them at init rather than assuming.

| Verb | API |
|---|---|
| fetch | `GET /list/{list_id}/task?statuses[]=<ready>`, limit 5 |
| claim | `PUT /task/{id}` with `assignees.add` and the claimed status |
| comment | `POST /task/{id}/comment` |
| move | `PUT /task/{id}` with the destination status |

## Notes

- Status names are **lowercase in the API** and title-case in the interface. Compare
  case-insensitively or the fetch silently returns nothing.
- A single `PUT` sets assignee and status together, which makes claiming effectively atomic.
- ClickUp rate limits per token, and the limit is low enough that a 10-minute poll on several
  lists will hit it. Poll one list.
- Priority is numeric and inverted: **1 is urgent**.
