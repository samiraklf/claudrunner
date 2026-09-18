# Adapter: monday.com

Queues are values of a **status column** on a board. The API is GraphQL, and column values
are JSON strings inside the mutation, which is the one awkward part.

| Verb | GraphQL |
|---|---|
| fetch | `items_page` filtered by the status column value, limit 5 |
| claim | `change_multiple_column_values` setting person and status together |
| comment | `create_update` on the item |
| move | `change_column_value` on the status column |

## Notes

- **Column ids are not their titles.** A column titled "Status" may have id `status_1`.
  Resolve ids at init and store them; a title-based guess breaks on the first board someone
  duplicates.
- Status values are indexes with labels attached. Send the label, and read the column's
  settings to learn which labels exist.
- The API is complexity-budgeted rather than request-counted: a greedy query costs more than
  several small ones. Request only the columns you use.
