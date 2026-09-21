---
title: Turn GitHub Issues into pull requests automatically
description: "An AI agent that fixes GitHub issues and opens pull requests by itself. Label an issue; it implements, tests and reviews it. Runs from GitHub Actions."
lead: The simplest setup there is. Add a label to an issue, and a tested, reviewed pull request follows. No account beyond GitHub, and it runs from GitHub Actions.
---

## Why start here

GitHub Issues needs **no extra account and no extra secret for the board** — the token your
GitHub Actions run already has is enough. It is the default in `init`, and the quickest way
to see what claudrunner does.

## Labels are the queues

| Label | Meaning |
|---|---|
| `claudrunner:ready` | You add this. The next run picks the issue up |
| `claudrunner:running` | Claimed by a run |
| `claudrunner:in-review` | A pull request is open for it |
| `claudrunner:needs-input` | Parked, with a question in a comment |
| `claudrunner:finding` | Filed by the bug sweep |

You can rename every one of them in `init`.

## What a run does

1. Lists open issues labelled ready, oldest first, up to five.
2. Swaps *ready* for *running*, then **re-reads the issue** — GitHub labels are not an
   atomic claim, so a concurrent run that also claimed it makes this one step back.
3. The AI coding agent implements the issue on a fresh branch, writes tests and runs them.
4. A fresh reviewer grades the diff P0, P1 or P2; serious findings are fixed first.
5. It opens the pull request, comments the link on the issue, and moves it to *in-review*.

**It never closes an issue.** Closing is your decision, after you merge.

## Set it up

In your terminal — one command, safe to paste as a whole:

```bash
claude plugin marketplace add samiraklf/claudrunner && claude plugin install claudrunner@claudrunner
```

Then, in Claude Code inside your repository:

```
/claudrunner:init
```

Pick **GitHub Issues** and **CI cron**. `init` writes two workflow files: the fast loop that
works issues, and the slow loop that sweeps for bugs. Add one secret, `ANTHROPIC_API_KEY`, for the
agent, commit the workflows, and it runs on the schedule you chose — every 10 minutes by default.

Runs never overlap: the workflow uses a concurrency group, so a slow run is never joined by
a second one in the same tree.

## Keep the repository safe

For a public repository, three settings matter more than anything the agent does:

1. **Protect the default branch** — require a pull request, block force-push and deletion.
   claudrunner never pushes there anyway; this protects you from everyone else.
2. **Require approval for workflows from forks**, so a stranger's pull request cannot read
   your secrets.
3. **Give the run token the narrowest scope** that works.

More in the [security model](../security.md).

## Next

- [AI code review before every PR](ai-code-review.md)
- [Scheduling](../scheduling.md) — choose how often it polls
