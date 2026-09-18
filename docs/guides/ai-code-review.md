---
title: AI code review before every pull request
description: "Adversarial AI code review on every change: a fresh reviewer attacks the diff, grades findings P0/P1/P2, and serious ones are fixed before the PR opens."
lead: The model that wrote a change is the worst judge of it — it already decided every questionable line was fine. claudrunner hands every diff to a fresh, hostile reviewer before a pull request opens.
---

## Why a fresh reviewer

Asking the same session to review its own work produces a clean bill of health almost every
time. The reviewer in claudrunner is a **separate agent with no memory of writing the code**.
It receives the **raw diff** — never a summary, because a summary carries the author's own
framing, which is exactly what a review exists to escape.

Its job is to find what passing tests cannot: race conditions, a comparison that fires when
nothing changed, a new status its consumers never handle, a query that grows with your
data, a contract a client still depends on.

## How findings are graded

| Grade | Meaning | What happens |
|---|---|---|
| **P0** | Fatal at runtime: a crash, corrupted data, exposed data | Fixed before the pull request opens. If it cannot be fixed with confidence, that change is reverted and parked as `failed-review` |
| **P1** | Wrong behaviour under realistic conditions — silent, which is worse | Fixed before the pull request opens, and the affected tests re-run |
| **P2** | Minor | Listed in the pull request under *Known minor findings*, not fixed |

Every finding needs a file, a line range, a one-sentence failure mode and a concrete
reproduction. Anything without code evidence is not reported, and "no findings" is a valid
answer — it never manufactures concerns.

## A second opinion from another vendor

Optionally, a **read-only command-line tool from a different model vendor** reviews the same
diff in parallel. Two vendors disagreeing is a much stronger signal than one model checking
itself. If that tool fails, the run records the real error and carries on with the main
reviewer — it never invents the missing review.

```yaml
review:
  second_vendor:
    enabled: true
    command: "your-other-cli --read-only"
```

## It gets better at your codebase

When the reviewer catches a failure mode that will recur, it is written into
`.claudrunner/gotchas.md` with the evidence. Every future review reads that file first. Over
a few weeks the reviewer becomes specifically good at *your* repository's traps.

## Use it on your own work too

The review is a skill you can call from any Claude Code session, not only inside scheduled
runs. Say *"review before PR"* or *"is this ready?"* and it reviews your branch the same way.

## Next

- [How a run works](../how-a-run-works.md) — where the review sits in a run.
- [Nightly AI security scan](ai-security-scan.md)
