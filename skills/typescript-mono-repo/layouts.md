# Layouts

Canonical trees. Gate on the earn checklists in [SKILL.md](SKILL.md).

## One package (default)

Most 2024–2026 TypeScript products: one Next, Expo, Kit, or Vite app.
Several routes, one version, one lockfile.

```
repo/
  package.json           # private app or "type": "module" library
  package-lock.json      # or pnpm-lock.yaml if that is already the manager
  tsconfig.json
  src/                   # or Next app/, Expo app/, Kit src/routes
```

Shared code that only this app uses stays in the app tree (`$lib`,
`src/<noun>/`, a colocated module). Split to a workspace package only
when a second app or a publish boundary appears. Do **not** add
`packages/` as ceremony.

## Next + Expo

Web and mobile that ship together. Official Expo workspace globs plus
a named Next app. Coding stays in `AGENTS.md` / `expo/skills`.

```
repo/
  package.json           # private: true, packageManager: pnpm@VERSION
  pnpm-workspace.yaml
  pnpm-lock.yaml
  apps/
    web/                 # Next — app/ as the pin documents
    mobile/              # Expo — Expo Router app/
  packages/
    api/                 # fetch client, Zod schemas — the noun
    tokens/              # colors, type — if both apps need them
```

```yaml
# pnpm-workspace.yaml
packages:
  - "apps/*"
  - "packages/*"
```

In-repo deps: `"@org/api": "workspace:*"`. One `react` version.
Expo isolated break: `nodeLinker: hoisted` in this file.

Do not put `div` and `View` in the same package unless that library
already exists.

## Two Next apps (create-turbo tree)

Official `create-turbo` shape. Take the directories. Leave
`@repo/eslint-config` when Biome already lints.

```
repo/
  package.json
  pnpm-workspace.yaml
  apps/
    web/
    docs/
  packages/
    ui/                  # React components both Next apps import
```

Next Turbopack sees workspace packages. Add `transpilePackages` only
when a package is still invisible (Pages Router, or raw TS in
`node_modules`).

A root `tsconfig.base.json` is enough for two packages. A
`packages/typescript-config` package waits until three or more need
the same `extends`.

## Expo + packages

Expo official: apps in `apps/`, SDK-style packages in `packages/`.
They do not have to publish.

```
repo/
  package.json
  pnpm-workspace.yaml
  apps/
    mobile/
  packages/
    cool-package/        # name is the noun, not shared/
```

SDK 52+: no hand-rolled Metro `watchFolders`. SDK 54+: isolated
first; hoist only if a native module fails.

## Kit + another app

```
repo/
  package.json
  pnpm-workspace.yaml
  apps/
    web/                 # SvelteKit — src/routes, sveltekit-app-structure
    mobile/              # optional Expo sibling
  packages/
    api/
```

Do not flatten `src/routes` into `src/<noun>/`. A second
`svelte.config` is a second app.

## Encore + JS workspace

One `encore.app`. Services are Go packages (`encore-go-app-structure`).
The UI is this file's workspace, not a Go module.

```
repo/
  encore.app
  go.mod
  hello/                 # Encore service
  apps/
    web/                 # Kit / Next / Expo
  pnpm-workspace.yaml
```

`go-mono-repo` owns the Go side. One Lefthook, one Justfile,
one `.vscode/launch.json` at the Git root.

## Turborepo (earned)

Same `apps/` + `packages/` tree. Add only `turbo.json` and a root
`turbo` devDependency.

```json
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "!.next/cache/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    }
  }
}
```

Scripts that already exist (`check`, `typecheck`, `test`) stay the
names. Point Turbo at them. Do not invent a parallel script set.
