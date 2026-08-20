# Debug Encore Go

Repo kit writes the attach config: `git-repo-setup-go`
[debug.md](../git-repo-setup-go/debug.md). Official:
[Debug with Delve](https://encore.dev/docs/go/how-to/debug).

Encore-only traps (do not F5 even if a `launch.json` is missing):

- No `main`. `encore run --debug=break`, then **Connect to Encore**.
- `encore test`, not Go: Debug Test.
- Temporal CLI is the cluster. The worker is the Encore process.
- Traces (`:9400`, MCP `get_traces`) for "why did this request fail";
  Delve for "stop on this line".
