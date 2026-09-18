---
title: claudrunner compared with other ways to run an AI coding agent
description: "claudrunner compared with running an AI coding agent by hand, in one CI workflow, or as a hosted service: tickets, review, safety and cost."
lead: There are several ways to put an AI coding agent to work on a repository. This page is an honest comparison, so you can pick the one that fits.
---

## At a glance

| | By hand in a terminal | One CI workflow per event | Hosted coding agent | **claudrunner** |
|---|---|---|---|---|
| Picks up tickets by itself | ❌ | Only the event it is wired to | Usually, from its own queue | ✅ From 11 task boards |
| Hunts bugs you did not report | ❌ | ❌ | Varies | ✅ Scheduled sweep with evidence |
| Independent review of every diff | If you ask | ❌ | Varies | ✅ Fresh reviewer, P0/P1/P2, optional second vendor |
| Regression test required for fixes | If you ask | ❌ | Varies | ✅ Always |
| Agent holds your credentials | Yes, your session | Often | Yes | ❌ Never — an orchestrator holds them |
| Can reach your default branch | Yes | Depends on the token | Varies | ❌ Never, at any autonomy level |
| Stops to ask mid-task | Yes | Fails instead | Varies | ❌ Parks the ticket with one question |
| Where it runs | Your laptop | Your CI | Their cloud | Your CI, your server, or your laptop |
| Price | Your subscription | Your subscription or API usage | A monthly fee | Free and MIT licensed; your own usage |

## By hand, in a terminal

The most flexible option and the best for exploratory work. It needs you there: you start
each task, answer its questions and review the result yourself. claudrunner uses exactly the
same agent, but gives it a queue, a schedule, a reviewer and a set of rules, so the routine
work arrives without you.

## One CI workflow per event

A workflow that runs an agent when someone comments on an issue is simple and useful. It
reacts to one event, though, and each workflow re-invents the rules: which branch, which
tests, when to stop. claudrunner is one install with a shared set of rules, and adds the
parts a single workflow lacks — claiming so two runs never collide, an independent review,
parking instead of failing, and a sweep that finds work nobody reported.

## Hosted coding agents

Hosted agents are convenient and need no setup. They run in someone else's cloud, usually
hold your repository and board credentials, and cost a monthly fee per seat. claudrunner runs
where you choose, keeps credentials out of the agent entirely, and costs nothing beyond your
own model usage.

## When claudrunner is not the right tool

- **One-off, exploratory work.** Use the agent by hand.
- **Windows-only build machines.** The orchestrator is POSIX shell and untested on Windows.
- **Gitea, Forgejo or Bitbucket Data Center.** Not supported yet.

## Next

- [Getting started](../getting-started.md)
- [Security model](../security.md)
