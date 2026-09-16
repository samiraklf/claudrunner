---
description: Set up claudrunner in this repository — detect the stack, wire a task board, choose a schedule, write the config.
argument-hint: "[--non-interactive]"
---

# claudrunner — init

Set this repository up. Detect what you can. Ask only what you cannot infer.

## Rules for this command

This is the **only** command that asks questions. The user is here, setting things up. Every
other command runs unattended and parks what it cannot decide.

- Never guess a command you have not seen in the repository. Propose, then confirm.
- Write nothing outside `.claudrunner/`, `.github/workflows/`, and the schedule files the
  user approves.
- Nothing is scheduled or enabled by this command. It writes files and prints the final
  step for the user to run themselves.

## Step 1 — Detect the stack

Look for, in this order: `package.json`, `pyproject.toml` or `requirements.txt`,
`*.csproj` or `*.sln`, `pom.xml` or `build.gradle*`, `go.mod`, `composer.json`,
`Cargo.toml`, `Gemfile`, `mix.exs`.

More than one match means a polyrepo or a monorepo. Ask which directory holds the code
this crew should work on, and whether other directories are read-only context.

Load the matching pack from `packs/<name>/pack.md` in this plugin. Read the project's own
scripts — `package.json` scripts, `Makefile`, `composer.json` scripts, `pyproject` tool
sections, CI workflow files — and prefer what the project already uses over the pack
default. The CI workflow is the most reliable source: it shows the commands that are known
to work.

Present what you found as a table, and ask for corrections:

| Purpose | Command | Source |
|---|---|---|
| test (all) | | |
| test (filtered) | | |
| lint | | |
| format | | |
| build | | |

An unknown stack uses `packs/generic/pack.md` and asks the user for all five.

## Step 2 — Ask what cannot be inferred

Ask these as one grouped question where the interface allows it. Give the recommended
option first.

1. **Task board** — GitHub Issues (no extra account), Trello, Jira, Linear, or none.
   "None" is valid: the sweep still files findings as Markdown reports.
2. **Board mapping** — which queue holds work ready to be picked up, where a finished item
   goes, and where a blocked item goes. For GitHub Issues these are labels; for the others,
   lists or statuses. Never hardcode names: read the board and match by meaning.
3. **Cadence** — fast loop interval (default 10 minutes) and slow loop schedule
   (default nightly; weekly suits a stable codebase).
4. **Autonomy** — `suggest`, `pr-only` (default), or `push`.
5. **Where it runs** — this session only, CI cron (default), or a server with systemd.

## Step 3 — Confirm the guardrails

State these back and let the user change them:

- The base branch it targets, and confirmation that the default branch is protected.
- The diff ceiling per pull request (default 600 changed lines).
- Whether new dependencies are allowed (default: no).

## Step 4 — Write the files

1. `.claudrunner/config.yml` — the answers above. Follow `docs/configuration.md` exactly.
2. `.claudrunner/gotchas.md` — an empty catalog with its header. It grows from real
   incidents in this repository and is read by every review.
3. `.claudrunner/notes.md` — anything you learned about the project that a future run
   needs and cannot re-derive cheaply: scale-sensitive tables, slow test paths, areas that
   are deliberately unconventional.
4. The schedule file for the chosen target, from `templates/`.

## Step 5 — Hand over

Print, in this order:

1. The secrets the user must add, by name, and where to add them. Never print a value.
2. The one command that turns the schedule on.
3. The command to try one cycle by hand first: `/claudrunner:triage`.

Recommend the manual run before enabling any schedule, so the user sees what a cycle does
before it does it on a timer.
