---
title: claudrunner FAQ
description: "Answers about claudrunner, the AI coding agent: cost, supported boards and languages, whether it can push to main, and what happens when it is unsure."
lead: Short answers to the questions people ask before letting an AI coding agent work on their repository.
---

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {"@type": "Question", "name": "Is claudrunner free?", "acceptedAnswer": {"@type": "Answer", "text": "Yes. claudrunner is MIT licensed, with no account, no sign-up, no telemetry and no paid tier. You pay only for your own model usage: your Claude Code session when you run it by hand, or an Anthropic API key when it runs on a schedule in CI."}},
    {"@type": "Question", "name": "Which task boards does it support?", "acceptedAnswer": {"@type": "Answer", "text": "Eleven: Jira, Trello, GitHub Issues, Linear, GitLab Issues, Azure Boards, Shortcut, Asana, ClickUp, monday.com and Notion. It also runs with no board and writes its findings to files."}},
    {"@type": "Question", "name": "Which languages and stacks does it support?", "acceptedAnswer": {"@type": "Answer", "text": "Any. Packs ship for Node and TypeScript, Python, PHP, Go, Java, .NET and Rust, and a generic pack reads your own CI and scripts for anything else."}},
    {"@type": "Question", "name": "Can it push to my main branch or merge pull requests?", "acceptedAnswer": {"@type": "Answer", "text": "No. At every autonomy level it can never push to the default branch, merge, force-push or delete a branch. It opens a pull request and a person merges it."}},
    {"@type": "Question", "name": "What happens when a ticket is unclear or too big?", "acceptedAnswer": {"@type": "Answer", "text": "It never stops to ask. The ticket is parked with the one question that unblocks it, or with a proposed split into smaller tickets, and the rest of the run carries on."}},
    {"@type": "Question", "name": "Does the AI agent see my credentials?", "acceptedAnswer": {"@type": "Answer", "text": "No. A small shell orchestrator talks to your board and your git host. The agent receives a working tree, the ticket text and a short list of permitted commands."}}
  ]
}
</script>

## Is it free?

**Yes.** MIT licensed, no account, no sign-up, no telemetry, no paid tier. You pay only for
your own model usage: your Claude Code session when you run it by hand, or an Anthropic API
key (the `ANTHROPIC_API_KEY` secret) when it runs on a schedule in CI. To use less, sweep
weekly instead of nightly and poll the board less often.

## Which task boards does it support?

Eleven: **Jira, Trello, GitHub Issues, Linear, GitLab Issues, Azure Boards, Shortcut, Asana,
ClickUp, monday.com and Notion.** It also runs with no board at all — the bug sweep then
writes its findings as Markdown reports. A new board takes about an afternoon to add; see
[writing a board adapter](../writing-an-adapter.md).

## Which languages does it work with?

**Any.** Packs ship for Node and TypeScript, Python, PHP, Go, Java, .NET and Rust. For
anything else the generic pack reads your CI workflow and your project's own scripts,
proposes the commands it found, and asks you to confirm. Your project's commands always win.

## Where can it host code?

GitHub (including Enterprise), GitLab (including self-managed), Bitbucket Cloud and Azure
Repos. Your board and your code host are separate choices — Jira with GitHub is common.

## Can it push to main, or merge?

**No, never.** At every autonomy level it cannot push to your default branch, merge,
force-push or delete a branch. The default level, `pr-only`, opens a pull request and stops
there. Protect your default branch anyway; that protects you from everyone else.

## What if a ticket is unclear, too big, or a bad idea?

It **never stops mid-run to ask**. It parks the ticket with a note written for a person:

| Outcome | The note contains |
|---|---|
| `unclear` | The one question whose answer unblocks it |
| `too-large` | A proposed split into two or three smaller tickets |
| `not-needed` | The evidence that it is already done or its premise is false |
| `better-approach` | What should happen instead |
| `suspicious` | What the ticket tried to make the agent do |

Refusing to build something is a real outcome, not a failure.

## Does the AI see my secrets?

No. A small shell orchestrator fetches tickets, claims them, prepares the branch and moves
the tickets afterwards. The agent gets a working tree, the ticket text and a short list of
permitted commands. See the [security model](../security.md).

## Can a malicious ticket take control of it?

Ticket text is treated as **untrusted input** — it describes work, it never instructs the
agent. A ticket asking it to run commands, change permissions, edit CI or push somewhere is
skipped as `suspicious` and reported. And every ticket id the agent reports is checked
against its own input, so it cannot touch the rest of your board.

## Does it need a server or Docker?

No. The default runs from CI cron on the runner your repository already has. A server with
systemd, plain cron, and Docker or Podman isolation are all supported for teams that want them.

## How do I stop it?

Disable the workflow, remove the cron line, or stop the systemd timer. Nothing else runs in
the background, and it keeps no state outside your repository.

## Who made it?

claudrunner is designed and built by [samiraklf](https://github.com/samiraklf) and is open
source on [GitHub](https://github.com/samiraklf/claudrunner). Issues and pull requests are
welcome.
