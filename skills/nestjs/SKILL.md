---
name: nestjs
description: >-
  Overlay on typescript-idioms: pin NestJS, pipes/guards vs DB
  atomicity, providers, queues redeliver. Use when generating,
  editing, or reviewing NestJS; when the user mentions Nest, NestJS,
  @nestjs/core, @Module, @Injectable, or ValidationPipe.
---

# NestJS 2026

Follow `typescript-idioms`. This file fills the **Nest** pin,
pipes/guards, and provider vs database atomicity. Do not introduce
Nest for a 40-line worker.

Sources: official Nest docs (`docs.nestjs.com`). Not a Nest
encyclopedia. Not a skills.sh pack. Layout:
`nestjs-app-structure`.

Kit: `git-repo-setup-typescript`. Tests: `typescript-unit-tests`.
4xx: `api-contracts`. Schema: `data-modeling`. Writer:
`source-of-truth`. Next / Expo: those stay vendor skills — this
file is the Node API.

## First step

1. Read `package.json`. Pin is `@nestjs/core`. Do not bump it.
2. Honor the platform already there (`@nestjs/platform-express` or
   Fastify). Do not swap Express ↔ Fastify as a drive-by.
3. TypeORM / Prisma / Drizzle already there: honor it. Do not add a
   second ORM. Layout: `nestjs-app-structure`.

No `@nestjs/core`: do not add Nest. Small HTTP: `typescript-idioms`
(`node:http` or Hono).

## Pin

| Pin | Always use | Not yet |
| --- | --- | --- |
| Nest 11.x | that series' APIs; Node 20+ | Nest 12 |
| Nest 10.x | 10.x docs | bumping to 11 to unlock a line |

Write the modern form for **that** pin. Decorators stay; this is
the framework. `typescript-idioms` `experimentalDecorators` trap
does **not** apply inside Nest (override).

## After every Nest edit

```bash
npx tsc --noEmit -p <tsconfig>
```

Then the repo test script (`git-repo-setup-typescript`). Format
with the repo's formatter. Do not add a second one.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| Transaction ignored | self-call skipped the proxy / interceptor |
| Duplicate job | queue at-least-once; handler not idempotent |
| 500 on a bad body | no `ValidationPipe` at the edge |
| Two ORMs | added Prisma next to TypeORM |
| Nest in a 40-line worker | did not stop; `typescript-idioms` |

## What this skill owns

| Own | Leave |
| --- | --- |
| Pin, pipes/guards, providers vs DB atomicity, queue redelivery | `typescript-idioms` spelling (except Nest decorators) |
| | Module tree (`nestjs-app-structure`) |
| | Next / Expo UI (vendor skills) |
| | Status codes (`api-contracts`) |

## Hard rules

- Providers **wire**. They do not make the database atomic. A
  transaction decorator / query runner is a real boundary. Self-call
  on `this` can skip the proxy — extract a call through the
  injected provider.
- Pipes (class-validator / Zod at the pin) run at the **edge**.
  Do not `as User` on `req.body`.
- Guards are authz **at the handler**. Tenant still belongs in the
  query (`authz-boundaries`).
- Persisted queues redeliver. Consumers are idempotent
  (`source-of-truth`). `Bull` `removeOnComplete` is not an outbox.
- Construct ORM connections in Nest modules (`forRoot` / `forRootAsync`).
  No module-level `new PrismaClient()` used at import besides the
  Nest provider pattern already in the repo.
- Request lifecycle ends when the response ends. Durable work needs
  a queue / worker, not a hanging Promise.

## Default shapes

Thin controller, rules in an injectable:

```ts
@Controller("items")
export class ItemsController {
  constructor(private readonly items: ItemsService) {}

  @Get(":id")
  findOne(@Param("id") id: string) {
    return this.items.findOne(id);
  }
}
```

`ValidationPipe` (whitelist) on the app or the handler. Service
owns the write. ORM repo / Prisma stay behind that service.

## Do not add

| Need | Use | Do not add |
| --- | --- | --- |
| HTTP | Nest already there | Express next to Nest; a second Nest app |
| Validation | `ValidationPipe` / the repo's Zod | a second schema lib |
| ORM | honor TypeORM / Prisma / Drizzle | a second ORM |
| Queue | honor Bull / the repo's broker | `setTimeout` as the job system |
| New small server | `typescript-idioms` Hono / `node:http` | Nest as fashion |

## LLM traps — never generate these

- Nest on a 40-line worker or a script
- `this.method()` self-call expected to open a transaction
- Prisma added next to TypeORM (or the reverse)
- Queue handler that is not idempotent
- `as User` on the body instead of a DTO + pipe
- Swapping `@nestjs/platform-express` for Fastify as a restyle
- Applying `typescript-idioms` `src/<noun>/` flatten to Nest
  `src/` modules
- Bumping Nest 10 → 11 to unlock a line

## Do not

- Restyle a working Express / Fastify / Hono app into Nest as a
  drive-by.
- Recopy `nestjs-app-structure` trees here.
- Recite `typescript-idioms` Zod catalogs except the decorator
  override.
- Fork a Nest course into `skills/`.
