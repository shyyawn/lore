# Go 1.18 → now — what to write

Gate every row on the module's `go` line. Do not use a symbol newer than `go.mod`.
`go test` on 1.27+ runs `stdversion` and will fail if you ignore this.

Write the **After** form. `go fix` is the backstop for rows it covers ([modernizers.md](modernizers.md)).

## 1.18 — generics, `any`, fuzzing, embed

| Before | After |
| --- | --- |
| `interface{}` | `any` |
| hand-rolled `MinInt`/`contains` per type | type parameters; later std `slices`/`maps` (1.21) |
| `// +build` | `//go:build` (already preferred; required with 1.18 files) |
| no fuzz | `func FuzzXxx(f *testing.F)` for parsers/codecs |
| go:embed workarounds | `//go:embed` (1.16, still the 2026 form) |

Generics: functions and types with constraints (`comparable`, interface type sets). Do not build inheritance. Do not put type parameters on methods until 1.27.

## 1.19 — atomic types

| Before | After |
| --- | --- |
| `var n int64; atomic.AddInt64(&n, 1)` | `var n atomic.Int64; n.Add(1)` |
| `atomic.Value` for typed pointers | `atomic.Pointer[T]` |

## 1.20 — wrapping many errors, comparable

| Before | After |
| --- | --- |
| first error only, or a string join | `errors.Join(errs...)` |
| `errors.Is`/`As` on a single wrap | they walk joined errors too |
| `http.ResponseController` hacks | `http.NewResponseController` where needed |
| global `math/rand.Seed` | own `rand.Source`; 1.22: `math/rand/v2` |

## 1.21 — slog, slices, maps, cmp, builtins, WithoutCancel

| Before | After |
| --- | --- |
| logrus / zap / `log.Printf` in new services | `log/slog` (`Info`, `Error`, `With`) |
| `golang.org/x/exp/slices` or a for-loop | `"slices"` |
| `golang.org/x/exp/maps` copy/clone/equal loops | `"maps"` |
| `if x < 0 { x = 0 }` | `x = max(0, x)` |
| `for k := range m { delete(m, k) }` | `clear(m)` (also slices) |
| `sort.Slice(s, func(i, j int) bool { return s[i] < s[j] })` | `slices.Sort(s)` |
| `context.Background()` to detach a child | `context.WithoutCancel(ctx)` (keeps values) |
| `errors.ErrUnsupported` hand-rolled | `errors.ErrUnsupported` |

Libraries never call `slog.SetDefault()` — `main` owns that.

## 1.22 — loop vars, range-int, ServeMux, rand/v2

| Before | After |
| --- | --- |
| `for i := 0; i < n; i++` | `for i := range n` |
| `for _, x := range s { x := x; go f(x) }` | drop `x := x` |
| `mux.HandleFunc("/p/", ...)` + `strings.TrimPrefix` | `http.NewServeMux(); mux.HandleFunc("GET /p/{id}", ...)` and `r.PathValue("id")` |
| `gorilla/mux` for method+path | stdlib mux |
| `math/rand` global | `math/rand/v2` (`IntN`, `N`, `ChaCha8`/`PCG`) |
| `reflect.TypeOf((*T)(nil)).Elem()` | `reflect.TypeFor[T]()` |

`GODEBUG=httpmuxgo121=1` is a migration hatch, not new code.

## 1.23 — iterators, unique, structs, timers

| Before | After |
| --- | --- |
| collect keys then sort | `slices.Sorted(maps.Keys(m))` |
| `for _, p := range strings.Split(s, sep)` (1.24 seq) | prefer `SplitSeq` once on 1.24 |
| custom intern maps | `"unique"` for canonical comparable values |
| `for i := len(s)-1; i >= 0; i--` | `for i, v := range slices.Backward(s)` |
| buffered timer channel assumptions | timers are synchronous; do not rely on `Reset` racing a receive |

New packages: `iter` (`Seq`, `Seq2`, `Pull`), `unique`, `structs`. Implement iterators with `yield`; return false from yield means the caller `break`s — stop cleanly.

## 1.24 — omitzero, t.Context, tools, Root, seq strings

| Before | After |
| --- | --- |
| `json:"t,omitempty"` on `time.Time` | `json:"t,omitzero"` |
| `ctx, cancel := context.WithCancel(context.Background()); defer cancel()` in tests | `ctx := t.Context()` |
| `for i := 0; i < b.N; i++` + `b.ResetTimer()` | `for b.Loop()` |
| `tools.go` with `_ "golangci-lint"` | `tool` directive in `go.mod`; run `go tool <name>` |
| `filepath.Join(root, userPath)` without jail | `os.OpenRoot` / `os.Root` |
| `[]byte(fmt.Sprintf(...))` | `fmt.Appendf(nil, ...)` |
| `strings.HasPrefix` + `TrimPrefix` | `strings.CutPrefix` |
| `crypto/rand` hex helpers | `rand.Text` where a readable secret is enough |
| `testing/synctest` via `GOEXPERIMENT` | available experimental; prefer 1.25 stable API |

Swiss-table maps are the runtime default — no source change.

## 1.25 — WaitGroup.Go, synctest stable

| Before | After |
| --- | --- |
| `wg.Add(1); go func() { defer wg.Done(); ... }()` | `wg.Go(func() { ... })` |
| `time.Sleep` in concurrent tests | `synctest.Test` / `synctest.Wait` (API as in the 1.25 stdlib, not the 1.24 experiment) |
| `go vet` missing waitgroup/hostport | those analyzers ship in vet; `go fix` applies hostport |

## 1.26 — new(expr), AsType, go fix, self-ref constraints

| Before | After |
| --- | --- |
| `p := v; return &p` helpers | `new(v)` |
| `var e *E; if errors.As(err, &e)` | `e, ok := errors.AsType[*E](err)` |
| hand-maintained old idioms | `go fix ./...` until `-diff` is empty |
| `interface{ Add(A) A }` workarounds for CRTP | `type Adder[A Adder[A]] interface { Add(A) A }` |

Green Tea GC is the default — no source change. Do not set `GOEXPERIMENT=nogreenteagc` in new modules.

## 1.27 — only if `go` is 1.27+

Draft as of 2026-08. Do **not** emit on a 1.26 module (`stdversion` will fail):

- Generic methods (type params on the method, not the receiver). They cannot implement interfaces.
- `go fix` may rename `waitgroup` → `waitgroupgo` and add `atomictypes`, `embedlit`, `slicesbackward`, `unsafefuncs`.
- `goroutineleak` pprof profile is GA.

When `go.mod` still says 1.26, keep generic helpers as package functions.
