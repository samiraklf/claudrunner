---
description: Run one cycle of the slow loop — sweep the codebase for findings and file them as cards.
argument-hint: "[security|scale|correctness|tests|all]"
---

# claudrunner — sweep

Find what is wrong before a user does. File each finding as a card the crew can pick up.

Default scope is `all`. With an argument, run only that pass.

## Passes

1. **correctness** — logic that is wrong under realistic conditions: comparisons that fire
   when nothing changed, state machines with no exit, enum cases with unhandled consumers,
   contract drift between a producer and its consumers.
2. **security** — the `security-sweep` skill. Injection, authorization gaps, tenant
   isolation, mass assignment, secrets in source, unsafe deserialization, request forgery,
   unescaped output.
3. **scale** — the `scale-sweep` skill. Queries in loops, unbounded reads, missing indexes,
   whole files buffered in memory, retry and timeout traps in background work.
4. **tests** — behavior that would ship broken silently: untested calculations, untested
   money or billing paths, untested authorization.

## Rules

- **Evidence or it does not get filed.** Every finding names a file, a line range, and
  quotes the code. A finding you cannot anchor in the repository is not a finding.
- **Quantify the impact.** "475 rows carrying 46,000 records and zero totals" tells a
  reader how much it matters. "The counts diverge" does not.
- **Check whether it is already fixed** before filing. Read the current code, not the last
  report.
- **Never file a duplicate.** Search the board first.
- **One finding per card.** A card that bundles four problems cannot be closed.

Use the `card-format` skill for every card you write. Cap a single sweep at fifteen new
cards; if you find more, file the highest-severity fifteen and say how many you held back.

## Output

File the cards, then report to the user: counts by severity, what you held back, and the
three findings you would fix first.
