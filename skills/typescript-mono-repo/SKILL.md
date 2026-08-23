---
name: typescript-mono-repo
description: >-
  Structures TypeScript monorepos: one package.json by default, pnpm
  workspaces when two apps or a publishable package appear, Turborepo only
  when CI time is the problem. Use when the repo has more than one
  package.json, pnpm-workspace.yaml, a workspaces field, turbo.json,
  nx.json, apps/ plus packages/, or the user mentions TypeScript monorepo,
  Next plus Expo, pnpm workspace, create-turbo, or splitting a package.
  Overlay on typescript-idioms. Next and Expo coding stay in AGENTS.md and
  expo/skills. Do not add Nx, Lerna, or a second package manager.
---

# TypeScript monorepo 2026

How many `package.json` files, and whether to add a workspace. Language
and flatten layout: `typescript-idioms`. Inside Next / Expo / Kit: those
skills, not this file. Hooks/CI: `git-repo-setup-typescript`. Trees:
[layouts.md](layouts.md).

Sources: `pnpm.io/workspaces`, Expo `guides/monorepos` (SDK 54+ isolated),
Next `transpilePackages`, Turborepo `create-turbo` tree. Not their
eslint-config. Not Nx, Lerna, or Bazel for a new app.

## First step

1. Count `package.json` files. Look for `pnpm-workspace.yaml`, a
   `workspaces` field, `turbo.json`, `nx.json`, and the lockfile.
2. Honor the lockfile / `packageManager`. Do not swap pnpm for npm (or
   the reverse) as a drive-by.
3. Match the shape that is already there. Do not split a working single
   Next, Expo, Vite, or Kit app into `apps/` + `packages/` as a drive-by.
4. `nx.json` / `lerna.json` / `moon.yml` already there: honor that runner.
   Do not add Turborepo next to it.

## What this skill owns

| Own | Leave |
| --- | --- |
| How many `package.json`; `pnpm-workspace.yaml` | TypeScript language (`typescript-idioms`) |
| Keys: `workspace:*`, one React, install from root | Next `app/` (`AGENTS.md` + `vercel/next.js`) |
| When to add `turbo.json` | Expo Router / native / EAS (`expo/skills`) |
| `apps/<noun>/` + `packages/<noun>/` | Kit `src/routes` (`sveltekit-app-structure`) |
| Polyglot JS side next to Encore | Go modules (`go-mono-repo`); kit (`git-repo-setup-typescript`) |

## Earn a second package.json

Default is **one package** for the whole Git repo. Tick **yes** on at
least two, or stay on one `package.json`.

```
Earn a workspace:
- [ ] Two deployable apps (Next + Expo, Next + Vite, two Next apps)
- [ ] A package two apps must import (types, client, tokens — not a grab-bag)
- [ ] Independent publish (another Git repo must `npm install` this name)
- [ ] A native module colocated with the Expo app (Expo official reason)
```

Routes, features, and `src/components/` are **not** packages. One Next
app with a library folder is still one `package.json`.

Next + Expo share **logic and types**. Do not invent a universal UI
package (`div` and `View` in one file) unless the repo already has that
library (Tamagui, NativeWind, …).

## Choose a layout

| Situation | Layout |
| --- | --- |
| One Next / Expo / Kit / Vite app | One package — `typescript-idioms` `architecture.md` |
| Next + Expo (web + mobile) | `apps/web` + `apps/mobile` + `packages/<noun>` |
| Two Next apps, shared UI | `apps/<noun>` + `packages/ui`. Official `create-turbo` tree, Biome not their eslint-config |
| Expo + shared packages only | `apps/<noun>` + `packages/<noun>` (Expo official) |
| Kit + another app | Kit stays `src/routes`. Sibling is another `apps/` entry |
| Encore + JS UI | One `encore.app` + JS workspace. `go-mono-repo` + this file |
| CI builds several apps and waits | Same tree + earned `turbo.json` |
| `nx.json` already there | Honor Nx. Do not add Turborepo |
| Hermetic polyglot at Google/Uber scale | Bazel. Do not invent for a greenfield app |

Trees: [layouts.md](layouts.md).

## Workspaces

New workspace, no lockfile: **pnpm**. File is `pnpm-workspace.yaml`, not
a root `workspaces` array. Root `package.json` is `"private": true`. Pin
`packageManager`.

```yaml
packages:
  - "apps/*"
  - "packages/*"
```

npm / Yarn / Bun already there: honor their workspace file. Same
`apps/` + `packages/` tree.

Internal deps use `workspace:*` (pnpm, Bun). Expo also accepts `"*"`.
Do not pin a published version of an in-repo sibling.

```bash
pnpm install                          # Git root only
pnpm --filter web dev
pnpm --filter mobile start
pnpm add zod --filter web
pnpm add @org/ui --filter web --workspace
```

`pnpm -r` / `--filter` is enough until CI time hurts. Then earn Turbo.

Align one React / `react-native` with `pnpm why`. A catalog in
`pnpm-workspace.yaml` is optional when three or more packages share that
pin. Do not add a catalog on day one.

Expo SDK 54+: isolated installs are supported. If a native module
breaks, set `nodeLinker: hoisted` **in** `pnpm-workspace.yaml` (pnpm
10+ settings live there). SDK 52+: do not hand-edit Metro
`watchFolders` / `disableHierarchicalLookup` — Expo already does.

Next Turbopack transpiles workspace packages. Add `transpilePackages`
only for a package that still ships raw TS/JSX and is not auto-seen
(Pages Router, or a `node_modules` library). Do not glob paths.

## Earn Turborepo

Default is **no** `turbo.json`. Tick **yes** on at least two, or stay
on `pnpm --filter`.

```
Earn turbo.json:
- [ ] CI runs build/test/typecheck on more than one app and is slow
- [ ] A package must build before an app (`dependsOn: ["^build"]`)
- [ ] Remote cache would skip work the team already paid for
```

Then `pnpm add turbo --save-dev --ignore-workspace-root-check`. Pin it
in the root. Honor `create-turbo` if that is how the repo started —
drop `@repo/eslint-config` only when Biome already owns lint.

Do not add Nx, Lerna, Moon, Lage, or Rush on a greenfield. Honor the
one that is already there.

## Hard rules

- One Git repo may still be one package. "Monorepo" ≠ many `package.json`s.
- One lockfile at the Git root. Install from the root. Never a nested
  `node_modules` install as the workflow.
- Name directories for the **noun** (`apps/web`, `packages/billing`).
  No `packages/shared`, `utils`, `common`, `lib` buckets
  (`typescript-idioms`).
- One `react` / `react-dom` / `react-native` version in the workspace.
  Duplicates break Expo native builds and React runtime.
- Do not flatten Next `app/` or Expo Router `app/` with
  `typescript-idioms` `src/<noun>/`.
- One `.vscode/launch.json` at the Git root. Nested app: `cwd` =
  that package (`git-repo-setup-typescript` debug.md).
- Root tools (Biome, turbo) live in the root `package.json`. App
  frameworks stay in the app.

## After every layout edit

```bash
pnpm install                         # or the lockfile's ci
pnpm --filter <name> exec tsc --noEmit
# if turbo.json exists:
pnpm exec turbo run check --filter=<name>
```

Honor each package's `typecheck` / `test` script. Expo: `jest-expo` in
that app. Journeys stay `e2e-tests`.

## Review workflow

```
TypeScript monorepo:
- [ ] One package.json unless the earn checklist passed
- [ ] Lockfile / packageManager honored; new workspace is pnpm
- [ ] workspace:* for in-repo deps; install from the Git root
- [ ] turbo.json only if the turbo earn passed; no Nx+Turbo pair
- [ ] No packages/shared, utils, common
- [ ] One react / react-native version (pnpm why)
- [ ] Next app/ and Expo app/ not flattened
- [ ] One .vscode/launch.json at the Git root
- [ ] Polyglot Go is go-mono-repo, not a JS package per Encore service
```

## LLM traps — never generate these

- A `package.json` per route, feature, or `src/components/`
- Splitting one Next/Expo/Kit app into `apps/` + `packages/` unasked
- `packages/shared`, `packages/utils`, `packages/common`
- `create-turbo` `@repo/eslint-config` next to house Biome
- Nx + Turborepo together, or Lerna on a new app
- Metro `watchFolders` / `disableHierarchicalLookup` on Expo SDK 52+
- Two `react` or `react-native` versions
- A universal `View`/`div` UI package on a greenfield Next+Expo repo
- `create-t3-turbo` tRPC / Drizzle / TanStack Start as the default tree
- Yarn PnP, or Bun as the default when Expo native modules need hoist
- `next-transpile-modules` (replaced by `transpilePackages`)

## Do not

- Restyle a working single-package app into a workspace as a drive-by.
- Duplicate Next `AGENTS.md`, `expo/skills`, or `sveltekit-app-structure`.
- Teach Nx / Moon / Bazel unless that file already exists.
- Swap the lockfile to unlock a line in this skill.
