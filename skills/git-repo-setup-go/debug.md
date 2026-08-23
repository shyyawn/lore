# Debug — Go

Hub: `git-repo-setup` [debug.md](../git-repo-setup/debug.md). This file is
the Go JSON. Cursor / VS Code / Zed consume it. Recommend `golang.go`.
`command -v dlv`; install: [hub `dlv`](../git-repo-setup/debug.md#dlv). Do
not pin `dlv` in the app `.mise.toml`. `*.cue` without `cue`:
[hub `cue`](../git-repo-setup/debug.md#cue) — no CUE extension.

## `encore.app`

Do **not** F5 / Launch Package / Zed F4 on a service package. Official:
[Debug with Delve](https://encore.dev/docs/go/how-to/debug). Zed:
[Go debugging](https://zed.dev/docs/languages/go#debugging).

```bash
encore run --debug=break
```

Delve on `127.0.0.1:2345`. Temporal: attach to Encore, not the Temporal CLI.

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

Do not: `go run`, `dlv debug ./<service>`, or Go: Debug Test on an
`//encore:api` package. Traces (`:9400`, MCP `get_traces`) for request
failures; Delve for a line.

## Tests

Connect to Encore does not run tests. Merge names; do not replace attach.

| Package | Debug how |
| --- | --- |
| No Encore init (`workflow/`, `cmd/` tests) | `mode: test`, or Go **debug test** CodeLens |
| Service package (`//encore:api`, `config.Load`, `encore.Meta()`, primitives at init) | `encore test ./<pkg>` only |

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

One config per such package, `name` = `Debug tests: <path>`. Scan
`*_test.go` parents; skip packages that call Encore at init. Plain Go:
CodeLens, or named configs for packages humans debug often.

## Plain Go (`cmd/` or `package main`)

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

`program` = the `main` package. Several binaries: one config per
`cmd/<name>`. `go.work`: include the module path under
`${workspaceFolder}`. dotenv (no Encore CUE): `"envFile":
"${workspaceFolder}/.env"`. One Launch per binary.

## `extensions.json`

`golang.go`, `golangci.golangci-lint-vscode`, plus hub
[scan](../git-repo-setup/debug.md#scan-extensions).

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
