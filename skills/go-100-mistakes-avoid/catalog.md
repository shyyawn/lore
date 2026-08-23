# Catalog

One-line **2026 action** per row. Read `go.mod` first. Do not expand these
into essays.

## Code and project organization

| # | Title | 2026 action |
| --- | --- | --- |
| 1 | Unintended variable shadowing | Do not redeclare `err`/`ctx` in an inner block when the outer binding must receive the value. Reusing `err` is the common exception. |
| 2 | Unnecessary nested code | Happy path left. Early return. No `else` after `return`. |
| 3 | Misusing init functions | No `init()` that dials, registers HTTP, or reads env. `NewX` from `main`. Static config only. |
| 4 | Overusing getters and setters | Exported fields unless an invariant or compatibility needs a method. No Java-style get/set. |
| 5 | Interface pollution | Discover abstractions. Do not invent producer interfaces "for mocking". |
| 6 | Interface on the producer side | Consumer-side interfaces, methods that consumer needs. |
| 7 | Returning interfaces | Return concrete types. Accept interfaces. |
| 8 | any says nothing | `any` only when the domain is truly any type (`json.Marshal`). Otherwise a type or generic. |
| 9 | Being confused about when to use generics | Generics for containers and helpers, not hierarchies. Need two+ concrete uses. |
| 10 | Problems with type embedding | Do not embed to hide a field path. Do not promote a mutex or a method that should stay private. |
| 11 | Functional options on an internal package | Public library ABI: `WithX` OK. Internal: options struct. No `WithX` for one caller. |
| 12 | Project misorganization | Follow `go-idioms` `architecture.md`. No `domain/` / `usecase/` / `adapter/` trees for a small module. Internals: `go-backend`. |
| 13 | Creating utility packages | No `util` / `common` / `helpers`. Name the noun. |
| 14 | Ignoring package name collisions | Package name is the last import-path element. Do not collide with stdlib (`http`, `json`) or call it `util`. |
| 15 | Missing code documentation | Exported names get a doc comment that starts with the name. Do not document the obvious. |

## Data types

| # | Title | 2026 action |
| --- | --- | --- |
| 16 | Creating confusion with octal literals | `0755` is octal. Write `0o755` when you mean POSIX mode. |
| 17 | Neglecting integer overflows | Typed integers wrap. Convert with care; do not assume `int` is 64-bit. |
| 18 | Not understanding floating-points | Never `==` on floats for money. Integer cents or a decimal type. |
| 19 | Not understanding slice length and capacity | `len` is used; `cap` is backing store. `append` reallocates when `len==cap`. |
| 20 | Inefficient slice initialization | Known size: `make([]T, 0, n)` then append, or `make([]T, n)` then index. `slices.Grow` when growing. |
| 21 | Being confused about nil vs. empty slice | Both have `len==0`. Prefer nil for "no slice". Empty `[]` only when JSON/semantics need it. |
| 22 | Not properly checking if a slice is empty | `len(s)==0`, not `s==nil` (misses empty non-nil). |
| 23 | Not making slice copies correctly | `slices.Clone` for a full copy. `copy` needs an allocated dst. |
| 24 | Unexpected side effects using slice append | `append` may reuse the backing array; aliases mutate. Clone before independent append. |
| 25 | Slices and memory leaks | A subslice keeps the whole array. `slices.Clone` when dropping the rest. |
| 26 | Inefficient map initialization | `make(map[K]V, hint)` when the size is known. |
| 27 | Maps and memory leaks | Delete does not return memory. Replace the map if it grew huge then emptied. Do not assume shrink-to-OS. |
| 28 | Comparing values incorrectly | `==` and map keys need comparable types. Slices/maps/funcs are not comparable (except to nil). `slices.Equal` / `maps.Equal`. |

## Control structures

| # | Title | 2026 action |
| --- | --- | --- |
| 29 | Ignoring that elements are copied in range loops | Range value is a copy. Pointer to an element: `&s[i]`, not `&v`. |
| 30 | Ignoring how arguments are evaluated in range loops | The range expr is evaluated once. Ranging an array copies the array; prefer a slice. |
| 31 | Making wrong assumptions during map iterations | No key order. Insert-during-iter is not guaranteed to appear. Do not sort by ranging. |
| 32 | Ignoring how the break statement works | `break` leaves the inner `for` / `switch` / `select`. Label the loop when breaking from `select` inside `for`. |
| 33 | Using defer inside a loop | `defer` runs at function return, not iteration. Per-iteration cleanup: explicit close, or a scoped func. |

## Strings

| # | Title | 2026 action |
| --- | --- | --- |
| 34 | Not understanding the concept of rune | `rune` is a code point. `len(s)` is bytes. |
| 35 | Inaccurate string iteration | `for i, r := range s` is runes. Do not index UTF-8 with `s[i]` expecting characters. |
| 36 | Misusing trim functions | `Trim` cuts a *set of runes*, not a prefix string. `TrimPrefix` / `CutPrefix` for a literal. |
| 37 | Under-optimized strings concatenation | Loop: `strings.Builder` + `Grow`, or `strings.Join`. Not `s +=` in a hot loop. |
| 38 | Useless string conversions | Keep `[]byte` if you stay in bytes. `string(bytes)` copies. |
| 39 | Substring and memory leaks | `s[i:j]` shares backing data. `strings.Clone` when the original is huge and dropped. |

## Functions and methods

| # | Title | 2026 action |
| --- | --- | --- |
| 40 | Not knowing which type of receiver to use | Pointer if mutating, if a `sync` field, or if large. Value if small and immutable. Do not mix without a reason. |
| 41 | Never using named result parameters | Name results when they document returns or simplify `defer`. Do not name unused results. |
| 42 | Unintended side effects with named result parameters | Naked `return` after assigning a named result can surprise if shadowed. Prefer explicit returns then. |
| 43 | Returning a nil receiver | A nil concrete pointer inside a non-nil interface is not `== nil`. Return a typed nil interface, or `return nil, err`. |
| 44 | Using a filename as a function input | Accept `io.Reader` / `fs.FS` when the caller should control I/O (tests). |
| 45 | Ignoring how defer arguments and receivers are evaluated | Args and the receiver are evaluated at `defer` time, not at run. Capture what you mean. |

## Error management

| # | Title | 2026 action |
| --- | --- | --- |
| 46 | Panicking | Libraries return errors. `panic` only for impossible invariants. The binary owns exit. |
| 47 | Ignoring when to wrap an error | Wrap at the boundary that knows context: `fmt.Errorf("open db: %w", err)`. Lowercase, no trailing punctuation. |
| 48 | Comparing an error type inaccurately | `errors.AsType` when `go` is 1.26+. Else `errors.As`. Never `err.(*T)` on wrapped errors. |
| 49 | Comparing an error value inaccurately | `errors.Is`. Never `==` on wrapped sentinels. Never compare error strings. |
| 50 | Handling an error twice | Log *or* return, not both, except at the process boundary. |
| 51 | Not handling an error | `_ = err` is a bug unless the API documents it. Check every call. |
| 52 | Not handling defer errors | Capture `Close()` / `Rollback()` errors. Do not ignore the deferred call. |

## Concurrency: foundations

| # | Title | 2026 action |
| --- | --- | --- |
| 53 | Thinking concurrency is always faster | Measure. Extra goroutines cost. I/O-bound vs CPU-bound. |
| 54 | Being puzzled about when to use channels or mutexes | Mutex for shared state. Channel for ownership transfer / signaling. Not both on the same data. |
| 55 | Not understanding race problems | Data race ≠ race condition. `go test -race`. No "benign" races. |
| 56 | Not understanding the concurrency impacts of a workload type | CPU-bound: bound workers. I/O-bound: oversubscribe with care. No unbounded `go` per request. |
| 57 | Misunderstanding Go contexts | `ctx` first. Honor `Done`. Values only for request-scoped non-API data (trace IDs). |

## Concurrency: practice

| # | Title | 2026 action |
| --- | --- | --- |
| 58 | Propagating an inappropriate context | Do not use request `ctx` for work that must outlive the request. `context.WithoutCancel` to keep parent values. Do not substitute `context.Background()` for that. |
| 59 | Starting a goroutine without knowing when to stop it | Visible lifetime: `WaitGroup.Go`, `errgroup`, or `Shutdown`. No fire-and-forget in libraries. |
| 60 | Expecting deterministic behavior using select and channels | Multiple ready cases: uniform random. Case order is not priority. |
| 61 | Not using notification channels | Signal-only: `chan struct{}`. Do not send a dummy bool. |
| 62 | Not using nil channels | A nil chan blocks forever. Use that to disable a `select` case. |
| 63 | Being puzzled about channel size | Unbuffered default. Buffer only with a reason and a bound. |
| 64 | Forgetting about possible side effects with string formatting | `fmt` / `slog` of a type whose `String` takes the same mutex can deadlock or race. Do not format under that lock. |
| 65 | Creating data races with append | Concurrent `append` on the same slice is a race. Mutex, or do not share. |
| 66 | Using mutexes inaccurately with slices and maps | The mutex must cover the header and the contents. Copy out under lock to return a snapshot. |
| 67 | Misusing sync.WaitGroup | `WaitGroup.Go`. Do not copy the WaitGroup. `Add` before `go` only when `go` is below 1.25. |
| 68 | Using sync.Cond | A channel. Not `sync.Cond`. |
| 69 | Not using errgroup | `errgroup.WithContext` for cancel-on-first-error worker sets. Do not hand-roll WaitGroup + first-error. |
| 70 | Copying a sync type | Never copy `Mutex` / `WaitGroup` / etc. Embed or pointer. `go vet` copylocks. |

## Standard library

| # | Title | 2026 action |
| --- | --- | --- |
| 71 | Providing a wrong time duration | `time.Sleep(1)` is one nanosecond. Always `time.Second` (or `Millisecond`, …). |
| 72 | JSON handling common mistakes | Do not embed `time.Time` (it implements `Marshaler`). `omitzero` for `time.Time`. Keep `omitempty` for slices/strings/pointers. |
| 73 | Common SQL mistakes | `sql.DB` is a pool: `Open` once. Close `Rows`. Context variants. Never sprintf SQL. |
| 74 | Not closing transient resources | HTTP body, `sql.Rows`, `os.File`: `defer Close` immediately after success. Check the error. |
| 75 | Forgetting the return after replying to an HTTP request | After `http.Error` / `WriteHeader`, `return`. Do not keep writing. |
| 76 | Using the default HTTP client and server | Never `http.DefaultClient` / `ListenAndServe` without timeouts. `ReadHeaderTimeout`. `Shutdown(ctx)`. `NewRequestWithContext`. |

## Testing

| # | Title | 2026 action |
| --- | --- | --- |
| 77 | Not categorizing tests | Build tags / `-short` / env for integration. `//go:build integration`. Do not hide unit tests behind tags. |
| 78 | Not enabling the race flag | `go test -race` on packages that start goroutines (`ci`). |
| 79 | Not using test execution modes | `t.Parallel()` when isolated. `-shuffle=on` in CI. Do not parallel tests that share globals. |
| 80 | Not using table-driven tests | `t.Run` tables. Do not copy-paste cases. |
| 81 | Sleeping in unit tests | No `time.Sleep` to wait for a goroutine. `synctest.Sleep` when `go` is 1.27+. Else `synctest.Test` + `Wait`. Ready channel if `go` is below 1.25. |
| 82 | Not dealing with the time API efficiently | Inject a clock. Do not call `time.Now()` deep in logic you need to test. |
| 83 | Not using testing utility packages | `httptest.NewRecorder` / `NewTestServer` (1.27+; else `NewServer` + Cleanup), `iotest`. Do not listen a real port in unit tests. |
| 84 | Writing inaccurate benchmarks | Setup outside the loop. `for b.Loop()`. Report allocations. Do not optimize from a bad bench. |
| 85 | Not exploring all the Go testing features | `t.Helper`, `t.Cleanup`, `t.TempDir`, `t.Setenv`, `t.Context`. Fuzz parsers and codecs. |

## Optimizations

| # | Title | 2026 action |
| --- | --- | --- |
| 86 | Micro-optimizing without a profile | Don't guess. Use `pprof` / the tracer before changing performance. |
