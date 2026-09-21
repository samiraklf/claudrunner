---
title: Nightly AI security scan and bug finder for your codebase
description: "Run an AI security scan on your codebase nightly or weekly. Finds injection, broken authorization, secrets, N+1 queries and untested code, with file and line."
lead: Every night, or every week, claudrunner reads your codebase like a hostile reviewer and files what it can prove — each finding with the file, the line, the quoted code, the impact and a proposed fix.
---

## What it looks for

The sweep runs four passes. You can run all of them, or only the ones you care about.

| Pass | Examples of what it files |
|---|---|
| **Security** | Injection · missing ownership checks · one customer reading another's data · secrets in source or logs · a whole request body assigned to a record · unsafe deserialization · outbound requests to a user-supplied address |
| **Correctness** | A condition that fires when nothing changed · a record left in a state nothing can move forward · a new enum case its consumers never handle · a response field a client still depends on · a cached value with no invalidation |
| **Scale and performance** | A query inside a loop (N+1) · an unbounded read on a growing table · a missing index on a newly filtered column · a whole file buffered in memory · a job whose timeout exceeds its retry window, so it runs twice · a migration that locks a large table |
| **Tests** | An untested calculation · an untested billing or money path · an untested authorization rule · a fake that suppresses the very callback the test claims to prove |

It works in **any language** — the passes describe failure patterns, not syntax — and each
stack pack adds the failures that ecosystem is known for.

## Evidence or nothing

A scanner that cries wolf gets ignored within a week. claudrunner's rule is simple: **a
finding it cannot anchor in your code does not get filed.**

Every ticket it files carries:

- the **file and line**, and the **quoted code**;
- the **impact**, measured where it can be — how many rows, how many callers;
- a **proposed fix** and an effort estimate;
- a **severity**, from your board's own labels.

It also **enumerates before it reports**: a handler with one injection usually has a missing
ownership check too, so it finds every issue in the scope before writing the first ticket.

## Where the findings go

To your task board — Jira, Trello, GitHub Issues, Linear or any of the
[11 supported boards](index.md) — in an intake queue, capped at a number you choose
(15 per sweep by default) so a first run on an old codebase does not bury your board.

No board? The sweep writes the same findings as Markdown reports in your repository.

And the fast loop can **fix them**: move a finding to your ready queue and it comes back as a
pull request with a regression test.

## Run it

In your terminal — one command, safe to paste as a whole:

```bash
claude plugin marketplace add samiraklf/claudrunner && claude plugin install claudrunner@claudrunner
```

Then, in Claude Code inside your repository:

```
/claudrunner:init
```

Try one pass by hand before you schedule anything:

```
/claudrunner:sweep security
```

Read three findings. If the evidence is good and the severities look right, it is
calibrated for your codebase. If one is wrong, write why in `.claudrunner/gotchas.md` —
every later sweep reads that file first, so a correction written once holds forever.

Then schedule it: **nightly** suits a codebase that changes daily, **weekly** suits a stable
one and produces fewer near-duplicates. Run it at a working hour — a failure at 07:00 gets
read at 07:05.

## Next

- [AI code review before every PR](ai-code-review.md) — catch these before they merge.
- [Scheduling](../scheduling.md)
