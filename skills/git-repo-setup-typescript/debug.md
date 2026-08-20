# Debug — TypeScript

Shared Cursor mechanics: `git-repo-setup` [debug.md](../git-repo-setup/debug.md).
This file is the TypeScript `launch.json` / `extensions.json`.

Cursor already debugs Node. Do not add a second JS debugger extension.

**Launch current file / Vite does not run the test suite.** Add test
configs next to them. Merge names.

## Tests

| Suite | Debug how |
| --- | --- |
| Vitest | `vitest current file` / `vitest <dir>` in `launch.json`. Breakpoints in the test file and source. |
| `node --test` | Node launch with `"args": ["--test", "${relativeFile}"]` (no vitest in the repo) |
| Encore.ts | `encore test` (and Vitest `commandLine` `encore test` if that is already the suite). Do not add Go **Connect to Encore**. |

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

If `package.json` is not at the Git root, set `cwd` and vitest `program`
to that package. Several JS packages: one vitest config per package that
has vitest, `name` = `vitest <dir>`. Drop vitest if the repo has none.
`node --test` only when that is the suite.

Honor `package.json` `"debug"` / `"test"` scripts — point a named config
at that script instead of inventing a parallel entry.

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

Plus the [Tests](#tests) vitest (or `node --test`) config. Nested app:
`cwd` = that package dir.

## Svelte / Vite

Honor the Svelte plugin. Add a Node launch of the Vite (or `vite dev`)
script the repo already uses. Do not add a Chrome-only config unless the
app is a static SPA with no Node server.

## `extensions.json`

Scan: [git-repo-setup debug.md](../git-repo-setup/debug.md#scan-extensions).
Omit the file only when the union of ids is empty. Do not write
`"recommendations": []`. A kit TS repo has `.mise.toml`, Justfile, and
`biome.json`, so Tombi + Just + Biome are in the union.

Svelte app: add `svelte.svelte-vscode` only if the Cursor Svelte plugin is
not already installed. Vitest UI is optional; the launch config above is
enough for breakpoints.
