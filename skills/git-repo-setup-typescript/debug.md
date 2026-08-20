# Debug — TypeScript

Hub: `git-repo-setup` [debug.md](../git-repo-setup/debug.md). Cursor
debugs Node; do not add a second JS debugger. Add test configs next to
app launch. Merge names.

## Tests

| Suite | Config |
| --- | --- |
| Vitest | `vitest current file` / `vitest <dir>` |
| `node --test` | `"args": ["--test", "${relativeFile}"]` |
| Encore.ts | `encore test` (do not add Go Connect to Encore) |

```json
{
  "name": "vitest current file",
  "type": "node",
  "request": "launch",
  "program": "${workspaceFolder}/node_modules/vitest/vitest.mjs",
  "args": ["run", "${relativeFile}"],
  "cwd": "${workspaceFolder}",
  "console": "integratedTerminal"
}
```

Nested `package.json`: set `cwd` / `program` to that package. One vitest
config per package that has vitest, `name` = `vitest <dir>`. Honor
existing `"debug"` / `"test"` scripts.

## Node / app

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch current file",
      "type": "node",
      "request": "launch",
      "program": "${file}",
      "cwd": "${workspaceFolder}",
      "console": "integratedTerminal"
    }
  ]
}
```

Plus the [Tests](#tests) config. Nested app: `cwd` = that package dir.

## Svelte / Vite

Honor the Svelte plugin. Launch the Vite script the repo already uses.
Chrome-only only for a static SPA with no Node server.

## `extensions.json`

Hub [scan](../git-repo-setup/debug.md#scan-extensions). Omit the file only
if the union is empty (a kit TS repo is not). Svelte:
`svelte.svelte-vscode` unless the Cursor Svelte plugin is the team install.
