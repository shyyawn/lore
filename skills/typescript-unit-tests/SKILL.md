---
name: typescript-unit-tests
description: >-
  Writes, reviews, and restyles TypeScript tests using 2024–2026 Vitest
  (it.each, vi.useFakeTimers, fakes over vi.mock) or the repo's Jest /
  node:test, and a 2026 what-to-test / what-to-skip policy. Use when
  writing, editing, reviewing, or generating TypeScript or JavaScript
  tests; when the user mentions vitest, jest, node:test, vi.mock,
  coverage, or flaky TS tests. Overlay on typescript-idioms. Svelte
  components: svelte. Browser journeys: e2e-tests. Next / Expo: house
  policy here, setup from the pin's Testing guide.
---

# TypeScript unit tests 2026

Follow `typescript-idioms`. This file fills **what to test** and the
runner's shapes. Patterns: [methods.md](methods.md). Per-domain:
[domains.md](domains.md). Kit runner: `git-repo-setup-typescript`.

Browser journeys: `e2e-tests`. Svelte pin: `svelte`. Next / Expo:
house here; setup from the pin's Testing guide. Do not flatten those
`app/` trees. Do not fork a Next or Expo test encyclopedia.

Sources: Vitest guide, Node `node:test`, Svelte `svelte/testing`, Next
Testing guide (pin), Expo `jest-expo`. Not their trees.

## First step

1. Read `package.json` (`vitest`, `jest`, `@playwright/test`) and the
   Vitest / Jest config. Target that runner. Do not bump `vitest` to
   unlock an API.
2. Match existing test files (`foo.test.ts` vs `*.spec.ts`, `describe`
   imports vs globals).
3. If a more specific owner already has this, **stop**.

| Detect | Follow |
| --- | --- |
| `playwright.config.*` / `tests/*.spec.ts` journeys | `e2e-tests` |
| `encore.app` + TypeScript | `encore test` (plugin). Not Vitest of generated client |
| `next` in `package.json` | This skill + pin Testing guide. Async RSC: `e2e-tests` |
| `expo` in `package.json` | This skill + `jest-expo`. Native journeys: `e2e-tests` |
| `svelte.config.*` | This skill for tables. Setup: `npx sv add vitest` |

| `vitest` | Always use | Not yet |
| --- | --- | --- |
| 4.x | `test.projects`, `provider: playwright()` from `@vitest/browser-playwright`, `import { … } from 'vitest/browser'` | `provider: 'playwright'`, `@vitest/browser/context` in new config |
| 3.2–3.x | `test.projects`, `provider: 'playwright'`, `@vitest/browser` | 4.x factory provider |
| 3.0–3.1 | The `workspace` file the repo already has | Renaming it as a drive-by |
| none, new Vite / Svelte / Next app | Add Vitest. Honor the lockfile's major if a parent already pins it | Jest |
| none, Expo | `jest-expo` (`npx expo install jest-expo jest`) | Vitest |
| none, zero-dep Node lib | `node:test` | Vitest as a drive-by |
| Jest already the suite | Honor Jest (`jest.fn`, `jest.useFakeTimers`) | A Vitest migrate |

Do not emit Vitest 4 provider factories on a 3.x pin.

## What this skill owns

| Own | Leave |
| --- | --- |
| What to test / skip, tables, fakes, timers, `AbortSignal` | Language (`typescript-idioms`) |
| Vitest / Jest / `node:test` shapes | Runner wiring (`git-repo-setup-typescript`) |
| Svelte / Vite React / Next / Expo house recipes | Pin (`svelte`); Kit tree (`sveltekit-app-structure`) |
| | Browser / device journeys (`e2e-tests`) |
| | Next Testing guide body; Expo Jest / Maestro docs |

## After every test edit

```bash
npx tsc --noEmit -p <tsconfig>   # or the typecheck / svelte-check script
npx vitest run <files>           # jest → npx jest; node:test → node --test
```

Honor the `test` script. A test that only passes alone is not done.

## What to test

Assert behaviour the type system cannot. Prefer one test of the public
result over five tests of the private path that produced it.

| Test | Why |
| --- | --- |
| Business rules, validation, state machines | This is the suite. Table every variant. |
| Error classification | Typed error / result union. Not-found vs conflict vs internal. |
| Boundaries | empty, `undefined` vs `null`, 0, invalid UTF-8, duplicate keys |
| `AbortSignal` cancel / timeout | Honor `signal` mid-flight, not only before the call. |
| Parsers, codecs, Zod at a boundary | Table the known cases. Do not re-test Zod. |
| Security-sensitive paths | authz allow/deny, path-jail, webhook signature, IDOR |
| Idempotency / retries | Second call does not double-apply. Permanent vs retryable. |
| HTTP contract the client depends on | Status, headers you own, parsed body. Not `fetch`. |
| Custom type guards / `schema.parse` wrappers | Round-trip. Failure is a typed error. |

## What not to test

| Skip | Why |
| --- | --- |
| Getters, field assignment, `new X` that only stores deps | The type system already did. |
| Generated code (`encore.gen/`, `./$types`, OpenAPI, Prisma client) | You do not own it. |
| Runtime / framework internals | Do not prove `JSON.parse` or Svelte runes work. |
| One-line wrappers around a library | Test your mapping, not their client. |
| Unexported helpers already covered by the public API | Lock the API, not the helper name. |
| That a mock was called, when the return value already proves it | Interaction tests couple to implementation. |
| Log line text as the spec | Brittle. |
| Exact `Date.now()` / `Temporal.Now` timestamps | Fake timer / injected clock, or assert order/delta, or don't. |
| 100% coverage, every `catch`, every `using` | Coverage is a lamp, not a goal. |
| Entry wiring (`src/index.ts`, `src/app.html`) | Test the functions the entry calls. |
| Component `innerHTML` as the spec | Roles / text. Extract logic first (`svelte/testing`). |
| Third-party retry / HTTP clients | Test *your* classification of retryable. |

Do not invent tests to move a coverage number. Do not skip a table case
because "that can't happen" if the function accepts the input.

## Review workflow

Copy this checklist against the tests you write or review.

```
TypeScript tests:
- [ ] Public behaviour, not private helpers / mock call order
- [ ] it.each / table for variants; separate it() when setup diverges
- [ ] Typed errors / result unions — no message-string compare
- [ ] AbortSignal abort + timeout cases on I/O
- [ ] No sleep to wait; vi.useFakeTimers or a ready promise
- [ ] Fakes at consumer types; no vi.mock of a 20-method module you own
- [ ] fetch / clock mocked at the I/O boundary only
- [ ] Svelte / Vite React: extract logic; Testing Library; getByRole
- [ ] Next: async RSC not in jsdom — journey instead
- [ ] Expo: jest-expo; do not add Vitest
- [ ] Isolated; no leaked timers, fetch mocks, or temp files
```

Fix in place. Do not add comments that restate the table `name`.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| Passes alone, fails in the full run | Shared mock, unreset timer, or import-order state. |
| Flaky around a timer / `setTimeout` | Real clock. `vi.useFakeTimers`. |
| `Cannot find name 'describe'` after a 6.0/7.0 bump | `types` defaults to `[]`. List the runner types, never `"*"`. |
| `provider: 'playwright'` fails on Vitest 4 | Factory provider. `@vitest/browser-playwright`. |
| `undefined: playwright` in vitest config | 3.x pin. Keep the string provider. |
| Encore: panic / missing runtime | `vitest` on an Encore package. `encore test`. |
| jsdom missing `navigation` / layout | Component needs a real browser, or this is an e2e journey. |
| jsdom / Vitest fails on an `async` Server Component | Official Next: e2e. `e2e-tests`. |
| Vitest next to `jest-expo` | Expo unit is Jest. Drop the Vitest drive-by. |
| Coverage gap on a `switch` / error path | Missing table row, not a new `vi.mock`. |

## LLM traps — never generate these

- `sleep` / `setTimeout` to "wait for a request" or "let the cache expire"
- Jest added to a Vite / Svelte app that has no Jest
- Vitest added to a zero-dep lib that already uses `node:test`
- `vi.mock` of a module the production file defined "for testing"
- `expect(err.message).toBe(...)` as the spec
- `as` / `as unknown as T` inside a test to silence a type
- `axios-mock-adapter` / `nock` on a codebase that uses `fetch`
- `Date.now = () => …` without restore — `vi.useFakeTimers`
- Tests of `./$types`, `encore.gen/`, or generated clients
- `innerHTML` snapshots of a Svelte component as the default
- Vitest browser mode as a substitute for Playwright journeys
- Vitest added to an Expo app that has `jest-expo`
- jsdom tests of `async` Server Components
- Flattening Next / Expo `app/` so a test looks "idiomatic"
- Bare React Native / Detox unasked
- Bumping `vitest` to unlock a 4.x line

## Do not

- Rip out working Jest / Mocha / `node:test`. New files stay on that
  runner.
- Hide unit tests behind an e2e job. Journeys are `e2e-tests`.
- Recopy the Next Testing guide or Expo Jest / Maestro docs here.
- Restyle unrelated production code in the name of a test pass.
- Chase 100% coverage or add tests that only satisfy a linter.
