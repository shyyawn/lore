# Architecture and practices (2024–2026)

Trends that settled in real TypeScript codebases (Node type-stripping, Vite,
Hono, Zod 4 / Standard Schema, platform APIs) — not hexagonal folder fashion.

Go 2024–2026 has the same shape: platform-first instead of stdlib-first,
`AbortSignal` instead of `context.Context`, consumer-side types instead of
consumer-side interfaces, entry wiring instead of `cmd/`. Apply those
instincts here; do not copy Go packages or `internal/` as a cargo cult.

## Platform-first

The runtime and TypeScript `lib` closed the gaps that used to justify a starter
kit of deps:

- `fetch` + `AbortSignal` → HTTP
- `Temporal` (TS 6) → dates
- `crypto.randomUUID` → IDs
- `Object.groupBy`, `Set` methods, iterator helpers, `Map.getOrInsert` → lodash
- `using` / `Disposable` → `try/finally` close
- Node type-stripping + `erasableSyntaxOnly` → `ts-node` in apps

Add a package when it does something the platform will not (a database driver,
OpenTelemetry, Zod at a trust boundary, Hono when you need a router). Do not
add a second library for HTTP clients, dates, UUID, or schema validation.

Hono / Fastify / Nest stay if the project already has them. Do not replace
them with `node:http` as a drive-by restyle. Do not introduce Nest for a
40-line worker.

## Layout

SvelteKit is `sveltekit-app-structure`. Expo Router is `expo/skills`.
Next `app/` is the project's `AGENTS.md` plus bundled `next` docs.
Do not apply this `src/<noun>/` tree to `src/routes` or those `app/`
trees.

Official instinct: start as a few modules next to `package.json`. Grow into
this when there is a second binary or a publish boundary:

```
src/index.ts           # wiring only; flags, logger, process handlers, exit
src/<noun>/            # private implementation; named for the noun
package.json           # "type": "module", "imports": { "#/*": "./src/*" }
tsconfig.json
```

- Tests live next to the code (`foo.test.ts`). Integration tests that must not
  run in the default `vitest` / `node --test` use a separate project or
  `*.integration.test.ts` the CI job opts into.
- `src/index.ts` / `src/cli.ts` stays small: construct deps, run, exit.
  Business logic is not in the entry once it has tests.
- Libraries publish via `package.json` `"exports"` (and `"imports"` for
  internal aliases). Do not invent a `pkg/` directory.

Do **not** create `domain/`, `usecase/`, `adapter/`, `controller/`,
`repository/`, `utils/`, `helpers/`, `common/` layers for a small package.
Flatten. Extract a module when an import cycle or a second entry forces it.

Barrel `index.ts` re-exports are not a layout. They hide cycles, defeat
`isolatedModules`, and slow `tsc`. Import the file that defines the symbol.

## Dependency direction

One-way:

```
entry → http or cli → <domain>
<domain> → platform / vendor SDK only
```

Domain modules must compile without Hono, React, or CLI parsing. Config that
is just "how we dial" belongs next to the client, not under the CLI.

`package.json` `"imports"` (`#/…`) are the 2026 alias. `tsconfig` `paths`
without a runtime equivalent are a lie — they type-check and fail in Node.
`baseUrl` is gone in 6.0/7.0.

## Components

- **Consumer-side types.** The caller declares the type with the two or three
  methods it calls. The producer does not export a 20-method interface "for
  mocking". Same rule as Go's consumer-side interfaces.
- **Fakes over mocks.** An in-memory fake in `foo.test.ts` beats `vi.mock` of
  the whole module for most domain tests. Mock `fetch` at a stubborn I/O
  boundary, not every function.
- **No global clients.** `fetch` wrappers, DB pools, SDK clients are
  constructed in the entry and passed down. No `let client` at module scope.
- **Options:** a typed options object for 2+ optional fields, with `signal?:
  AbortSignal`. Do not add a `withX()` builder to an internal module with one
  caller.
- **Config:** typed object, filled from flags/env in the entry, **parsed**
  (Zod / Standard Schema). No `process.env.FOO!`. No package named `config`
  that accumulates unrelated fields.

## Cancellation and concurrency

`AbortSignal` is `context.Context`:

- Pass `signal` in on any I/O; honor it (`fetch`, streams, loops that `throwIfAborted`).
- Combine with `AbortSignal.any([parent, AbortSignal.timeout(ms)])`.
- One owner creates the `AbortController`; everyone else only receives the
  `AbortSignal`.
- Shared state: don't mutate across concurrent `Promise`s without a queue or
  a lock analog. `structuredClone` at the boundary if you must snapshot.
- No fire-and-forget `void fetch()` in libraries. The caller must see the
  lifetime (`await`, or an explicit `using` / shutdown).

## HTTP services (when you add one)

```ts
import { Hono } from "hono";

const app = new Hono();
app.get("/items/:id", (c) => c.json({ id: c.req.param("id") }));
// Entry owns listen + SIGTERM shutdown (Node `server.close`, Bun.serve, …).
```

Prefer `fetch`-style handlers `(req: Request) => Response` (Hono, `node:http`
with a thin adapter, Cloudflare, Bun). Middleware is
` (next) => (req) => Response `. Request-scoped values that are not in the
signature (trace IDs) may ride `AsyncLocalStorage`. IDs and user objects stay
arguments.

Do not put domain types on `Request` via declaration merging.

## Validation

Parse at the trust boundary (HTTP body, env, CLI, `JSON.parse`, queue payload):

```ts
const User = z.object({ id: z.string(), email: z.email() });
type User = z.infer<typeof User>;
const user = User.parse(input); // throws or returns User — never `as User`
```

Standard Schema (Zod 4, Valibot, ArkType, Effect Schema) is the 2025–2026
interchange. Use **one** in a package. Zod 4 for new code if nothing exists.
Effect Schema only if the repo already runs Effect.

## Logging

- Binary: one logger in the entry (JSON for services, pretty for CLI).
- Library/domain: take a `log` function or a logger type the consumer owns.
  Do not `console.log` inside a library.
- Bind fields per operation (`{ request_id }`), don't format errors into the
  message string.

## Tooling

Apps (Node 22.6+ / 24+, erasable):

```json
{
  "type": "module",
  "imports": { "#/*": "./src/*" }
}
```

```json
{
  "compilerOptions": {
    "target": "esnext",
    "module": "nodenext",
    "moduleResolution": "nodenext",
    "strict": true,
    "verbatimModuleSyntax": true,
    "erasableSyntaxOnly": true,
    "noUncheckedSideEffectImports": true,
    "allowImportingTsExtensions": true,
    "noEmit": true,
    "types": ["node"]
  }
}
```

Libraries that emit `.js` + `.d.ts`: `declaration`, `isolatedDeclarations`,
explicit export types, `rewriteRelativeImportExtensions` if source imports
`.ts`. Bundled UIs: `module: preserve`, `moduleResolution: bundler`.

CI that serious 2025–2026 packages run: formatter check, `tsc --noEmit`,
unit tests, the package manager's audit. TypeScript 7: `tsc` in CI even when
the editor still uses 6.0 for Vue/Svelte/eslint.

TypeScript 7 parallel flags (`--checkers`, `--builders`) are CI knobs, not
source. Pin them when diagnostics must match across machines. Don't raise
both until you have measured memory.

## What 2024–2026 code stopped reaching for

| Stopped | Instead |
| --- | --- |
| `enum` / `namespace` / parameter properties | `as const` objects, ESM, class fields |
| `any` / `as Foo` at boundaries | `unknown` + schema parse |
| `axios` / `node-fetch` | `fetch` |
| `moment` / new `dayjs` | `Temporal` |
| `lodash` for group/clone/set | platform APIs |
| `uuid` | `crypto.randomUUID()` |
| `ts-node` in new Node apps | type-stripping + `tsc --noEmit` |
| `baseUrl` / `moduleResolution: node` | `nodenext` / `bundler` + `#/` imports |
| `utils` / `helpers` / `common` packages | a noun module or a function in the caller |
| interfaces defined "for the whole domain" up front | type at the call site |
| hexagonal `domain/usecase/adapter` for a small package | one module until cycles force a split |
| barrel `index.ts` | direct imports |
| Effect / Nest / tRPC added to look modern | only if the repo already is that shape |
