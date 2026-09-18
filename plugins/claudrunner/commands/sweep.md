---
description: Run one slow-loop sweep — hunt the codebase for defects and file them as cards.
argument-hint: "[security|scale|correctness|tests|all]"
---

# claudrunner — sweep

Find what is wrong before a user does. Default scope is `all`.

| Scope | Skill that owns it |
|---|---|
| `security` | `security-sweep` |
| `scale` | `scale-sweep` |
| `correctness` | this file, below |
| `tests` | this file, below |

**correctness** — logic that is wrong under realistic conditions: comparisons that fire when
nothing changed, records left in a state nothing can move forward, new enum cases whose
consumers were never updated, and drift between a producer and its consumers.

**tests** — behavior that would ship broken in silence: untested calculations, untested money
or billing paths, untested authorization.

## When you run it yourself

In a Claude Code routine or by hand there is no orchestrator. A sweep reads code, so it needs
no setup: skip `stack.commands.setup` unless a finding can only be proven by running
something, and then set up only that part, as one step. Never repair the environment yourself. File findings through the board as `board.via` says: the shell
adapter (`board.via: api`), or the board's claude.ai connector on `board.connector.board`
(`board.via: connector`), into the list named by `board.queues.filed`.

## Never pause

Nobody is watching. Do not ask a question, do not wait for confirmation, and do not stop
half-finished. Anything that needs a person is parked on the human queue with the question
in its note, and the run carries on and finishes.

## Rules

- **Evidence or it is not filed.** Every finding names a file, a line range, and quotes the
  code. Quantify the impact wherever the data can be queried.
- **Check it is not already fixed.** Read the current code, not the last report.
- **Search the board before filing.** Never file a duplicate.
- **One finding per card.** A card bundling four problems cannot be closed.
- Write every card with the `card-format` skill. Cap the run at `loops.slow.max_new_cards`;
  if you find more, file the most severe and say how many you held back.

Finish by reporting counts by severity, what you held back, and the three you would fix first.
