# Scheduling

Two loops, two different rhythms.

## The fast loop

Polls the ready queue. Its job is to make picking up work feel immediate.

Ten minutes is the default. The right interval is a function of how often work appears on
your board, not how fast you want it to feel — a poll that finds nothing still costs a
little. On a quiet board, thirty minutes is honest. A busy team can justify five.

Whatever the interval, **runs must never overlap**. Every template enforces this: a
concurrency group in CI, `flock` in cron and systemd. Two agents in one working tree
corrupt each other's work.

## The slow loop

Sweeps the codebase and files findings.

Nightly suits an active codebase where the surface changes daily. Weekly suits a stable
one, and produces a better board: a week of changes gives the sweep more to correlate and
fewer near-duplicates.

Schedule it at a working hour rather than the middle of the night. A failure at 07:00 gets
read at 07:05. A failure at 02:00 gets discovered on Thursday.

## Choosing a target

**CI cron** is the default because the runner already exists and is thrown away after every
job. No machine to maintain, no isolation to configure.

Two caveats. Scheduled workflows on a busy host are queued, not exact — a ten-minute
schedule may fire at twelve. And some hosts disable scheduled workflows on repositories
with no recent activity.

**Cron on your own machine** is the simplest thing that works, if you already leave a
machine running. It must clean the working tree before every run.

**systemd** earns its complexity at several repositories or several lanes: one lane per
repository, a lock per lane, a timeout per lane, and teardown that still runs when a lane
is killed.

## The failure that will bite you

A run killed by its timeout leaves uncommitted changes in the working tree. The next run's
branch checkout aborts, and every later run fails the same way — silently, because nobody
reads a log for a job that appears to have run.

Every template resets the tree before it starts. Keep that, whatever else you change.
