# Pack: dotnet

## Detection

`*.sln`, `*.csproj`, or `*.fsproj`.

## Commands

| Purpose | Default |
|---|---|
| test (all) | `dotnet test` |
| test (filtered) | `dotnet test --filter {filter}` |
| lint | `dotnet format --verify-no-changes` |
| format | `dotnet format` |
| build | `dotnet build` |

## Characteristic failure modes

- Async work forced to run synchronously, which deadlocks under load.
- A scoped service captured by a singleton, which then holds a dead dependency.
- A database context shared across threads.
- Deferred queries evaluated after the connection closes, or evaluated twice by accident.
