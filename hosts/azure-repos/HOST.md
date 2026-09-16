# Host: azure-repos

Azure DevOps. The change is a pull request, and this host pairs naturally with the
`azure-boards` adapter — most teams keep both in the same project.

| Verb | Command |
|---|---|
| push | `git push -u origin <branch>` |
| propose | `az repos pr create --target-branch <base> --title <title> --description <body>` |
| link | The `url` field in the JSON the command returns |

## Notes

- `az` authenticates from `AZURE_DEVOPS_EXT_PAT`. The token needs Code (read and write) and,
  when the crew links work items, Work Items (read and write).
- `--work-items <id>` links the pull request to its work item. Use it: the link is what makes
  the board and the repository tell the same story, and it removes a separate comment call.
- Branch policies can require a linked work item or a minimum reviewer count. A pull request
  that violates one is created but not completable — which is fine, since the crew never
  merges, but say it in the body so the human is not confused.
- Organisation and project come from the config, never from the current `az` defaults, which
  are per machine and will differ on a runner.
