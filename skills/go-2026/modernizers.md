# go fix modernizers (Go 1.26)

Run `go tool fix help` for the live list on this toolchain. Write these forms
directly; `go fix` is the backstop. Version meaning of each rewrite:
[versions.md](versions.md).

```bash
go fix ./<packages>              # skip vendor
go fix -diff ./<packages>        # must be empty when done
```

Modernizers do not cascade in one pass (`minmax` is the usual example). Re-run
until `-diff` is empty.

Disabled by default in 1.26 `go fix`, so write them by hand when they apply:
`fmtappendf`, `bloop`, `appendclipped`.

On a **1.27** toolchain, names may differ (`waitgroup` → `waitgroupgo`;
`atomictypes`, `embedlit`, `slicesbackward`, `unsafefuncs` added; `fmtappendf`
dropped). Still write the After form. Do not emit 1.27-only language on a 1.26
module.

## Language

| Analyzer | Before | After |
| --- | --- | --- |
| `any` | `interface{}` | `any` |
| `rangeint` | `for i := 0; i < n; i++` | `for i := range n` |
| `forvar` | `for _, x := range s { x := x; ... }` | drop `x := x` |
| `minmax` | `if x < 0 { x = 0 }` | `x = max(0, x)` |
| `newexpr` | helper that returns `&v` | `new(v)` |
| `plusbuild` | `// +build linux` | `//go:build linux` |
| `inline` | call to a `//go:fix inline` wrapper | inlined callee |

## Slices, maps, iterators

| Analyzer | Before | After |
| --- | --- | --- |
| `slicessort` | `sort.Slice(s, func(i, j int) bool { return s[i] < s[j] })` | `slices.Sort(s)` |
| `slicescontains` | loop looking for `x` | `slices.Contains(s, x)` / `ContainsFunc` |
| `slicesbackward` | `for i := len(s)-1; i >= 0; i--` | `for i, v := range slices.Backward(s)` |
| `mapsloop` | copy/clone/equal loops | `maps.Copy` / `Clone` / `Equal` |
| `stditerators` | collect keys then range | `for k := range maps.Keys(m)` |
| `reflecttypefor` | `reflect.TypeOf((*T)(nil)).Elem()` | `reflect.TypeFor[T]()` |
| `omitzero` | `json:"t,omitempty"` on `time.Time` | `json:"t,omitzero"` |

## Strings and fmt

| Analyzer | Before | After |
| --- | --- | --- |
| `stringscut` | `Index` + slice | `strings.Cut` |
| `stringscutprefix` | `HasPrefix` + `TrimPrefix` | `strings.CutPrefix` (same for suffix) |
| `stringsseq` | `for _, p := range strings.Split(s, sep)` | `for p := range strings.SplitSeq(s, sep)` |
| `stringsbuilder` | `s += p` in a loop | `strings.Builder` |
| `fmtappendf` | `[]byte(fmt.Sprintf(...))` | `fmt.Appendf(nil, ...)` |

## Net, errors, concurrency, tests

| Analyzer | Before | After |
| --- | --- | --- |
| `hostport` | `fmt.Sprintf("%s:%d", host, port)` | `net.JoinHostPort(host, strconv.Itoa(port))` |
| `errorsastype` | `var e *E; errors.As(err, &e)` | `e, ok := errors.AsType[*E](err)` |
| `waitgroup` | `wg.Add(1); go func() { defer wg.Done(); ... }()` | `wg.Go(func() { ... })` |
| `testingcontext` | `ctx, cancel := context.WithCancel(...)` in a test | `ctx := t.Context()` |
| `bloop` | `for i := 0; i < b.N; i++` | `for b.Loop()` |

`atomictypes` (`atomic.Int64` methods) may not be in 1.26 `go tool fix`; still
write the typed form for new code (1.19+).
