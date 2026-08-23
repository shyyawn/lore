---
name: go-idioms
description: >-
  Writes, restyles, and reviews Go using idioms from Go 1.18 through 1.27
  (generics, generic methods, any, slog, slices/maps, iterators, ServeMux,
  errors.AsType, WaitGroup.Go, uuid, encoding/json/v2, go fix) and 2024–2026
  architecture practices (stdlib-first, cmd/internal layout, consumer-side
  interfaces, context-first I/O). Use when generating, editing, reviewing, or
  modernizing Go; when the user mentions idiomatic Go, 2026 Go, go fix, slog,
  iterators, or matching go.mod.
---

# Go 2026

Write Go as if `go fix` already ran on the module's `go` version. Do not emit
pre-generics tutorial Go (`interface{}`, `io/ioutil`, `for i := 0; i < n; i++`,
`sort.Slice` for ordered types, `gorilla/mux`, `logrus`, `pkg/errors`).

Full catalogs: [versions.md](versions.md) (1.18→now), [modernizers.md](modernizers.md)
(`go fix`), [architecture.md](architecture.md) (2024–2026 structure).

## First step

Read `go.mod`. Target that version. Do not bump `go` to unlock an idiom.

| `go` | Always use | Not yet |
| --- | --- | --- |
| 1.27+ | everything below plus generic methods, nested struct-literal keys, `"uuid"`, `encoding/json/v2`, `strings.CutLast`, 1.27 `go fix` | `simd` |
| 1.26 | `errors.AsType`, `new(expr)`, `go fix` modernizers | generic methods, `"uuid"`, `encoding/json/v2` |
| 1.25 | `sync.WaitGroup.Go`, `testing/synctest` (stable) | `errors.AsType`, `new(expr)` |
| 1.24 | `t.Context()`, `b.Loop()`, `omitzero`, `tool` in go.mod, `os.Root`, `strings.SplitSeq` | `WaitGroup.Go` |
| 1.23 | `iter.Seq`/`Seq2`, `for range` over iterators, `unique`, `slices.Sorted` | 1.24 testing APIs |
| 1.22 | `for i := range n`, per-iteration loop vars, `http.ServeMux` method+path, `math/rand/v2` | range-over-func (preview only) |
| 1.21 | `any`, `min`/`max`/`clear`, `log/slog`, `slices`, `maps`, `cmp`, `context.WithoutCancel` | loop-var change is not default yet |
| 1.18–1.20 | generics, `any`, `errors.Join` (1.20), fuzzing | std `slices`/`maps` (still x/exp) |

Experimental `GOEXPERIMENT` APIs are out of scope unless the module already enables them.

## After every Go edit

```bash
gofmt -w <files>
go fix ./<packages>          # skip vendor; repeat until go fix -diff is empty
go vet ./<packages>          # catches a class of bug tests do not
go test ./<packages>
```

Write the modern form the first time. Do not write old Go and wait for `go fix`.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| `undefined: errors.AsType`, `new(expr)`, `uuid.New`, `encoding/json/v2` | `go.mod` targets below the version that added it. Write to the module's version; do not bump `go`. |
| `method must have no type parameters` | Generic method on a `go` below 1.27. Keep the helper as a package function. |
| `missing go.sum entry for module providing package …` | A dependency was added but not resolved. `go mod tidy` — never hand-edit `go.sum`. |
| `go vet`: `conversion from X (int) to string yields a string of one rune` | `string(someIntType)` where you meant `.String()` or `strconv.Itoa`. Compiles, passes tests, wrong in production. |
| `go fix -diff` still non-empty after a pass | Modernizers do not cascade. Re-run until empty. |
| Passes alone, fails in `./...` | Shared state or a real-time assumption, exposed by parallelism. `testing/synctest` (1.25+) removes the clock dependency; otherwise find the shared state. |

## Language (1.18 → now)

- `any`, never `interface{}` (including comments).
- Generics for containers, helpers, and constraints — not class hierarchies or "to look modern".
- Type params on a **method** (1.27+), not only the type. They cannot implement interfaces. Below 1.27, keep the helper as a package function.
- Struct-literal keys may be any valid field selector (1.27+). Below 1.27, nest the embedded composite.
- `for i := range n` for 0-based counting. Keep `for i := 1; i <= n; i++` when the domain is 1-based.
- Byte index over a string: `for i := range len(s)`, **not** `for i := range s`.
- No `x := x` inside range loops (1.22+).
- `min`/`max`/`clear` instead of hand-rolled clamps and `for k := range m { delete(m, k) }`.
- `new(expr)` (1.26) for a pointer to a non-zero value. Keep `&T{}` for structs you fill in.
- `//go:build`, never `// +build`.
- Range-over-func iterators (`iter.Seq`, `iter.Seq2`) for streaming APIs; a slice is still right for small in-memory data.
- Go has **no enums**. A named string type plus typed consts is the idiomatic stand-in (`type Step string`; `const StepPaid Step = "paid"`): it documents intent, serializes as itself, and keeps API contracts honest. Two real limits — the compiler does not check exhaustiveness, and a named type does not assert to `string` through `any` (`any(Step("paid")).(string)` is false; assert to `Step`). Use `iota` only for values that are genuinely ordinal and never serialized — renumbering an `iota` const that reached a database or a wire format is silent data corruption.

## Architecture (2024–2026)

Stdlib-first: do not add a dependency the standard library now covers.

| Need | Use | Do not add |
| --- | --- | --- |
| HTTP routing | `http.ServeMux` (1.22 `GET /path/{id}`) | `gorilla/mux`, `gin` for new internal services |
| Logging | `log/slog`; enrich with `slog.With` | `logrus`, new `zap` |
| Errors | `fmt.Errorf("%w")`, `errors.Join`, `errors.AsType` | `pkg/errors` |
| CLI | `flag` for one-off tools; Cobra when a real command tree already exists | a new CLI framework beside an existing one |
| Random | `math/rand/v2` (non-crypto), `crypto/rand` (secrets) | math/rand global Seed |
| UUID | `"uuid"` (1.27+): `uuid.New()`, `uuid.Parse` | `github.com/google/uuid` on 1.27+ |
| JSON | `encoding/json`; 1.27+ new code may use `encoding/json/v2` | jsoniter |
| Tools | `tool` directive in go.mod (1.24) | `tools.go` blank imports |

Layout is earned: `cmd/` for binaries, `internal/` for private code. `pkg/` only when you deliberately publish. No `util/`, `common/`, `helpers/`. Do not invent `domain/` / `usecase/` / `adapter/` trees unless the repo is already that shape. Service internals: `go-backend`. Aggregates: `go-ddd`. More than one module: `go-mono-repo`.

- Name packages for what they **are**, not which binary imports them.
- One-way imports: domain packages must not import CLI, HTTP, or UI wiring.
- Accept interfaces, return structs. Define interfaces at the **consumer**, with the methods that consumer needs.
- Constructors are ordinary functions (`NewX`). No `init()` side effects. No package-level mutable clients.
- Pass `context.Context` as the first argument on any I/O, RPC, or cancellation-aware function.
- `context.WithoutCancel(ctx)` (1.21) for fire-and-forget work that must keep parent values (trace IDs) after the request ends. Do not substitute `context.Background()` for that.

## Errors, concurrency, I/O

- Wrap at the boundary that knows the context: `fmt.Errorf("open db: %w", err)`. Error strings are lowercase, no trailing punctuation.
- Sentinels (`var ErrNotFound = errors.New(...)`) + `errors.Is`. Never `nil, nil` for "not found". Never compare error strings.
- `defer` cleanup immediately after the matching success. `t.Cleanup` in tests.
- Goroutines have a lifetime the caller can see: `WaitGroup.Go` (1.25), `errgroup`, or an explicit done path. No fire-and-forget `go f()` in libraries.
- In `select` on 1.22 and earlier, `time.After` leaks until it fires; use `time.NewTimer` and `Stop`. On 1.23+ unstopped timers are GC'd — `time.After` is fine; call `Stop` only to cancel a pending timer.
- `http.NewRequestWithContext`, never `http.Get`/`http.Post`. Close response bodies. Set `ReadHeaderTimeout` on `http.Server`; shut down with `Shutdown(ctx)`.
- `sql.DB` is a pool: `Open` once, not per request.
- `os`/`io`, never `io/ioutil`.
- JSON: `omitzero` for `time.Time` and other `IsZero` types; keep `omitempty` for slices, strings, pointers.

## Tests

How to write them: `go-unit-tests`. Encore runner: `encore-go`. Temporal:
`temporal-go`.

- `t.Context()` / `b.Context()` (1.24). `for b.Loop()` in new benchmarks.
- `testing/synctest` (stable 1.25) instead of `time.Sleep` to "wait for a goroutine".
- Table tests with `t.Run`; `t.Parallel()` when the test is isolated. Stdlib `testing` for new code; do not rip out existing testify.
- Fuzz functions for parsers and codecs.
- Assert behaviour the type system cannot.

## LLM traps — never generate these

- `interface{}`, `io/ioutil`, `panic(err)` in library code
- `log.Println` / `log.Fatal` inside libraries (the binary owns the logger)
- `%v` when wrapping errors; use `%w`
- `WaitGroup` copied by value; `defer` inside a `for` that must run per iteration
- `init()` that dials, registers HTTP, or reads env as hidden control flow
- Copying `sync.Mutex` (embed or pointer)
- `http.DefaultClient` with no timeout
- New `pkg/errors`, `logrus`, `gorilla/mux`, or a util package
- `github.com/google/uuid` on a 1.27+ module (`"uuid"`)

## Do not

- Restyle unrelated files, or rewrite comments that already tell the truth.
- Rewrite working `encoding/json` to v2 as a drive-by.
- Extract a helper until the third copy.
- Add generics, interfaces, or typed-string "enums" only to look modern.
- Run `go fix` on `vendor/`.
