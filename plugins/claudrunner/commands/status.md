---
description: Show the current claudrunner configuration, schedule and recent run history for this repository.
---

# claudrunner — status

Report the current state. Change nothing.

1. **Config** — read `.claudrunner/config.yml`. Show the stack commands, board, cadence,
   autonomy level and limits. Flag anything missing or self-contradictory.
2. **Schedule** — read the schedule file for the configured target. Report whether it is
   enabled, and when it last ran and next runs, if the target can tell you.
3. **Queue** — read the board's ready queue and report how many items are waiting, how
   many are claimed, and how many are parked for input.
4. **History** — read `.claudrunner/runs/` if it exists. Show the last five runs: when,
   what shipped, what was skipped and why.
5. **Health** — call out anything that needs attention: items parked for more than a week,
   a schedule that has not fired, repeated `failed-review` outcomes on one area.

Keep it to one screen.
