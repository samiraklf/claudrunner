# Write a code host

A host is where the branch is pushed and where the change is proposed. Three verbs, and they
are the only part of the flow that is not plain git.

| Verb | Contract |
|---|---|
| `push` | Push the working branch. Never the base branch, never forced |
| `propose` | Open the change for review, return its URL |
| `link` | Turn that URL into something the board adapter can post back |

## Steps

1. Copy `plugins/claudrunner/hosts/github/HOST.md` to `plugins/claudrunner/hosts/<name>/HOST.md`.
2. Give the command or API call for each verb, with the fields it needs.
3. Say what **the change is called** there. Merge request and pull request are not
   interchangeable words to the people reading what the crew writes.
4. Name the credential and the scopes it needs.
5. List what the host can refuse. Branch policies, required reviewers and required linked
   work items all produce a change that exists but cannot be merged. That is fine — the crew
   never merges — but the body should say so, or a human will think something broke.

## Rules

- **Never merge, never force-push, never delete a branch.** True on every host.
- **Do not set reviewers.** A machine guessing at reviewers irritates people, and most hosts
  apply default reviewers themselves.
- **Never use a "fill from commits" shortcut.** The body is written deliberately by the
  `ship` skill, and it is the only thing a reviewer reads before the diff.
- Take the organisation, project and remote from the config, never from a CLI's local
  defaults. Those are per machine and will differ on a runner.
