---
title: Turn Trello cards into pull requests with an AI coding agent
description: "Automate your Trello board with an AI coding agent: cards in your ready list come back in review with a tested, reviewed pull request."
lead: Drag a card into your ready list, and a pull request comes back with the card moved to review. This guide connects claudrunner to a Trello board.
---

## How it uses your board

Trello queues are **lists**. `init` reads your board and maps lists by meaning, not by name,
because people rename lists:

| Role | Typical list |
|---|---|
| Ready | "To do", "Ready", "Triage" |
| Review | "In review", "PR open" |
| Parked | "Needs input", "Blocked" |
| Filed by the bug sweep | "Inbox", "Intake" |

On each run claudrunner fetches cards from the ready list, adds a *running* label to claim
them, and **re-reads each card to make sure no other run claimed it at the same moment** —
Trello has no atomic claim, so the re-read is what stops two runs from building the same card.

Then the AI coding agent implements the card, writes and runs tests, and a fresh reviewer
attacks the diff before the pull request opens. The card moves to your review list with the
pull request link in a comment. A card it cannot finish goes to your parked list with a note
saying exactly why.

## Set it up

In your terminal — one command, safe to paste as a whole:

```bash
claude plugin marketplace add samiraklf/claudrunner && claude plugin install claudrunner@claudrunner
```

Then, in Claude Code inside your repository:

```
/claudrunner:init
```

Choose **Trello**. `init` proposes the list mapping and stores the list ids.

Credentials, as CI secrets or environment variables — never in the config file:

| Variable | Where to get it |
|---|---|
| `TRELLO_API_KEY` | trello.com/power-ups/admin, your Power-Up's API key |
| `TRELLO_TOKEN` | The token generated for that key |

The shell orchestrator uses them; the AI agent never sees them.

Try a single card with `/claudrunner:triage`, read the pull request, then turn on the
schedule `init` printed.

## One board, several repositories

A Trello board often feeds more than one codebase. Give each repository its own label and its
own claudrunner install. A card carrying **two** repository labels would be built twice, so
claudrunner parks it with an explanation instead of guessing.

## Labels carry meaning

Severity and kind are read from your labels, never guessed from the wording. The bug sweep
files its findings with the same labels, so they sort the way the rest of your board does.

## Next

- [Nightly AI security scan](ai-security-scan.md) — let it fill the intake list with real bugs.
- [Configuration reference](../configuration.md) — every Trello setting.
