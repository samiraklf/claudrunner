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

**A Claude Code routine** is the first choice when you use Claude Code with a subscription.
It runs in Anthropic's cloud on that subscription — no API key, no server to keep on, no CI
minutes — and you can see, edit, pause or run it on claude.ai. `/claudrunner:init` creates
the routines and prints their links. Three things differ from the other targets:

- **One hour is the shortest interval.** For most boards that is plenty.
- **A routine cannot install plugins**, so `init` installs the crew into the repository's
  own `.claude/` and `.claudrunner/`, and commits it. Keep those folders out of `.gitignore`:
  a routine only sees what is on the base branch.
- **It starts from a bare checkout.** Put what the tests need in `stack.commands.setup`.


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

## Where the tests run

A run tests a change only when it is about to open a pull request, and only the parts the
change touched (`verify.mode: auto`). What that costs depends on the machine, so
`/claudrunner:init` recommends a setup for each one. `.claudrunner/setup.sh [part]` is always
the single entry point.

| Where the crew runs | What `init` sets up | Recommended `verify.mode` |
|---|---|---|
| Claude Code routine | A cloud environment of its own, with a setup script that installs what the image lacks and fills the package caches. The environment keeps the result for about seven days, so runs start with it on disk. `setup.sh` only starts the services. | `auto` |
| GitHub Actions | Services in the workflow's `services:` block, dependencies from the setup action's cache. | `here` |
| Cron or systemd on your machine | The machine is prepared once, with a separate test database. `setup.sh` reinstalls only when a lock file changed. | `here` |
| By hand | Your own development environment, as it is. | `here` |

**In a Claude Code environment:**

- The image already has PostgreSQL 16, Redis 7, Docker, `gh`, `jq` and `yq`, and the common
  language toolchains. The setup script installs only what is missing.
- Running processes are not kept between runs. Services start in `setup.sh`, and only when a
  change is tested.
- Everyone who uses an environment can read its variables. Never put a secret there. Use the
  board's connector, or, on Pro and Max plans, the environment's API credentials, which the
  session never sees.
- The setup script must finish in under five minutes and always exit 0.

**Docker.** On your own machine, a laptop or GitHub Actions, Docker makes things easiest:
`init` reuses your `docker-compose.yml` for the services the tests need, so the crew tests
against the same versions as development. In a Claude Code environment, Docker works if the
images are pulled in the setup script, where the snapshot keeps them. Pulling during a run
fails often, because Docker Hub rate-limits the shared cloud addresses. There, prefer the
image's own PostgreSQL and Redis or an `apt-get` package, and use Docker only when a service
exists only as an image or its exact version matters.

## Create the cloud environment, step by step

For a routine, `/claudrunner:init` writes the setup script, copies it to your clipboard and
opens claude.ai/code. Creating the environment is the one step you do yourself: Claude Code has
no command or API that creates one.

1. At claude.ai/code, find the small button **just above the message box**, left of **Select
   repository…**. It has a cloud icon and shows your current environment's name, often
   **Default**. There is no "Environments" page in the sidebar; this button is the only way in.
2. In the menu (**Local**, **Cloud**, **Remote Control**), point at **Cloud** and click **Add cloud
   environment…**.
3. Name it `claudrunner-<your project>`. Leave **Network access** on **Trusted** and
   **Environment variables** empty.
4. Paste the setup script into **Setup script**, then click **Add environment**.
5. Back in the terminal, type `/remote-env` and pick the new environment. `init` reads its id
   from there, then puts your previous default back.

Not seeing the button? Finish the first-time setup of Claude Code on the web once, following the
prompts on claude.ai/code, and look again.

## Installed only what it uses

When the crew is installed into a repository, it copies only what the configuration uses:
the one board binding (none with a connector), the sweep only when the slow loop is on, and a
sweep skill only for a scope it runs. `.claudrunner/installed.txt` lists the files, and a
later `init` removes those the configuration no longer needs. Files you wrote yourself are
never touched.

## The failure that will bite you

A run killed by its timeout leaves uncommitted changes in the working tree. The next run's
branch checkout aborts, and every later run fails the same way — silently, because nobody
reads a log for a job that appears to have run.

Every template resets the tree before it starts. Keep that, whatever else you change.
