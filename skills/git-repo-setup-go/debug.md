# Debug — Go

Shared Cursor mechanics: `git-repo-setup` [debug.md](../git-repo-setup/debug.md).
This file is the Go `launch.json` / `extensions.json`.

Recommend `golang.go`. It offers Delve on first debug; otherwise
`go install github.com/go-delve/delve/cmd/dlv@latest`. Do not pin `dlv` in
the app `.mise.toml`.

## `encore.app` (default for this overlay when present)

Do **not** F5 / Launch Package. No `main`; Encore primitives panic outside
`encore run` / `encore test`. Official:
[Debug with Delve](https://encore.dev/docs/go/how-to/debug).

```bash
encore run --debug=break
```

Headless Delve listens on `127.0.0.1:2345`. Temporal seam: start
`temporal server start-dev` first; attach to Encore, not the Temporal CLI.

`.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Connect to Encore",
      "type": "go",
      "request": "attach",
      "mode": "remote",
      "remotePath": "${workspaceFolder}",
      "port": 2345,
      "host": "127.0.0.1"
    }
  ]
}
```

Run and Debug → **Connect to Encore** → green play. Set breakpoints (`F9`),
then hit the API. The in-process Temporal worker is this process; prefer
breakpoints in API handlers and activities, not workflow replay.

Alternate: `encore run --debug` prints a PID — attach local process. Use
when the app must stay up before the debugger connects.

Do not: `go run`, `dlv debug ./<service>`, or Go: Debug Test on an
`//encore:api` package (that runs `go test`). Request traces (`:9400`,
Encore MCP `get_traces`) are the other local debug path.

## Tests

**Connect to Encore does not run tests.** Add `mode: test` configs next to
it. Merge names; do not replace the attach config.

| Package | Debug how |
| --- | --- |
| No Encore init (`workflow/`, `cmd/` tests, a module without `config.Load` / `encore.Meta()` / `sqldb` at package scope) | `mode: test` in `launch.json`, or the Go extension **debug test** CodeLens |
| Encore service package (`//encore:api`, `config.Load`, `encore.Meta()`, other primitives at init) | `encore test ./<pkg>` only. There is no `encore test --debug=break`. CodeLens debug test runs `go test` and panics |

```json
{
  "name": "Debug tests: fees/workflow",
  "type": "go",
  "request": "launch",
  "mode": "test",
  "program": "${workspaceFolder}/fees/workflow",
  "args": ["-test.v"]
}
```

One config per such package, `name` = `Debug tests: <path>`. `program` is
the package directory. Scan `*_test.go` parents; skip any package whose
non-test files call Encore at init.

Plain Go (no `encore.app`): one `mode: test` per package with tests, or
rely on CodeLens. Still add named configs for packages humans debug often.

## Plain Go (`cmd/` or a `package main`)

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch",
      "type": "go",
      "request": "launch",
      "mode": "auto",
      "program": "${workspaceFolder}/cmd/<name>"
    }
  ]
}
```

Point `program` at the real `main` package. Several binaries: one config
per `cmd/<name>`, `name` = that binary. `go.work`: `program` includes the
module path under `${workspaceFolder}`. Tests: [Tests](#tests) above.

If the process reads dotenv (`.env` / `.env.local` exists, no Encore CUE):
set `"envFile": "${workspaceFolder}/.env"` (or `.env.local` if that is
the committed convention). Do not invent `--env` flags. Do not copy a
debug config per Kafka consumer / country; one Launch per binary.

## `extensions.json`

`golang.go` and `golangci.golangci-lint-vscode` (the overlay writes
`.golangci.yml` unless a linter already exists), plus
[scan](../git-repo-setup/debug.md#scan-extensions) hits (`.mise.toml` →
Tombi, `Justfile` → `nefrob.vscode-just`). Do not add a CUE extension
for `config.cue`.

```json
{
  "recommendations": [
    "golang.go",
    "golangci.golangci-lint-vscode",
    "tombi-toml.tombi",
    "nefrob.vscode-just"
  ]
}
```
