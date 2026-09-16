---
name: work-a-card
description: "Select, size and implement a board item unattended: size limits, batching, the seven skip reasons, commit format. Triggers: work the queue, take this card, work this card, implement this ticket, pick up this issue."
---

# Work a card

You are running unattended. There is no human to ask. An ambiguous decision takes the
conservative path and is recorded in the report, never guessed.

## Selection

Judge **priority** from the item's own labels or fields. Priority is urgency, not size.

Judge **size** yourself, from the item and the actual code:

- **S** — few files, no schema or background-job changes, obvious acceptance criteria.
- **M** — multiple files, tests to write or update, one subsystem.
- **L** — schema, queue, or contract changes; cross-cutting; or unclear acceptance criteria.

Take at most **one L, or two M, or three S**. Everything selected lands in one branch and
one pull request, so batch only when both hold:

1. **Anchored.** You have found each item's referenced code in *this* repository before
   selecting it. An item you cannot anchor runs alone at most.
2. **Same area.** The items touch one subsystem, so the pull request reads as one change.

Keep the total diff under the configured ceiling, 600 changed lines by default.

## Skipping

Seven reasons exist: `unclear`, `too-large`, `wrong-place`, `suspicious`, `failed-review`,
`not-needed`, `better-approach`. Two of them mean *this should not be built*, and using them
well is the highest-value thing you do.

Before skipping anything, read `references/skip-reasons.md` beside this file. It gives the
exact condition for each reason and what the note must contain — the note is posted to the
item and read by a human, so it has to answer them, not log at them.

## Implementation

For each selected item, in order:

1. Read enough surrounding code to match the conventions already in use. Match the
   neighbours, not your preferences.
2. Search before you write. Reuse what exists; extend what is close; create only then.
3. Implement the smallest change that resolves the item. No drive-by refactors.
4. Write or update tests wherever the repository tests similar code. **A fix without a
   regression test is not finished.** The test must fail against the old code.
5. Run the narrowest relevant tests with the configured test command. Fix what you broke.
   Note pre-existing failures; do not fix them.
6. Commit as `<type>: <summary>`, a blank line, then the item reference.

**Never claim tests pass without a run to show for it.**

## Attribution

Commit messages end at the item reference. Never add a co-author trailer, a session link,
or a "generated with" line — not to your commits, and not to a delegated agent's commits.

## Time

A killed run ships nothing. If the first item's test cycle is slow, finish that one alone
and ship it. Move to shipping no later than when testing has consumed half the budget.

## Escalation

If an item turns out to be genuinely hard — architecture spanning many files, subtle
concurrency or data-integrity work, or something you have already gotten wrong twice — do
not grind. Delegate to the `deep-work` agent with the item text, the file paths and every
constraint you have found. You still own the result: re-run the tests yourself and put its
diff through the same review as your own.
