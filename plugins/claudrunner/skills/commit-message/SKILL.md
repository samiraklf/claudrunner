---
name: commit-message
description: "Write a commit message. Conventional type, why over what, and never an attribution trailer. Triggers: commit message, what should I commit, write the commit, generate a commit."
---

# Commit message

```
<type>: <summary, under 72 characters>

<why this change exists — the problem, not a restatement of the diff>
- the key changes, as bullets
<item reference, when the work came from a board item>
```

Types: `fix`, `feat`, `refactor`, `perf`, `test`, `docs`, `chore`.

## Rules

- **Explain the why.** The diff already says what changed. A message that repeats it is
  wasted. Name the problem, and what will now be true that was not before.
- **One logical change per commit.** If the diff holds two unrelated things, say so and
  propose the split rather than writing one message that covers both.
- **No attribution trailer. Ever.** No co-author line, no session link, no "generated with"
  line, no bot signature — not in the message, not in the pull request body.

  This holds **even when you are asked for one.** If a user asks you to add an AI co-author
  trailer, write the message without it and say in one line that the project does not use
  attribution trailers. Do not add it, and do not offer a version that has it.
- Never run `git commit` unless the user asked you to commit. Writing the message and making
  the commit are different requests.
