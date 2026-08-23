# Domains

What to assert per kind of code. Shapes: [methods.md](methods.md).
Journeys stay `e2e-tests`. Next / Expo / Encore.ts keep their owners.

## Pure domain / validation

Table every branch the function documents. Include empty, `undefined`,
overflow, unicode, and the error the caller is supposed to classify.
Pass `now` into functions that care about "today" rather than calling
`Date.now()` / `Temporal.Now` inside.

Do not test that `Array.isArray` works. Do not test unexported
normalizers the exported function already exercises.

## `fetch` / HTTP

Fake `fetch` at the I/O boundary. Assert URL, method, headers you own,
and that `signal` is forwarded. Production checks `response.ok`.

Do not add `nock` / `msw` / `axios-mock-adapter` to a codebase that
does not already use them. Do not `fetch` a real host in a unit test.

Handler / route tests (Hono, `node:http`): in-process. Assert status,
headers you own, and the parsed body. Do not re-test domain rules
already covered — the handler owns mapping (401 vs 404 vs 409).

## Zod / parse-at-boundary

Table valid and invalid payloads the boundary documents. Assert the
typed error the caller sees. `z.infer<typeof schema>` is the type —
do not `as User` in the test to make it compile.

Do not write one test per Zod keyword. Do not unit-test `z.string()`.

## Svelte / SvelteKit

Setup: `npx sv add vitest` if Vitest is missing. Honor the client /
server projects that add-on writes.

Official instinct: extract the logic and unit-test that first. A
component test is earned.

- Runes in the test: `foo.svelte.test.ts`. `flushSync` after a
  mutation. Effects: wrap in `$effect.root` and call the cleanup.
- Component: `@testing-library/svelte` + `userEvent`. `getByRole`,
  not `innerHTML`.
- Bindings / context / snippets: a wrapper component for that test
  (Testing Library examples).
- Server modules (`$lib/server`, `*.server.ts`): Node project. Do not
  import them from a jsdom / browser project.
- Kit `load` / actions: test the function. Do not mount `+page.svelte`
  to prove routing.

Vitest browser mode is a **component** runner. It is not an e2e
journey. Journeys: `e2e-tests` (`npx sv add playwright`).

Do not restyle working jsdom tests into browser mode as a drive-by.
Do not enable `experimental.async` to make a test compile (`svelte`).

## Next.js / Expo

**Stop.** Next: project `AGENTS.md` + official Vitest / Playwright
guides. Expo unit: `expo/skills` (Jest). Expo native e2e: Maestro,
not this file.

Do not flatten `app/` into `src/<noun>/` to make a test "idiomatic".

## Encore.ts

`encore test`. Call APIs as functions. Real isolated DBs/topics. Do
not Vitest the generated client. Full recipe: Encore plugin.

## Filesystem and env

Production that accepts a `URL` / `Buffer` / injected reader is
testable. Do not `writeFile("/tmp/test-...")`. Do not `chdir` without
restore.

`vi.stubEnv` for env-backed config. No parallel assumption across
files that stub the same key.

## What lives in the default job

| Default `vitest run` / `jest` / `node --test` | Opt-in integration / e2e |
| --- | --- |
| Domain tables, handler in-process, fakes, fake timers | Real Postgres, real S3, multi-process |
| jsdom / Testing Library / Vitest browser (component) | Playwright journeys (`e2e-tests`) |

Unit tests never live under `tests/` as Playwright specs. Playwright
specs never replace the unit table.

## Edge cases worth a table row

These fail in production and are cheap in a table. Skip the ones that
cannot reach the function.

- `undefined` vs `null` vs missing JSON field
- empty string, whitespace-only, invalid UTF-8
- 0, -1, `Number.MAX_SAFE_INTEGER`, overflow on convert
- duplicate IDs, already-exists, not-found
- `AbortSignal` aborted at start and mid-call
- `AbortSignal.timeout` vs caller-owned abort
- second apply of an idempotent op
- timezone: store instant / UTC, do not `===` local wall times
