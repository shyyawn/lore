# Architecture and practices (2024–2026)

Trends that settled in real codebases (stdlib, Tailscale, Caddy, pgx, kubernetes-style layout) — not hexagonal folder fashion.

## Stdlib-first

The stdlib closed the gaps that used to justify a starter kit of deps:

- 1.21 `slog` → structured logs
- 1.22 `ServeMux` → method+path routing and `{wildcards}`
- 1.23 `iter` → lazy sequences
- 1.24 `tool` → versioned dev tools
- 1.25 `synctest` / `WaitGroup.Go` → structured concurrency in tests and servers
- 1.26 `errors.AsType` / `new(expr)` / `go fix`
- 1.27 generic methods / `"uuid"` / `encoding/json/v2` / `jsontext` / `crypto/mldsa`

Add a module when it does something the standard library will not (a database driver, OpenTelemetry, Cobra for a real CLI tree). Do not add a second library for logging, muxing, error wrapping, or slice helpers.

Cobra stays if the project already has a command tree. Do not replace it with `flag` as a drive-by restyle. Do not introduce Cobra for a 40-line `main`.

## Layout

Official instinct: start as a single package next to `go.mod`. Grow into this when there is a second binary or a publish boundary:

```
cmd/<name>/main.go     # wiring only; signal, flags, slog.SetDefault, os.Exit
internal/<noun>/       # private implementation; named for the noun
go.mod
```

- `internal/` is the only directory with compiler teeth. Use it.
- `pkg/` is optional and contested. Skip it unless you are publishing a library from this module.
- Tests live next to the code (`foo_test.go`). Integration tests that must not run in `go test ./...` use `//go:build integration`.
- `package foo_test` (external test) when you want to lock the public API.
- `main.go` stays small: construct deps, run, exit. Business logic is not in `package main` once it has tests.

Do **not** create `domain/`, `usecase/`, `adapter/`, `controller/`, `repository/` layers for a small module. Flatten. Extract a package when an import cycle or a second binary forces it.

Dual-store / cache: `source-of-truth`. Schema types: `data-modeling`.
Slice vs map: `choose-collections`.

Inside a service (handlers, persistence, shutdown): `go-backend`. When
invariants appear: `go-ddd` — still inside the package, still no those
folders. More than one `go.mod` / `go.work`: `go-mono-repo`. Default
stays **this** tree (one module).

## Dependency direction

One-way:

```
cmd → internal/cli or internal/http → internal/<domain>
internal/<domain> → stdlib / vendor SDK only
```

Domain packages must compile without Cobra, net/http, or flag structs. Config that is just "how we dial" belongs next to the client, not under the CLI.

## Components

- **Accept interfaces, return structs.** The consumer declares the interface with the two or three methods it calls. The producer does not export a 20-method interface "for mocking".
- **Fakes over mocks.** An in-memory fake in `foo_test.go` (or `internal/foostore/memory.go`) beats generated mocks for most domain tests. `//go:generate mockery` is fine at a stubborn I/O boundary, not on every struct.
- **No global clients.** `*sql.DB`, HTTP clients, RPC clients are constructed in `main` (or a `New` in the binary's package) and passed down.
- **Options:** a struct of options for 2+ optional fields. Functional options only when you are writing a public library that must stay binary-compatible. Do not add `WithX()` to an internal package with one caller.
- **Config:** typed struct, filled from flags/env in `main`. No `viper` for a handful of flags. No package named `config` that accumulates unrelated fields.

## Concurrency

- Every goroutine's lifetime is visible: `errgroup.WithContext`, `WaitGroup.Go`, or a server `Shutdown`.
- Pass `ctx` in; honor it in loops (`select` on `ctx.Done()`).
- Shared state: mutex or channel ownership, not both on the same data.
- `sync.Once` for one-time init. `atomic.Int64` / `atomic.Pointer[T]` for simple counters and snapshots.
- Race detector is part of the test story: `go test -race` on packages that start goroutines.

## HTTP services (when you add one)

```go
mux := http.NewServeMux()
mux.HandleFunc("GET /items/{id}", handleGet)
s := &http.Server{
    Addr:              addr,
    Handler:           mux,
    ReadHeaderTimeout: 5 * time.Second,
    ReadTimeout:       15 * time.Second,
    WriteTimeout:      15 * time.Second,
    IdleTimeout:       60 * time.Second,
}
// ListenAndServe in a goroutine; Shutdown(ctx) on
// signal.NotifyContext(ctx, os.Interrupt, syscall.SIGTERM)
```

`GET /livez` (no I/O) and `GET /readyz` (dependency ping). Full recipes:
`go-backend` `internals.md`.

Middleware is `func(http.Handler) http.Handler`. Request-scoped values go in `context.WithValue` only for things that are not in the signature (trace IDs). IDs and user objects stay arguments.

## Logging

- Binary: `slog.SetDefault` once in `main` (text for CLI, JSON for services).
- Library/domain: take `*slog.Logger` or use `slog.Default()` without reconfiguring it.
- `logger := slog.With("request_id", id)` per operation, not a global with no fields.
- Errors: `slog.Error("listen", "err", err)` — do not `err.Error()` into the message.
- With a request `ctx`: `InfoContext` / `ErrorContext` so trace IDs survive.

## Tooling

```
go 1.27

tool (
    golang.org/x/vuln/cmd/govulncheck
)
```

`go get -tool golang.org/x/vuln/cmd/govulncheck` then `go tool govulncheck ./...`. golangci-lint: `git-repo-setup-go` (mise pin). No `curl | sh` in the Makefile.

CI that serious 2025–2026 modules run: `gofmt`/`goimports` check, `go vet ./...`, `golangci-lint run`, `go test ./...`, `go tool govulncheck ./...` when tooled. Add `-race` where goroutines exist.

## What 2024–2026 code stopped reaching for

| Stopped | Instead |
| --- | --- |
| `pkg/errors` | std `errors` + `%w` |
| `io/ioutil` | `os`, `io` |
| `gorilla/mux` for new services | `http.ServeMux` |
| `logrus` / new `zap` | `slog` |
| `tools.go` | `tool` in go.mod |
| `nil, nil` for missing rows | `ErrNotFound` |
| sleep-based concurrency tests | `testing/synctest` |
| util/common/helpers packages | a noun package or a function in the caller |
| interfaces defined "for the whole domain" up front | interface at the call site |
| micro-package-per-file under `internal/foo/bar/baz` | one package until cycles force a split |
