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
