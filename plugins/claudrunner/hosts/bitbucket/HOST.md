# Host: bitbucket

Bitbucket Cloud. The change is a pull request, but there is no first-party CLI worth
depending on, so the crew uses REST.

| Verb | How |
|---|---|
| push | `git push -u origin <branch>` |
| propose | `POST /2.0/repositories/{workspace}/{repo}/pullrequests` |
| link | `links.html.href` from the response |

The body of the create call needs `title`, `description`, `source.branch.name` and
`destination.branch.name`.

## Notes

- Authenticate with an app password or a workspace token, never an account password.
- Bitbucket Data Center (self-hosted) uses a different API. Treat it as a separate host.
- Default reviewers are applied by the project, not by the crew. Do not set reviewers
  yourself; a machine guessing at reviewers annoys people.

## Auto-merge

Not supported: Bitbucket Cloud has no merge-when-green. `validate-config.sh` rejects
`policy.merge: auto` for this host.
