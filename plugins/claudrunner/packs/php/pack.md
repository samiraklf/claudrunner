# Pack: php

## Detection

`composer.json`.

## Commands

| Purpose | Default |
|---|---|
| test (all) | `vendor/bin/phpunit` |
| test (filtered) | `vendor/bin/phpunit --filter {filter}` |
| lint | `vendor/bin/phpstan analyse` |
| format | `vendor/bin/php-cs-fixer fix` |
| build | *usually none* |

Frameworks commonly wrap these — check the project's own scripts and CI before defaulting.

## Characteristic failure modes

- Related records fetched inside a loop instead of eager-loaded.
- A whole request body assigned to a record's fields.
- A background job whose timeout exceeds the queue's retry window, so it runs twice.
- A migration that rewrites a large table and locks it for the duration.
