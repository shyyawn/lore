---
name: typescript-idioms
description: >-
  Writes, restyles, and reviews TypeScript using idioms from TypeScript 5
  through 7 (standard decorators, using, inferred predicates, erasableSyntaxOnly,
  Temporal, native tsc) and 2024–2026 architecture practices (platform-first,
  ESM, consumer-side types, AbortSignal cancellation, parse-at-boundary). Use
  when generating, editing, reviewing, or modernizing TypeScript; when the user
  mentions idiomatic TypeScript, 2026 TypeScript, erasableSyntaxOnly,
  verbatimModuleSyntax, or matching tsconfig.
---

# TypeScript 2026

Write TypeScript as if `tsc` already type-checked against the project's
installed `typescript` version. Do not emit pre-5 tutorial TypeScript
(`enum`, `namespace`, `module Foo {}`, `experimentalDecorators`, `any`,
`as` on object literals, `axios`, `moment`, `lodash`, path `baseUrl`).

Full catalogs: [versions.md](versions.md) (5.0→now), [modernizers.md](modernizers.md)
(rewrites), [architecture.md](architecture.md) (2024–2026 structure).
Svelte / SvelteKit: `svelte`. Layout: `sveltekit-app-structure`.
Tests: `typescript-unit-tests`. Journeys: `e2e-tests`.
CSS: `css-idioms`.
Expo / React Native-with-Expo: official `expo/skills` (install — lore
README). Web React: official `react-best-practices`. Next.js: project
`AGENTS.md` + official `vercel/next.js` skills; performance still
`react-best-practices`. Do not flatten those `app/` trees with this
file's `src/<noun>/`.

## First step

Read `package.json` (`typescript` / `@typescript/native`) and `tsconfig.json`.
Target that compiler. Do not bump `typescript` to unlock an idiom.

| `typescript` | Always use | Not yet |
| --- | --- | --- |
| 7.0+ | everything below plus native `tsc`, `--checkers`/`--builders`, Unicode template inference, 6.0 defaults as hard errors | 7.1 programmatic API; keep `@typescript/typescript6` beside 7.0 for eslint/Vue/Svelte/Astro/Angular templates |
| 6.0 | Temporal types, `#/` subpath imports, 6.0 defaults (`strict`, `module: esnext`, `types: []`), `stableTypeOrdering` when comparing emit to 7.0 | native `tsc`; `ignoreDeprecations: "6.0"` is a hatch, not new code |
| 5.9 | `import defer`, `--module node20` | Temporal in `lib` |
| 5.8 | `erasableSyntaxOnly`, `--module node18`, granular return checks | |
| 5.7 | `rewriteRelativeImportExtensions`, `--target es2024` | |
| 5.6 | iterator helpers, `noUncheckedSideEffectImports` | |
| 5.5 | inferred type predicates, `isolatedDeclarations`, `Set` methods | |
| 5.4 | `NoInfer`, `Object.groupBy` / `Map.groupBy`, `--module preserve` | |
| 5.3 | `import … with { type: "json" }`, `switch (true)` narrowing | |
| 5.2 | `using` / `await using`, decorator metadata | |
| 5.0–5.1 | standard decorators, `const` type params, `verbatimModuleSyntax`, `--moduleResolution bundler` | `using` |

TypeScript 7.0 is a **Go port of the compiler**, not a language rewrite. Source
is still TypeScript. Do not emit Go. Do not call 7.0's missing compiler API.

## After every TypeScript edit

```bash
npx tsc --noEmit -p <tsconfig>   # or the project's typecheck script
```

Write the modern form the first time. Do not write `enum` / `namespace` /
`assert` imports and wait for a later flag. Format with the repo's formatter
(Biome, Prettier, dprint) — do not introduce a second one.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| `erasableSyntaxOnly` errors on `enum` / `namespace` / parameter properties | Non-erasable syntax. Rewrite ([modernizers.md](modernizers.md)); do not turn the flag off. |
| `Cannot find name 'process'` / `'describe'` after a 6.0/7.0 bump | `types` now defaults to `[]`. List what you need (`["node"]`), never `"types": ["*"]` in new config. |
| `baseUrl` / `moduleResolution: node` / `target: es5` hard error | 6.0 deprecations are errors in 7.0. Fix the tsconfig; do not set `ignoreDeprecations` on 7.0 (it does not exist). |
| typescript-eslint / Vue / Svelte / Astro / Angular templates fail on 7.0 | No public compiler API until 7.1. Alias `typescript` to `@typescript/typescript6` and keep 7.0 as `@typescript/native` for `tsc`. |
| `stableTypeOrdering` makes 6.0 25% slower | Use it only when diffing 6.0 vs 7.0 emit. 7.0 has it on permanently. |
| Node runs `.ts` then blows up on `enum` | Runtime type-stripping is not `tsc`. Keep `erasableSyntaxOnly`. |

## Language (5.0 → now)

- `unknown`, never `any` (including comments). Narrow with predicates, `in`,
  discriminated unions, or a schema parse — not `as`.
- `satisfies` on object literals. `as const` for literal unions. Never `as T`
  to silence a mismatch.
- `import type` / `export type` under `verbatimModuleSyntax`. No elided imports.
- No `enum`, `const enum`, `namespace`, `module Foo {}`, parameter properties,
  or `import =` / `export =`. `erasableSyntaxOnly` is the contract for Node
  type-stripping and for new code even when the flag is off.
- A named string union plus `as const` object is the stand-in for enums
  (`const Step = { Paid: "paid" } as const; type Step = typeof Step[keyof typeof Step]`).
  It serializes as itself. Use a numeric union only for values that are
  genuinely ordinal and never serialized.
- Standard decorators (`@dec`), never `experimentalDecorators`.
- `using` / `await using` for `Disposable` / `AsyncDisposable`. No `try/finally`
  close when a disposer exists.
- Inferred type predicates (5.5+): write `return x != null`, not
  `x is T`, unless inference fails.
- `NoInfer<T>` when a generic should be fixed by another parameter.
- `import … with { type: "json" }`, never `assert`.
- `import defer * as ns from "…"` (5.9+) for side-effect-heavy modules you
  might not evaluate.
- `Temporal` (6.0+, `lib`/`target` esnext or `esnext.temporal`) for new date-time.
  Do not add `moment` / `dayjs` to a codebase that can use Temporal.

## Architecture (2024–2026)

Platform-first: do not add a dependency the runtime, Web APIs, or TypeScript
`lib` now cover. Same instinct as Go stdlib-first ([architecture.md](architecture.md)).

| Need | Use | Do not add |
| --- | --- | --- |
| HTTP client | `fetch` + `AbortSignal` | `axios`, `node-fetch`, `got` |
| HTTP server (new, small) | `node:http` or Hono | a second Express/Fastify/Nest beside an existing one |
| Validation at a boundary | Zod 4 (or the repo's Standard Schema lib) | a second schema lib; `as` on `req.body` |
| Dates | `Temporal` (6.0+) | new `moment` / `dayjs` |
| IDs | `crypto.randomUUID()` | `uuid` |
| Deep clone / grouping | `structuredClone`, `Object.groupBy` | lodash `cloneDeep` / `groupBy` |
| Module aliases | `package.json` `"imports": { "#/*": "./src/*" }` | `baseUrl`, new `paths` that the runtime will not honor |
| Types in Node | `nodenext` + `erasableSyntaxOnly` | `ts-node` in new apps |
| Bundled apps | `--module preserve` + `--moduleResolution bundler` | `moduleResolution: node` |

Layout is earned: start as a few modules next to `package.json`. Grow when a
second entry or a publish boundary appears. No `utils/`, `helpers/`, `common/`,
`domain/` / `usecase/` / `adapter/` trees unless the repo is already that shape.

- Name modules for what they **are**, not which app imports them.
- One-way imports: domain modules must not import HTTP, CLI, or UI wiring.
- Consumer-side types: the caller declares the 2–3 methods it needs. Do not
  export a 20-method `IUserRepository` "for mocking".
- Construct clients in the entry (`main`, `src/index.ts`) and pass them down.
  No module-level `fetch` wrappers with a captured global.
- Pass `AbortSignal` on any I/O, RPC, or cancellation-aware function
  (`signal` in an options object). Honor it. Do not invent a parallel
  `CancelToken`.

## Errors, async, I/O

- Fail at the boundary that knows the context. Error messages are lowercase,
  no trailing punctuation, and include the operation (`open config: …`).
- `unknown` in `catch`. Narrow before use. Never `catch (e: any)`.
- Do not swallow. Do not `return null` for "not found" when the caller must
  distinguish missing from error — throw a typed error or return a result
  union `{ ok: true; value } | { ok: false; error }`. Match the repo.
- Do not introduce Effect, neverthrow, or a result library into a codebase
  that throws. Do not rip one out.
- `await` in try/catch or let it reject. No floating promises. `using` for
  handles that must close.
- `fetch` with `signal`. Check `response.ok`. Time out via `AbortSignal.timeout`
  (or `AbortSignal.any`). No `http.get` without a timeout analog.
- Parse, don't annotate: `schema.parse(unknown)` at HTTP, env, and file
  boundaries. `z.infer<typeof schema>` for the type. Never `as User`.

## Tests

How to write them: `typescript-unit-tests`. Browser journeys:
`e2e-tests`. Kit runner: `git-repo-setup-typescript`. Next / Expo:
vendor.

## LLM traps — never generate these

- `any`, `as any`, `as unknown as T`, `@ts-ignore` / `@ts-expect-error` without
  a one-line reason
- `enum`, `namespace`, `experimentalDecorators`, parameter properties
- `import x from "./foo"` when `x` is type-only (`verbatimModuleSyntax`)
- `import … assert { type: "json" }`
- `axios`, `moment`, `lodash`, `uuid`, `node-fetch` in new code
- `baseUrl`, `moduleResolution: "node"`, `target: "es5"`, `outFile`
- Default `export default` in libraries (named exports). Match the file in apps
- Barrel `index.ts` re-export files added "for convenience"
- `console.log` in libraries (the binary owns logging)
- A new `utils.ts` / `helpers.ts` / `types.ts` grab-bag

## Do not

- Restyle unrelated files, or rewrite comments that already tell the truth.
- Extract a helper until the third copy.
- Add generics, branded types, or Effect only to look modern.
- Bump `typescript` or flip `strict` off to make an edit compile.
- Replace Express/Fastify/Nest/Zod/Jest as a drive-by restyle.
