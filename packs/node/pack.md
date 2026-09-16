# Pack: node

## Detection

`package.json`. Read its `scripts` block — it is authoritative.

## Commands

| Purpose | Default |
|---|---|
| test (all) | `npm test` |
| test (filtered) | `npm test -- {filter}` |
| lint | `npm run lint` |
| format | `npm run format` |
| build | `npm run build` |

Use the project's package manager: check for `pnpm-lock.yaml`, `yarn.lock`, or `bun.lockb`
before defaulting to npm. Mixing managers corrupts the lockfile.

## Characteristic failure modes

- A dev server and a production build writing the same output directory at once leaves a
  broken state that fails silently at runtime.
- Floating dependency ranges make an unattended run non-reproducible. Install from the
  lockfile.
- Async work started and not awaited passes tests and loses data in production.
- Framework caching keyed on the request path alone leaks between users when the response
  depends on a header.
