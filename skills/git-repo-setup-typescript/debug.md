# Debug — TypeScript

Hub: `git-repo-setup` [debug.md](../git-repo-setup/debug.md). This file is
the TypeScript JSON. Cursor / VS Code / Zed consume it. Do not add a
second JS debugger. Add test configs next to app launch. Merge names.

| Detect | App | Tests |
| --- | --- | --- |
| `next` | [Next.js](#nextjs) | vitest if present, else jest |
| `expo` | [Expo](#expo) | `jest-expo` / jest |
| `@sveltejs/kit` | [SvelteKit](#sveltekit) | vitest |
| `svelte.config` without Kit | [Vite + Svelte](#vite--svelte) | vitest |
| Node lib | [Node / app](#node--app) | vitest, else `node --test` |

## Tests

| Suite | Config |
| --- | --- |
| Vitest | `vitest current file` / `vitest <dir>` |
| Jest / `jest-expo` | `jest current file` |
| `node --test` | `"args": ["--test", "${relativeFile}"]` |
| Encore.ts | `encore test` (do not add Go Connect to Encore) |
| Playwright | `npx playwright test --debug`. Not a launch config |

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

```json
{
  "name": "jest current file",
  "type": "node",
  "request": "launch",
  "program": "${workspaceFolder}/node_modules/jest/bin/jest.js",
  "args": ["--runInBand", "${relativeFile}"],
  "cwd": "${workspaceFolder}",
  "console": "integratedTerminal"
}
```

Nested `package.json`: `cwd` / `program` = that package, `name` =
`vitest <dir>` or `jest <dir>`. Honor `"debug"` / `"test"` scripts.

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

## Next.js

Official: [Debugging](https://nextjs.org/docs/app/guides/debugging).
Honor the lockfile. Nested: `"cwd": "${workspaceFolder}/apps/web"`.

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Next.js: debug server-side",
      "type": "node-terminal",
      "request": "launch",
      "command": "npm run dev -- --inspect"
    },
    {
      "name": "Next.js: debug client-side",
      "type": "chrome",
      "request": "launch",
      "url": "http://localhost:3000"
    },
    {
      "name": "Next.js: debug full stack",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/node_modules/next/dist/bin/next",
      "runtimeArgs": ["--inspect"],
      "skipFiles": ["<node_internals>/**"],
      "serverReadyAction": {
        "action": "debugWithChrome",
        "killOnServerStop": true,
        "pattern": "- Local:.+(https?://.+)",
        "uriFormat": "%s",
        "webRoot": "${workspaceFolder}"
      }
    }
  ]
}
```

Plus [Tests](#tests). Do not add Firefox Debugger.

## Expo

Official: [Tools](https://docs.expo.dev/debugging/tools). One **attach**.
Do not launch.

```bash
npx expo start
# then i (simulator) or a (emulator), or scan the QR
```

```json
{
  "name": "Debug Expo app",
  "type": "expo",
  "request": "attach",
  "projectRoot": "${workspaceFolder}",
  "bundlerHost": "127.0.0.1",
  "bundlerPort": "8081"
}
```

```json
{
  "name": "Expo: debug web",
  "type": "chrome",
  "request": "launch",
  "url": "http://localhost:8081",
  "webRoot": "${workspaceFolder}"
}
```

Plus `jest current file`. Nested: `projectRoot` = that package. Do not
add `type: reactnative`.

## SvelteKit

Official: [Breakpoint Debugging](https://svelte.dev/docs/kit/debugging).
Honor the lockfile. Nested: `"cwd": "${workspaceFolder}/apps/web"`.

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "SvelteKit: debug",
      "type": "node-terminal",
      "request": "launch",
      "command": "npm run dev"
    },
    {
      "name": "SvelteKit: debug client-side",
      "type": "chrome",
      "request": "launch",
      "url": "http://localhost:5173"
    },
    {
      "name": "SvelteKit: debug (node)",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/node_modules/vite/bin/vite.js",
      "args": ["dev"],
      "cwd": "${workspaceFolder}",
      "console": "integratedTerminal"
    }
  ]
}
```

Plus `vitest current file`. `{@debug}` / `$inspect` stay in the plugin.
Do not add a compound or `vavite`.

## Vite + Svelte

No `@sveltejs/kit`. Same Vite command. Do not add Kit.

```json
{
  "name": "Vite: debug",
  "type": "node-terminal",
  "request": "launch",
  "command": "npm run dev"
}
```

Chrome and `Vite: debug (node)` match SvelteKit, `Vite:` prefix.

## `extensions.json`

Hub [scan](../git-repo-setup/debug.md#scan-extensions). Svelte:
`svelte.svelte-vscode` unless the Cursor Svelte plugin is the team
install. Next: no extra id.

```json
{
  "recommendations": [
    "svelte.svelte-vscode",
    "expo.vscode-expo-tools",
    "biomejs.biome",
    "tombi-toml.tombi",
    "nefrob.vscode-just"
  ]
}
```
