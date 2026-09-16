<div align="center">

# claudrunner

**More human than human.**

An autonomous dev crew for your repository. It takes work off your board, fixes it,
proves the fix, and opens the pull request — then tells you what it refused to build.

Any language. Any stack. Any task board. No server required.

</div>

---

## What it actually does

Two loops run against your repository.

**The fast loop** watches your triage queue. A card lands, and within minutes an agent
has claimed it, branched, implemented it, written a regression test, put the diff through
an adversarial review, and opened a pull request. If the card is ambiguous, it parks the
card with the exact question it needs answered, and stops. It never guesses.

**The slow loop** sweeps the codebase on a schedule and files what it finds as new cards:
correctness bugs, security holes, scale traps, missing tests. Each card carries the
evidence — file, line, the quoted code, the measured impact, and a proposed fix.

You review pull requests. You answer questions. That is the job.

## Why this is not another "AI writes your code" tool

Three rules make it safe to leave running unattended.

**The agent holds no power.** The orchestrator fetches the work, picks the repository,
mints the token and moves the cards. The agent gets a working tree and a short list of
permitted commands. It never sees a credential. It cannot touch a task that was not handed
to it.

**Every change is cross-examined.** A finished diff faces a fresh reviewer with no memory
of writing it, and — where you enable it — a second reviewer from a different model
vendor. Findings are graded. Anything that can crash or corrupt is fixed before the pull
request opens, or the change is reverted.

**Refusing is a valid outcome.** An agent that ships nothing and explains why beats one
that ships code you must maintain forever. Two of the seven card outcomes exist purely to
say *this should not be built*, with evidence.

## Install

```
/plugin marketplace add samiraklf/claudrunner
/plugin install claudrunner
```

Then, inside the repository you want it to work on:

```
/claudrunner:init
```

It reads your project, proposes the commands it found, and asks what it cannot infer:
which board holds your work, how often to look, and how much autonomy you are granting.
It writes a config file and a schedule. Nothing runs until you say so.

## Requirements

Just the coding agent. That is the whole list.

No Node install, no shell script piped from the internet, no Docker, and no server. The
default schedule runs on your repository host's own CI, which is a disposable machine that
already exists. Docker and a dedicated box are supported, not required.

## Works with

| | |
|---|---|
| **Stacks** | Node · Python · .NET · Java · Go · PHP · Rust · anything else, via the generic pack |
| **Boards** | GitHub Issues · Trello · Jira · Linear |
| **Schedules** | CI cron · your own machine · a server with systemd |
| **Isolation** | disposable CI runner · local container · direct |

A stack is four commands and a notes file. A board is four verbs. Both are small on
purpose — writing your own takes an afternoon.

## Autonomy is a dial

| Level | What happens |
|---|---|
| `suggest` | It writes a report. You do the work. |
| `pr-only` | It branches, commits and opens a pull request. Nothing merges without you. |
| `push` | It pushes to the branch you name. Still never to your default branch. |

The default is `pr-only`, and the default branch is always protected from it.

## Cost

An agent that works while you sleep bills while you sleep. A ten-minute poll on a busy
board is not free. The install asks for a budget, the defaults are conservative, and
`docs/cost.md` shows how to estimate yours before you turn anything on.

## Documentation

- [Getting started](docs/getting-started.md)
- [Configuration reference](docs/configuration.md)
- [Scheduling](docs/scheduling.md) · [Cost](docs/cost.md) · [Security model](docs/security.md)
- [Write a stack pack](docs/writing-a-pack.md) · [Write a board adapter](docs/writing-an-adapter.md)

## License

MIT © samiraklf
