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
- Write nothing outside `.claudrunner/`, `.claude/`, `.github/workflows/`, and the schedule
  files the user approves.
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

## Step 1b — Shape the crew to this project

Ask: **"Shape the crew to this project? I read the code once and save what I learn, so no
run has to work it out again."** Recommend yes. Every run that does not rediscover the
project saves minutes and tokens.

On yes, study the repository once, and bound it — this is a survey, not a review:

- `README`, `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md` and the `docs/` index.
- The manifests and lock files, the CI workflows, `Dockerfile` and `docker-compose*.yml`,
  `.env.example`: they give the versions, the services and the commands that are known to work.
- The directory tree two levels deep.
- Three or four representative source files and two test files, chosen from the most
  recently changed ones, to learn how code is really written here.

Write `.claudrunner/profile.md` from `${CLAUDE_PLUGIN_ROOT}/templates/profile.md`. Fill
every section from what you read, never from general knowledge of the framework. Add the
pack's characteristic failure modes that apply to this code under **What must not break**,
so a run never needs the pack. Record the commit it describes. Keep it under 4 KB: point at
files instead of copying them.

Show the user a short summary — stack, services, three conventions, the riskiest area — and
take corrections before you continue.

On no, write only the **Stack** section and the pointers under **Rules that live elsewhere**.

Also note what the tests need to run: a database and which one, other services, whether the
project already starts them with Docker. Step 2c uses it.

## Step 2 — Ask what cannot be inferred

Ask these as one grouped question where the interface allows it. Give the recommended
option first.

1. **Task board** — GitHub Issues (no extra account), then Jira, Trello, Linear, GitLab
   Issues, Azure Boards, Shortcut, Asana, ClickUp, monday.com, Notion, or none. "None" is
   valid: the sweep still files findings as Markdown reports.
2. **Board mapping** — which queue holds work ready to be picked up, where a finished item
   goes, and where a blocked item goes. For GitHub Issues these are labels; for the others,
   lists or statuses. Never hardcode names: read the board and match by meaning.
3. **Where it runs** — ask this early: it decides what goes into git. First explain, in plain
   words, that there are three kinds of place, then offer the choices. Recommend the routine.

   | Kind | Choice | Say | Files in git |
   |---|---|---|---|
   | **Cloud** | **Claude Code routine** (`routine`) — recommended | "Runs in Anthropic's cloud on your Claude subscription. No API key, no server, no CI minutes. You can see and edit it on claude.ai." | Committed |
   | **Cloud** | **GitHub Actions** (`github-actions`) | "Runs in your CI. Needs an `ANTHROPIC_API_KEY` secret, billed per use by the API." | Committed |
   | **Server** | **Cron or systemd on a server** (`cron`, `systemd`) | "Runs on a machine you keep on, on your subscription. systemd suits a server with many repositories." | Committed |
   | **Local** | **Cron on this computer** (`cron`) | "Runs on this computer while it is on, on your subscription." | Kept out of git |
   | **Local** | **By hand only** (`manual`) | "Nothing scheduled; you run `/claudrunner:triage` yourself." | Kept out of git |

   Then say why the last column differs, in these words or close to them:

   > "On your own computer, the plugin you just installed gives the crew everything it needs.
   > Nothing has to go into git, so I will add claudrunner's files to `.gitignore` and your
   > repository stays exactly as it is. A routine, GitHub Actions or a server starts from a
   > fresh copy of your repository and cannot install plugins the way you did. It only sees
   > what is pushed. So for those, the crew's files — its configuration, its skills, its
   > reviewer and its scripts — are committed and pushed with your code."

   If the user picks a local choice but wants the files shared with teammates anyway, commit
   them; the choice is theirs. Record it as `schedule.commit_files: false` for local-only,
   `true` otherwise.

   Routines need the repository on GitHub and a claude.ai login in this session. If either is
   missing, say so and recommend the next choice.
4. **Cadence** — for a routine the shortest interval is one hour; default the fast loop to
   hourly and the slow loop to weekly. Elsewhere, fast loop 10 minutes, slow loop nightly.
   Ask for times in the user's own timezone and convert to UTC.
5. **Board access** — with a routine and a board that has a claude.ai connector (Trello,
   Jira, Linear, Asana, Notion and others), recommend `board.via: connector`: no keys to
   store. Check the connector can see the board before relying on it. Otherwise
   `board.via: api`, with the credentials in the environment.
6. **How the crew tests its changes** (`verify.mode`) — offer these. Recommend `auto` for a
   routine, where every setup starts from nothing, and `here` for a machine that keeps its
   setup (Step 2c):

   | Choice | Say |
   |---|---|
   | **Auto** (`auto`) | "The crew decides per change: no setup for text or docs, and only the part of the project it changed for code. Fewest minutes and tokens." |
   | **Always here** (`here`) | "Every change is tested before the pull request opens. Slower, most certain." |
   | **Leave it to CI** (`ci`) | "The crew writes the tests and never installs anything; your CI runs them on the pull request." Recommend only when CI runs the tests on pull requests. |

   Then look at what the project needs to run its tests. If it has separable parts (a backend
   and a frontend, several services), write the setup so it takes a part name and list the
   parts in `stack.commands.setup_parts`.
7. **Autonomy** — `suggest`, `pr-only` (default), or `push`. Do not say where a merge goes
   until the next question is answered.
8. **Which branch pull requests target** (`project.base_branch`) — many teams release to a
   development branch first and never want the crew's work going straight to production. Look
   before asking:
   - List the remote branches (`git branch -r`) and the default branch
     (`git symbolic-ref refs/remotes/origin/HEAD`).
   - Find integration branches by name — `develop`, `development`, `dev`, `staging`, `next`,
     `release/*` — and check they are active (commits in the last few weeks).
   - Read the CI and deploy workflows: which branch deploys to production, and which to a test
     environment. Say it plainly, for example "a merge to `main` deploys to production; a merge
     to `develop` deploys to staging".

   Offer the choices found, each with what a merge there does. Recommend the integration branch
   when one is active, and the default branch otherwise. Always allow typing another name. With
   `push` autonomy, ask the same for `policy.push_branch`, and never offer a branch that deploys
   to production.
9. **Where the status page lives** — see the next step. Ask it last; it is optional.

## Step 2c — Where the tests run

The answer depends on where the crew runs. Recommend the setup below for the machine chosen
in Step 2, explain it in two or three plain sentences, and let the user change it. Whatever
the machine, `.claudrunner/setup.sh [part]` is the one entry point a run calls, and only
when it is about to test a change.

**Claude Code routine** — a fresh cloud machine per run, with a disk snapshot that is kept.

- Recommend **a cloud environment of its own**, named `claudrunner-<project.name>`, with
  the default **Trusted** network. It keeps this project's installs, network rules and
  variables apart from the user's other cloud sessions.
- Write `.claudrunner/cloud-setup.sh` from `${CLAUDE_PLUGIN_ROOT}/templates/environment/cloud-setup.sh`,
  for the user to paste into the environment's **Setup script** field. It installs what the
  image lacks and fills the package caches. It runs once; the environment keeps the result
  for about seven days, so runs start with everything on disk. It must finish in under five
  minutes and always exit 0.
- The image already has PostgreSQL 16, Redis 7, Docker, `gh`, `jq` and `yq`, and PHP, Node,
  Python, Ruby, Java, Go and Rust toolchains. Install only what is missing, with `apt-get`
  where the package exists.
- Running processes are not kept, so `setup.sh` starts the services (`service postgresql
  start`, `mysqld`, or `dockerd` and `docker compose up -d`), installs from the warm caches
  and prepares the test database. It must still work, only slower, in an environment
  without the setup script.
- Never put a secret in the environment's variables: everyone who uses the environment can
  read them. Prefer the board's connector. On Pro and Max plans, an environment's
  **API credentials** attach a key to requests without the session ever seeing it.

**GitHub Actions** — a fresh runner per run, next to your CI.

- Start the services in the workflow's `services:` block, with the same images CI uses, and
  cache dependencies with the setup action's cache. Recommend `verify.mode: here`: setup is
  cheap there and the pull request arrives already tested.

**Cron or systemd on your own machine** — the machine and its disk persist between runs.

- Prepare the machine **once, now**, with the user's permission: install the dependencies
  and create a **separate test database**, never the development or production one. Name it
  in the profile.
- `setup.sh` then only refreshes: it reinstalls a part when its lock file changed since the
  last run and otherwise returns at once.
- Recommend `verify.mode: here`: testing costs almost nothing on a prepared machine.

**By hand** — the user's own development environment.

- Use what the user already runs. `setup` stays empty unless they ask for it.

### When the project uses Docker

- **Own machine, laptop or GitHub Actions:** Docker makes it easiest. Reuse the project's
  `docker-compose.yml` for the services the tests need, so the crew tests against the same
  versions as development. On a machine you care about, offer `executor.mode: container` to
  run the tests inside it.
- **Claude Code routine:** Docker works, but pull the images in `cloud-setup.sh`, where the
  snapshot keeps them, and never during a run: the shared cloud addresses get rate-limited
  by Docker Hub. Prefer the image's own PostgreSQL and Redis, or an `apt-get` package; use
  Docker only when a service exists only as an image or its exact version matters.

## Step 2b — The status page

The page shows every task the crew is working on, and the step it is at, while it happens. It
can only show runs it can see, so **offer only the choices that work for where the crew runs**
(Step 2, question 3). Never offer a choice that would show an empty page.

**When the crew runs in the cloud or on a server** (routine, GitHub Actions, cron or systemd
on another machine), offer, recommended first:

| Choice | Say |
|---|---|
| **From a branch** (`branch`) — recommended for a private repository | "Every step of every task is published to a `claudrunner-status` branch in your repository. `/claudrunner:dashboard` shows it live on your computer, updated about every 20 seconds. Only people with access to the repository can see it." |
| **GitHub Pages** (`github-pages`) — recommended for a public repository | "The same live page as a link for your whole team, with nothing to run. Anyone with the link can see it." |
| **Your own server** (`server`) | "A subdomain such as `crew.example.com`, or a path such as `example.com/claudrunner/`, on a server you run." |
| **No page** (`none`) | "Skip it. You can add it later by editing the config." |

**When the crew runs on this computer** (cron here, or by hand), offer:

| Choice | Say |
|---|---|
| **On this computer** (`local`) — recommended | "Open it any time with `/claudrunner:dashboard`. It follows every task live. Only you can see it, and nothing is pushed anywhere." |
| **No page** (`none`) | "Skip it. You can add it later by editing the config." |

With `schedule.commit_files: false`, never offer `branch` or `github-pages`: both push to the
repository.

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

- The branch pull requests target, what a merge there does, and confirmation that the
  production branch is protected.
- The diff ceiling per pull request (default 600 changed lines).
- Whether new dependencies are allowed (default: no).

## Step 4 — Write the files

1. `.claudrunner/config.yml` — the answers above, including the `dashboard:` section. Follow
   the configuration reference in the claudrunner repository exactly.
2. **Install the crew into the repository**, now that the config says what it needs: run
   `${CLAUDE_PLUGIN_ROOT}/runtime/install-into-repo.sh ${CLAUDE_PLUGIN_ROOT}`, adding
   `--local` when `schedule.commit_files` is `false` — it then adds `.claudrunner/` to
   `.gitignore`, so nothing claudrunner writes is ever committed, and the plugin supplies the
   commands, skills and agents. Otherwise add `--with-commands` for a routine — a cloud routine cannot install plugins, so the crew's
   commands, skills and agents go into the repository's own `.claude/`. It copies only what
   this configuration uses: the one board binding (none with a connector), the sweep only when
   the slow loop is on, a sweep skill only for a scope it runs. A later run removes what is no
   longer needed, from its list in `.claudrunner/installed.txt`. With `--with-commands` it also
   sets `attribution` in `.claude/settings.json`, so cloud commits and pull requests carry no
   session link or attribution line. When files are committed, only `.claudrunner/runs/` and
   `.claudrunner/dashboard/` are ignored.
3. `.claudrunner/profile.md` — from Step 1b.
4. `.claudrunner/gotchas.md` — an empty catalog with its header. It grows from real
   incidents in this repository and is read by every review.
5. `.claudrunner/setup.sh` and, for a routine, `.claudrunner/cloud-setup.sh` — from Step 2c.
   Fill in every placeholder in `cloud-setup.sh`, including the repository name, and delete the
   sections the project does not need: the user pastes it as it is. Set `stack.commands.setup`
   to the first. When it takes a part name, list the parts in
   `stack.commands.setup_parts`. Keep both quiet: send output to a log file and print one line
   when done. In a run, a failed setup is reported, never repaired.
6. The schedule for the chosen target: a workflow, crontab line or unit from
   `${CLAUDE_PLUGIN_ROOT}/templates/` — or, for a routine, nothing here; see Step 4b.

## Step 4b — Create the routines

Only for `routine`, and only after the files from Step 4 are committed and pushed to the
base branch: a routine checks out the base branch and sees nothing that is not there. When
the base branch is not the repository's default branch, a routine session still starts on the
default branch and loads `.claude/` from there, so the crew's files must be on both: say so,
and open a pull request to each. If
they are not on the base branch yet, open the pull request, say the routines will be created
once it is merged, and stop here.

### Create the cloud environment

Claude Code has no command or API that creates a cloud environment: only claude.ai/code and the
Desktop app can. Say so plainly, so the user knows why this one step is theirs, then make it as
short as possible. The helper is `${CLAUDE_PLUGIN_ROOT}/runtime/cloud-env.sh`.

1. Run `cloud-env.sh default` and remember what it prints (it may print nothing): the user's
   current default cloud environment, to put back at the end.
2. Run `cloud-env.sh copy .claudrunner/cloud-setup.sh`, then `cloud-env.sh open`.
3. Show the user these steps, exactly, as a numbered list:

   > **Create the environment** (about one minute) — claude.ai/code is open in your browser:
   >
   > 1. Find the small button **just above the message box**, left of **Select repository…**.
   >    It has a **cloud icon** and shows your current environment's name, often **Default**.
   >    Click it. *There is no "Environments" page or menu in the sidebar: this button is the
   >    only way in.*
   > 2. A small menu opens with **Local**, **Cloud** and **Remote Control**. Point at **Cloud**,
   >    then click **Add cloud environment…** at the bottom of the list that appears.
   > 3. The **Add cloud environment** form opens. Fill it in with the values below — copy each
   >    one and paste it into the field of the same name.
   > 4. Click **Add environment**. Nothing runs yet.
   >
   > **Then, here in this terminal**, type `/remote-env`, pick `claudrunner-<project.name>`, and
   > tell me when you are done. That is how I learn its id, so you never copy one by hand.

   Right after the steps, print the **values to paste**, one labelled block per field, with the
   real values filled in — never a placeholder the user must edit:

   > **Name** — copy and paste:
   > ```
   > claudrunner-<project.name>
   > ```
   > **Network access** — choose **Trusted** from the list (it is already selected).
   >
   > **Environment variables** — leave empty. Never put a password or key here: everyone who
   > uses the environment can read them.
   >
   > **Setup script** — copy and paste all of it (it is also on your clipboard already):
   > ```bash
   > <the whole of .claudrunner/cloud-setup.sh, exactly as written>
   > ```

   Print the setup script in full, never shortened, so a copy of the block works as it is.

   If `copy` could not reach a clipboard, it printed the script: tell the user to copy it from
   there. If the user does not see the cloud button, they have not finished the first-time setup
   of Claude Code on the web: tell them to follow the prompts on claude.ai/code once, then look
   again.
4. When the user says done, run `cloud-env.sh default`. A new value is the environment id. If it
   is unchanged, the pick did not happen: ask once more.
5. Put the user's own default back with `cloud-env.sh restore <value from step 1>` (an empty
   value removes the key), and say you did.

If the user would rather not create an environment, use their existing one, and say that every
run then installs what it needs from nothing, which costs minutes on each run.

Create two routines with the `RemoteTrigger` tool (`action: create`). For each:

- `name`: `claudrunner triage — <project.name>` and `claudrunner sweep — <project.name>`.
- `cron_expression`: the cadence from Step 2 in UTC, at least one hour apart. Start the
  triage at a minute other than :00 so it does not queue behind everyone else's.
- `enabled`: `true`.
- `job_config.ccr.environment_id`: the environment from **Create the cloud environment** below.
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

0. What happens with git. Local-only: "Nothing to commit: claudrunner's files are in
   `.gitignore`." Otherwise: the files to commit and push, and that the schedule only works
   once they are on the base branch.

1. The secrets the user must add, by name, and where to add them. Never print a value.
   For a routine, the cloud environment from Step 2c too, if it does not exist yet.
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
