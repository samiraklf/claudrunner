# Host: github

Default. Covers github.com and GitHub Enterprise Server.

| Verb | Command |
|---|---|
| push | `git push -u origin <branch>` |
| propose | `gh pr create --base <base> --title <title> --body <body>` |
| link | The URL `gh pr create` prints |

## Without `gh`

A cloud routine has git but no `gh`, and installing tools there is refused. Push the branch
as usual, then open the pull request with the session's own GitHub pull-request tool if it
has one. If it has none, do not try to install one: use the compare link
`https://github.com/<owner>/<repo>/compare/<base>...<branch>?expand=1` as the pull-request
link — one click opens the pull request with your title and body pasted from the summary.

## Notes

- `gh` authenticates from `GH_TOKEN`. In CI the job's own token is usually enough, and it
  needs `contents: write` and `pull-requests: write`.
- Enterprise Server works once `GH_HOST` is set.
- Never pass `--fill`. The pull-request body is written deliberately, by the `ship` skill.

## Auto-merge (`policy.merge: auto`)

`.github/workflows/claudrunner-automerge.yml` merges the pull request, not the crew. `init`
installs it from `templates/github-actions/claudrunner-automerge.yml`. It merges a pull request
from a `claudrunner/` branch once CI passed on its last commit, and never one that is held,
changes a workflow, matches `policy.hold_paths`, or conflicts with the base branch. Setting
`policy.merge: review` on the base branch stops it at once.

Nothing to do when you open the pull request: the workflow finds it.

**Hold:** add the label `claudrunner:hold` (`gh pr edit <n> --add-label claudrunner:hold`, or
the session's GitHub tool). Without either, say "held" in the first line of the pull request
body and in the item comment, so the owner adds the label; the workflow reads only the label.
