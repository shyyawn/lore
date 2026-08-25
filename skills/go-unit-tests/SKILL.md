---
name: go-unit-tests
description: >-
  Writes, reviews, and restyles Go tests using 2024–2026 stdlib testing
  (table-driven t.Run, t.Context, testing/synctest, fuzzing, b.Loop,
  cryptotest, httptest) and a 2026 what-to-test / what-to-skip policy.
  Use when writing, editing, reviewing, or generating Go tests; when the
  user mentions go test, table tests, synctest, fuzz, httptest, coverage,
  mocks, or flaky Go tests. Overlay on go-idioms. Encore: encore-go.
  Temporal: temporal-go.
---

# Go unit tests 2026

Write tests the stdlib already covers. Language and layout: `go-idioms`.
Don't-do-this review: `go-100-mistakes-avoid` (#77–85). Patterns:
[methods.md](methods.md). Per-domain: [domains.md](domains.md).

Encore packages: `encore test`, not `go test` (`encore-go`). Temporal
workflows: `testsuite` + replay (`temporal-go`). This skill still owns
table shape, fakes, race, and what to assert.

## First step

1. Read `go.mod`. Target that `go` line. Do not bump `go` to unlock a
   testing API.
2. Match the package's existing test files (`foo_test.go`, testify or not,
   `package foo` vs `foo_test`).
3. If `encore.app` exists, the runner is `encore test`.

| `go` | Always use | Not yet |
| --- | --- | --- |
| 1.27+ | `synctest.Sleep`, `httptest.NewTestServer` (in-memory, synctest-safe) | — |
| 1.26 | `t.ArtifactDir`, `testing/cryptotest.SetGlobalRandom` | `synctest.Sleep`, `NewTestServer` |
| 1.25 | `synctest.Test` / `Wait`, `t.Attr`, `t.Output` | `cryptotest` |
| 1.24 | `t.Context()`, `b.Context()`, `for b.Loop()`, `t.Chdir` | `synctest.Test` / `Wait` |
| 1.23 | `httptest.NewRequestWithContext` | `t.Context` |
| 1.22 | per-iteration loop vars (no `tt := tt`) | — |
| 1.18–1.21 | fuzz (`FuzzXxx`), `t.Setenv`, `t.TempDir`, `t.Cleanup` | later APIs |

Use `synctest.Test` / `synctest.Wait` on 1.25+.

## After every test edit

```bash
gofmt -w <files>
go test ./<packages>                 # encore.app → encore test
go test -race ./<packages>           # if the package starts goroutines
```

A test that only passes alone is not done. `go test ./...` with `-shuffle=on`
and `-count=1` is the flake check.

## What to test

Assert behaviour the type system cannot. Prefer one test of the public
result over five tests of the private path that produced it.

| Test | Why |
| --- | --- |
| Business rules, validation, state machines | This is the suite. Table every variant. Aggregates: `go-ddd`. |
| Error classification | `errors.Is` / `As` / `AsType`. Status mapping. Not found vs conflict vs internal. |
| Boundaries | empty, nil vs empty slice, 0, max int, invalid UTF-8, duplicate keys |
| Context cancel / deadline | Honor `ctx.Done()` mid-flight, not only before the call. |
| Concurrency contracts | No data race. Correct publish-then-observe. `synctest` + `-race`. |
| Parsers, codecs, validators | Table the known cases. **Fuzz** the rest. |
| Security-sensitive paths | authz allow/deny, path-jail (`os.Root`), webhook signature, IDOR |
| Idempotency / retries | Second call does not double-apply. Permanent vs retryable errors. |
| Custom marshalers | Types you wrote `MarshalJSON` / `TextMarshaler` for. Round-trip. |
| SQL that encodes rules | Unique, `ErrNoRows` mapping, transaction rollback. Integration, not a mock driver. |
| HTTP contract the client depends on | Status, `PathValue` routing, headers you own. Not the framework. |

## What not to test

| Skip | Why |
| --- | --- |
| Getters, field assignment, `NewX` that only stores deps | The type system already did. |
| Generated code (`encore.gen/`, protobuf, `stringer`, `mockery` output) | You do not own it. |
| Stdlib / framework internals | Do not prove `json.Marshal` or `http.ServeMux` works. |
| One-line wrappers around a library | Test your mapping, not their client. |
| Unexported helpers already covered by the public API | Lock the API, not the helper name. |
| That a mock was called, when the return value already proves it | Interaction tests couple to implementation. |
| Log line text as the spec | Brittle. `slogtest` only if you **implement** a `slog.Handler`. |
| Exact `time.Now()` timestamps | Fake clock / `synctest`, or assert order/delta, or don't. |
| Goroutine counts, GC, scheduling | Not a contract. `-race` and `synctest` deadlock are. |
| 100% coverage, every `%w` wrap, every `defer Close` | Coverage is a lamp, not a goal. |
| `package main` wiring | Test the functions `main` calls. |
| Third-party retry/backoff libraries | Test *your* classification of retryable. |

Do not invent tests to move a coverage number. Do not skip a table case
because "that can't happen" if the function accepts the input.

## Review workflow

Copy this checklist against the tests you write or review.

```
Go tests:
- [ ] Public behaviour, not private helpers / mock call order
- [ ] Table + t.Run for variants; separate TestXxx when setup diverges
- [ ] errors.Is / AsType — no err.Error() string compare
- [ ] t.Context (1.24+); t.Cleanup / t.TempDir; no leaked files or listeners
- [ ] No time.Sleep to wait; synctest (1.25+) or a ready channel
- [ ] t.Parallel only when isolated; never with t.Setenv / t.Chdir / cryptotest
- [ ] Fakes at consumer interfaces; no producer-side 20-method mock
- [ ] Fuzz on parsers/codecs; seed with f.Add; commit crashing inputs
- [ ] httptest / fstest / iotest / MapFS — no real port, no /tmp/foo
- [ ] -race on concurrent packages; -shuffle=on in CI
```

Fix in place. Do not add comments that restate the table `name`.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| Passes alone, fails in `./...` or under `-shuffle` | Shared state, map iter order, or a real-time assumption. |
| Flaky around a timer / sleep | Real clock. `synctest.Test`. |
| `synctest` deadlock / Test panics | A goroutine is blocked on a mutex, I/O, or a channel created **outside** the bubble (not durably blocked). |
| `t.Setenv` / `t.Chdir` panic | `t.Parallel` on this test or a parent. Drop Parallel. |
| `undefined: synctest.Test` | `go` < 1.25. |
| `undefined: cryptotest.SetGlobalRandom` | `go` < 1.26. Don't fake `crypto/rand` by hand. |
| `undefined: synctest.Sleep` | `go` < 1.27. `time.Sleep` + `synctest.Wait`. |
| `undefined: httptest.NewTestServer` | `go` < 1.27. `NewServer` + `t.Cleanup(srv.Close)`. |
| Race detector hit | Real bug. No "benign" races. Don't `sync.Mutex` the test to hide it. |
| Coverage gap on a `switch` / error path | Missing table row, not a new mock. |
| Encore: panic `apps must be run using the encore command` | `go test` instead of `encore test`. |

## LLM traps — never generate these

- `time.Sleep` to "wait for a goroutine" or "let the cache expire"
- `testify` / `gomock` / `mockery` / `go-cmp` added to a module that does not already use them
- `err.Error() == "..."`, `strings.Contains(err.Error(), ...)`
- `httptest.NewRequest` when the handler needs cancel — use `NewRequestWithContext(t.Context(), ...)` (1.23+)
- `httptest.NewServer` on 1.27+ when `NewTestServer` would do (in-memory / synctest)
- Calling a `PathValue` handler as a bare func (mux never ran)
- `sqlmock` / generated mocks of a 15-method store the production type defined
- `t.Parallel()` plus `t.Setenv`, `t.Chdir`, or `cryptotest.SetGlobalRandom`
- `Wait(t)` (it is `synctest.Wait()`)
- `for i := 0; i < b.N; i++` in new benchmarks — `for b.Loop()`
- `os.MkdirTemp` / hardcoded `/tmp/...` — `t.TempDir()`
- `os.Setenv` / `os.Chdir` without restore — `t.Setenv` / `t.Chdir`
- `tt := tt` copies on 1.22+
- `package util_test`, a `testutil` package, or assertion helpers in `internal/helpers`
- Tests of `encore.gen/`, protobuf `.pb.go`, or mockery output
- Fuzz targets that dial the network or sleep
- `testing/quick` for new code (fuzz replaced it)
- Clock interfaces on a 1.25+ module whose only need is `time.Sleep` / timers

## Do not

- Rip out working testify / suites / mockery. New files stay stdlib.
- Hide unit tests behind `//go:build integration`. Tags are for the slow suite.
- Duplicate `encore-go` or `temporal-go` test recipes here.
- Restyle unrelated production code in the name of a test pass.
- Chase 100% coverage or add tests that only satisfy a linter.
