---
name: vk-review
description: "Adversarial review before a change ships: a fresh reviewer, an optional second vendor, findings graded P0/P1/P2. Use before every pull request and before calling work done, especially when the tests pass. Triggers: is it ready, ready to open a PR, the tests pass, done, looks good, double-check this, review before PR."
---

# The review pass

You cannot review your own work in the session that wrote it. You already decided every
questionable line was fine. The reviewer must be a fresh context, and it must be hostile.

## Step 1 — Collect the whole change

```
git diff <base>...HEAD      # everything committed on this branch
git diff HEAD               # staged and unstaged
git status --short          # untracked files — read each one
```

An empty working-tree diff does not mean there is nothing to review. If the branch is
ahead of base, *those commits are the change set*. Reviewing an empty diff produces a
false clean bill of health.

## Step 2 — Send it out

Spawn the `inspector` agent, in the foreground, with the **raw diff**, and wait for its report. Never a summary — a summary carries your
own framing, which is exactly what the review exists to escape.

Where a second vendor's CLI is configured and available, start it first, read-only, on the
same diff, and let it run while the inspector works. Two vendors disagreeing is a far
stronger signal than one model checking itself. If that command errors or returns nothing,
proceed on the inspector alone and record the actual error. Never invent its findings, and
never report it unavailable without having run it.

## Step 3 — Grade

Every finding is one of:

- **P0** — fatal at runtime. It will crash, corrupt data, or expose something.
- **P1** — wrong behavior under realistic conditions. Silent, which is worse.
- **P2** — minor. Will not block shipping.

A finding needs a file, a line range, a one-sentence failure mode, and a concrete
reproduction. Anything without code evidence is not reported.

## Step 4 — Act

- **P0 and P1** — fix now, then commit as `fix: <finding> (review)`. If the fix touches
  background jobs, schema or a public contract, re-run the affected tests.
- **P2** — do not fix. List them in the pull request under "Known minor findings".
- **A P0 you cannot fix confidently** — revert that item's commits, mark it
  `failed-review`, and carry on with the rest.
- **Nothing found** — say "review: no findings" and proceed. Do not manufacture concerns.

Return the reviewer's output as written. Do not soften it.

## Step 5 — Feed the catalog

`.claudrunner/gotchas.md` is this repository's institutional memory. When a review catches
a failure mode that will recur, add it there with the evidence. Every future review reads
it first. This is how the crew gets smarter about *your* codebase specifically.
