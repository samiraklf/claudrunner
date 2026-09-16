# Gotchas

Failure modes that have actually happened in this repository. Every review reads this file
first. Add to it when a review catches something that will recur; delete an entry when it
stops being true.

## A shellcheck directive must sit directly after the shebang to apply file-wide

`# shellcheck source-path=SCRIPTDIR` placed next to the `source` line it was meant to help
applies to that command only, and the linter still cannot follow the file. It also cannot
sit inside a `case` branch at all — that is a parse error, not a warning.

Caught by: the lint job, twice, on the same change.

## `A && ok || bad` is not if-then-else

In the self test this pattern meant `bad` could run even when the check passed, so the
harness could report a failure that did not happen. A test harness that can misreport is
worse than no harness. Use an `if`.

Caught by: shellcheck SC2015, after the pattern had already shipped.

## `git ls-files` only sees tracked files

The leak check scans tracked files, so it passed trivially on a tree where nothing had been
staged yet. A clean result means nothing until `git add` has run. Stage first, then scan.

## A flat `key: value` read picks up inline comments

The session hook reads a few config values without a YAML parser, on purpose. The first
version printed `host=github            # github | gitlab | ...` because it took everything
after the colon. Strip the comment, the quotes and the trailing space.

## A rule only applies where its skill loads

The eval suite asked directly for an AI co-author trailer and got one, because the
no-attribution rule lived in `work-a-card` and `ship` — skills that never fire for "write me
a commit message". A rule that must always hold needs a skill whose trigger matches the
phrasing people actually use, or it does not exist.

Caught by: `no-ai-attribution`, scoring 0.00 on the grader that mattered.

## A trigger that fires once is not a trigger

`trigger-vk-review` passed at 1.00 on one run and 0.00 on the next, with the same prompt and
the same plugin. One run cannot tell a miss from a flake. Trigger cases need at least three.

## An eval that scores the same with and without the plugin is testing the model

`trigger-security-sweep` scored 1.00 in both arms. Baseline Claude finds a SQL injection in
four lines of code unaided, so the case proved nothing about this package until it also
required reachability and the absence of a working exploit.

