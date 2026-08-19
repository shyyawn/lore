---
name: temporal-go-app-structure
description: >-
  Structures Temporal Go applications: samples-go layout for a single
  workflow, OMS production layout (package per bounded context, one binary
  with worker/api roles), task-queue ownership, and where tests live. Use
  when scaffolding a Temporal Go app, adding a worker or starter, splitting
  subsystems, or the user mentions samples-go, OMS, reference-app-orders-go,
  cmd/worker, or task queues. If the repo is an Encore app (encore.app),
  use encore-temporal-go-app-structure instead.
---

# Temporal Go App Structure

Where files live in a Temporal Go module. Workflow determinism, SDK APIs,
versioning, and tests live in the `temporal-go` skill. Language idioms
follow `go-idioms` (`cmd/` binaries, `internal/`, no `util/`).

Sources: `temporalio/samples-go` (greetings, helloworld), Temporal Go SDK
worker docs, `temporalio/reference-app-orders-go` (OMS) source tree and
`docs/technical-description.md`.

## First step

1. Read `go.mod` for `go.temporal.io/sdk`. Do not bump the SDK.
2. Find `RegisterWorkflow` / `RegisterActivity`. Match that package shape.
3. Reuse existing Task Queue names and Workflow IDs.

If `encore.app` exists, stop and follow `encore-temporal-go-app-structure`.

If the repo is not yet a Temporal app, add the SDK and a worker binary.
Do not invent a second workflow engine beside it.

## Choose a layout

| Situation | Layout |
| --- | --- |
| One workflow, learning / spike | samples-go: same package, `worker/` + `starter/` |
| One workflow, activities need deps | SDK default: `workflows/` + `activities/` packages |
| Several bounded contexts, production | OMS: package per subsystem, one binary, roles at runtime |

Do not restyle samples-go into OMS (or the reverse) as a drive-by. Grow
when a second bounded context or a real worker/API split appears.

## Small — samples-go

Every sample in `temporalio/samples-go` is a unit of one workflow.
`greetings` is the canonical split-files shape; `helloworld` also ships
`replay_test.go` + a recorded history.

```
greetings/
  workflow.go            # deterministic orchestration only
  activities.go          # all I/O
  workflow_test.go       # testsuite
  replay_test.go         # replayer + checked-in history (helloworld)
  worker/
    main.go              # dial, register, w.Run()
  starter/
    main.go              # dial, ExecuteWorkflow
```

Conventions this encodes:

- Workflow and activities in the **same package**, separate files.
  Workflows stay deterministic; activities do I/O.
- **Worker and starter are separate binaries.** The worker is a
  long-running deployment; the starter is whatever triggers work
  (CLI, HTTP, cron).
- Replay tests sit next to the workflow — the guard for changing
  production workflow code.
- Task Queue name is a shared const (often `shared.go` in Learn
  Temporal tutorials). Worker and starter must use the same string.
- Durable code is importable. Do not put Workflow/Activity definitions
  only in `package main`.

### SDK default (one workflow, injected activity deps)

When activities need HTTP/DB clients, Temporal's documented layout is
separate packages. The `temporal-go` skill uses this as its default
shape. Do not collapse it into one package as a restyle if the repo
already split them.

```
myapp/
  workflows/
    greeting.go
  activities/
    greet.go             # Activities struct + methods
  worker/
    main.go
  starter/
    main.go
```

Register the struct (`RegisterActivity(&activities.Activities{...})`),
not individual methods. Workflows stay package functions.

## Production — OMS

`temporalio/reference-app-orders-go`. Package = bounded context. One
binary, role selected at runtime (`oms worker` vs `oms api`).

```
reference-app-orders-go/
  cmd/oms/
    main.go              # cobra: worker | api | codec-server
  app/
    order/               # SUBSYSTEM
      workflows.go       # Order workflow, TaskQueue const, signal names
      activities.go      # Activities struct, injected config
      api.go             # REST for this subsystem
      worker.go          # RunWorker(ctx, cfg, client)
      workflows_test.go
      activities_test.go
    shipment/            # same five-file shape
    billing/
    fraud/
    config/              # AppConfig from env
    db/                  # API read cache (replace SQLite in prod)
    server/              # RunWorkers / RunAPIs, client options from env
    temporalutil/        # DataConverter, interrupt helpers
    test/                # cross-subsystem tests
  deployments/k8s/
  charts/
  docs/
```

Each subsystem owns:

- its Task Queue (`TaskQueue` const)
- exported signal / query / update names
- `RunWorker` and (if it has HTTP) `Router` / `api.go`

`cmd/oms` only wires: flags choose *which* subsystems' workers or APIs
run in this process. K8s Deployments then place workers and APIs on
different pods independently.

## Production patterns (from OMS)

1. **Activities as a struct with injected deps** — config at
   registration, not globals:
   `w.RegisterActivity(&Activities{BillingURL: cfg.BillingURL})`.
2. **Tuned worker options in `worker.go`** — poller counts per
   subsystem (`MaxConcurrentWorkflowTaskPollers`,
   `MaxConcurrentActivityTaskPollers`). Tune with evidence.
3. **Cross-subsystem communication**:
   - Same Namespace: **Child Workflow** on the child's Task Queue
     (Order → Shipment).
   - Status back to parent: **Signal**.
   - Different Namespace / different team: **HTTP** (OMS Billing) or
     **Nexus** (the current cross-namespace answer). Child Workflows
     do not cross Namespaces.
4. **Idempotency** — UUID from `workflow.SideEffect` (or an Activity)
   passed into the Charge activity as the idempotency key.
5. **Query vs list cache** — Query one execution; maintain a **read
   cache (DB) in the API layer** for listings. Custom Search Attributes
   are eventually consistent and not a list-all store. OMS's SQLite
   cache is explicitly "replace for production load."
6. **Payload encryption** — custom DataConverter + **codec server** so
   CLI/Web UI can decode. Keyed by a flag such as `--encryption-key-id`.
7. **Environment portability** — same binary against local
   (`temporal server start-dev`), self-hosted, or Temporal Cloud.
   Client options from env (`envconfig` or OMS
   `server.CreateClientOptionsFromEnv`).

## What lives where

| Concern | Owner |
| --- | --- |
| Workflow definition | subsystem `workflows.go` (deterministic) |
| Activity I/O | subsystem `activities.go` (struct + deps) |
| Task Queue name, signal names | same package, exported consts |
| Worker registration + options | `worker.go` / `worker/main.go` |
| Start / signal / query / update from HTTP | `api.go` or `starter/` |
| Config, dial, process interrupt | `cmd/` + `app/server` (OMS) or `worker/main.go` |
| Encryption codec | `temporalutil/` (or equivalent), used by every client |
| Replay + unit tests | next to the workflow (`*_test.go`) |

## Binaries

| Scale | Shape |
| --- | --- |
| Sample | `worker/main.go` + `starter/main.go` |
| Production | One `cmd/<app>` with subcommands `worker` and `api` (OMS). Flags select subsystems. |

Workers poll; APIs start/signal/query. Deploy them independently when
load diverges. All Workers on one Task Queue register the **same**
Workflow and Activity types.

## Tests

- `workflow_test.go` / `activities_test.go` beside the definitions.
- Replay tests + checked-in histories before changing a workflow that
  already has in-flight runs.
- Cross-subsystem tests in `app/test/` (OMS), not inside one package.
- `//go:build integration` for tests that need a real Temporal server.
  Unique Task Queue names per test.

## After layout changes

```bash
gofmt -w <files>
go fix ./<packages>
workflowcheck ./<packages>   # skip if not in the module yet
go test ./<packages>
```

## LLM traps — never generate these

- Workflow/Activity types defined only in `package main`
- Worker and starter using different Task Queue strings
- One giant `app/` package for every workflow
- Child Workflows targeting another Namespace
- Listing endpoints that Query every workflow instead of a read model
- `cmd/` that contains workflow logic instead of wiring
- Restyling OMS five-file packages into `workflows/` + `activities/`
  (or the reverse) without a reason
- Cron `workflow.Sleep` loops — use the Schedule API
- Putting the Temporal client in a package-level `var` and dialing in
  `init()`

## Do not

- Apply Encore layout (`encore.app`, no `main`) to a plain Temporal module.
- Enable Worker Versioning in a toy binary with no deployment story.
- Use `temporal server start-dev` as production.
- Introduce Python/TypeScript Temporal code in a Go module.
