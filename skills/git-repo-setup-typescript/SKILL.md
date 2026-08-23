---
name: git-repo-setup-typescript
description: >-
  TypeScript overlay for git-repo-setup: Biome (or the repo's Prettier),
  tsc --noEmit, vitest/node --test, Playwright e2e when playwright.config
  exists, pnpm/npm lockfile, commitlint when Node is first-class,
  Cursor/VS Code/Zed Node/vitest/Next/Expo launch.json. Use when
  bootstrapping or retrofitting Git hooks / just / Lefthook in a
  TypeScript or JS repo, or when the repo has package.json,
  tsconfig.json, *.ts, *.tsx, svelte.config, next, expo, or the user
  asks to debug TypeScript, Next, Expo, iOS, Android, set breakpoints,
  or add launch.json.
---

# Git repo setup — TypeScript

Follow `git-repo-setup` for the kit. This file fills the **TypeScript**
commands and [debug.md](debug.md). Language idioms stay in
`typescript-idioms`. How to write unit tests: `typescript-unit-tests`.
Journeys: `e2e-tests`. Commitlint wiring is in `conventional-commits` /
`tooling.md`.

## First step

1. Apply `git-repo-setup`.
2. Read `package.json` and the lockfile (`pnpm-lock.yaml`, `package-lock.json`,
   `yarn.lock`, `bun.lock`). Honor `packageManager` if set.
3. Read the formatter that already exists: `biome.json` / `biome.jsonc`,
   `.prettierrc*`, `eslint.config.*`. **One formatter.** If none of those
   exist, add Biome. Do not add Biome next to Prettier.

Polyglot (TypeScript + `go.mod`): also apply `git-repo-setup-go`. One
`lefthook.yml`, one Justfile.

Svelte (`svelte.config.js` / `svelte.config.ts`): same overlay. Include
`*.svelte` in the formatter glob. Do not invent a second hook runner for
the Svelte app. Coding: `svelte`. Layout: `sveltekit-app-structure`.

Next (`next` in `package.json`) or Expo (`expo`): same overlay. Coding:
project `AGENTS.md` / `expo/skills`. Journeys: `e2e-tests`.

## 2026 TypeScript defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Runtime pin | mise `node` = LTS the repo already documents, else current Node LTS | `volta` / `engines.node` already pins |
| Package manager | Lockfile / `packageManager` field | New, no lockfile: `pnpm` for workspaces, `npm` for a single package |
| Format + lint | [Biome](https://biomejs.dev/) | Prettier and/or ESLint already in the repo |
| Types | `npx tsc --noEmit -p <tsconfig>` (or the `typecheck` script) | — |
| Test | `vitest` if present, else `node --test`, else `npm test` | `expo` → `jest` / `jest-expo`. Honor `npm test` |
| E2E | `npx playwright test` if `playwright.config.*` exists | Honor the existing `e2e` / `test:e2e` script. Expo iOS / Android: Maestro / the EAS workflow already there |
| Commit-msg | commitlint + Lefthook (`conventional-commits` / `tooling.md`) | Use commitlint here; do not fall back to the Go/Python regex |
| JSON/MD/YAML | Biome or the existing Prettier | `dprint` already owns those files |
| Debug | `.vscode/launch.json` ([debug.md](debug.md)): current file + vitest / jest / `node --test`; Next / SvelteKit / Vite / Expo when those deps exist | Honor existing named configs |

Do not add Husky. Lefthook is the hook runner. Do not add a second of
Biome/Prettier/ESLint/dprint that formats the same globs.

## mise

```toml
[tools]
lefthook = "VERSION"
just = "VERSION"
gitleaks = "VERSION"
typos = "VERSION"
node = "24"   # pin engines.node / current LTS, not latest
```

Install JS deps in `bootstrap` with the lockfile's manager (`pnpm install`,
`npm ci`, `yarn install --frozen-lockfile`, `bun install`). Not a mix.

## `.gitignore` extras

On top of the shared secrets/local-overrides, use
[github/gitignore Node.gitignore](https://github.com/github/gitignore/blob/main/Node.gitignore) plus:

```gitignore
node_modules/
dist/
build/
.turbo/
coverage/
*.tsbuildinfo
```

When `playwright.config.*` exists, also ignore:

```gitignore
playwright-report/
test-results/
blob-report/
playwright/.cache/
```

Commit `.nvmrc` / `.node-version` only if the repo already uses them **instead
of** mise. Prefer mise. Do not add both as competing pins.

## Lefthook (TypeScript commands)

Keep gitleaks, typos, pre-push from `git-repo-setup`. Formatter — **one** of:

```yaml
pre-commit:
  commands:
    fmt-ts:
      glob: "*.{ts,tsx,js,jsx,json,css}"
      run: npx --no -- biome check --write --no-errors-on-unmatched {staged_files}
      stage_fixed: true
    # prettier (only if the repo already uses it, not Biome):
    # fmt-ts:
    #   glob: "*.{ts,tsx,js,jsx,json,md,css}"
    #   run: npx --no -- prettier --write {staged_files}
    #   stage_fixed: true
```

Svelte: add `svelte` to the glob (`*.{ts,tsx,js,jsx,json,css,svelte}`). Honor
the Svelte plugin the repo already uses (`prettier-plugin-svelte`, Biome
experimental, or `eslint-plugin-svelte`). Do not swap it.

commit-msg (this is a Node repo — commitlint, not the regex):

```yaml
commit-msg:
  commands:
    commitlint:
      run: npx --no -- commitlint --edit {1}
```

Install `@commitlint/cli` and `@commitlint/config-conventional` as devDependencies
if missing. Config: `export default { extends: ["@commitlint/config-conventional"] }`.

`tsc --noEmit` is **not** a pre-commit command (too slow, whole-program).
It belongs in `just check`.

## Recipes

```just
bootstrap:
    mise install
    npm ci          # or pnpm install / yarn install --frozen-lockfile
    lefthook install --force

check:
    typos
    gitleaks dir --no-banner .
    npx --no -- biome ci .
    npx tsc --noEmit

test:
    npx vitest run

e2e:
    npx playwright test   # only if playwright.config.* exists

ci: check test
```

Honor scripts already in `package.json` (`lint`, `typecheck`, `test`,
`e2e`). Point `check` / `test` / `e2e` at those names instead of
inventing parallel commands. Do not put `e2e` in `ci` unless the repo
already does. Journeys are earned (`e2e-tests`).

Biome `ci` is the non-mutating full-tree gate (CI, agents). Pre-commit uses
`biome check --write` on staged files.

If the repo has Prettier+ESLint instead of Biome:

```just
check:
    typos
    gitleaks dir --no-banner .
    npx --no -- prettier --check .
    npx --no -- eslint .
    npx tsc --noEmit
```

## Debug

[debug.md](debug.md). App: current file / Vite / SvelteKit / Next /
Expo. Tests: vitest, jest-expo, or `node --test`.

## Do not

- Husky + lint-staged in a new TS repo (Lefthook covers it).
- `tsc` on every commit.
- Biome **and** Prettier on the same globs.
- commitlint in a Go/Python-only tree that happens to contain one `package.json`
  for docs. If Node is not a first-class toolchain, use the Lefthook regex.
- Omit `.vscode/launch.json` on a new TypeScript repo, or overwrite instead of merging.
- Omit `extensions.json` when the hub scan is non-empty.
- Omit Next / SvelteKit / Vite / Expo launch names when those deps exist, or add React Native Tools next to Expo Tools.
- Playwright / Cypress as a drive-by on a library with no UI (`e2e-tests`).
