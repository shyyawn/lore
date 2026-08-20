# Debug (Cursor / VS Code)

Shared `.vscode/launch.json` + `extensions.json` at the Git root. Overlay
fills JSON: [git-repo-setup-go/debug.md](../git-repo-setup-go/debug.md),
[git-repo-setup-typescript/debug.md](../git-repo-setup-typescript/debug.md),
[git-repo-setup-python/debug.md](../git-repo-setup-python/debug.md).
Templates: [files.md](files.md). App attach does not run tests — overlay
adds a test config.

One `launch.json`, one `extensions.json`. Merge named configs and ids;
do not replace. Omit `extensions.json` only if the scan union is empty.

| File | Commit |
| --- | --- |
| `.vscode/extensions.json` | yes |
| `.vscode/launch.json` | yes |
| `.vscode/settings.json` | no (unless the team already shares it) |
| `*.code-workspace` | no |

Do not gitignore `.vscode/`. Ignore `*.code-workspace`.

## Decide

Workspace root = Git root (`git rev-parse --show-toplevel`). Never a
per-package `.vscode/`. Existing repo: fill the gap, same list.

```
launch.json:
- [ ] Git root
- [ ] encore.app → Connect to Encore (do not Launch Encore packages)
- [ ] each cmd/<name> (non-Encore) → Launch that binary
- [ ] Go tests with no Encore init → Debug tests: <path> (`mode: test`)
- [ ] Encore service package tests → encore test only (no mode: test)
- [ ] package.json app → Node, cwd = that dir
- [ ] vitest → vitest <dir>; else node --test if that is the suite
- [ ] pytest (or unittest if that is the suite)
- [ ] keep existing names; append missing; unique names
```

```
extensions.json:
- [ ] Git root, next to launch.json
- [ ] overlay defaults + [Scan](#scan-extensions); dedup by id
- [ ] keep existing ids; append missing
- [ ] skip only if union is empty
```

```
editor CLIs (machine, not the repo .mise.toml):
- [ ] Go overlay → command -v dlv; if missing: [dlv](#dlv)
- [ ] *.cue and cue missing → [cue](#cue) (optional; Encore does not need it)
```

## `dlv`

Required for a Go `launch.json`.

```bash
command -v dlv
# missing:
GOBIN="${HOME}/.local/bin" go install github.com/go-delve/delve/cmd/dlv@VERSION
```

Pin a module tag (`v1.27.1`), not `@latest`. Do not pin `dlv` in the app
`.mise.toml`.

## `cue`

Do not add a CUE extension ([Scan](#scan-extensions)). If `*.cue` exists
and `command -v cue` fails:

```bash
mise use -g cue@VERSION
```

Skip when there are no `*.cue` files.

## Scan extensions

Skip `node_modules/`, `vendor/`, `.encore/`. Add every hit. Do not invent
ids from a blog list.

| Detect | Add |
| --- | --- |
| `go.mod` / `*.go` / `encore.app` | `golang.go` |
| `pyproject.toml` / `*.py` | `ms-python.python` |
| Ruff (overlay default; not Black-as-formatter) | `charliermarsh.ruff` |
| `svelte.config.*` | `svelte.svelte-vscode` (skip if the Cursor Svelte plugin is the team install) |
| `.mise.toml` / `*.toml` | `tombi-toml.tombi` |
| `biome.json` / `biome.jsonc` | `biomejs.biome` |
| `eslint.config.*` | `dbaeumer.vscode-eslint` |
| `.prettierrc*` / `prettier` in package.json | `esbenp.prettier-vscode` |
| `.golangci.yml` / golangci-lint in mise or `tool` | `golangci.golangci-lint-vscode` |
| `Justfile` / `justfile` | `nefrob.vscode-just` |

**Do not add:** CUE extension, `tamasfe.even-better-toml`, Encore/Temporal
marketplace plugins (`/add-plugin`), GitLens, Error Lens, themes, Pylance
as a second id, Vitest Explorer.

## Do not

- Pin `dlv` or `cue` in the app `.mise.toml`.
- A second `launch.json` under a package directory.
- Commit `go.alternateTools`.
- `--inspect` / `print()` as the team debugger.
