# Debug Encore Go

Kit: `git-repo-setup-go` [debug.md](../git-repo-setup-go/debug.md). Official:
[Debug with Delve](https://encore.dev/docs/go/how-to/debug).

Encore traps (do not F5 / Zed F4 even if `launch.json` is missing):

- No `main`. `encore run --debug=break`, then **Connect to Encore**.
- Tests with no Encore init: `mode: test` (`git-repo-setup-go` debug.md).
- Service-package tests: `encore test ./<pkg>` — not Go: Debug Test / Zed F4.
- Temporal CLI is the cluster. The worker is the Encore process.
- Traces (`:9400`, MCP `get_traces`) vs Delve (a line).
- `golangci-lint` `unused` on `initService` / `config.Load`: exclusions in
  `git-repo-setup-go` `.golangci.yml`. Do not delete those symbols.
