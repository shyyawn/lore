# Methods

Canonical shapes. Gate symbols on the `vitest` pin
([SKILL.md](SKILL.md)). Domain recipes: [domains.md](domains.md).

## Files

- `foo.test.ts` next to `foo.ts`. Match `*.spec.ts` if the repo already
  uses it. Fixtures: `testdata/` or a colocated `foo.fixtures.ts`.
- Svelte runes in the test file: `foo.svelte.test.ts` (official).
- Integration that must not run in the default job:
  `*.integration.test.ts` or a separate Vitest project. CI opts in.
- Do not invent a `test-utils` package on the first helper. Third copy
  → same-folder unexported func.

`node:test`: `foo.test.ts` with `import { test } from 'node:test'` and
`node:assert/strict`. Jest: honor `*.test.ts` / `*.spec.ts` already
there.

## Table-driven

Default for more than one input/output pair. Separate `it` when setup,
teardown, or assertions diverge.

```ts
import { describe, expect, it } from "vitest";
import { parse } from "./parse.ts";

describe("parse", () => {
	it.each([
		{ name: "empty", raw: "", wantErr: "empty" },
		{ name: "ok", raw: "ok", want: { v: "ok" } },
	])("$name", ({ raw, want, wantErr }) => {
		const got = parse(raw);
		if (wantErr !== undefined) {
			expect(got.ok).toBe(false);
			if (!got.ok) expect(got.error).toBe(wantErr);
			return;
		}
		expect(got).toEqual({ ok: true, value: want });
	});
});
```

- Case `name` is a stable id, not a sentence. It shows up in `-t` and
  CI.
- Match the repo's result shape (`throw` vs `{ ok, error }`). Do not
  introduce a result library to make the table prettier.
- Do not table-ize unrelated cases that share no fields.

Jest: `it.each` / `test.each`. `node:test`: `t.test(name, …)` in a
loop. Same table instinct.

## Isolation

| Need | Use | Restore |
| --- | --- | --- |
| Time | `vi.useFakeTimers()` | `vi.useRealTimers()` in `afterEach`, or `vi.useFakeTimers` per file |
| `fetch` | Fake `fetch` at the call site, or `vi.stubGlobal` | `vi.unstubAllGlobals` |
| Env | `vi.stubEnv` (Vitest) | `vi.unstubAllEnvs` |
| Temp files | `fs.mkdtemp` under `os.tmpdir`, delete in `afterEach` | Do not write `/tmp/foo` |
| `AbortSignal` | `AbortSignal.abort()` / `AbortSignal.timeout` | — |

`afterEach` clears mocks and timers. A test that mutates
`globalThis` without restore is not done.

Jest: `jest.useFakeTimers` / `jest.stubEnv` if present. `node:test`:
`t.after` / `mock.timers` (Node 20+). Honor that runner.

## Fakes, not mocks

Consumer-side type, methods the caller needs
(`typescript-idioms`). In the test file, a small concrete fake:

```ts
const store: Store = {
	items: new Map<string, Item>(),
	async get(_signal, id) {
		const item = this.items.get(id);
		if (!item) throw new NotFoundError(id);
		return item;
	},
};
```

- **Fake** (working subset) for stores, clocks you still inject, queues.
- **Stub** (canned return) for a single error path.
- **Spy** (`vi.fn` that records) only when the side effect *is* the
  contract (you must publish exactly once).
- **`vi.mock`** only at a stubborn I/O module, and only if the repo
  already mocks that way.

Do not generate a mock of a 20-method type the production file
exported "for testing". Do not `expect(fn).toHaveBeenCalled` when the
output already changed.

## Errors

- Typed error class / discriminant. `instanceof` or the result union
  the caller uses.
- Do not compare `error.message` strings. Messages are not API.
- `wantErr` in the table, not `wantErr: boolean`, when more than one
  failure exists.

## Time and `AbortSignal`

Pass `signal` on I/O. Tests:

1. Already-aborted signal → fails immediately.
2. Abort mid-flight → does not succeed after abort.

Do not `sleep` to wait. Fake timers for TTL / debounce:

```ts
vi.useFakeTimers();
start();
await vi.advanceTimersByTimeAsync(1_000);
expect(expired()).toBe(true);
```

Inject `now` into pure functions that care about "today". Do not add a
Clock type only to avoid fake timers.

## Coverage / CI

| Flag | When |
| --- | --- |
| `vitest run` / `jest` / `node --test` | Every change |
| `--coverage` | Local diagnosis. Do not gate merge on a percentage. |
| Separate integration project | Real DB, real network, multi-process |
| `vitest run --changed` | Optional local. Not a substitute for CI `run` |

`git-repo-setup-typescript` owns where these sit in Lefthook / just /
CI. Do not run the full suite on every commit. Do not put Playwright
in `just test`.
