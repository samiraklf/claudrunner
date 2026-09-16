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

## Rules

- **Evidence or it is not filed.** Every finding names a file, a line range, and quotes the
  code. Quantify the impact wherever the data can be queried.
- **Check it is not already fixed.** Read the current code, not the last report.
- **Search the board before filing.** Never file a duplicate.
- **One finding per card.** A card bundling four problems cannot be closed.
- Write every card with the `card-format` skill. Cap the run at `loops.slow.max_new_cards`;
  if you find more, file the most severe and say how many you held back.

Finish by reporting counts by severity, what you held back, and the three you would fix first.
