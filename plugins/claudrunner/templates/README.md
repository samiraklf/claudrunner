# Schedule templates

Pick one target. `init` copies the files, fills in the values from your config, and prints
the single command that turns it on.

| Target | Use when | Needs |
|---|---|---|
| `github-actions/` | Default. Almost everyone. | A repository on GitHub, and one secret |
| `cron/` | A machine you already leave running | A shell, and the agent CLI installed |
| `systemd/` | Heavy use, many repositories, one server | Root on a Linux box |

The disposable runner in the CI target is why the default path needs no container runtime:
the job runs on a fresh machine that is destroyed afterwards.
