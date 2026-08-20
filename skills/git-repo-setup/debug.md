# Debug (Cursor / VS Code)

Every new repo ships a **shared** debugger config. Humans and agents use the
same attach/launch names. Cursor is the VS Code debug UI (`Ctrl+Shift+D`).

Language overlay writes the configurations: [git-repo-setup-go/debug.md](../git-repo-setup-go/debug.md),
[git-repo-setup-typescript/debug.md](../git-repo-setup-typescript/debug.md),
[git-repo-setup-python/debug.md](../git-repo-setup-python/debug.md).

## Committed files

Write both on a **new** repo. If `.vscode/` already exists, **merge** named
configs and recommendations; do not wipe custom ones. Missing file on an
existing repo: add it (same as a missing Justfile recipe).

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
- [ ] Each package.json that is a real app (has vitest / vite / svelte.config / a debug script)
      → Node configs with cwd = that package dir (not the Git root if the app is nested)
- [ ] pyproject.toml / pytest → Python configs with cwd = that project dir
- [ ] Existing launch.json → keep every existing name; append only missing names
- [ ] Unique name per config (vitest web vs vitest api if two packages)
```

```
extensions.json:
- [ ] Union of overlay recommendations (golang.go, ms-python.python, …)
- [ ] Dedup by extension id
```

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
