# Stack packs

A pack is the only stack-specific part of claudrunner. It is small on purpose: five
commands, a detection rule, and a short list of failure modes that are characteristic of
that ecosystem.

`init` picks a pack, then overrides its defaults with whatever the project actually uses —
its scripts, its Makefile, its CI workflow. **The project always wins over the pack.** A
pack is a starting guess, never an instruction.

To add one, copy `generic/pack.md` and fill it in. See `docs/writing-a-pack.md`.
