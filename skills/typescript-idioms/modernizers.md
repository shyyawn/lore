# Rewrites (TypeScript 5 → 7)

TypeScript has no `go fix`. Write these forms directly. `tsc --noEmit` and
the repo's typescript-eslint / Biome are the backstop. Version meaning of
each rewrite: [versions.md](versions.md).

```bash
npx tsc --noEmit -p <tsconfig>
```

Do not "modernize" by bumping `typescript`, flipping `strict` off, or adding
`ignoreDeprecations`.

## Syntax TypeScript cannot strip

Required for Node type-stripping and for any project with
`erasableSyntaxOnly` (5.8+). Write them even when the flag is off.

| Before | After |
| --- | --- |
| `enum Status { Open = "open" }` | `const Status = { Open: "open" } as const; type Status = typeof Status[keyof typeof Status]` |
| `const enum Flags { A = 1 }` | same `as const` object, or a number union that is never serialized |
| `namespace Utils { export function f() {} }` | ESM `export function f()` in `utils.ts` |
| `module Foo { export const x = 1 }` | ESM. (`module` as namespace is a 6.0+ error) |
| `constructor(public readonly x: number) {}` | `constructor(x: number) { this.x = x; }` with a class field `readonly x: number` |
| `import fs = require("fs")` / `export =` | `import fs from "node:fs"` + `"type": "module"` (or a `.cts` file if the package is CJS) |

## Types

| Before | After |
| --- | --- |
| `any` | `unknown`, then narrow |
| `as Foo`, `as any`, `as unknown as Foo` | `satisfies Foo`, a type predicate, or `schema.parse` |
| `foo as Bar` on a generic default | `NoInfer<Bar>` or an extra type parameter (5.4+) |
| `function isX(v: unknown): v is X { return … }` | drop `: v is X` when 5.5+ infers it |
| `xs.filter((x): x is T => x != null)` | `xs.filter(x => x != null)` |
| `xs.filter(Boolean)` | still not a predicate — write `x => x != null` |
| `interface Foo { f(): void }; class Foo` mix | one or the other; prefer a type + functions unless you need `instanceof` |
| `IUserService` with 20 methods | the 2–3 methods the caller uses, declared next to the caller |

## Modules and tsconfig

| Before | After |
| --- | --- |
| `import type { Foo } from "./foo"; const x: Foo` without `import type` | `import type { Foo } from "./foo.ts"` (or `.js` if that is the emit contract) |
| `import { type Foo, bar } from "./m"` when Foo is type-only | `import type { Foo } from "./m"; import { bar } from "./m"` under `verbatimModuleSyntax` |
| `import x from "./data.json" assert { type: "json" }` | `with { type: "json" }` |
| `import "./polyfill"` typo that type-checks | `noUncheckedSideEffectImports` |
| `baseUrl: "./src"` + `"@/*": ["*"]` | `package.json` `"imports": { "#/*": "./src/*" }` and `import from "#/foo.ts"` |
| `moduleResolution: "node"` / `"node10"` / `"classic"` | `nodenext` (Node) or `bundler` (Vite/webpack/Bun) |
| `module: "amd"` / `"umd"` / `"system"` / `"none"` | `esnext` or `preserve` |
| `target: "es5"` / `downlevelIteration` / `outFile` | evergreen `target`; bundler concatenates |
| `esModuleInterop: false` | default import: `import express from "express"` |
| `"types"` omitted on 6.0+ | `"types": ["node"]` (list globals; don't `"*"`) |
| `rootDir` inferred on 6.0+ | `"rootDir": "./src"` when sources live in `src/` |
| `paths` that only `tsc` understands | runtime-valid specifiers (`#/`, relative, package `exports`) |

Apps that Node runs directly: `module`/`moduleResolution` `nodenext`,
`erasableSyntaxOnly`, `verbatimModuleSyntax`, `noEmit`, `allowImportingTsExtensions`.
Libraries that emit `.d.ts`: `isolatedDeclarations` + explicit export types.
Bundled apps: `module: preserve`, `moduleResolution: bundler`.

## Platform APIs (stop adding a package)

| Before | After |
| --- | --- |
| `axios.get` / `node-fetch` | `fetch` + `AbortSignal` |
| `moment` / new `dayjs` | `Temporal` (6.0+) |
| `uuid` | `crypto.randomUUID()` |
| `lodash.groupBy` / `cloneDeep` | `Object.groupBy` / `structuredClone` |
| `_.uniq` / hand-rolled set ops | `Set` methods (5.5+) |
| `[...iter].map(f)` for a lazy iterator | iterator helpers (5.6+) |
| `map.has(k) ? map.get(k)! : map.set(k, v).get(k)!` | `map.getOrInsert(k, v)` (6.0+) |
| `new Date()` arithmetic | `Temporal.Now.instant()` / `Temporal.Duration` |
| `try { … } finally { await file.close() }` | `await using file = await open()` (5.2+) |

## Async, errors, I/O

| Before | After |
| --- | --- |
| `catch (e: any)` | `catch (e: unknown)` then narrow |
| `await fetch(url)` with no timeout | `fetch(url, { signal: AbortSignal.timeout(ms) })` |
| `axios.CancelToken` | `AbortSignal` / `AbortSignal.any([parent, timeout])` |
| `as User` on `req.body` / `JSON.parse` / `env` | `schema.parse(input)` (Zod 4 or the repo's Standard Schema lib) |
| floating `void somePromise()` | `await`, or `void somePromise().catch(report)` at a fire-and-forget edge |

## Tests and tooling

| Before | After |
| --- | --- |
| Jest in a **new** package | Vitest, unless the repo is already Jest |
| `ts-node` / `tsx` in a Node 24+ app that is erasable | `node file.ts` + `tsc --noEmit` |
| generated mock of a 20-method interface | in-memory fake of the 2 methods the SUT calls |
| `tsc` 7.0 as `import "typescript"` for eslint | `@typescript/typescript6` peer; 7.0 as the CLI |

## Do not "rewrite" these as a drive-by

Existing Express, Fastify, Nest, Prisma, Jest, Zod 3, or Effect stays.
CJS `"type": "commonjs"` packages stay CJS until someone owns an ESM
migration. `ignoreDeprecations: "6.0"` stays until the tsconfig is actually
cleaned — don't delete it unless you fixed every deprecation.
