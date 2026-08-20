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
module path under `${workspaceFolder}`. Tests: open a `_test.go` and use
Go: Debug Test only when the package does **not** import Encore
primitives.

## `extensions.json`

```json
{
  "recommendations": ["golang.go"]
}
```
