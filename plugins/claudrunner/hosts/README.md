# Code hosts

A host is where the branch is pushed and where the change is proposed for review. It is a
separate choice from your task board: plenty of teams keep code in one place and work items
in another.

The contract is three verbs:

| Verb | Contract |
|---|---|
| `push` | Push the working branch. Never the base branch, never forced |
| `propose` | Open the change for review and return its URL |
| `link` | Turn that URL into something the board adapter can post back |

Everything before `push` — branching, committing, reviewing — is plain git and identical
everywhere. Only these three verbs differ.

## Shipped

| Host | Change is called | CLI used |
|---|---|---|
| `github` | pull request | `gh` |
| `gitlab` | merge request | `glab` |
| `bitbucket` | pull request | REST |
| `azure-repos` | pull request | `az repos` |

Set it as `project.host` in `.claudrunner/config.yml`. See `docs/writing-a-host.md`.
