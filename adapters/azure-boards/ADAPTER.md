# Adapter: Azure Boards

For teams on Azure DevOps. Work items are the queue; the queue role is a **State** on the
work item's board.

Status: documented, agent-side. The shell orchestrator has no binding for it yet, so runs
are driven from the agent rather than from `claudrunner-run.sh`.

## Queue mapping

| Queue | Typical state |
|---|---|
| ready | Approved, or Committed |
| claimed | Active |
| review | Resolved |
| parked | New, with a blocked tag |

States are per process template — Agile, Scrum and CMMI all differ, and teams customise
them. Read the project's real states at init and store their names in the config. Never
assume "Active" exists.

## Verbs

| Verb | How |
|---|---|
| fetch | WIQL query: work items in the ready state, in this area path, ordered by priority |
| claim | Set `System.AssignedTo` to the runner identity, then set state to the claimed state |
| comment | Add to the work item's discussion (`System.History`) |
| move | Patch `System.State` |

The `az boards` CLI covers all four, and is usually easier than raw REST inside a run.

## Notes

- **Claiming is atomic enough**, because assignment and state change in one patch. Read the
  item back anyway, and confirm the assignee is the runner.
- **Area path is the routing key** when one project feeds several repositories. It plays the
  role a repository label plays on other boards. Set it in the config, and park any item
  that matches more than one lane.
- Priority is numeric and inverted: **1 is highest**. Do not sort ascending by accident.
- Azure DevOps hosts its own git and pull requests. The crew's git flow works there, but the
  pull-request step is written for GitHub. Until that is generalised, use this adapter with a
  repository hosted on GitHub, or set `policy.autonomy` to `suggest` or `push`.
