# Debug — TypeScript

Shared Cursor mechanics: `git-repo-setup` [debug.md](../git-repo-setup/debug.md).
This file is the TypeScript `launch.json` / `extensions.json`.

Cursor already debugs Node. Do not add a second JS debugger extension.

## Node / Vitest

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
    },
    {
      "name": "vitest current file",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/node_modules/vitest/vitest.mjs",
      "args": ["run", "${relativeFile}"],
      "cwd": "${workspaceFolder}",
      "console": "integratedTerminal"
    }
  ]
}
```

If `package.json` is not at the Git root, set `cwd` (and vitest
`program`) to that package directory. Several JS packages: one vitest
config per package that has vitest, `name` = `vitest <dir>`.

Drop the vitest config if the repo has no `vitest`. Honor `package.json`
`"debug"` scripts — point a named config at that script (`runtimeExecutable`
+ `runtimeArgs`) instead of inventing a parallel entry.

`node --test`: same shape with `"program": "${file}"` and the test file
open, or `"args": ["--test", "${relativeFile}"]` on `node`.

## Svelte / Vite

Honor the Svelte plugin. Add a Node launch of the Vite (or `vite dev`)
script the repo already uses. Do not add a Chrome-only config unless the
app is a static SPA with no Node server.

## `extensions.json`

```json
{
  "recommendations": []
}
```

Svelte app: add `svelte.svelte-vscode` only if the Cursor Svelte plugin is
not already installed. Vitest UI is optional; the launch config above is
enough for breakpoints.
