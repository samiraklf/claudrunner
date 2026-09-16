---
name: verify-finding
description: "Verify a reported finding against the real code, then move its card to the state the evidence justifies. Triggers: is this still an issue, verify these findings, triage the board."
---

# Verify a finding

A card is somebody's belief at the time they wrote it. It can be stale, wrong about the
mechanism, or right. Treat every card as a hypothesis.

## The rule that matters

**Verify from the code. Never from the card.**

Findings are wrong more often than people expect, in both directions. A confident
"Critical" can rest on how a dependency behaved two major versions ago. A "theoretical,
cannot happen in practice" can be happening right now, in the data, at scale.

The failure mode in both directions is identical: believing prose instead of checking.

## Verdicts, and what each one costs to claim

| Verdict | Required evidence |
|---|---|
| **Fixed** | The corrected code is on the branch **and you have read it**. A commit message claiming the fix is not evidence — commit messages lie by accident. Where a regression test exists, confirm it fails against the old code. |
| **Still real** | You reproduced it. The line is present and the conditions hold. Name the concrete trigger. |
| **False positive** | You disproved the **mechanism**, not the conclusion. Quote the schema, the config value, or the dependency's own source, with a file and line. "I could not reproduce it" is not a disproof. |
| **Partly done** | Name exactly which half is done and which is not. Never round up to fixed. |

Quantify whenever the data can be queried.

## Order of checking

Cheap checks first. Schema and configuration before query plans. History before reading
whole files. A finding is often answered by a single schema line.

## Then move the card

1. Read the board's real shape first. Never hardcode queue names — match by meaning.
2. **Report the classification to the user before writing anything**, especially for
   anything headed to won't-fix. Closing a Critical on one agent's reading is a big call.
3. Move, then label.

- **Fixed** → the done queue, with the evidence.
- **False positive** → the won't-fix queue. Leaving a disproven finding in the intake queue
  is not neutral: someone will eventually implement its suggested fix.
- **Still real, unstarted** → leave it. Moving it would imply something happened.
- **Partly done** → the in-progress queue, with what remains.
