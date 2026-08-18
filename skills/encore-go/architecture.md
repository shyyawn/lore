# Architecture (Encore Go 2024–2026)

Encore is not opinionated about monolith vs microservices. It is opinionated
about **one app**, **package = service**, and **infrastructure in code**.

## Layout

Start as a single service next to `encore.app`. Grow when a domain boundary
appears.

```
my-app/
  encore.app          # JSON/HJSON manifest. App id, CORS, build flags.
  go.mod              # module path is often encore.app
  hello/
    hello.go          # //encore:api → this package is a service
    hello_test.go
    db.go             # optional
    migrations/
      1_create.up.sql
  internal/
    validate/         # no //encore:api → not a service
```

Multi-service:

```
user/     user.go, db.go, migrations/
order/    order.go
notify/   notify.go
internal/ # shared helpers, never APIs
```

Large app — **systems** are directories only (no runtime meaning):

```
commerce/order/  commerce/cart/  commerce/payment/
identity/user/   identity/auth/
comms/email/     comms/push/
```

- `encore.app` at the repo root. One per backend.
- Tests live next to code (`foo_test.go`).
- Sub-packages of a service are internal helpers. They **cannot** define APIs.
- Do not apply the `go-idioms` skill's `cmd/<bin>/main.go` to an Encore app. Encore is the binary.
- No `domain/` / `usecase/` / `adapter/` trees unless the repo already has them.
- No `util/`, `common/`, `helpers/` at the app root. Name packages for a noun.

## When a package is a service

A package is a service if it contains at least one `//encore:api` **or** an
explicit `//encore:service` struct (v1.39+ service roots). The latter is how a
Pub/Sub/cron worker exists with no HTTP surface.

| Signal | Action |
| --- | --- |
| Different scaling or deploy cadence | Split into a new service |
| Clear domain + its own data | Split |
| Shared tables / tight transactions | Keep together |
| "I want folders" | Sub-package, not a service |
| Shared validation / money / ids | `internal/<noun>`, no APIs |

Services cannot nest. `identity/user` and `identity/auth` are siblings, both
services; `user/internal/hash` is a helper.

## Service-to-service calls

Import the service package and call the API function. Encore handles discovery,
serialization, tracing, and auth propagation.

```go
package order

import "encore.app/user"

//encore:api auth method=GET path=/orders/:id
func Get(ctx context.Context, p *GetParams) (*OrderWithUser, error) {
	o, err := getOrder(ctx, p.ID)
	if err != nil {
		return nil, err
	}
	u, err := user.Get(ctx, &user.GetParams{ID: o.UserID})
	if err != nil {
		return nil, err
	}
	return &OrderWithUser{Order: o, User: u}, nil
}
```

Do not look up URLs. Do not wrap the call in an HTTP client. The function
signature **is** the contract.

## Dependency injection

Prefer a service struct once the package has clients, config, or test seams.

```go
package email

import "encore.dev/pubsub"

//encore:service
type Service struct {
	client sendgridClient
	signup pubsub.Publisher[*SignupEvent]
}

func initService() (*Service, error) {
	ref := pubsub.TopicRef[pubsub.Publisher[*SignupEvent]](Signups)
	return &Service{
		client: newSendgrid(secrets.SendGridAPIKey),
		signup: ref,
	}, nil
}
```

- Dependencies are struct fields. Constructors are `initService` / `init<Type>`.
- Accept small consumer-side interfaces (`sendgridClient`) for third parties.
- Pass `pubsub.TopicRef` / `objects.BucketRef` into library code so Encore still
  sees the resource. Do not hide `NewTopic` inside a helper.
- `Shutdown(force context.Context)`: finish work until `force` is cancelled.
- No `init()` that dials networks. No package-level mutable clients except
  Encore resource vars (`var db = sqldb.NewDatabase(...)`).

Package-level API funcs are still correct for tiny services with no deps. Do not
rewrite them into structs as a drive-by.

## Databases per service

Default: each service owns its Postgres. Share only with `sqldb.Named("other")`
when a report/read model genuinely needs another service's tables. Prefer an API
or a Pub/Sub event over sharing.

## CORS, CGO, generated clients

CORS lives in `encore.app` (`allow_origins_with_credentials`, etc.). Do not add
a CORS middleware package.

CGO: `"build": { "cgo_enabled": true }` in `encore.app` if needed. Libraries
must statically link.

Frontends: `encore gen client --lang=typescript` (or `go`, `javascript`,
`openapi`). Do not hand-roll the API client.

## Observability

`encore run` → dashboard at `http://localhost:9400` (traces, APIs, Flow,
Object Explorer). Every API, SQL query, RPC, and Pub/Sub publish is a span.
`encore test` records the same spans (test tracing, v1.31) — open the dashboard
while tests run. Do not bootstrap OpenTelemetry unless exporting to an
already-chosen vendor.

`encore run --level=debug` / `--redact` for local log level and sensitive-data
redaction. Trace sampling is a Cloud setting (v1.54), not application code.

Logs: `encore.dev/rlog` (`rlog.Info("msg", "key", val)`). Metrics:
`encore.dev/metrics` (`NewCounter` / `NewGauge` / `*Group`). Keep label
cardinality in the tens-to-hundreds, not thousands.
