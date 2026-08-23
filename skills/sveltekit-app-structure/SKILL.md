---
name: sveltekit-app-structure
description: >-
  Structures SvelteKit apps: official src/routes and $lib tree, server-only
  modules, colocate route-only widgets. Use when scaffolding a SvelteKit
  app, adding a route, choosing $lib vs colocation, or the user mentions
  svelte.config, src/routes, $lib, or SvelteKit app structure. Coding stays
  in svelte and the Svelte plugin.
---

# SvelteKit App Structure

Layout and route boundaries for SvelteKit. Coding idioms live in `svelte`
and the Svelte plugin. Types follow `typescript-idioms` except **layout**:
do not flatten `src/routes` into `src/<noun>/`.

Sources: official `kit/project-structure`, `kit/routing`,
`kit/creating-a-project`, `kit/server-only-modules`. Not the plugin
runes catalog. New app: `npx sv create`. Not their extra add-ons unless
asked. Unit tests: `typescript-unit-tests`. Journeys: `e2e-tests`.

## First step

1. Read `svelte.config.js` / `svelte.config.ts` and `package.json`.
2. Find `src/routes`. Match that shape (`.ts` vs `.js`).
3. Never edit `.svelte-kit/` (generated).

No `@sveltejs/kit`: Vite + Svelte only. Honor it. Do not add Kit as a
drive-by.

`encore.app` in the same workspace: Encore owns HTTP APIs. This tree is
the UI. Call `encore gen client`. Do not put `//encore:api` here. No
combined skill yet.

## Hard rules

- **One `svelte.config` for the app.** A second config is a second app.
- **Routes are `src/routes` + `+` files.** URL path = directory.
  `+page.svelte` is a page. `+layout.svelte` wraps children with
  `{@render children()}`. `+page.server.ts` is server `load` / actions.
- **Shared UI lives in `$lib`.** Route-only widgets colocate in that
  route. Do not invent `src/components/` as a second shared tree.
- **Secrets are server-only.** `$lib/server` or `*.server.ts`. Do not
  import them from `+page.svelte` or other client modules.
- **New Kit app is `npx sv create`.** Do not invent `src/pages/` or
  `src/app/` routers.
- Data: `load` in `+page.server.ts` / `+page.ts`. Remote functions only
  when `svelte` says the flag is already on.

## Choose a layout

| Situation | Layout |
| --- | --- |
| New Kit app | Official `sv create` tree |
| Vite + Svelte, no Kit | Honor Vite. Do not add Kit |
| Widget used by one route | Colocate in that route directory |
| Widget or helper used by several routes | `$lib` |
| Secrets, DB, private env | `$lib/server` or `*.server.ts` |
| Param matcher | `src/params` |
| Static unhashed file (`robots.txt`) | `static/` |
| Encore API + this UI | Kit consumes the Encore client. No duplicate API routes |

Start as the official tree. Do not invent feature / domain / usecase
folders on a greenfield Kit app.

## Small app (official)

```
my-app/
  src/
    lib/
      server/            # $lib/server — never imported by the client
    params/              # optional matchers
    routes/
      +layout.svelte
      +page.svelte
      +page.server.ts    # honor .js if the repo is JS
      about/
        +page.svelte
    app.html
    hooks.server.ts      # optional
  static/
  tests/                 # Playwright if the repo already has it (`e2e-tests`)
  package.json
  svelte.config.js
  tsconfig.json          # extends .svelte-kit/tsconfig.json
  vite.config.ts
```

Unit tests colocate (`foo.test.ts`) when Vitest is in the repo
(`typescript-unit-tests`).

## Shared code

| Need | Put it |
| --- | --- |
| Helper used by one route | Next to that `+page.svelte` |
| Helper used by several routes | `$lib/<noun>` |
| Server secret / DB client | `$lib/server` or `*.server.ts` |
| Route data | `load` in `+page.server.ts` / `+layout.server.ts` |
| HTML form POST | Form actions in `+page.server.ts` |
| Webhook / non-HTML API | `+server.ts` |

No `util/`, `common/`, `helpers/`, `components/` at `src/` root. No
`domain/` / `usecase/` / `adapter/` trees unless the repo already has
them.

## Do not add

| Need | Use | Do not add |
| --- | --- | --- |
| Pages / URLs | `src/routes` + `+` files | `src/pages/`, React Router, a hand-rolled router |
| Shared modules | `$lib` | `src/components/` beside `$lib` |
| Server secrets | `$lib/server`, `*.server.ts` | Importing them from `+page.svelte` |
| New app | `npx sv create` | `npm create vite` then invent Kit files |
| Backend HTTP in this repo | Encore client, or Kit `load` / actions | A second Express/Hono next to Kit |
| Generated types | `./$types`, `PageProps` | Hand-copied `PageData` on Kit 2.16+ |

## Growth

1. One `+page.svelte` at `src/routes`.
2. Server data or actions → `+page.server.ts` next to it.
3. Second route needs the widget → `$lib`.
4. Secrets appear → `$lib/server`.
5. Split a route only for a real URL boundary. Shared layout stays a
   `+layout.svelte`.

## After layout changes

```bash
npx tsc --noEmit -p <tsconfig>   # or the typecheck / svelte-check script
```

Validate new `.svelte` files with the plugin autofixer (`svelte`).

## LLM traps — never generate these

- `src/pages/` or `src/app/` like Next
- Importing `$lib/server` from `+page.svelte`
- A second `svelte.config` or a second `src/routes`
- Feature / domain / usecase folder trees on a greenfield Kit app
- Kit 3 `$app/manifest` / `$app/service-worker` on a 2.x pin
- `+server.ts` as the default for a browser `<form>`
- Restyling colocated route files into `$lib` as a drive-by
- Applying `typescript-idioms` `src/index.ts` + `src/<noun>/` to Kit

## Do not

- Restyle a working `sv create` tree as a drive-by.
- Add SvelteKit to a Vite SPA unless asked.
- Recite runes or the pin table (those stay in `svelte`).
- Edit `.svelte-kit/` or commit it.
