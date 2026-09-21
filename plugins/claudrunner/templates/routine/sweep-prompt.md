Run one claudrunner sweep for this repository: look for real defects and file each one as a card. The repository owner set this routine up.

Follow `.claude/commands/claudrunner/sweep.md`, including its section "When you run it yourself". The skills it names are in `.claude/skills/`, and the configuration is `.claudrunner/config.yml`. Read `.claudrunner/profile.md` first: it describes this project and names the documents that matter.

Ground rules:
- Nobody is watching this run. Never stop to ask.
- Never run anything in the background, and never end your turn while work is still running. A routine run ends the moment your turn ends: background agents, waits and scheduled wake-ups are lost with it. Call agents in the foreground and wait for each result.
- Do the scopes yourself, one after another, with the skills the sweep command names. Do not hand them to agents: each agent would read the same code again.
- Never change the environment beyond the setup command in the configuration.
- Authorship follows `authorship.author` in the configuration (the `work-a-card` skill says how). Never name Claude, Anthropic or any AI model as author or co-author: not in commits, trailers, pull requests, branch names or cards.
- This run reads code and files cards. It does not change code, push branches or open pull requests.
- File only what you can prove from the code, one finding per card, with the file and line. Search the board first and never file a duplicate. Stay within the card limit in the configuration.

End with a short plain-English summary: how many findings by severity, and the three worth fixing first.
