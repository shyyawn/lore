---
name: go-backend
description: >-
  Writes, restyles, and reviews Go service internals (thin handlers,
  consumer-side persistence, config and clients constructed at the edge,
  visible shutdown). Use when generating or reviewing Go backends, HTTP or
  API handlers, repositories, graceful shutdown, or growing a flat package.
  Overlay on go-idioms. Encore: encore-go owns process layout; this skill
  still owns the inside of a service. Rich domain: go-ddd.
---

# Go backend 2026

Inside a service. Language, stdlib-first, flatten layout: `go-idioms`.
Don't-do-this: `go-100-mistakes-avoid`. Tests: `go-unit-tests`. Process
layout: `encore-go-app-structure` if `encore.app` exists, else
`go-idioms` `architecture.md`. Aggregates: `go-ddd`. Recipes:
[internals.md](internals.md).

Sources: `ardanlabs/service` *ideas* (data-oriented types, wiring at the
edge, consumer-side interfaces). Not its `api/` / `business/` /
`foundation/` tree, Makefile, or Kubernetes kit.

## First step

1. Read `go.mod`. Target that `go` line. Do not bump `go`.
2. If `encore.app` exists, Encore owns `main`, HTTP, logging, and errors.
   Do not add `cmd/`, `net/http` servers, or `slog` in handlers
   (`encore-go`). This skill still owns thin APIs vs persistence.
3. If `go.temporal.io/sdk` is in `go.mod` and there is no `encore.app`,
   worker layout is `temporal-go-app-structure`.
4. Match the package that is already there. Do not invent `domain/` /
   `usecase/` / `adapter/` / `controller/` / `repository/` trees.

## After every edit

```bash
gofmt -w <files>
go vet ./<packages>
go test ./<packages>                 # encore.app → encore test
```

## What this skill owns

| Own | Leave |
| --- | --- |
| Thin handler / `//encore:api`: decode, one call, map errors | Mux, slog, `cmd/` — `go-idioms` / `encore-go` |
| Persistence interface at the **consumer**, 2–3 methods | SQL dialect, `sqldb`, migrations — `encore-go` |
| Clients and config constructed at the edge, passed down | Encore package-level topics/DBs/secrets — platform constructors |
| Shutdown the caller can see | Encore `Shutdown` on the service struct |
| Growing a flat package when a cycle or a second binary appears | Systems / new Encore services — `encore-go-app-structure` |

## Inside a service

Keep the HTTP/API file boring. Put rules in functions or types next to it,
in the **same package**, until an import cycle or a second binary forces a
split.

```
item.go              # types + rules
store.go             # SQL / client that implements the consumer interface
http.go              # non-Encore: ServeMux handlers
# Encore: item.go holds //encore:api; db.go holds sqldb
item_test.go
```

Handler: decode → call one function → map sentinels to status. No business
rules in the handler. No `log.Fatal`. Recipes: [internals.md](internals.md).

## Persistence

The package that **calls** storage declares the interface with the methods
it needs. The SQL type is concrete and lives beside it (or in a sub-package
when the driver types would otherwise leak).

- Return `Item`, not `*Item`, unless you need a distinguishable nil.
- `ErrNotFound` (and friends) in this package. Never `nil, nil`.
- Fake in `_test.go`. Do not generate a 15-method mock of a type you own.
- One `*sql.DB` / `*pgxpool.Pool` / Encore `*sqldb.Database` for the
  process. Open once. Not per request.

Encore: `sqldb.NewDatabase` as a package-level var is the platform
constructor. Do not also `sql.Open` into a global. Prefer fields on the
`//encore:service` struct once you need a test seam.

## Config and clients

Construct in `main` (or Encore `initService`). Pass down. No package-level
mutable clients you own. No `init()` that dials.

- Typed config struct. Flags/env at the edge. No `viper` for a handful of
  fields. No package named `config` that accumulates unrelated keys.
- HTTP client: explicit timeout, not `http.DefaultClient`.
- Options struct for 2+ optional fields. No `WithX` on an internal package.

## Shutdown

Every goroutine has a stop the caller can see: `errgroup.WithContext`,
`WaitGroup.Go` (1.25), or `http.Server.Shutdown`. Non-Encore recipe:
[internals.md](internals.md). Encore: `Shutdown(force context.Context)` on
the service struct.

## Growth

Start one package. Split when:

| Pressure | Split |
| --- | --- |
| Import cycle | Extract the noun that both sides need |
| Second binary | `cmd/<name>` + `internal/<noun>` |
| Second Encore domain with its own data | New **service**, not a sub-package of APIs |
| Handler file is a thousand lines of rules | Types + functions in the same package first |

Do not split so two packages share tables. Do not restyle a working flat
service into layers as a drive-by.

## When the domain got rich

Load `go-ddd` only if an invariant must hold across fields, or another
package must react without importing you. CRUD with validation is still
this skill.

## Review workflow

```
Go backend:
- [ ] Handler / API is decode → one call → map errors
- [ ] Interface at the consumer, 2–3 methods; fake in _test.go
- [ ] ErrNotFound (etc.) sentinels; no nil, nil; no err.Error() map
- [ ] Clients constructed at the edge (main / initService), passed down
- [ ] No domain/ usecase/ adapter/ trees; no util package
- [ ] Shutdown / errgroup / WaitGroup.Go is visible
- [ ] encore.app → no cmd/, no net/http server, no slog in APIs
```

## LLM traps — never generate these

- `domain/` / `usecase/` / `adapter/` / `controller/` / `repository/` folders
- Producer-side `type Repository interface { ... }` in the store package
- `WithX` options, `viper`, a `config` package of unrelated fields
- `http.DefaultClient`, `ListenAndServe` with no timeouts, no `Shutdown`
- Package-level `var db *sql.DB` you `Open` yourself
- `log.Fatal` / `slog` in Encore APIs
- Gin/Echo/Chi on a greenfield internal service (`ServeMux` / `//encore:api`)
- Copying `ardanlabs/service` `foundation/` or Wild Workouts hexagonal trees

## Do not

- Apply this skill's `cmd/` + `http.Server` shape to an Encore app.
- Duplicate `encore-go` primitives or `go-idioms` catalogs here.
- Restyle unrelated files in the name of a backend pass.
- Load `go-ddd` for a CRUD handler.
