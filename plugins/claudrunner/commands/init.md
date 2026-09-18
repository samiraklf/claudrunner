---
description: Set up claudrunner in this repository — detect the stack, wire a task board, choose a schedule, write the config.
argument-hint: "[--non-interactive]"
---

# claudrunner — init

Set this repository up. Detect what you can. Ask only what you cannot infer.

## Rules for this command

This is the **only** command that asks questions. The user is here, setting things up. Every
other command runs unattended and parks what it cannot decide.

- Never guess a command you have not seen in the repository. Propose, then confirm.
- Write nothing outside `.claudrunner/`, `.github/workflows/`, and the schedule files the
  user approves.
- Nothing is scheduled or enabled by this command. It writes files and prints the final
  step for the user to run themselves.

## Step 1 — Detect the stack

Look for, in this order: `package.json`, `pyproject.toml` or `requirements.txt`,
`*.csproj` or `*.sln`, `pom.xml` or `build.gradle*`, `go.mod`, `composer.json`,
`Cargo.toml`, `Gemfile`, `mix.exs`.

More than one match means a polyrepo or a monorepo. Ask which directory holds the code
this crew should work on, and whether other directories are read-only context.

Load the matching pack from `${CLAUDE_PLUGIN_ROOT}/packs/<name>/pack.md`. Read the project's own
scripts — `package.json` scripts, `Makefile`, `composer.json` scripts, `pyproject` tool
sections, CI workflow files — and prefer what the project already uses over the pack
default. The CI workflow is the most reliable source: it shows the commands that are known
to work.

Present what you found as a table, and ask for corrections:

| Purpose | Command | Source |
|---|---|---|
| test (all) | | |
| test (filtered) | | |
| lint | | |
| format | | |
| build | | |

An unknown stack uses `${CLAUDE_PLUGIN_ROOT}/packs/generic/pack.md` and asks the user for all five.

## Step 2 — Ask what cannot be inferred

Ask these as one grouped question where the interface allows it. Give the recommended
option first.

1. **Task board** — GitHub Issues (no extra account), then Jira, Trello, Linear, GitLab
   Issues, Azure Boards, Shortcut, Asana, ClickUp, monday.com, Notion, or none. "None" is
   valid: the sweep still files findings as Markdown reports.
2. **Board mapping** — which queue holds work ready to be picked up, where a finished item
   goes, and where a blocked item goes. For GitHub Issues these are labels; for the others,
   lists or statuses. Never hardcode names: read the board and match by meaning.
3. **Where it runs** — offer these, in this order, and recommend the first:

   | Choice | Say |
   |---|---|
   | **Claude Code routine** (`routine`) — recommended | "Runs in Anthropic's cloud on your Claude subscription. No API key, no server, no CI minutes. You can see and edit it on claude.ai." |
   | **GitHub Actions** (`github-actions`) | "Runs in your CI. Needs an `ANTHROPIC_API_KEY` secret, billed per use by the API." |
   | **Cron on this machine** (`cron`) | "Runs on a machine you leave on, on your subscription." |
   | **systemd lanes** (`systemd`) | "For a server that runs many repositories." |
   | **By hand only** (`manual`) | "Nothing scheduled; you run `/claudrunner:triage` yourself." |

   Routines need the repository on GitHub and a claude.ai login in this session. If either is
   missing, say so and recommend the next choice.
4. **Cadence** — for a routine the shortest interval is one hour; default the fast loop to
   hourly and the slow loop to weekly. Elsewhere, fast loop 10 minutes, slow loop nightly.
   Ask for times in the user's own timezone and convert to UTC.
5. **Board access** — with a routine and a board that has a claude.ai connector (Trello,
   Jira, Linear, Asana, Notion and others), recommend `board.via: connector`: no keys to
   store. Check the connector can see the board before relying on it. Otherwise
   `board.via: api`, with the credentials in the environment.
6. **Autonomy** — `suggest`, `pr-only` (default), or `push`.
7. **Where the status page lives** — see the next step. Ask it last; it is optional.

## Step 2b — The status page

Offer these four, recommended first. Explain each in one line, in these words:

| Choice | Say |
|---|---|
| **On this computer** (`local`) | "Open it any time with `/claudrunner:dashboard`. Only you can see it. Nothing to set up." |
| **From a branch** (`branch`) | "Each run publishes its status to a `claudrunner-status` branch; `/claudrunner:dashboard` shows it live on your computer. Private." |
| **GitHub Pages** (`github-pages`) | "A link for your whole team, updated after every run. Free on a public repo. Anyone with the link can see it." |
| **Your own server** (`server`) | "A subdomain such as `crew.example.com`, or a path such as `example.com/claudrunner/`, on a server you run." |
| **No page** (`none`) | "Skip it. You can add it later by editing the config." |

Recommend **GitHub Pages** when the repository is public and runs happen in CI or a routine —
the team gets a link and nobody runs anything. When runs happen in a routine or CI on a
private repository, recommend **From a branch**: this computer never sees those runs any
other way. Otherwise recommend **On this computer**.

Follow-up questions, only for the choice made:

- **GitHub Pages:** "Use your own domain, or the free `github.io` address?" If their own, take
  the domain and tell them to add a CNAME record pointing at `<owner>.github.io`.
  Then ask: "Show task titles on the page, or only task numbers?" Default to **numbers** and
  say why: titles often name customers, bugs and security issues, and this page is public.
- **Your own server:** "Does the crew run on that same server?" If yes, ask for the folder the
  web server serves (`dashboard.server.webroot`). If no, ask for the SSH target, for example
  `deploy@your-server:/var/www/claudrunner/` (`dashboard.server.ssh_target`), and tell them the
  CI secret it needs: `CLAUDRUNNER_DASHBOARD_SSH_KEY`. Ask for the subdomain or path it should
  appear on, and write the matching nginx snippet from
  `${CLAUDE_PLUGIN_ROOT}/templates/hosting/`.

Never ask for the key itself, and never write a secret into any file.

## Step 3 — Confirm the guardrails

State these back and let the user change them:

- The base branch it targets, and confirmation that the default branch is protected.
- The diff ceiling per pull request (default 600 changed lines).
- Whether new dependencies are allowed (default: no).

## Step 4 — Write the files

0. **Install claudrunner into the repository**, so scheduled runs work without the plugin:
   run `${CLAUDE_PLUGIN_ROOT}/runtime/install-into-repo.sh ${CLAUDE_PLUGIN_ROOT}`, adding
   `--with-commands` for a routine — a cloud routine cannot install plugins, so the crew's
   commands, skills and agents go into the repository's own `.claude/`, which every Claude
   Code session loads. Everything it installs is committed; only `.claudrunner/runs/` and
   `.claudrunner/dashboard/` are ignored, and the script refuses a `.gitignore` that would
   hide the rest.
1. `.claudrunner/config.yml` — the answers above, including the `dashboard:` section. Follow
   the configuration reference in the claudrunner repository exactly.
2. `.claudrunner/gotchas.md` — an empty catalog with its header. It grows from real
   incidents in this repository and is read by every review.
3. `.claudrunner/notes.md` — anything you learned about the project that a future run
   needs and cannot re-derive cheaply: scale-sensitive tables, slow test paths, areas that
   are deliberately unconventional.
4. The schedule for the chosen target: a workflow, crontab line or unit from
   `${CLAUDE_PLUGIN_ROOT}/templates/` — or, for a routine, nothing here; see Step 4b.
5. If the tests need preparation in a fresh machine (dependencies, a database), put it in a
   script such as `.claudrunner/setup.sh` and set `stack.commands.setup` to it. A routine
   starts from a bare checkout every time.

## Step 4b — Create the routines

Only for `routine`, and only after the files from Step 4 are committed and pushed to the
base branch: a routine checks out the base branch and sees nothing that is not there. If
they are not on the base branch yet, open the pull request, say the routines will be created
once it is merged, and stop here.

Create two routines with the `RemoteTrigger` tool (`action: create`). For each:

- `name`: `claudrunner triage — <project.name>` and `claudrunner sweep — <project.name>`.
- `cron_expression`: the cadence from Step 2 in UTC, at least one hour apart. Start the
  triage at a minute other than :00 so it does not queue behind everyone else's.
- `enabled`: `true`.
- `job_config.ccr.environment_id`: the user's cloud environment. If there is more than one,
  ask which.
- `job_config.ccr.session_context.sources`: this repository's GitHub URL, nothing else.
- `job_config.ccr.session_context.allowed_tools`: `Bash, Read, Write, Edit, Glob, Grep, Skill, Agent`.
- `job_config.ccr.events`: one user message whose content is
  `${CLAUDE_PLUGIN_ROOT}/templates/routine/triage-prompt.md` (or `sweep-prompt.md`), verbatim.
  Do not add anything to it: it is written so an unattended session reads it as the plain
  development work it is.
- `mcp_connections`: only the board's connector when `board.via` is `connector`, and nothing
  else. A routine starts with every connector the account has; send the list explicitly.

The response gives each routine's id. Store them as `schedule.routines.triage` and
`schedule.routines.sweep` in `.claudrunner/config.yml` so later runs of `init` update the
same routines instead of creating new ones.

## Step 5 — Hand over

Print, in this order:

1. The secrets the user must add, by name, and where to add them. Never print a value.
2. The one command that turns the schedule on — for a routine, the two claude.ai links
   `https://claude.ai/code/routines/<id>`, where the user can see, edit, pause or run them.
3. The command to try one cycle by hand first: `/claudrunner:triage`.
4. Where to see the crew:
   - `local` — "`/claudrunner:dashboard`"
   - `github-pages` — the address, and the one setting to switch on: **Settings → Pages →
     Source: Deploy from a branch → `claudrunner-status` / root**. If `gh` is signed in, offer
     to switch it on for them. The branch appears after the first run.
   - `server` — the address they chose, and the nginx snippet you wrote.

Recommend the manual run before enabling any schedule, so the user sees what a cycle does
before it does it on a timer.
