# Adapter: Trello

Queues are lists. Works through either the connector the agent already has, or the REST
API with a key and token supplied as secrets.

## Queue mapping

`init` reads the board and proposes a mapping by meaning, not by name:

| Queue | Typical list |
|---|---|
| ready | the triage or ready list |
| review | the review or pull-request list |
| parked | the needs-input list |
| filed by sweep | the intake list |

Store the resolved list identifiers in the config. Re-resolve them if a lookup fails —
lists get renamed.

## Verbs

| Verb | REST |
|---|---|
| fetch | `GET /1/lists/{listId}/cards` |
| claim | `PUT /1/cards/{id}` adding the running label |
| comment | `POST /1/cards/{id}/actions/comments` |
| move | `PUT /1/cards/{id}?idList={destination}` |

## Notes

- **Multi-target cards.** Where one board feeds several repositories, a card carrying two
  repository labels would be implemented twice. Detect that case, park the card with an
  explanation, and exclude it from the run.
- Labels carry both severity and kind. Read them; do not infer severity from wording.

## Running it from the orchestrator

Shipped as `scripts/lib/board-trello.sh`, so the shell fetches, claims and moves. The agent
never holds the board credential.

| | |
|---|---|
| Credentials | `TRELLO_API_KEY`, `TRELLO_TOKEN` |
| Config | `board.settings.lists.<role>` — list ids, and `board.settings.claim_label_id` |

Set `board.adapter: trello` and map every queue role under `board.queues`.
`scripts/validate-config.sh` fails when a required setting is missing, so a half-configured
board is caught before the first scheduled run rather than at two in the morning.

