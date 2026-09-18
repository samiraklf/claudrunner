# Getting started

## 1 — Install

```
/plugin marketplace add samiraklf/claudrunner
/plugin install claudrunner
```

## 2 — Set it up in a repository

```
/claudrunner:init
```

It reads the project, proposes the commands it found, and asks what it cannot infer. It
writes `.claudrunner/config.yml` and a schedule file. It starts nothing.

## 3 — Try one cycle by hand

Before you schedule anything, run a cycle yourself and watch what it does:

```
/claudrunner:sweep security
```

This files findings. Read three of them. If the evidence is good and the severities look
right, the sweep is calibrated for your codebase. If they are noisy, add what it got wrong
to `.claudrunner/gotchas.md` and run it again — that file is read by every later pass.

Then put one item in the ready queue and run:

```
/claudrunner:triage
```

Read the pull request. That is exactly what will arrive while you sleep.

## 4 — Turn the schedule on

`init` printed the command. It is one of:

- for a Claude Code routine: merge the setup pull request, then open the two routine links
  `init` printed — they run on your Claude subscription, and you can pause or run them there
- commit the workflow files, for the CI target
- add two lines to a crontab
- `systemctl enable --now` two timers

## 5 — The first week

Keep `autonomy` at `pr-only` and read every pull request. You are calibrating, not
delegating yet. Three things to watch:

1. **Items parked as `unclear`.** If many are parked, your items are underspecified. That
   is useful information about your board, not a failure of the crew.
2. **Findings marked `not-needed`.** Read the evidence. A wrong refusal means the sweep
   needs a note in `.claudrunner/notes.md` about how your project actually works.
3. **Review findings.** If the same class appears twice, put it in the gotchas file. It
   will never get through again.

## What to do when it gets something wrong

Do not correct it in a chat message; that lasts one session. Write the correction into
`.claudrunner/notes.md` or `.claudrunner/gotchas.md`. Those files are read on every run,
so a correction written once holds forever.
