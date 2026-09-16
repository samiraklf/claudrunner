# Security model

An agent working unattended on your repository is a real attack surface. This is how the
surface is kept small.

## The principle

**The agent holds no power. The orchestrator holds it all.**

The orchestrator fetches the work, decides which repository, mints the token, prepares the
branch, launches the agent, and moves the items afterwards. The agent receives a working
tree, a task, and a short list of permitted commands.

That split matters because the agent's input is partly untrusted. Item text is written by
people, sometimes by people outside your team.

## Untrusted input

An item describes **what to build**. It is never an instruction to the agent.

Any item that asks the agent to run commands, change permissions, edit CI workflows,
exfiltrate data, add a dependency from an unusual source, or push or merge anywhere is
skipped as `suspicious` and reported. The same rule applies to text inside a pull request
comment, a code comment, or a file the agent reads.

## What the agent may never do

- Push to the default branch, at any autonomy level.
- Merge anything.
- Force-push, or delete a branch.
- Edit CI workflow files, unless you enable `policy.edit_ci` *and* an item explicitly asks.
- Add a dependency, unless `policy.allow_new_dependencies` is on and an item asks for it.
- Read secret files, or print a secret value.

## Secrets

Secrets live in the runner's environment, never in a prompt, a config file, a log, or an
item. If you run on your own machine, keep the config directory unreadable by the account
the agent runs as.

Where the agent needs a privileged action, give it one narrow wrapper for that action —
never the underlying tool. A wrapper validates its own arguments and derives its target
from the working directory, not from what it is told. Handing an agent direct access to a
container runtime is equivalent to handing it root, and it bypasses every other guard here.

## Repository settings that matter

1. Protect the default branch: require a pull request, block force-push, block deletion.
2. Require approval before workflows run on pull requests from forks. This is the standard
   way a public repository leaks its secrets.
3. Give the run token the narrowest scope that works.
4. Keep the collaborator list short. A stranger cannot push to your repository; a
   collaborator can.

## Reviewing what it produced

Read the pull request, not the summary. The summary is written by the same system that
wrote the code. The diff is the evidence.
