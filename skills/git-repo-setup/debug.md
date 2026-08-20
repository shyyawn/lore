# Debug (Cursor / VS Code)

Every new repo ships a **shared** debugger config. Humans and agents use the
same attach/launch names. Cursor is the VS Code debug UI (`Ctrl+Shift+D`).

Language overlay writes **app and test** configurations:
[git-repo-setup-go/debug.md](../git-repo-setup-go/debug.md),
[git-repo-setup-typescript/debug.md](../git-repo-setup-typescript/debug.md),
[git-repo-setup-python/debug.md](../git-repo-setup-python/debug.md).
App attach/launch does not run tests — each overlay adds a separate test
config.

## Committed files

Write **both** `.vscode/launch.json` and `.vscode/extensions.json`.
`extensions.json` is overlay defaults **plus** a file scan ([Scan](#scan-extensions)).
Omit `extensions.json` only when the union of ids is empty. A kit
TypeScript repo writes `.mise.toml`, Justfile, and `biome.json`, so that
union is not empty.
Polyglot: one file, union of ids. Missing file on an existing repo: add it.
Existing file: keep every id, append missing ones.

| File | Commit | Role |
| --- | --- | --- |
| `.vscode/extensions.json` | yes | Recommended extensions so F5 works |
| `.vscode/launch.json` | yes | Shared launch/attach configs |
| `.vscode/settings.json` | no | Personal unless the team already shares it |
| `*.code-workspace` | no | Personal |

Do not gitignore `.vscode/`. Ignore only `*.code-workspace`.

Templates: [files.md](files.md) (`.vscode`). Overlay fills `configurations`
and `recommendations`.

Polyglot and monorepos: still **one** `launch.json` at the Git root. How
to fill it: [Decide](#decide).

## Decide

Cursor reads `.vscode/` from the **workspace root**. That must be the Git
root (`git rev-parse --show-toplevel`), next to `Justfile` / `.mise.toml` /
`encore.app`. Never a per-package `.vscode/launch.json`.

Inventory first. Then apply every matching overlay and **merge**. Same
procedure on an **existing** repo (fill the gap; do not wait for greenfield).

```
launch.json:
- [ ] Git root (not apps/web, not a Go service dir)
- [ ] encore.app → add Connect to Encore. Do not Launch Encore packages.
- [ ] Each extra package main (cmd/<name>, non-Encore) → Launch named after that binary, program = that dir
- [ ] Each Go package with tests and no Encore init → Debug tests: <path> (`mode: test`). Skip service packages that Load config / Meta / sqldb at init — those are `encore test` only
- [ ] Each package.json that is a real app (has vite / svelte.config / a debug script)
      → Node launch with cwd = that package dir
- [ ] Each package.json with vitest → vitest <dir>; else `node --test` if that is the suite
- [ ] pyproject.toml / pytest → Python: pytest (unittest instead if that is the suite)
- [ ] Existing launch.json → keep every existing name; append only missing names
- [ ] Unique name per config (vitest web vs vitest api if two packages)
```

```
extensions.json:
- [ ] Git root, next to launch.json. Create if missing.
- [ ] Overlay defaults + [Scan](#scan-extensions) hits. Dedup by id.
- [ ] Keep ids already in the file; append missing ones.
- [ ] Skip the file only if the union is empty
```

## Scan extensions

Inventory committed files (skip `node_modules/`, `vendor/`, `.encore/`).
Add every hit. Do not invent extras from a 2026 blog list.

| Detect | Add | Notes |
| --- | --- | --- |
| `go.mod` / `*.go` / `encore.app` | `golang.go` | gopls + Delve |
| `pyproject.toml` / `*.py` | `ms-python.python` | Debugger (debugpy). Pulls Pylance; do not also list Pylance |
| Ruff in the Python overlay (`ruff` in `pyproject.toml` / mise, no Black-as-formatter) | `charliermarsh.ruff` | 2026 Python lint/format in the editor |
| `svelte.config.*` | `svelte.svelte-vscode` | Skip if the Cursor Svelte plugin is already the team install |
| `.mise.toml` / `*.toml` | `tombi-toml.tombi` | 2026 TOML. Not Even Better TOML |
| `biome.json` / `biome.jsonc` | `biomejs.biome` | TS overlay default formatter |
| `eslint.config.*` | `dbaeumer.vscode-eslint` | Only when ESLint is already the repo's linter |
| `.prettierrc*` / `prettier` in package.json | `esbenp.prettier-vscode` | Only when Prettier is already the formatter |
| `.golangci.yml` / `golangci-lint` in mise or `go.mod` `tool` | `golangci.golangci-lint-vscode` | Go overlay default. Add the linter first if the repo has none |
| `Justfile` / `justfile` | `nefrob.vscode-just` | Kit task runner; syntax, not a second runner |

**Do not add**

| Temptation | Why |
| --- | --- |
| CUE (`cuelang.org.cue` or similar) because of `*.cue` | Prompts for a `cue` CLI. Encore evaluates `config.cue`. Optional global `cue` is personal, not a repo recommendation |
| `tamasfe.even-better-toml` | Stale; Tombi is the 2026 TOML extension |
| Encore / Temporal marketplace plugins | `/add-plugin`, not `extensions.json` |
| GitLens, Error Lens, themes, YAML-for-K8s, Pylance as a second id, Vitest Explorer | Not this kit. Python extension already suggests Pylance. Vitest is the launch config |
| Committed `go.alternateTools` / `go.lintTool` in `settings.json` | Mise shim paths are per-machine. golangci-lint is the VS Code extension + `just check` |

## One Git-root launch.json

Go + TypeScript in one repo is the common case (Encore + Svelte, or
`cmd/` + `web/`). One file, both `type: go` and `type: node` entries.
Do not write two launch files. Do not add a compound "launch all" config
unless the repo already documents starting frontend and API together.

Monorepo does **not** change the Encore rule: many services, one
`encore.app`, one attach. JS workspaces (pnpm/npm) do not get a launch
file per package. Point `cwd` / `program` at the package; keep the JSON
at the Git root.

`go.work` / several `go.mod`: still one `.vscode/` at the Git root.
`program` is `${workspaceFolder}/<module>/cmd/<name>`. Follow
`go-mono-repo` for modules; do not invent a launch config per module
that has no `main`.

If the user opened a subdirectory as the Cursor workspace, still write
`.vscode/` at the Git root and say so. A second launch.json in the
subdir is the bug.

## Breakpoints

Click the gutter or `F9`. Red = bound. Grey = debugger could not bind
(wrong config, not attached, optimized out).

Step: `F10` over, `F11` into, `Shift+F11` out, `F5` continue. Locals and
watches are in the debug pane.

Pick the overlay's named config in Run and Debug, then green play. Do not
F5 an auto "Launch Package" / "Launch current file" when the overlay says
to **attach**.

## Do not

- Pin editor CLIs (`dlv`, `cue`) in the app `.mise.toml`. Extensions install
  them, or the human installs globally (`mise use -g`).
- Add a second `launch.json` under a package directory.
- Document `--inspect` / `print()` as the team debugger.
