# TypeScript 5.0 → now — what to write

Gate every row on the installed `typescript` in `package.json`. Do not use a
flag or syntax newer than that compiler. Write the **After** form.
[modernizers.md](modernizers.md) is the rewrite catalog.

## 5.0 — standard decorators, const type params, bundler, verbatimModuleSyntax

| Before | After |
| --- | --- |
| `experimentalDecorators` / legacy `--emitDecoratorMetadata` | standard `@dec` (TC39); metadata via 5.2 `Symbol.metadata` |
| `function f<T>(x: T)` when `T` should stay literal | `function f<const T>(x: T)` |
| `moduleResolution: node` / `node10` | `bundler` (apps that bundle) or `node16`/`nodenext` (Node libraries) |
| import elision, mixed type/value imports | `verbatimModuleSyntax`; `import type { Foo }` |
| `export *` of types only | `export type *` |
| many `extends` hacks | `"extends": ["a.json", "b.json"]` |

`satisfies` (4.9) is already the 2026 form: `const c = { … } satisfies Config`.

All `enum`s are union enums — still prefer `as const` objects; see 5.8.

## 5.1 — implicit undefined returns, getters/setters

| Before | After |
| --- | --- |
| dummy `return undefined` on `(): void` / `undefined` | omit the return when the return type includes `undefined` |
| same type forced on get/set | unrelated getter/setter types when the runtime API is that shape |

Prefer functions over getters. Do not invent asymmetric accessors.

## 5.2 — `using`, decorator metadata

| Before | After |
| --- | --- |
| `try { … } finally { h.close() }` | `using h = open()` (`Symbol.dispose`) |
| `try { … } finally { await h.close() }` | `await using h = open()` (`Symbol.asyncDispose`) |
| ad-hoc decorator metadata maps | `Symbol.metadata` / `DecoratorMetadata` |
| mixed labeled/unlabeled tuple elements forbidden | named + anonymous tuple elements allowed |

`DisposableStack` / `AsyncDisposableStack` when disposal is conditional or many.

## 5.3 — import attributes, switch(true)

| Before | After |
| --- | --- |
| `import x from "./a.json" assert { type: "json" }` | `import x from "./a.json" with { type: "json" }` |
| `if/else` chains that are really a decision table | `switch (true)` with narrowing `case`s |
| `import type` without `resolution-mode` | `import type … with { "resolution-mode": "import" }` when CJS/ESM types differ |

## 5.4 — NoInfer, groupBy, module preserve

| Before | After |
| --- | --- |
| extra dummy type params to block inference | `NoInfer<T>` |
| lodash `groupBy` / hand-rolled maps | `Object.groupBy` / `Map.groupBy` |
| `module: esnext` when a bundler should see original imports | `module: preserve` + `moduleResolution: bundler` |
| `require()` forbidden under bundler | `require()` allowed with `module: preserve` |

## 5.5 — inferred predicates, isolatedDeclarations, Set methods

| Before | After |
| --- | --- |
| `function isS(x: unknown): x is string { return typeof x === "string" }` | drop `: x is string` when the body infers it |
| `.filter((x): x is T => x != null)` | `.filter(x => x != null)` (still not `.filter(Boolean)` — that is not a predicate) |
| inferred export types in a library `.d.ts` | `isolatedDeclarations`: explicit types on exported bindings |
| hand-rolled `Set` intersection/union | `intersection`, `union`, `difference`, `isSubsetOf`, `isDisjointFrom` |

`${configDir}` in tsconfig `extends` for configs that live outside the package.

## 5.6 — iterators, noUncheckedSideEffectImports

| Before | After |
| --- | --- |
| `[...iter].map/filter` just to transform a lazy iterator | iterator helpers (`map`, `filter`, `take`, `drop`, …) |
| `import "./side-effect"` typos that type-check | `noUncheckedSideEffectImports` (default on in 6.0+) |
| `tsc --build` blocked by downstream errors | build continues; fix the errors, don't hide them with `--noCheck` in CI |

`--strictBuiltinIteratorReturn` is on under `strict`. Don't yield `undefined`
from iterators that claim a useful `TReturn`.

## 5.7 — .ts import rewrite, es2024, never-initialized

| Before | After |
| --- | --- |
| extensionless relative imports that Node cannot strip | `import { x } from "./x.ts"` + `rewriteRelativeImportExtensions` when emitting JS |
| `--target es2023` as "latest" | `es2024` when the compiler is 5.7+ and the runtime supports it |
| use-before-init that used to slip through | initialize; the 5.7 check is a real bug |

Relative `.ts` imports rewrite to `.js` on emit. Package / `#/` / `.js` specifiers
are not rewritten — write those correctly yourself.

## 5.8 — erasableSyntaxOnly, node18, granular returns

| Before | After |
| --- | --- |
| `enum E { A }`, `namespace N`, `constructor(public x: number)`, `import F = …` | erasable forms ([modernizers.md](modernizers.md)) |
| `--module node16` on Node 18-pinned apps | `--module node18` |
| Node 22+ `require(esm)` workarounds | `--module nodenext` (apps on 22+) |
| `return cond ? a : b` where one branch is the wrong type | both branches checked against the return type |

Combine `erasableSyntaxOnly` with `verbatimModuleSyntax`. That pair is the
Node type-stripping contract (`node file.ts`).

## 5.9 — import defer, node20

| Before | After |
| --- | --- |
| eager `import * as heavy from "heavy"` | `import defer * as heavy from "heavy"` when evaluation is optional |
| `--module node18` on Node 20-pinned apps | `--module node20` |

Editor expandable hovers are tooling, not source. Cached instantiations: no
source change.

## 6.0 — last JS-based `tsc`; bridge to 7.0

| Before | After |
| --- | --- |
| `Date` arithmetic, `moment` for instants/durations | `Temporal` (`Instant`, `Duration`, `PlainDate`, `ZonedDateTime`) via `esnext.temporal` |
| `baseUrl` + `paths` | `paths` rooted at the tsconfig; prefer `package.json` `"imports": { "#/*": "./src/*" }` |
| `moduleResolution: node` / `classic` | `nodenext` or `bundler` |
| `target: es5`, `downlevelIteration`, `outFile` | evergreen `target`; a bundler for concatenate |
| `types` omitted (loads all `@types`) | `"types": ["node"]` (or whatever globals you actually need) |
| `module Foo { }` | `namespace Foo` is still legal but **don't**; use ESM |
| `assert { type: "json" }` (incl. `import()`) | `with { type: "json" }` |
| `esModuleInterop: false` / `alwaysStrict: false` | leave them on (6.0+ cannot turn them off) |
| `#alias/` subpath that needed a dummy segment | `"#/*": "./src/*"` (`nodenext` / `bundler`) |
| `Map` missing-then-set | `getOrInsert` / `getOrInsertComputed` |
| hand-rolled regex escape | `RegExp.escape` |

New defaults (also 7.0, where they are not optional): `strict: true`,
`module: esnext`, `target` ≈ `es2025`, `noUncheckedSideEffectImports: true`,
`libReplacement: false`, `rootDir: "."`, `types: []`.

`ignoreDeprecations: "6.0"` silences 6.0 warnings. 7.0 ignores it and errors.
`stableTypeOrdering` makes 6.0 emit order match 7.0; don't leave it on in 6.0 CI
unless you are comparing compilers (up to ~25% slower).

## 7.0 — native Go `tsc`; 6.0 semantics, 6.0 deprecations as errors

Language-compatible with a clean 6.0 build (`stableTypeOrdering` on, no
`ignoreDeprecations`). Compiler is native: 8–12× full-build, LSP language
service, parallel parse/check/emit.

| Before | After |
| --- | --- |
| `typescript@6` `tsc` for apps that only type-check | `npm i -D typescript@^7` and `npx tsc` |
| tools that `import "typescript"` (eslint, Vue, Svelte, Astro, Angular templates) | keep 6.0 API via `typescript: "npm:@typescript/typescript6"` and add `@typescript/native: "npm:typescript@^7"` for CLI |
| UTF-16 surrogate split in `` `${infer H}${infer T}` `` | one Unicode code point per infer (`"😀abc"` → `["😀", "abc"]`) |
| JSDoc `@enum`, Closure `function(string): void`, postfix `!` in `.js` | TypeScript-shaped JSDoc (`typeof`, `@typedef`, `(s: string) => void`) |

Flags: `--checkers` (default 4), `--builders` (project references),
`--singleThreaded` (debug / tiny CI). Pin `--checkers` across machines if you
need bit-identical diagnostics. `--checkers` × `--builders` multiplies memory.

No public programmatic API. Do not `ts.createProgram` against 7.0. Wait for 7.1
(expected later in 2026) or stay on the 6.0 API package.

## 7.1 — only if `typescript` is 7.1+

Draft as of 2026-08-25. Iteration plan: beta 2026-09-09, RC 2026-10-20,
stable 2026-11-10. Do **not** emit 7.1-only APIs on a 7.0 install:

- New (different) programmatic compiler API. Tools migrate off
  `@typescript/typescript6` when the project's `typescript` is 7.1+ **and**
  the tool supports it.
- Until then, side-by-side 6.0 + 7.0 is the supported path.
