# Pack: python

## Detection

`pyproject.toml`, `requirements.txt`, `setup.cfg`, or `tox.ini`.

## Commands

| Purpose | Default |
|---|---|
| test (all) | `pytest` |
| test (filtered) | `pytest -k {filter}` |
| lint | `ruff check .` |
| format | `ruff format .` |
| build | *usually none* |

Detect the environment manager before running anything: `uv`, `poetry`, `pipenv`, or a
plain virtualenv. Running outside the project's environment produces import errors that
look like code bugs.

## Characteristic failure modes

- A mutable default argument shared across every call.
- Fetching related rows inside a loop over query results, with lazy loading hiding it.
- Blocking calls inside async handlers, which stall the whole event loop.
- Test isolation lost through module-level state that survives between tests.
