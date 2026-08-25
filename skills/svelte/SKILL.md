---
name: svelte
description: >-
  Overlay on the official Svelte plugin and typescript-idioms: pin Svelte 5
  and SvelteKit 2, $app/state not $app/stores.
  Use when generating, editing, reviewing Svelte or SvelteKit; when the
  user mentions Svelte, SvelteKit, .svelte, runes, $app/state, or
  svelte.config.
---

# Svelte 2026

Follow the Svelte Cursor plugin (`svelte-core-bestpractices`,
`svelte-file-editor`, MCP) and `typescript-idioms`. This file fills
the **pin** and `$app/state`. Do not fork the plugin into `skills/`.

Sources: official Svelte 5 / SvelteKit docs via the plugin MCP. Not
`svelte-core-bestpractices`. Layout: `sveltekit-app-structure`. Kit:
`git-repo-setup-typescript`. Tests: `typescript-unit-tests`. Journeys:
`e2e-tests` (`npx sv add vitest` / `playwright`). CSS in `<style>`:
`css-idioms`.

## First step

1. Read `package.json` (`svelte`, `@sveltejs/kit`) and `svelte.config.js`
   / `svelte.config.ts`. Target those pins. Do not bump them.
2. `.svelte` / `.svelte.ts` / `.svelte.js`: `svelte-file-editor` and the
   plugin MCP. This file does not restyle runes.

Vite + `svelte.config` and no `@sveltejs/kit`: stay Vite. Do not add
SvelteKit unless asked.

`encore.app` in the same workspace: Encore owns HTTP APIs. This app is
the UI. No combined skill yet.

## What this skill owns

| Own | Leave |
| --- | --- |
| Pin, `$app/state` | Runes, snippets, `{@attach}` (plugin) |
| Stop-and-follow `svelte-file-editor` | Formatter / hooks / `launch.json` (`git-repo-setup-typescript`) |
| | TypeScript language (`typescript-idioms`) |
| | `src/routes` / `$lib` (`sveltekit-app-structure`) |
| | Unit tests (`typescript-unit-tests`); journeys (`e2e-tests`) |

## Pin

| Pin | Always use | Not yet |
| --- | --- | --- |
| `svelte` 5.x | Runes (plugin). `createContext` on 5.40+ | — |
| `@sveltejs/kit` 2.x | `$app/state` (2.12+), `load`, form actions | — |

Write the modern form the first time. Do not emit Svelte 4 and wait.

## After every Svelte edit

Validate with `svelte-autofixer` (plugin MCP, or `svelte-code-writer`).
Then the repo gate:

```bash
npx tsc --noEmit -p <tsconfig>   # or the typecheck / svelte-check script
```

Format with the repo's formatter. Do not add a second one.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| `await` in markup / `$derived` fails | Use `{#await}` or `load` |
| `$app/stores` types or no updates | Kit 2.12+. Switch to `$app/state` |
| Svelte templates fail on TypeScript 7.0 | No public compiler API on 7.0. Hatch: `typescript-idioms` |

## Hard rules

- Install the Svelte plugin (`/add-plugin svelte`). Do not copy its
  skills into this repo.
- New code is **runes**. The plugin owns the catalog.
- Kit 2.12+: `import { page } from '$app/state'`. Not `$app/stores`.
- Shared UI state: `createContext` or a `$state` class. Not `writable()`
  in new code.
- Forms: form actions. A new `+server` route is for webhooks and
  non-HTML, not the default POST.

## Do not add

| Need | Use | Do not add |
| --- | --- | --- |
| Runes / snippets / attach | Plugin + MCP | A lore runes catalog |
| Page / nav state (Kit 2.12+) | `$app/state` | `$app/stores` |
| Shared UI state | `createContext`, `$state` class | `writable()` / `readable()` in new code |
| Async UI | `{#await}` or `load` | `await` in markup as the default |
| Mutations from the page | Form actions | A REST `+server` for a `<form>` |
| Component types | `$props()`, `PageProps` | `export let` |

## LLM traps — never generate these

- `export let`, `on:click`, `<slot>`, `$:`, `$$props` / `$$restProps`
- `$app/stores` on Kit 2.12+
- `await` in markup / `$derived` as the default
- A fork of `svelte-core-bestpractices` under `skills/`
- `writable()` as the default shared-state tool
- Bumping `svelte` / `@sveltejs/kit` to unlock a line

## Do not

- Restyle working Svelte 4 files to runes as a drive-by.
- Bump the pin to make an edit compile.
- Recite the plugin catalog in this file.
- Apply `typescript-idioms` `src/<noun>/` flatten to `src/routes`.
