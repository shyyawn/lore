---
name: go-100-mistakes-avoid
description: >-
  Reviews and rewrites Go against a catalog of common mistakes still in force
  in 2026 (slices/append, consumer-side interfaces, error wrapping, goroutine
  lifetime, HTTP timeouts). Use when reviewing or generating Go; when the
  user mentions common Go pitfalls, Go mistakes, or avoiding Go mistakes.
  Overlay on go-idioms.
---

# Go 100 mistakes (2026 overlay)

Numbered rows: [catalog.md](catalog.md). Language, `go fix`, slog, ServeMux,
iterators: `go-idioms`. Layout: `go-idioms` `architecture.md`. Tests:
`go-unit-tests`. This skill is the don't-do-this review. Keep actions to
the catalog lines.

## First step

1. Read `go.mod`. Target that `go` line. Do not bump `go` to unlock an API.
2. Apply [catalog.md](catalog.md) against the diff (or the files you are writing).
3. Catalog actions are 2026 defaults. If `go` is older, use the `go-idioms`
   substitute (`errors.As` not `AsType`, `Add`/`Done` not `WaitGroup.Go`, …).

## Review workflow

Copy this checklist and tick it against the Go you are writing or reviewing.

```
Go 100 (high-frequency):
- [ ] No init() I/O, no util package, no producer-side interface soup (#3 #5–8 #13)
- [ ] Slices: len==0 not ==nil; append aliases; clone when dropping backing array (#21–25)
- [ ] Range: don't take &v; break labels on select-in-for; no defer in for (#29 #32 #33)
- [ ] Errors: wrap %w once; Is/As/AsType; log or return (#47–52)
- [ ] Every goroutine has a stop; no DefaultClient; close bodies/Rows/File (#59 #74 #76)
- [ ] No copy of sync types; WaitGroup.Go / errgroup (#67 #69 #70)
- [ ] Tests: no Sleep; t.Context; race on ci; table tests (#78–81 #85)
```

Fix in place. Do not add comments that only restate the catalog title.

## LLM traps — never generate these

- `init()` that dials, registers HTTP, or reads env (#3)
- `util` / `common` / `helpers` packages (#13)
- `WithX` options on an internal package (#11)
- `return (*T)(nil), err` stuffed into an interface (#43)
- `err == ErrX` or `err.(*T)` on wrapped errors (#48 #49)
- `go f()` in a library with no wait/cancel (#59)
- `http.DefaultClient` / `ListenAndServe` without timeouts (#76)
- `time.Sleep` to wait for a goroutine in a test (#81)
- `time.Sleep(1)` (one nanosecond) (#71)
- Copying `sync.Mutex` / `WaitGroup` (#70)
- `defer` inside `for` for per-iteration cleanup (#33)
- `break` from `select` intending to leave the `for` (#32)
- `pkg/errors`, `sync.Cond`

## Do not

- Expand catalog rows into essays, examples, or extra commentary.
- Duplicate `go-idioms` catalogs (`versions.md`, `modernizers.md`, slog, ServeMux).
- Restyle unrelated files in the name of a catalog pass.
