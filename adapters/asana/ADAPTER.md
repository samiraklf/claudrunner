# Adapter: Asana

Queues are **sections** within a project. Tasks move between sections, which maps cleanly.

| Verb | API |
|---|---|
| fetch | `GET /tasks?section=<gid>&completed_since=now`, limit 5 |
| claim | `PUT /tasks/{gid}` setting `assignee` to the runner |
| comment | `POST /tasks/{gid}/stories` with `text` |
| move | `POST /sections/{gid}/addTask` with the task gid |

## Notes

- **Everything is a gid**, not a name. Resolve section gids once at init and store them.
- Claiming by assignee is effectively atomic: read the task back and confirm the assignee is
  the runner before starting.
- Custom fields carry priority in most workspaces, and their option values are gids too.
  Read the field's metadata; never match on the display string.
- Subtasks are separate tasks and do not appear in a section listing. If your team puts real
  work in subtasks, fetch them for the parent before judging size.
