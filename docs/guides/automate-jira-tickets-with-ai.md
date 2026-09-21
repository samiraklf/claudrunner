---
title: Automate Jira tickets with an AI coding agent
description: "Turn Jira tickets into reviewed pull requests automatically. An AI coding agent picks up ready issues, implements, tests and reviews them, and opens the PR."
lead: Move a Jira ticket to your ready status, and a tested, reviewed pull request arrives. This guide wires claudrunner to a Jira project in about ten minutes.
---

## What happens to a ticket

1. **Fetch.** On each run, claudrunner searches your Jira project with JQL for issues in
   your *ready* status, highest priority first, up to five at a time.
2. **Claim.** It assigns each issue to the runner account and transitions it to *in
   progress*, so a second run can never pick up the same ticket.
3. **Implement.** The AI coding agent reads the ticket, reads your code as it is today,
   makes the change and writes tests. A bug fix always gets a regression test that fails
   against the old code.
4. **Review.** A fresh reviewer that did not write the code attacks the diff and grades
   what it finds P0, P1 or P2. P0 and P1 findings are fixed before anything ships.
5. **Ship.** It opens a pull request with a clear description and links it on the ticket.
6. **Move.** The ticket moves to your *in review* status. A ticket it could not finish is
   parked in your *blocked* status with one clear question in a comment.

Your code does not have to live next to your tickets. Jira for planning with code on GitHub,
GitLab, Bitbucket or Azure Repos is a normal setup.

## What you need

| You need | Why |
|---|---|
| Claude Code | claudrunner is a plugin for it |
| A Jira Cloud project | Any workflow; you map its statuses once |
| A Jira API token | For a runner account, ideally a dedicated one |
| A git repository | With your tests runnable from the command line |

## Set it up

**1. Install the plugin**

In your terminal — one command, safe to paste as a whole:

```bash
claude plugin marketplace add samiraklf/claudrunner && claude plugin install claudrunner@claudrunner
```

**2. Run the setup inside your repository**

```
/claudrunner:init
```

Choose **Jira** as the task board. `init` reads your project's workflow and proposes which
status means *ready*, *in progress*, *in review* and *blocked*. It stores the **transition
ids**, not the status names, so renaming a status does not break anything.

**3. Give it credentials — outside the config**

Three environment variables, as CI secrets or in your server's environment:

| Variable | Value |
|---|---|
| `JIRA_BASE_URL` | `https://your-team.atlassian.net` |
| `JIRA_EMAIL` | The runner account's email |
| `JIRA_API_TOKEN` | An API token for that account |

The AI agent never sees these. A small shell orchestrator talks to Jira; the agent only
receives the ticket text and your working tree.

**4. Narrow what it picks up (optional)**

Instead of a whole project, give it a JQL filter in `.claudrunner/config.yml`:

```yaml
board:
  adapter: jira
  settings:
    jql: 'project = API AND labels = ai-ready ORDER BY priority DESC'
```

**5. Try one ticket by hand, then schedule it**

Put one small, well-described ticket in your ready status and run `/claudrunner:triage`.
Read the pull request it opens. When you like what you see, turn on the schedule that
`init` printed — a CI cron job, a crontab line, or a systemd timer.

## Writing tickets the agent can finish

- **Say what should be true when it is done**, not how to do it.
- **Name the place** if you know it: the endpoint, the screen, the job.
- **One change per ticket.** A ticket too big for one safe unattended pass is parked as
  `too-large` with a proposed split into two or three smaller tickets.
- A ticket that needs a decision only a person can make is parked as `unclear`, with the one
  question whose answer unblocks it.

## Jira-specific details

- **A transition can be forbidden** from the current status. claudrunner reads the available
  transitions for each issue and reports clearly when no path exists.
- **Priority is a first-class field** in Jira, so it is used directly instead of labels.
- **Custom fields vary** per project; claudrunner never assumes one exists.

## Also find bugs, not only fix them

The same install runs a slower sweep — nightly by default — that hunts your codebase for
security holes, silent bugs, scale traps and missing tests, and files each finding as a Jira
ticket with the file, the line and a proposed fix. See the
[AI security scan guide](ai-security-scan.md).
