---
name: encore-temporal-go-app-structure
description: >-
  Structures a Go backend that uses Encore for APIs/infra and Temporal for
  durable orchestration: one Encore app, a Temporal seam service (client +
  worker in the service struct, workflows in a sub-package), env-suffixed
  task queues, CUE cluster config, and OMS-style worker split at scale. Use
  when the repo has encore.app and go.temporal.io/sdk, when scaffolding
  orderflow/greeting Temporal services, or the user mentions Encore plus
  Temporal, seam service, or the official how-to/temporal guide.
---

# Encore + Temporal Go App Structure

One Encore app owns HTTP, data, and infra. Temporal owns multi-step
orchestration. This skill is **layout and the seam**. Encore APIs/infra:
`encore-go` + `encore-go-app-structure`. Workflow determinism and SDK:
`temporal-go`. Plain Temporal (no `encore.app`): `temporal-go-app-structure`.

Sources: Encore `docs/go/how-to/temporal.md`, official example
`encoredev/examples/ts/temporal` (shape translates 1:1), OMS
(`temporalio/reference-app-orders-go`) for production worker split.

## First step

1. Confirm `encore.app` and `go.temporal.io/sdk`. Match existing seam
   services if any (`greeting`, `orderflow`, `temporal`).
2. Keep ordinary Encore services ordinary — do not sprinkle Temporal
   clients through every package.
3. Never edit `encore.gen/` or `.encore/`.

Local cluster is `temporal server start-dev` (Encore docs still say
Temporalite; that project is folded into the CLI). Production is
Temporal Cloud or self-hosted — not the dev server. Debug APIs and the
in-process worker by attaching to Encore (`git-repo-setup-go`
[debug.md](../git-repo-setup-go/debug.md)); do not attach to the Temporal CLI.

## Division of labor

| Concern | Owner |
| --- | --- |
| HTTP APIs, auth, validation, generated clients | Encore |
| Databases, migrations, Pub/Sub, cron, secrets, cache | Encore |
| Multi-step orchestration, retries, timers, saga compensation | Temporal |
| Human-in-the-loop (Signals), status (Queries / Updates) | Temporal |
| Activity side-effects (charge, ship, notify) | Activities → typed Encore API calls |
| Cluster address, task queue names | Encore config + `encore.Meta()` |

Activities do not open their own Postgres DSNs or HTTP to `localhost:4000`.
They import the other service and call the API function.

## Default layout (Go)

Synthesized from the Go how-to plus `ts/temporal` (`orders` + `temporal`
services, `endpoints.ts` triad).

```
my-app/
  encore.app
  go.mod
  orders/                         # ordinary Encore service: system of record
    orders.go                     # CRUD + status APIs activities call
    db.go
    migrations/
      1_create_orders.up.sql
  orderflow/                      # Temporal SEAM service
    orderflow.go                  # //encore:service: client + worker
    endpoints.go                  # sync / async / status
    config.go
    config.cue                    # per-env Temporal address
    workflow/                     # sub-package: NO APIs, pure Temporal
      workflow.go
      activities.go               # typed calls into orders.*
      workflow_test.go
      replay_test.go
  notify/                         # any other ordinary Encore services
```

Name the seam after the domain (`orderflow`, `greeting`), not a generic
`temporal/` package, once there is more than one workflow family. A
single hello-world may use `greeting/` as in the how-to.

Ordinary services stay on `encore-go-app-structure`. Group into systems
when the app grows; the seam is just another service (or lives under a
system directory).

## Seam service

One Encore service owns the Temporal client and, by default, the worker.
Lifecycle hooks are `initService` / `Shutdown` — Encore has no `main`.

```go
package orderflow

var (
	envName           = encore.Meta().Environment.Name
	orderflowTaskQueue = envName + "-orders"
)

//encore:service
type Service struct {
	client client.Client
	worker worker.Worker
}

func initService() (*Service, error) {
	c, err := client.Dial(client.Options{HostPort: cfg.TemporalServer})
	if err != nil {
		return nil, fmt.Errorf("create temporal client: %w", err)
	}
	w := worker.New(c, orderflowTaskQueue, worker.Options{})
	w.RegisterWorkflow(workflow.Order)
	w.RegisterActivity(&workflow.Activities{ /* injected deps */ })
	if err := w.Start(); err != nil {
		c.Close()
		return nil, fmt.Errorf("start temporal worker: %w", err)
	}
	return &Service{client: c, worker: w}, nil
}

func (s *Service) Shutdown(force context.Context) {
	s.worker.Stop()
	s.client.Close()
}
```

**Env-suffixed task queues** so one Temporal Cloud namespace can serve
local / preview / staging / prod without collisions.

**Workflows live in a sub-package** (`orderflow/workflow/`). Encore
sub-packages cannot define APIs; workflow code must not. Separate
`workflow.go` and `activities.go`. Register from `initService` with
**function / struct references**, not strings (`temporal-go`).

Prefer an Activities struct once activities call other services or need
clients. Tiny how-to samples may `RegisterActivity(workflow.ComposeGreeting)`.

## Endpoint triad

Copy the official example. Almost every caller needs one of these three:

| Shape | Behavior |
| --- | --- |
| Sync | `ExecuteWorkflow` + `we.Get` — wait for result |
| Async | fire-and-forget, return workflow ID |
| Status | `DescribeWorkflowExecution` and/or Query |

```go
//encore:api public method=POST path=/orders
func (s *Service) Create(ctx context.Context, p *CreateParams) (*OrderResult, error)

//encore:api public method=POST path=/orders/async
func (s *Service) Start(ctx context.Context, p *CreateParams) (*StartResult, error)

//encore:api public method=GET path=/orders/:id
func (s *Service) Status(ctx context.Context, p *StatusParams) (*StatusResult, error)
```

Workflow IDs are business keys (`"order-"+orderID`), not random UUIDs
(`temporal-go`). Log with `rlog`, not `slog`. API errors use
`encore.dev/beta/errs`.

## Cluster config

Two clusters minimum: local and Cloud/self-hosted. Address from Encore
config (CUE), not `os.Getenv`.

```
-- orderflow/config.cue --
TemporalServer: [
    if #Meta.Environment.Cloud == "local" { "localhost:7233" },
    "my.cluster.address:7233",
][0]
```

Secrets (Temporal Cloud API keys / mTLS) use `var secrets struct { ... }`,
not `.env` files. Namespace and TLS belong on `client.Options` next to
`HostPort`.

## Activities → Encore services

```go
// orderflow/workflow/activities.go
func (a *Activities) UpdateStatus(ctx context.Context, id, status string) error {
	return orders.UpdateStatus(ctx, &orders.UpdateStatusParams{
		ID: id, Status: status,
	})
}
```

The `orders` service owns Postgres and migrations. The workflow never
touches `sqldb`. See `source-of-truth` / `data-modeling`. Workflow
Id: `identity`. Saga compensation is workflow code calling compensating
activities (refund, unreserve) — same pattern as `ts/temporal`.

## Scale-out (OMS on top of the how-to)

The how-to runs the **worker inside the Encore service process**. Correct
for dev and modest load: Encore manages `Start` / `Stop`.

When workflow load must scale independently of HTTP:

1. Keep the seam **client-only** (start / signal / query / update). Drop
   `worker` from the service struct.
2. Run workers in a **worker-only Encore service** (`//encore:service`,
   no public APIs) that imports the same `workflow/` package. Encore
   process allocation can then place it on its own process. Prefer this
   while you still deploy via Encore.
3. If workers must live **outside** Encore (dedicated K8s Deployment per
   Task Queue, OMS `deployments/k8s/`), add a small `cmd/worker` that
   imports `orderflow/workflow`. This is the one justified `cmd/` in an
   Encore repo — HTTP still does not get a `main`.
4. Adopt OMS hygiene as workflow families multiply: Task Queue const per
   seam, Activities structs, replay tests, DataConverter + codec server
   for sensitive payloads, tuned poller counts.

Same Task Queue string on every client start and every worker. All
workers polling it register the same types.

## Multiple workflow families

| Need | Structure |
| --- | --- |
| One saga (orders) | One seam service + `workflow/` sub-package |
| Second unrelated saga | Second seam service, own task queue, own CUE |
| Same domain, more workflows | More files under the same `workflow/` package |
| Cross-team / other Namespace | HTTP or Nexus; not Child Workflows |

Do not put every workflow in one global `temporal` service once domains
diverge — that couples scaling and deploys.

## After edits

```bash
gofmt -w <files>
encore check
encore test ./<packages>
workflowcheck ./orderflow/workflow   # skip if not in the module yet
```

`encore test`, not `go test`. Workflow packages that import Encore APIs
still run under `encore test`.

## LLM traps — never generate these

- `cmd/api` or `net/http` next to `encore.app` for the HTTP surface
- Temporal client dialed in every service instead of one seam
- `//encore:api` inside `workflow/`
- Hard-coded task queue `"orders"` shared across Encore environments
- `os.Getenv("TEMPORAL_HOST")` instead of `config.cue` / secrets
- Activities using `http.Client` against another Encore service
- `we.Get` on a long saga in a public endpoint with no timeout story
  (use the async + status pair)
- Random UUID Workflow IDs for entity workflows
- Child Workflows to another Namespace
- Worker `Run()` (blocking) in `initService` — use `Start()`; Encore
  must finish booting. `Stop()` in `Shutdown`
- `slog` / `fmt.Println` in workflow code; `go test` for Encore packages

## Do not

- Restyle a working in-process worker into `cmd/worker` without a
  scale reason.
- Apply plain OMS `app/order/api.go` HTTP servers inside Encore — APIs
  stay `//encore:api`.
- Apply `go-idioms` `cmd/` layout to Encore HTTP.
- Introduce Encore.ts or TypeScript Temporal workers in a Go app.
