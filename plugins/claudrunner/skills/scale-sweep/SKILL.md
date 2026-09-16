---
name: scale-sweep
description: "Performance and scale pass, any language: queries in loops, unbounded reads, missing indexes, memory-bound work, queue timeout traps. Triggers: slow, timeout, N+1, out of memory, scale."
---

# Scale sweep

Assume production is larger than your test data by three orders of magnitude. Most scale
bugs are invisible at development size and fatal at real size.

## Establish the scale profile first

Before judging any query, find out how big the tables actually are. Read the project's own
notes in `.claudrunner/notes.md`, then verify against the database where you have read
access. Record what you learn back into that file. A review without a scale profile is
guessing.

## What to hunt

**Queries in a loop.** The signature is a lookup whose input is one element of a collection
you are already iterating. A filter with a single-element list inside a loop is the same
bug wearing a disguise.

**Unbounded reads.** Any fetch with no limit, on a table that grows. Ask what happens at a
million rows, then at a hundred million.

**Missing indexes.** Every column newly used for filtering, joining, or ordering. Check the
schema, do not assume. Also check that the index order matches the query's leading columns.

**Whole-object buffering.** Files, exports and batches read fully into memory before being
written out. Streaming costs one line and removes the ceiling. Check the memory budget of
the process that runs it.

**Background work.** Three specific traps:
1. A job whose timeout exceeds the queue's retry window — it gets processed twice.
2. A job that is not safe to run twice, when retries are enabled.
3. A job assigned to a queue that no worker actually serves.

**Full-table operations in migrations.** A schema change that rewrites a large table locks
it. Find the row count before approving it.

**Caching that lies.** A cached value with no invalidation path from the write that
changes it. And a cache key that does not include everything the value depends on — tenant,
locale, permissions.

## Reporting

Use the `card-format` skill. Two additions:

- **Measure where you can.** Row counts, query plans, response times, memory. A measured
  finding gets fixed; an asserted one gets argued about.
- **Say what you did not measure.** A read-only review that ran no query plan must say so
  in its source line. Honest limits keep the whole board credible.
