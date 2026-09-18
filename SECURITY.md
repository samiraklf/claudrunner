# Security policy

## Reporting a vulnerability

Please do not open a public issue for a security problem.

Report it privately instead: open the **Security** tab of this repository and choose
**Report a vulnerability**. Only the maintainer sees the report.

Include what you found, the steps to reproduce it, and the version or commit you used.
You get an answer within seven days.

## Scope

claudrunner runs a coding agent on your repository with your credentials. These count as
security problems:

- a way for the text of a task, an issue or a pull request to make the agent act outside its run;
- a way for credentials to reach the agent, a log, a commit or the status page;
- a way for the status page to show private data that the configuration hides.

How the crew keeps credentials away from the agent is in [docs/security.md](docs/security.md).

## Supported versions

Only the latest release on `main` gets fixes.
