# Host: gitlab

GitLab.com and self-managed. The change is a **merge request**, and the vocabulary differs
enough to matter in anything the crew writes.

| Verb | Command |
|---|---|
| push | `git push -u origin <branch>` |
| propose | `glab mr create --target-branch <base> --title <title> --description <body>` |
| link | The URL `glab mr create` prints |

Without `glab`, push options do the same thing in one step:

```
git push -o merge_request.create -o merge_request.target=<base> -o merge_request.title=<title>
```

## Notes

- `glab` authenticates from `GITLAB_TOKEN`, and `GITLAB_HOST` points it at a self-managed
  instance.
- A project may require the source branch to be deleted on merge, or squash commits. Neither
  affects the crew, but say so in the merge-request body if the project expects it.
- GitLab **Issues** are a natural board here. Pair this host with the `gitlab-issues` adapter
  and one credential covers both.

## Auto-merge (`policy.merge: auto`)

GitLab merges when the pipeline succeeds. Turn it on as you propose:
`glab mr merge <id> --auto-merge --squash --remove-source-branch`, or add the push option
`-o merge_request.merge_when_pipeline_succeeds`.

**Hold:** do not turn it on. Say "held" and the reason in the description.
