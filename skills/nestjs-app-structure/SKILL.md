---
name: nestjs-app-structure
description: >-
  Structures NestJS apps: official nest new tree, feature modules,
  AppModule, providers scoped to a module. Use when scaffolding a
  Nest app, adding a module, choosing src/ layout, or the user
  mentions nest new, @Module, AppModule, or Nest app structure.
  Coding stays in nestjs.
---

# NestJS App Structure

Layout and module boundaries for NestJS. Coding idioms live in
`nestjs` and `typescript-idioms`. Do not flatten this tree into
`src/<noun>/` as a library.

Sources: official `docs.nestjs.com/modules`, `cli/usages` (`nest new`,
`nest g module`). Not a hexagonal starter. New app: `nest new`.
Honor the tree already there.

## First step

1. Read `package.json` (`@nestjs/core`) and `src/main.ts`.
2. Find `AppModule`. Match that shape (flat feature modules vs
   already nested).
3. Never edit `dist/` as source.

No `@nestjs/core`: this is not Nest. Honor it. Do not add Nest as a
drive-by (`nestjs`).

Several `package.json`: `typescript-mono-repo`. This file stays the
Nest app that has `AppModule`.

## Hard rules

- **One `AppModule` for the app.** A second root module is a second
  app.
- **Feature modules own controllers + providers for that noun.**
  Import / export what other modules need. Do not dump every
  provider into `AppModule` once a second domain appears.
- **`main.ts` is wiring only.** `NestFactory.create`, pipes, listen.
  Rules stay in injectables.
- **Do not apply `typescript-idioms` `src/<noun>/` flatten** to Nest
  `src/`. Nest's unit is the module, not a library package.
- **Shared helpers** that are not providers live next to the module
  that uses them, or a shared module if two features import them.

## Choose a layout

| Situation | Layout |
| --- | --- |
| New app | Official `nest new` tree |
| One domain | `AppModule` + one feature module |
| Several domains | one module per noun under `src/` |
| Shared auth / config | a shared / core module, imported once |
| Prisma / TypeORM | the ORM module the pin already uses |

Start as `nest new`. Do not invent `domain/` / `usecase/` /
`adapter/` on a greenfield Nest app.

## Small app (official)

```
src/
  main.ts
  app.module.ts
  items/
    items.module.ts
    items.controller.ts
    items.service.ts
  app.controller.ts
  app.service.ts
```

`nest g module items` then controller / service. Keep the generated
suffixes unless the repo already dropped them.

## Growth

1. Root + one feature module.
2. Split a module when a second noun's controllers appear.
3. Do not split so two modules write the same table. Shared table →
   one module.

## After layout changes

```bash
npx tsc --noEmit -p <tsconfig>
```

Then the repo test script. Do not commit `dist/` if `.gitignore`
already excludes it.

## LLM traps — never generate these

- `src/<noun>/` flatten copied from `typescript-idioms`
- Every provider registered only in `AppModule` after the second
  feature
- Hexagonal `domain/` / `usecase/` / `adapter/` as the Nest tree
- A second `main.ts` / `AppModule` as fashion
- Nest `src/app/` confused with Next `app/`
- `nest new` extras (Docker, microservices) unasked

## Do not

- Restyle a working `nest new` tree as a drive-by.
- Add Nest to a Hono / Express repo unless asked.
- Recite pipes / transactions (those stay in `nestjs`).
- Bump Nest to unlock a layout.
