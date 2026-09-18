# Pack: rust

## Detection

`Cargo.toml`.

## Commands

| Purpose | Default |
|---|---|
| test (all) | `cargo test` |
| test (filtered) | `cargo test {filter}` |
| lint | `cargo clippy -- -D warnings` |
| format | `cargo fmt` |
| build | `cargo build --release` |

## Characteristic failure modes

- A lock held across an await point, which blocks the executor.
- Unwrap on a path that can legitimately fail at runtime.
- A blocking call inside an async task.
- Unbounded channels used as queues, which trade a crash for unbounded memory growth.
