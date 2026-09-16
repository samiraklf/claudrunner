---
name: card-format
description: "House format for a finding card or issue: problem, evidence, impact, fix, effort, dependencies, source. Use when filing any bug, finding, ticket or issue."
---

# Card format

A card is read by someone who was not there. It must carry everything needed to act, and
nothing that needs a follow-up question.

## Title

`[area] what is wrong, in one line, in plain words`

State the defect, not the task. "Daily files are buffered whole in memory instead of
streamed" beats "Improve file handling".

## Body — seven sections, always in this order

**Problem** — the mechanism. Why does this happen, not what the symptom looks like.

**Evidence** — file paths with line numbers, and the code quoted. Where a claim rests on
configuration, schema, or a dependency's source, quote that too. A reader must be able to
verify every claim without searching.

**Impact** — who is hurt, how, and how much. Quantify wherever the data can be queried.
An unquantified impact gets deprioritized forever.

**Proposed fix** — the actual change, concretely, plus the test that would prove it.

**Effort / Risk** — S, M or L, and what could break.

**Dependencies** — which other card must land first, or "safe to fix independently".

**Source** — which pass produced it, when, and what it could not check. A read-only review
that took no measurements must say so.

## Labels

Four axes, all of them:

1. **Severity** — Critical, High, Medium, Low.
2. **Kind** — bug, security, performance, correctness, scalability, tech-debt, test-gap,
   maintainability.
3. **Origin** — machine-filed, or needs-human.
4. **Target** — which repository or component, when the board covers more than one.

## The rule that keeps it honest

Write the card so that the fix can be verified from the card's own evidence. If a reader
must trust you rather than check you, the card is not finished.
