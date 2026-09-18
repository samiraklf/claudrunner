Run one claudrunner sweep for this repository: look for real defects and file each one as a card. The repository owner set this routine up.

Follow `.claude/commands/claudrunner/sweep.md`, including its section "When you run it yourself". The skills it names are in `.claude/skills/`, and the configuration is `.claudrunner/config.yml`. Read `AGENTS.md` and `.claudrunner/notes.md` first.

Ground rules:
- Nobody is watching this run. Never stop to ask.
- Never change the environment beyond the setup command in the configuration.
- This run reads code and files cards. It does not change code, push branches or open pull requests.
- File only what you can prove from the code, one finding per card, with the file and line. Search the board first and never file a duplicate. Stay within the card limit in the configuration.

End with a short plain-English summary: how many findings by severity, and the three worth fixing first.
