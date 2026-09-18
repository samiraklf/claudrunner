# Adapter: GitHub Issues

The default. Needs no account beyond the one hosting the repository, and the token the CI
run already has.

## Queue mapping

Queues are labels. `init` proposes these names and the user may change them:

| Queue | Default label |
|---|---|
| ready | `claudrunner:ready` |
| claimed | `claudrunner:running` |
| review | `claudrunner:in-review` |
| parked | `claudrunner:needs-input` |
| filed by sweep | `claudrunner:finding` |

## Verbs

```bash
# fetch — ready, not already claimed, oldest first
gh issue list --label "claudrunner:ready" --state open --limit 5 \
  --json number,title,body,url,labels

# claim — add running, remove ready. Re-read before working: a concurrent run may have won.
gh issue edit <n> --add-label "claudrunner:running" --remove-label "claudrunner:ready"

# comment
gh issue comment <n> --body "<note>"

# move
gh issue edit <n> --add-label "<destination>" --remove-label "claudrunner:running"
```

## Notes

- **Claiming is not atomic here.** After claiming, re-read the issue and confirm your label
  is the only claim present. If another run also claimed it, drop yours and move on.
- Priority comes from labels (`Critical`, `High`, `Medium`, `Low`) or from the issue's
  project field if the repository uses one.
- Closing is a human decision. Move to `in-review`; never close an issue yourself.
