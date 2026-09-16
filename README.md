<div align="center">

# claudrunner

**More human than human.**

An autonomous dev crew for your repository. It takes work off your board, fixes it,
proves the fix, and opens the pull request — then tells you what it refused to build.

Any language. Any stack. Any task board. No server required.

</div>

---

## The two loops

| Loop | Runs | Does | You get |
|---|---|---|---|
| **Fast** | every ~10 min | Takes ready work, implements it, tests it, reviews it | A pull request, or a question |
| **Slow** | nightly or weekly | Sweeps the codebase for defects | New cards, each with evidence |

## Requirements

| | Required? | Notes |
|---|---|---|
| Claude Code | **Yes** | The only hard dependency |
| A git repository | **Yes** | GitHub for the default schedule |
| `jq` | For scheduled runs | Already on every CI runner |
| API key | For scheduled runs | Not needed to run it by hand in your own session |
| Node.js | No | Installed by the CI template, not by you |
| Docker | No | Optional, for isolation on a machine you care about |
| A server | No | The default schedule uses your CI runner |
| A task board | Optional | The sweep works without one |
| A second model CLI | Optional | Adds a cross-vendor reviewer |

## Stacks

| Stack | Detected by | Status |
|---|---|---|
| Node | `package.json` | ✅ Supported |
| Python | `pyproject.toml`, `requirements.txt` | ✅ Supported |
| .NET | `*.csproj`, `*.sln` | ✅ Supported |
| Java | `pom.xml`, `build.gradle` | ✅ Supported |
| Go | `go.mod` | ✅ Supported |
| PHP | `composer.json` | ✅ Supported |
| Rust | `Cargo.toml` | ✅ Supported |
| Anything else | generic pack | ✅ You supply five commands |

A pack is five commands and a short list of that ecosystem's characteristic failures. The
project's own scripts and CI always override the pack's guesses.

## Task boards

| Board | Queues are | Claim is atomic | Status |
|---|---|---|---|
| GitHub Issues | labels | No — re-read guard | ✅ Supported, shell-orchestrated |
| Trello | lists | No — re-read guard | ✅ Supported, agent-side |
| Jira | workflow statuses | Yes, via assignee | ✅ Supported, agent-side |
| Linear | workflow states | Yes, via assignee | ✅ Supported, agent-side |
| None | — | — | ✅ Sweep only, reports to files |

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

## Cost

An agent that works while you sleep bills while you sleep. A ten-minute poll on a busy
board is not free. The install asks for a budget, the defaults are conservative, and
[docs/cost.md](docs/cost.md) shows how to estimate yours before you turn anything on.

## Documentation

| Doc | Read it when |
|---|---|
| [Getting started](docs/getting-started.md) | First install, and week one |
| [How a run works](docs/how-a-run-works.md) | You want to know what it does to your repo |
| [Configuration](docs/configuration.md) | Tuning anything |
| [Scheduling](docs/scheduling.md) | Choosing a cadence and a target |
| [Cost](docs/cost.md) | Before the first schedule |
| [Security model](docs/security.md) | Before letting it run unattended |
| [Write a stack pack](docs/writing-a-pack.md) | Your stack is not listed |
| [Write a board adapter](docs/writing-an-adapter.md) | Your board is not listed |

## License

MIT © samiraklf
