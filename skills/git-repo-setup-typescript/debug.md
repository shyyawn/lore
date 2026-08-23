# Debug — TypeScript

Hub: `git-repo-setup` [debug.md](../git-repo-setup/debug.md). Cursor, VS
Code, and Zed debug Node; do not add a second JS debugger. Add test configs
next to app launch. Merge names.

Sources: Next [Debugging](https://nextjs.org/docs/app/guides/debugging),
Expo [Tools](https://docs.expo.dev/debugging/tools), Expo Tools
`type: expo` attach. Not React Native Tools. Not Radon.

| Detect | App | Tests |
| --- | --- | --- |
| `next` | [Next.js](#nextjs) | vitest if present, else jest |
| `expo` | [Expo](#expo) (iOS / Android / device) | `jest-expo` / jest |
| Vite / Svelte | [Svelte / Vite](#svelte--vite) | vitest |
| Node lib | [Node / app](#node--app) | vitest, else `node --test` |

## Tests

| Suite | Config |
| --- | --- |
| Vitest | `vitest current file` / `vitest <dir>` |
| Jest / `jest-expo` | `jest current file` |
| `node --test` | `"args": ["--test", "${relativeFile}"]` |
| Encore.ts | `encore test` (do not add Go Connect to Encore) |
| Playwright | `npx playwright test --debug` (official Playwright skills). Not a launch config |

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

Nested `package.json`: set `cwd` / `program` to that package. One vitest
or jest config per package that has that runner, `name` = `vitest <dir>`
or `jest <dir>`. Honor existing `"debug"` / `"test"` scripts. Expo:
`jest-expo` is still this jest config.

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

Official minus Firefox (that needs an extra extension). Honor the
lockfile (`pnpm dev --inspect` / `yarn dev --inspect`). Nested app:
`"cwd": "${workspaceFolder}/apps/web"`. Port not 3000: change the URL.

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

Plus the [Tests](#tests) config. `debugWithChrome` is the house pick
(official default is Edge). Do not add Firefox Debugger.

Zed runs the `type: node` full-stack name. `node-terminal` / Chrome
`serverReadyAction` are Cursor / VS Code.

## Expo

One **attach** for iOS, Android, and a device. Expo Tools does not
launch. Start Metro, open the app (`i` / `a` / QR), then F5.

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

```bash
npx expo start
# then i (simulator) or a (emulator), or scan the QR
```

Nested app: `projectRoot` = that package. Honor a Metro port the repo
already uses. Official stable path: React Native DevTools (`j` in the
Expo terminal). Cursor / VS Code attach is alpha.

Expo Web: start `npx expo start --web`, then Chrome. Journeys stay
Playwright (`e2e-tests`).

```json
{
  "name": "Expo: debug web",
  "type": "chrome",
  "request": "launch",
  "url": "http://localhost:8081",
  "webRoot": "${workspaceFolder}"
}
```

Plus `jest current file`. Do not add `type: reactnative` or a second
config per platform.

Zed has no `expo` adapter. Same `launch.json`; use RN DevTools. Do not
add `.zed/debug.json` to fake it.

## Svelte / Vite

Honor the Svelte plugin. Launch the Vite script the repo already uses.
Chrome-only only for a static SPA with no Node server.

## Zed

No extra files. Hub: do not add `.zed/debug.json` or a workspace
`extensions.json`. Built-in JavaScript adapter reads `type: node` /
`pwa-node` (vitest, jest, Next full stack, current file). F4 lists
`package.json` scripts and detected Jest / Vitest / Node tests.

| `type` | Zed |
| --- | --- |
| `node` / `pwa-node` | yes |
| `chrome` | yes if the JS adapter accepts it |
| `node-terminal` | no — Cursor / VS Code |
| `expo` | no — RN DevTools (`j`) |

## `extensions.json`

Hub [scan](../git-repo-setup/debug.md#scan-extensions). Omit the file only
if the union is empty (a kit TS repo is not).

```json
{
  "recommendations": [
    "expo.vscode-expo-tools",
    "biomejs.biome",
    "tombi-toml.tombi",
    "nefrob.vscode-just"
  ]
}
```

Svelte: `svelte.svelte-vscode` unless the Cursor Svelte plugin is the
team install. Next: no extra id (built-in Node / Chrome). Zed ignores
this file.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| Expo F5: launch not supported | Attach only. Metro + device first |
| `type expo` unknown | Missing `expo.vscode-expo-tools` |
| Next breakpoints miss in Zed | Child workers. Cursor / VS Code full stack, or attach after `next dev --inspect` |
| Jest debug never hits | Missing `--runInBand`, or Vitest on an Expo app |

## Do not

- `msjsdiag.vscode-react-native` / `type: reactnative` next to Expo Tools
- Radon IDE, Firefox Debugger, Jest / Vitest Explorer
- A Next marketplace plugin
- Separate iOS vs Android launch names
- `.zed/debug.json` so Zed can "see" Expo
