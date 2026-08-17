---
name: encore-go
description: >-
  Writes, restyles, and reviews Encore.go backends using 2024–2026 idioms:
  infrastructure-from-code, service packages, //encore:api, service structs,
  sqldb/pubsub/cron/secrets, rlog, and encore.dev/beta/errs. Use when generating,
  editing, reviewing, or scaffolding Encore Go; when the user mentions Encore,
  encore.dev, encore.app, //encore:api, sqldb, pubsub, encore run, or encore test.
---

# Encore Go 2026

Encore.go is an **infrastructure-from-code** backend platform, not an HTTP
router. Declare services, APIs, Postgres, Pub/Sub, cron, secrets, caches, and
object storage in Go. Encore provisions them locally and in the cloud.

Language idioms follow the `go-idioms` skill. Target the module's `go` version
(Encore.go requires **1.22+**; **1.26** is supported from Encore v1.56). This
skill **overrides** `go-idioms` on layout, HTTP, logging, errors, and tests: do not
add `net/http` servers, `cmd/` binaries, `slog` in handlers, or `go test`.

Catalogs: [architecture.md](architecture.md) (services, DI, split rules),
[primitives.md](primitives.md) (APIs, auth, errors, middleware),
[infrastructure.md](infrastructure.md) (db, pubsub, cron, secrets, config).

## First step

1. Read `encore.app` (CUE text, despite the `.app` suffix) and `go.mod`.
2. Find existing `//encore:api` packages — each is a service. Match that shape.
3. Never edit `encore.gen/` or `.encore/` (CLI-regenerated).

If the repo is not yet an Encore app, create one with `encore app create` /
`encore app init`. Do not invent a `cmd/` + Docker Compose stack beside it.

## After every Encore edit

```bash
gofmt -w <files>
encore check                          # compile + boot + health
encore test ./<packages>              # not go test
```

Use `encore check 'curl /path'` to hit a relative path once healthy. Paths must
start with `/`; flags go **after** the path (`curl /orders -X POST -d '...'`).

## When it breaks

| Symptom | Usually means |
| --- | --- |
| `failed to start cluster: database did not come up … dial error: timeout` | Encore provisions local infrastructure in Docker with a bounded startup window; a cold or slow start can exceed it. Check whether the container is actually running before treating this as a code or migration fault — if it is, re-run. If it persists, the cause is Docker itself: not running, out of resources, or the port already taken. |
| `encore apps must be run using the encore command` (panic) | `go test` instead of `encore test`. Every Encore primitive panics outside the runtime — `go build` and `go vet` are still fine. |
| The parser rejects a resource | `sqldb.NewDatabase` / `pubsub.NewTopic` / `cache.NewCluster` declared inside a function. They are package-level `var`s. |
| An API is unreachable from another service | You reached for HTTP instead of importing the package and calling the function, or the caller is not actually a service. `private` is not the cause — that is exactly how services and cron are meant to call. Never "fix" this by flipping the endpoint to `public`. |
| Client sees 500 where you meant 404 / 409 | A bare `error` escaped the endpoint. Map it: `sqldb.ErrNoRows` → `errs.NotFound`, unique violation → `errs.AlreadyExists`. |

`encore check` compiles, boots and migrates — a faster signal than `encore run`
when you only need to know the app is valid.

## Hard rules

- One Encore app = the whole backend monorepo. Do not start a second `encore.app`.
- A Go package becomes a service if it contains `//encore:api` **or**
  `//encore:service` (worker-only packages with Pub/Sub/cron and no HTTP).
  Package name = service name. Services cannot nest; use sub-packages without
  APIs instead.
- Infrastructure (`sqldb.NewDatabase`, `pubsub.NewTopic`, `cron.NewJob`,
  `cache.NewCluster`, `objects.NewBucket`) is a **package-level `var`**. Never
  inside a function.
- Call other services by importing the package and calling the API function.
  Encore turns that into an RPC. Never `http.Client` to another Encore service.
- Typed APIs return `(*T, error)` or `error`. Request params are `*Struct` or
  omitted. `context.Context` is always first.
- API errors are `encore.dev/beta/errs`. Do not return bare `errors.New` /
  `fmt.Errorf` from an `//encore:api` if the client should see a status code.
- Request logs use `encore.dev/rlog` (trace-correlated). Do not add `logrus`,
  `zap`, or a new `slog` handler inside Encore services.
- Secrets: `var secrets struct { Name string }`. Never `os.Getenv` for keys.
  External vaults (v1.57.9+) are wired in Encore Cloud / infra config, not via
  a Vault SDK in application code.
- Tests: `encore test`. Call APIs as functions. Mock third parties, not Encore infra.

## Access control

| Annotation | Who can call |
| --- | --- |
| `//encore:api public` | Internet |
| `//encore:api auth` | Internet, after `//encore:authhandler` succeeds |
| `//encore:api private` | Other services + cron only |

Cron, internal workers, and "admin cleanup" are `private`. One auth handler per
app. Auth data propagates automatically on service-to-service calls.

## Default shapes

Tiny service, no deps — package-level functions are fine:

```go
package hello

//encore:api public method=GET path=/hello/:name
func Hello(ctx context.Context, p *HelloParams) (*HelloResponse, error) {
	return &HelloResponse{Message: "hello " + p.Name}, nil
}
```

Anything with clients, DB pools, or test seams — service struct:

```go
//encore:service
type Service struct {
	send *sendgrid.Client
}

func initService() (*Service, error) {
	return &Service{send: sendgrid.New(secrets.SendGridAPIKey)}, nil
}

//encore:api private
func (s *Service) Send(ctx context.Context, p *SendParams) error {
	return s.send.Send(ctx, p)
}
```

`init<TypeName>` if the type is not `Service` (`initAPI` for `type API struct`).
Optional `Shutdown(force context.Context)` for graceful drain.

## Do not add

Encore already covers these. Adding them fights the compiler and the platform:

| Need | Use | Do not add |
| --- | --- | --- |
| HTTP routing | `//encore:api` | gin, echo, chi, gorilla/mux, `http.Server` |
| Inter-service RPC | import + function call | REST clients, gRPC stubs, env-based URLs |
| Postgres | `encore.dev/storage/sqldb` | docker-compose Postgres, manual DSN |
| Queues | `encore.dev/pubsub` | Kafka/SQS/NATS SDKs for new work |
| Secrets | `var secrets struct` | `.env`, Vault/SSM **SDKs** in app code |
| Tracing / metrics | built-in + `rlog` / `encore.dev/metrics` | DIY OpenTelemetry bootstrap |
| API docs / clients | `encore gen client` | hand-written OpenAPI |
| Local infra | `encore run` (dashboard `:9400`) | extra compose stacks for Encore resources |

Raw `//encore:api public raw` is for webhooks and WebSockets only. Prefer typed
APIs. Acknowledge webhooks with 2xx fast; publish to Pub/Sub for slow work.
Typed streaming (`api.streamIn` / `streamOut`) is **Encore.ts**; do not invent
a Go equivalent. Go WebSockets stay `raw`.

## LLM traps — never generate these

- Infrastructure declared inside `setup()` / `init()` / constructors
- `//encore:api` without `context.Context` as the first parameter
- Returning a non-pointer response struct
- `fmt.Sprintf` SQL; always `$1` placeholders
- `go test` instead of `encore test`
- `os.Getenv("DATABASE_URL")` or a DSN for an Encore database
- HTTP calls to `localhost:4000` from another service in the same app
- `//encore:api public` on cron or "internal" endpoints
- Nested service packages (`user/auth/` both with `//encore:api`)
- Editing `encore.gen/` or committing `.encore/`
- `gin` / `echo` "because we need middleware" — use `//encore:middleware`
- Non-idempotent Pub/Sub handlers (default is at-least-once)
- `panic(err)` in APIs; ignore `sqldb.ErrNoRows` without mapping to `errs.NotFound`
- `*string` for "maybe missing" API fields — use `option.Option[T]`
- N sequential cache `Get`s — use `MultiGet`
- Streaming large files through an API — use signed object URLs
- Inventing Go `api.streamIn` / `streamOut` (TypeScript only)

## Do not

- Restyle a package-level API service into a service struct unless deps need it.
- Split a service to "look like microservices". Split on scaling, deploy cadence,
  or a real domain boundary. Shared tables stay in one service.
- Introduce Encore.ts, Python, or a second backend language.
- Bypass Encore primitives with cloud SDKs unless the resource is **external**
  (existing RDS, third-party API). External DBs get a dedicated non-service
  package and `secrets`, not `sqldb.NewDatabase`.
