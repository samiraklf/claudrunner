# Pack: generic

For any stack without a dedicated pack. Nothing is assumed; `init` asks for all five
commands and writes them into the config.

## Detection

Fallback. Used when no other pack matches, or when the user overrides the match.

## Commands

| Purpose | Default |
|---|---|
| test (all) | *ask the user* |
| test (filtered) | *ask the user — must accept a filter argument* |
| lint | *ask the user, may be empty* |
| format | *ask the user, may be empty* |
| build | *ask the user, may be empty* |

Read the CI workflow first. It shows the commands that are known to work on a clean
machine, which is exactly what an unattended run needs.

## Notes

With no ecosystem knowledge, lean harder on the repository itself: match the conventions of
the files you are editing, and be more conservative about what counts as a safe unattended
change.
