# How a run works

One triage cycle, in order. The split between what the orchestrator does and what the agent
does is the whole safety model, so it is worth reading once.

## 1 — Fetch (orchestrator)

The adapter returns up to five ready items. The agent is not involved and never sees the
board credential.

## 2 — Claim (orchestrator)

Each item is marked as taken, then **re-read to confirm the claim is uncontested**. Few
boards offer an atomic claim. Without the re-read, two runs can take the same item and open
two conflicting pull requests. A contested item is released and left for next time.

Items that could not be claimed are dropped from the input file. If none survive, the run
exits.

## 3 — Prepare the tree (orchestrator)

Fetch with prune. Verify the configured base branch still exists — it is explicit,
because many projects integrate on a branch that is not the repository default.

Then **reset hard and clean**, before every run. A run killed at its timeout leaves
uncommitted work behind; that aborts the next checkout and silently kills every later run.
The symptom is a schedule that appears to fire and never does anything.

Finally, branch from the base.

## 4 — Work (agent)

The agent gets the working tree, the task, and a tool allowlist. It selects from the input,
implements, writes tests, runs them, and commits. It renames the branch after the primary
item so the pull request reads as its content.

It cannot push unless the autonomy level allows it, and it can never push to the base
branch.

## 5 — Review (agent)

The finished diff goes to a fresh reviewer with no memory of writing it, and optionally to a
second reviewer from another model vendor. P0 and P1 findings are fixed, and the affected
tests re-run. A P0 that cannot be fixed with confidence reverts that item.

## 6 — Ship (agent)

Format, push, open the pull request with the five-section body, then emit one fenced JSON
block: what was done, what was skipped and why, the pull request link, the review counts,
and the test result.

## 7 — Move the items (orchestrator)

The summary block is parsed, and **every id is checked against this run's own input file**.
An id the agent did not receive is refused. That single check is what stops a confused or
manipulated agent from touching the rest of your board.

Done items go to review with the pull request link. Skipped items go to review when the
reason is "should not be built", and to the parked queue otherwise — always with the note.
An item that leaves with no disposition gets re-analyzed on every run, forever.

## It never waits for you

No step in this sequence asks a question. A run that stopped to ask would sit there until
somebody noticed, which on a ten-minute schedule means the next run starts behind a stalled
one.

Anything that needs a person leaves through the queue instead. The item is parked with the
question written into its note, the rest of the run continues, and the run finishes. You
answer when you open the board, not when the crew happens to need you.

The one exception is `/claudrunner:init`, which is a conversation on purpose — you are
setting it up, so you are already there.

## When it fails

A failed agent run leaves the items **claimed**, on purpose. A human opening the board sees
exactly what was in flight. The run record is kept under `.claudrunner/runs/`, and the CI
target uploads it as an artifact.
