---
title: Linear issues to pull requests with an AI coding agent
description: "Automate Linear with an AI coding agent: issues in your ready state come back In Review with a tested, reviewed pull request attached."
lead: Move a Linear issue to Todo, and it comes back In Review with a pull request attached. This guide connects claudrunner to a Linear team.
---

## How it maps to Linear

Queues are **workflow states**. `init` resolves your team's states once and stores their ids:

| Role | Typical state |
|---|---|
| Ready | Todo, or a triage-complete state |
| Claimed | In Progress |
| Review | In Review |
| Parked | Blocked |

Claiming is atomic: claudrunner sets the assignee and the state in one update, so two runs
cannot take the same issue.

## Priority and sub-issues

- Linear priority is numeric and **1 is urgent** — claudrunner sorts it the right way round.
- **Sub-issues inherit context from their parent.** The agent reads the parent before judging
  whether the work fits in one safe pass.

## Set it up

```
/plugin marketplace add samiraklf/claudrunner
/plugin install claudrunner
/claudrunner:init
```

Choose **Linear**, confirm the state mapping, and add one secret:

| Variable | Value |
|---|---|
| `LINEAR_API_KEY` | A personal API key from Linear settings, ideally for a runner account |

As with every board, the key lives in the orchestrator's environment — the AI agent never
receives it.

## What arrives

A pull request with a five-part description, tests that ran, and the review findings listed.
The Linear issue moves to In Review with the link. Anything unclear goes to Blocked with one
question in a comment, so your team answers it in Linear, where they already are.

## Next

- [Nightly AI security scan](ai-security-scan.md) — findings land as Linear issues too.
- [How a run works](../how-a-run-works.md)
