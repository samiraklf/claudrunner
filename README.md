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
| GitLab, Bitbucket, self-hosted git | The git flow is host-agnostic; the pull-request step is not. Planned |
| Windows runners | Untested. The orchestrator is POSIX shell |
| Multiple repositories from one board | Works, but each repository needs its own lane and its own label |

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
