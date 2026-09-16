# Pack: go

## Detection

`go.mod`.

## Commands

| Purpose | Default |
|---|---|
| test (all) | `go test ./...` |
| test (filtered) | `go test ./... -run {filter}` |
| lint | `golangci-lint run` |
| format | `gofmt -w .` |
| build | `go build ./...` |

Run tests with `-race` where the project's own CI does.

## Characteristic failure modes

- A returned error assigned and never checked.
- A goroutine that outlives its caller with no cancellation path.
- A loop variable captured by a closure or a goroutine.
- A deferred close inside a loop, holding every handle until the function returns.
