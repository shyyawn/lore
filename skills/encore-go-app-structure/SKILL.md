---
name: encore-go-app-structure
description: >-
  Structures Encore Go backends: one encore.app monorepo, service = package
  with //encore:api or //encore:service, migrations inside the service,
  sub-packages without APIs, systems as plain directories. Use when scaffolding
  an Encore Go app, adding a service, grouping into systems, choosing
  package layout, or the user mentions encore.app, app structure, or
  monolith vs microservices. If the repo also uses Temporal
  (go.temporal.io/sdk), use encore-temporal-go-app-structure instead.
---

# Encore Go App Structure

Layout and package boundaries for Encore.go. API, infra, and coding idioms
live in the `encore-go` skill. Language idioms follow `go-idioms` except
**layout**: Encore generates `main`; do not add `cmd/` or `net/http` servers.

Sources: Encore `docs/go/primitives/app-structure.md`, `services.md`, and
starters `uptime`, `trello-clone`, `booking-system`.

## First step

1. Read `encore.app` and `go.mod`. One `encore.app` for the whole backend.
2. Find existing `//encore:api` / `//encore:service` packages. Match that
   shape (flat services vs systems).
3. Never edit `encore.gen/` or `.encore/`.

If the repo is not yet an Encore app: `encore app create` / `encore app init`.
Do not invent a `cmd/` + Compose stack beside it.

If `go.temporal.io/sdk` is already a dependency, stop and follow
`encore-temporal-go-app-structure`.

## Hard rules

- **One Encore app = the entire backend monorepo.** A second `encore.app`
  splits the application model (tracing, Flow, service catalog).
- **A Go package is a service** if it contains `//encore:api` **or**
  `//encore:service`. Package name = service name. The compiler discovers
  services; there is no registration file.
- **No `main` function.** Encore generates it and boots infrastructure.
  Custom init is `initService()` on a `//encore:service` struct, plus
  optional `Shutdown(force context.Context)`.
- **Migrations live inside the owning service** (`migrations/1_create.up.sql`,
  sequentially numbered).
- **Sub-packages cannot define APIs.** Nest helpers freely; keep endpoints
  in the service package and call down into sub-packages.
- **Services cannot nest.** `commerce/order` and `commerce/payment` are
  sibling services under a system directory. `order/internal/hash` is a
  helper, not a service.
- **Systems are directories only.** Encore does not treat them as a
  construct. Grouping into systems is `mv`. Endpoints and architecture
  do not change.
- **Monolith vs microservices is a deploy decision.** On AWS/GCP, process
  allocation is per environment. Do not split packages "to look like
  microservices."

## Choose a layout

| Situation | Layout |
| --- | --- |
| New app, one domain | Single service next to `encore.app` |
| A few clear domains | Flat multi-service at repo root |
| Many services, several logical domains | Systems (directories of services) |
| Shared validation / ids / money | `internal/<noun>` — no APIs |
| Different scaling or deploy cadence | New service, not a sub-package |
| Shared tables / tight transactions | Keep in one service |

Start flat. Introduce systems when the root has enough services that
domain grouping helps humans, not the compiler.

## Small app (official)

```
my-app/
  encore.app
  go.mod                 # module path is often encore.app
  hello/
    hello.go             # //encore:api → this package is a service
    hello_test.go
    foo/                 # sub-package: logic, NO APIs
      foo.go
    migrations/
      1_create_table.up.sql
  world/
    world.go
  internal/
    validate/            # shared helpers, never APIs
```

Starters (`uptime`, `trello-clone`) are this shape: `monitor/`, `site/`,
`slack/` or `board/`, `card/` at the root.

## Large app — systems (official Trello example)

```
my-trello-clone/
  encore.app
  trello/                # SYSTEM (plain directory)
    board/               #   board service
      board.go
    card/
      card.go
  premium/
    payment/
      payment.go
    subscription/
      subscription.go
  usr/
    org/
      org.go
    user/
      user.go
```

Refactoring into systems is moving service packages into subfolders.
Import paths change; API contracts do not.

## Inside a service

Keep endpoints thin. Put DB access, domain logic, and third-party clients
in files or sub-packages in the same service.

```
hello/
  hello.go               # APIs only
  db.go                  # sqldb.NewDatabase + queries (package-level var)
  migrations/
  foo/                   # helpers the APIs call
```

Pub/Sub topics, cron jobs, secrets, and caches are **package-level vars
in the owning service**. Cross-service calls are imports:

```go
import "encore.app/hello"

hello.Ping(ctx, ...)     // compiled to RPC; never http.Client
```

Default: one Postgres per service. Sharing a DB (`sqldb.Named`) is a
deliberate choice, not a convenience.

### Service struct (init / state / shutdown)

Use once the package needs clients, config, or a test seam. Tiny
no-dep services stay as package-level API funcs.

```go
//encore:service
type Service struct {
	db     *sqldb.Database
	client SomeClient
}

func initService() (*Service, error) { /* ... */ }

func (s *Service) Shutdown(force context.Context) { /* drain until force */ }
```

`init<TypeName>` if the type is not `Service`. Encore generates
`encore.gen.go` so other services still call APIs as package-level functions.

## Shared code

| Need | Put it |
| --- | --- |
| Helper used by one service | Sub-package of that service |
| Helper used by several services | `internal/<noun>` — no `//encore:api` |
| Data owned by a service | That service's DB + API, not a shared package of models |

No `util/`, `common/`, `helpers/` at the app root. No `domain/` /
`usecase/` / `adapter/` trees unless the repo already has them.

## Do not add

| Need | Use | Do not add |
| --- | --- | --- |
| Process entrypoint | Encore-generated `main` | `cmd/`, `package main` |
| HTTP routing | `//encore:api` | gin, echo, chi, `http.Server` |
| Inter-service RPC | import + function call | REST/gRPC clients, env-based URLs |
| Service grouping | system directories | a second `encore.app` |
| "More microservices" | split on domain/scale | nested service packages |

## Growth

1. One service, APIs + `migrations/` in the same package.
2. Second domain with its own data → new service at the root.
3. Root gets crowded → `mv` related services under a system directory.
4. Split an existing service only for scaling, deploy cadence, or a real
   domain boundary. Shared tables stay together.

## After layout changes

```bash
gofmt -w <files>
encore check
encore test ./<packages>
```

## LLM traps — never generate these

- A second `encore.app` or a `cmd/<bin>/main.go` next to Encore
- `//encore:api` inside a sub-package of a service
- Nested services (`user/auth/` both with APIs)
- `migrations/` at the repo root instead of inside the service
- `http.Client` to another service in the same app
- Hexagonal / clean-architecture folder trees on a greenfield Encore app
- Splitting a service so two services share the same tables
- Restyling package-level APIs into a service struct with no deps

## Do not

- Restyle a working flat app into systems as a drive-by.
- Apply `go-idioms` `cmd/` layout to an Encore app.
- Introduce Encore.ts or a second backend language.
