# Adapter: GitLab Issues

Queues are labels, exactly as on GitHub. Pair it with the `gitlab` host and one credential
covers the board and the code.

| Verb | Command |
|---|---|
| fetch | `glab issue list --label <ready> --per-page 5 -F json` |
| claim | `glab issue update <id> --label <claimed> --unlabel <ready>` |
| comment | `glab issue note <id> --message <text>` |
| move | `glab issue update <id> --label <dest> --unlabel <claimed>` |

## Notes

- **Scoped labels** (`status::ready`, `status::doing`) are the idiomatic queue here, and they
  are mutually exclusive by design — GitLab removes the old one when you add a new one in the
  same scope. Prefer them: they make the move atomic and remove a whole class of bug.
- Claiming is not atomic with plain labels. Claim, re-read, and release if contested.
- Weight is often used for size. Read it, but judge size from the code anyway.

## Running it from the orchestrator

Shipped as `lib/board-gitlab-issues.sh`, installed into your repo at `.claudrunner/bin/`, so the shell fetches, claims and moves. The agent
never holds the board credential.

| | |
|---|---|
| Credentials | `GITLAB_TOKEN`, plus `GITLAB_HOST` for self-managed |
| Config | `board.settings.project` — the path or id, when the runner is not inside the repository |

Set `board.adapter: gitlab-issues` and map every queue role under `board.queues`.
`.claudrunner/bin/validate-config.sh` fails when a required setting is missing, so a half-configured
board is caught before the first scheduled run rather than at two in the morning.

