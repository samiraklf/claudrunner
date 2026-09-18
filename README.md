<div align="center">

# claudrunner

**More human than human.**

An autonomous dev crew for your repository. It takes work off your board, fixes it,
proves the fix, and opens the pull request — then tells you what it refused to build.

Any language. Any stack. Any task board. No server required.

<a href="https://samiraklf.github.io/claudrunner/"><img src="docs/assets/preview.gif" width="800"
alt="The claudrunner status page: robots type at laptops while the reviewer bonks them with a rope, a lifeguard runs to rescue a dog from the sea, and a runner flees through a maze"></a>

**[▶ Open the live demo](https://samiraklf.github.io/claudrunner/)** — the status page with sample tasks.
On the page, press `P` to play the scene's gag now, `R` to make the reviewer throw his rope,
`D` for a dance, and `T` for the task list.

</div>

---

## The two loops

| Loop | Runs | Does | You get |
|---|---|---|---|
| **Fast** | every ~10 min | Takes ready work, implements it, tests it, reviews it | A pull request, or a question |
| **Slow** | nightly or weekly | Hunts defects: security holes, silent bugs, scale traps, missing tests | New cards, each with evidence |

## What the sweep looks for

| Pass | Examples of what it files |
|---|---|
| **Security** | Injection · missing ownership checks · one tenant reading another's data · secrets in source or logs · a whole request body assigned to a record · unsafe deserialization · outbound requests to a user-supplied address |
| **Correctness** | A condition that fires when nothing changed · a record left in a state nothing can move forward · a new enum case its consumers never handle · a response field a client still depends on · a cached value with no invalidation path |
| **Scale & performance** | A query inside a loop · an unbounded read on a growing table · a missing index on a newly filtered column · a whole file buffered in memory · a job whose timeout exceeds the retry window, so it runs twice · a migration that locks a large table |
| **Tests** | An untested calculation · an untested billing or money path · an untested authorization rule · a fake that suppresses the callback the test claims to prove |

Every card carries the file, the line, the quoted code, the measured impact and a proposed
fix. A finding it cannot anchor in your code does not get filed.

## What you need

| Required | Why | Note |
|---|---|---|
| **Claude Code** | The crew ships as a plugin for it | The only hard dependency |
| **A git repository** | It works in branches and pull requests | GitHub for the default schedule |
| **`jq`** | Reads the config and the agent's run summary | Already on every CI runner |
| **An API key** | Only for runs on a schedule | Running by hand uses your own session |

## What is supported but optional

| | Supported | What it adds | What happens without it |
|---|---|---|---|
| **Docker / Podman** | ✅ | Runs tests inside a container, on machines you care about | Tests run directly — which is correct on a CI runner, since it is destroyed after the job |
| **Your own server** | ✅ systemd lanes | Many repositories in parallel, no CI minutes, full control | CI cron runs it instead. No machine to maintain |
| **A task board** | ✅ 4 boards | The fast loop: work gets picked up on its own | The sweep still runs and writes its findings to files |
| **A second model CLI** | ✅ any read-only CLI | A reviewer from a different vendor on the same diff | One fresh-context reviewer, which is already the main gate |
| **Node.js** | ✅ | Nothing you do — the CI template installs the agent with it | Nothing. You never install it yourself |
| **A monorepo** | ✅ | `code_dir` points the crew at one directory | — |

## Not yet

| | Status |
|---|---|
| Bitbucket Data Center, Gitea, self-hosted Forgejo | A different API from the shipped hosts. Planned |
| Windows runners | Untested. The orchestrator is POSIX shell |
| Multiple repositories from one board | Works, but each repository needs its own lane and its own label |

## Stacks

**All of them.** The core knows nothing about your language — a stack is five commands
(test, filtered test, lint, format, build) plus a short list of that ecosystem's
characteristic failures.

Packs ship for **Node, Python, .NET, Java, Go, PHP and Rust**. Anything else uses the
generic pack: `init` reads your CI workflow and your project's own scripts, proposes what it
found, and asks you to confirm. Your project's commands always win over a pack's guesses.

## Task boards

Eleven, and every one runs from the orchestrator — the shell fetches, claims and moves, so
the agent never holds your board credential. A board is four verbs, so adding yours takes an
afternoon.

| Board | Queues are | Claiming |
|---|---|---|
| **GitHub Issues** · **GitLab Issues** | labels | Claim, re-read, release if contested |
| **Jira** · **Linear** · **Azure Boards** · **Shortcut** | workflow states | Atomic, via assignee |
| **Asana** · **ClickUp** · **monday.com** · **Notion** | sections, statuses, columns | Atomic, one write |
| **Trello** | lists | Claim label, verified by re-read |
| **None** | — | Sweep only, findings written to files |

## Code hosts

Where the branch lands and the change gets proposed. A separate choice from the board —
plenty of teams split them.

| Host | The change is called | Uses |
|---|---|---|
| **GitHub** · GitHub Enterprise | pull request | `gh` |
| **GitLab** · self-managed | merge request | `glab` |
| **Azure Repos** | pull request | `az repos` |
| **Bitbucket Cloud** | pull request | REST |

## Schedules

| Target | Needs | Best for |
|---|---|---|
| CI cron | A repository and one secret | **Default.** Almost everyone |
| Plain cron | A machine you leave running | The simplest thing that works |
| systemd | Root on a Linux box | Many repositories, many lanes |
| By hand | Nothing | Trying it, and calibrating week one |

## Isolation

| Mode | Needs | Use when |
|---|---|---|
| `direct` | Nothing | On a CI runner — it is already disposable |
| `container` | Docker or Podman | Runs happen on a machine you care about |

## Autonomy

| Level | What it does | Can it reach your default branch |
|---|---|---|
| `suggest` | Writes a report. You do the work. | Never |
| `pr-only` | **Default.** Branches, commits, opens a pull request. | Never |
| `push` | Pushes to one branch you name. | Never |

## Guarantees

| | |
|---|---|
| The agent holds a credential | ❌ Never. The orchestrator does. |
| The agent chooses the repository | ❌ Never. It is handed one. |
| The agent can touch other board items | ❌ Refused — ids are checked against its own input |
| It stops mid-run to ask you something | ❌ Never. It parks the item and carries on |
| A run can stall waiting for an answer | ❌ Never. Nobody has to be watching |
| The agent can merge | ❌ Never |
| The agent can force-push | ❌ Never |
| Item text can instruct the agent | ❌ Treated as untrusted input |
| Every change is reviewed by a fresh context | ✅ Always, before the pull request opens |
| Refusing to build something is a valid outcome | ✅ Two of the seven outcomes exist for it |

## Install

```
/plugin marketplace add samiraklf/claudrunner
/plugin install claudrunner
```

Then, inside the repository you want it to work on:

```
/claudrunner:init
```

It reads your project, proposes the commands it found, and asks what it cannot infer.
It writes a config and a schedule. Nothing runs until you say so.

## Commands

| Command | Does |
|---|---|
| `/claudrunner:init` | Set up this repository. Detect, ask, write, hand over. |
| `/claudrunner:triage` | Run one fast-loop cycle now. |
| `/claudrunner:sweep` | Run one slow-loop sweep now. Takes a scope. |
| `/claudrunner:status` | Config, schedule, queue and recent runs. Changes nothing. |
| `/claudrunner:dashboard` | Open the status page on this computer. |

## What it costs to run

**claudrunner is free.** MIT licensed, no account, no sign-up, no telemetry, no paid tier,
and nothing is sold to you here.

It runs on your own Claude subscription, exactly as if you had typed the work yourself. To
use less of it, run the sweep weekly instead of nightly and poll the board less often.

## Documentation

| Doc | Read it when |
|---|---|
| [Getting started](docs/getting-started.md) | First install, and week one |
| [How a run works](docs/how-a-run-works.md) | You want to know what it does to your repo |
| [Configuration](docs/configuration.md) | Tuning anything |
| [Scheduling](docs/scheduling.md) | Choosing a cadence and a target |
| [Security model](docs/security.md) | Before letting it run unattended |
| [Write a stack pack](docs/writing-a-pack.md) | Your stack is not listed |
| [Write a board adapter](docs/writing-an-adapter.md) | Your board is not listed |
| [Write a code host](docs/writing-a-host.md) | Your git host is not listed |
| [The status page](docs/dashboard.md) | You want a screen showing what the crew is doing |

## License

MIT © samiraklf
