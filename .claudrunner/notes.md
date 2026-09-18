# Project notes

What the crew has learned about this repository and cannot cheaply re-derive.

- **This repository is instructions, not application code.** Prose is the product. A vague
  sentence here becomes a wrong decision in somebody else's repository at 03:00.
- **The self test needs no dependency beyond `jq`.** Keep it that way: it runs on a clean CI
  image with nothing installed.
- **Nothing stack-specific belongs in the core.** If a rule only makes sense in one language,
  it belongs in `plugins/claudrunner/packs/`.
- **Private details must never appear here.** `scripts/check-leaks.sh` enforces it, and it
  runs in CI. Examples use invented names.
- **Shell bindings are written against documented API behaviour.** None has been run against
  a live board yet, so treat a first-contact bug report as likely correct.
