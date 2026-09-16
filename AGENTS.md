# claudrunner — contributor and agent guide

This project packages a way of working. It has to follow its own rules, or nobody should
believe them.

## What this repository is

A plugin plus the parts around it. There is no application code — the deliverables are
instructions, small shell scripts, and templates. Treat prose as the product: a vague
sentence here becomes a wrong decision in somebody's repository at three in the morning.

## Layout

| Path | Holds |
|---|---|
| `plugins/claudrunner/` | commands, skills and agents — the behavior |
| `packs/` | one file per stack: five commands and its characteristic failures |
| `adapters/` | one file per board: four verbs |
| `scripts/` | the orchestrator, the guards, the self test |
| `templates/` | schedule targets |
| `docs/` | the reference the commands point at |

## Rules

**Nothing stack-specific in the core.** If a rule only makes sense for one language, it
belongs in a pack. The core must read correctly to someone writing Go, Java or C#.

**No private details, ever.** No employer, no internal service, no hostname, no person, no
machine path. Examples use invented names: `acme-api`, `example.com`. `scripts/check-leaks.sh`
enforces this and runs in CI. Private patterns live in an untracked `.namecheck`, never here.

**No model attribution.** No co-author trailer, no session link, no "generated with" line,
in any commit or pull request body.

**Every claim is checkable.** A skill that says "this fails under load" says how, and what
to look at. Advice a reader cannot verify is noise.

**Keep prose short.** Short sentences, active voice, one instruction per sentence, one name
per concept. This text is parsed by agents as often as by people.

## Before you commit

```bash
./scripts/lint.sh
```

It runs exactly what CI runs — the self test, the config check, the leak check, and
shellcheck at the version CI pins — and fails if your shellcheck is a different release,
because releases disagree about what passes. Do not commit until it prints `lint passed`.

After pushing, check the run: `gh run list --limit 3`. A red run is fixed before the next
commit, never after twenty more.

When you change a skill or its description, also run the eval suite. It costs real money, so
it is not in CI:

```bash
claude plugin eval plugins/claudrunner --no-publish
```

## Writing a skill

- The front-matter `description` is the trigger. Say when to use it, in the words a user
  would actually type. A skill nobody triggers is dead weight.
- The directory name and the `name` field must match. The self test enforces it.
- Write the failure mode, not the theory. The value is in what goes wrong and how to see it.

## Extending

New stack: copy `packs/generic/pack.md`, follow `docs/writing-a-pack.md`.
New board: follow `docs/writing-an-adapter.md`, and be honest about whether claiming is
atomic. It usually is not, and the doc must say what happens then.

## Scope

Change what the task asks for. This repository is instructions, so an unrequested edit to a
skill changes behavior in every repository that installs it.
