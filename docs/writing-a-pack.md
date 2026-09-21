# Write a stack pack

A pack is a starting guess for an ecosystem. It is deliberately small — five commands, a
detection rule, and the failure modes characteristic of that stack.

## Steps

1. Copy `plugins/claudrunner/packs/generic/pack.md` to `plugins/claudrunner/packs/<name>/pack.md`.
2. **Detection** — the file that proves this stack is present. Be specific enough that two
   packs cannot both claim a repository. Name the alternatives a project may use.
3. **Commands** — five: test all, test filtered, lint, format, build. The filtered form must
   accept a `{filter}` placeholder; it is what makes runs fast enough to iterate.
4. **Characteristic failure modes** — four or five, no more. These seed reviews for projects
   in this ecosystem before they have any history of their own.

## Rules

- **The project always wins over the pack.** Defaults are a guess; the repository's own
  scripts, Makefile and CI workflow are facts. Say so in the pack.
- **Prefer the project's wrapper** where the ecosystem has one, so the agent uses the same
  toolchain version as the team.
- **Never assume a global install.** An unattended run happens on a clean machine.
- **No project-specific knowledge.** That belongs in `.claudrunner/profile.md`, not in a pack
  shipped to everybody.
- Failure modes must be things that *silently* pass tests. Anything a linter already catches
  does not belong here.
