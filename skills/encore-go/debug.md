# Debug Encore Go

Repo kit writes the attach config: `git-repo-setup-go`
[debug.md](../git-repo-setup-go/debug.md). Official:
[Debug with Delve](https://encore.dev/docs/go/how-to/debug).

Encore-only traps (do not F5 even if a `launch.json` is missing):

- No `main`. `encore run --debug=break`, then **Connect to Encore**.
- Tests in a subpackage with no Encore init: Delve `mode: test` (`git-repo-setup-go` debug.md).
- Tests in a service package: `encore test ./<pkg>` — not Go: Debug Test
  (`go test` panics; Encore has no test `--debug=break`).
- Temporal CLI is the cluster. The worker is the Encore process.
- Traces (`:9400`, MCP `get_traces`) for "why did this request fail";
  Delve for "stop on this line".
- `golangci-lint` `unused` on `initService` / `config.Load`: Encore
  exclusions in `git-repo-setup-go` `.golangci.yml`. Do not delete those
  symbols.
