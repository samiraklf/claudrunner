# Host: github

Default. Covers github.com and GitHub Enterprise Server.

| Verb | Command |
|---|---|
| push | `git push -u origin <branch>` |
| propose | `gh pr create --base <base> --title <title> --body <body>` |
| link | The URL `gh pr create` prints |

## Notes

- `gh` authenticates from `GH_TOKEN`. In CI the job's own token is usually enough, and it
  needs `contents: write` and `pull-requests: write`.
- Enterprise Server works once `GH_HOST` is set.
- Never pass `--fill`. The pull-request body is written deliberately, by the `ship` skill.
