# Adapter: Notion

Queues are values of a **select property** in a database. Common in teams that run everything
in Notion, and workable, but it is a document store wearing a board's clothes.

| Verb | API |
|---|---|
| fetch | `POST /v1/databases/{id}/query` filtered on the status property, page size 5 |
| claim | `PATCH /v1/pages/{id}` setting the person property and the claimed status |
| comment | `POST /v1/comments` with the page as parent |
| move | `PATCH /v1/pages/{id}` with the destination status |

## Notes

- **The item body is a block tree, not a string.** Fetch the page's children to read the
  description. A query result alone gives you properties and almost no content.
- Property names are user-defined and renameable. Resolve them at init, store the ids, and
  re-resolve when a query fails.
- Claiming is a single patch, so it is effectively atomic.
- Notion is a wiki first. Expect items that are really design documents, and skip them
  `too-large` with a proposed split rather than trying to implement a page.
