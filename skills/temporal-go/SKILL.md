---
name: temporal-go
description: >-
  Writes, restyles, and reviews Temporal Go workflows, activities, workers, and
  clients using official Go SDK practice (function references, activity structs,
  workflows/activities/worker packages) plus 2024–2026 APIs (workflowcheck,
  Worker Versioning, Updates, Update-With-Start, Nexus, typed search
  attributes, slog adapter). Use when generating, editing, reviewing, or
  testing Temporal Go; when the user mentions Temporal, workflows, activities,
  workers, task queues, signals, queries, updates, Nexus, continue-as-new,
  determinism, replay, or go.temporal.io/sdk.
---

# Temporal Go 2026

Temporal is a **durable execution** platform. Workflows orchestrate; Activities
do I/O. The cluster records Event History and **replays** workflow code from the
top to restore state. The Go SDK (`go.temporal.io/sdk`) has **no sandbox** —
determinism is convention plus `workflowcheck`.

Language idioms follow the `go-idioms` skill. This skill **overrides** `go-idioms`
inside workflow functions: no `slog`, no `go`/`chan`/`select`, no `time.Now` /
`time.Sleep`, no `WaitGroup`. Activities and `cmd/` wiring stay ordinary Go.

Catalogs: [determinism.md](determinism.md) (replay, workflowcheck, GetVersion),
[primitives.md](primitives.md) (activities, errors, signals/queries/updates,
saga), [workers.md](workers.md) (client, worker, versioning, Nexus, tests, CLI).
Package layout: `temporal-go-app-structure`. If `encore.app` exists:
`encore-temporal-go-app-structure`.

## First step

1. Read `go.mod` for the SDK version (`go.temporal.io/sdk`). Target that
   version. Do not bump the SDK to unlock an API.
2. Find existing `RegisterWorkflow` / `RegisterActivity` call sites. Match
   that shape: function references by default, `Register*WithOptions` only
   where names are already customized.
3. Reuse existing Task Queue names and package layout.

If the repo is not yet a Temporal app, add `go.temporal.io/sdk` and a worker
binary. Do not invent a second workflow engine (Asynq, Cadence, homegrown
sagas) beside it.

## After every Temporal edit

```bash
gofmt -w <files>
go fix ./<packages>
go vet ./<packages>
workflowcheck ./<packages>   # skip if the tool is not in the module yet
go test ./<packages>
```

Write the deterministic form the first time. Do not write native `go`/`time`
in a workflow and wait for replay to fail.

Add `workflowcheck` as a `tool` in `go.mod` when `go` is 1.24+. Pin
`VERSION` to the `go.temporal.io/sdk` line already in `go.mod`. Do not
use `@latest`.

```bash
go get -tool go.temporal.io/sdk/contrib/tools/workflowcheck@VERSION
```

## Hard rules

- Workflows are deterministic orchestration. All I/O, clocks, RNG, UUID, and
  network live in Activities (or `workflow.SideEffect` for cheap local values).
- Register and execute with **function / method references**, not strings.
  The SDK checks parameters against the definition. Default type name is the
  Go function or method name.
- Activities are struct methods when they need deps. Register the struct
  (`RegisterActivity(&Activities{...})`), not individual methods. Workflows
  stay package functions — struct methods as Workflows are strongly
  discouraged.
- `StartToCloseTimeout` (or `ScheduleToCloseTimeout`) is required on every
  Activity. Prefer `StartToCloseTimeout`.
- Activities must be **idempotent**. Retries and Worker crashes re-run them.
- Query handlers and Update validators are read-only and non-blocking.
- All Workers polling one Task Queue register the **same** Workflow and
  Activity types. A Task Queue does not route by type.
- Workflow and Activity definitions live in importable packages. Worker and
  starter `main`s import them; durable code does not import CLI, HTTP, or UI.
- `tctl` is gone. Use the `temporal` CLI. Dev server is not production.

## Default shapes

Separate packages for workflows, activities, and the worker — Temporal's
documented layout. Activities as struct methods so the worker injects deps;
the workflow references methods through a nil pointer (compile-time types,
no instance in workflow code).

```
workflows/greeting.go
activities/greet.go
worker/main.go
starter/main.go
```

```go
// workflows/greeting.go
func GreetingWorkflow(ctx workflow.Context, name string) (string, error) {
	ctx = workflow.WithActivityOptions(ctx, workflow.ActivityOptions{
		StartToCloseTimeout: time.Minute,
	})
	var a *activities.Activities
	var result string
	if err := workflow.ExecuteActivity(ctx, a.Greet, name).Get(ctx, &result); err != nil {
		return "", fmt.Errorf("greet: %w", err)
	}
	return result, nil
}

// activities/greet.go
type Activities struct {
	HTTP *http.Client
	DB   *sql.DB
}

func (a *Activities) Greet(ctx context.Context, name string) (string, error) {
	activity.GetLogger(ctx).Info("creating greeting", "name", name)
	return fmt.Sprintf("Hello, %s!", name), nil
}

// worker/main.go
w := worker.New(c, "greeting-task-queue", worker.Options{})
w.RegisterWorkflow(workflows.GreetingWorkflow)
w.RegisterActivity(&activities.Activities{HTTP: httpClient, DB: db})
return w.Run(worker.InterruptCh())
```

A tiny hello with no deps may keep workflow and activity functions in one
package and `RegisterActivity(Greet)`. Do not put definitions only in
`package main`.

## Names and Workflow IDs

Default type name = function or method name. Pass the function into
`ExecuteWorkflow` / `ExecuteActivity` / `ExecuteChildWorkflow` so the SDK
validates arguments.

`Register*WithOptions` + `Name` only when you must customize the type
(stable name across a rename, or a CLI that cannot import the package).
Then **every** register, start, and execute site uses that same string —
do not mix a custom `Name` with a function reference.

Strings without a custom `Name` are the other-language / no-import path,
not the default.

Workflow IDs for entity workflows are **business keys** (`"order-"+orderID`).
Use `WorkflowIDConflictPolicy` / `WorkflowIDReusePolicy` deliberately. Hello
samples may use a unique ID; do not copy that onto orders.

## Determinism (workflow body only)

| Instead of | Use |
| --- | --- |
| `go f()` | `workflow.Go(ctx, f)` |
| `chan T` / `select` | `workflow.Channel` / `workflow.Selector` |
| `time.Now` / `time.Sleep` / `time.After` | `workflow.Now` / `workflow.Sleep` / `workflow.NewTimer` |
| `rand.*` / `uuid.New` | `workflow.SideEffect` or an Activity |
| `log` / `fmt.Println` / `slog` | `workflow.GetLogger(ctx)` |
| `for k := range m` | sort keys (`slices.Sorted(maps.Keys(m))` on 1.23+) |

Anonymous functions as local activities get a non-deterministic name. Named
functions only.

Details and `GetVersion`: [determinism.md](determinism.md).

## Timeouts, retries, errors

Prefer `StartToCloseTimeout`. Add `HeartbeatTimeout` for anything that should
cancel or resume. Do not invent retry loops; set `temporal.RetryPolicy` and
mark permanent failures with `temporal.NewNonRetryableApplicationError`.

In workflows, Activity failures arrive as `*temporal.ActivityError`. Unwrap
with `errors.As` (or `errors.AsType` on 1.26+). Returning any error from a
Go workflow **fails the execution** — there is no implicit workflow-task
retry like Python/TypeScript. Set a start-time `RetryPolicy` only when the
workflow itself should retry.

Heartbeats deliver cancellation. Long Activities `RecordHeartbeat` and select
on `ctx.Done()`. Cleanup after workflow cancel uses
`workflow.NewDisconnectedContext`.

## Messages

| Primitive | Mutates? | Returns? | Blocks? | Use |
| --- | --- | --- | --- | --- |
| Query | no | yes | no | peek state |
| Signal | yes | no | yes | fire-and-forget |
| Update | yes | yes | yes | mutate and return |

Signals are channels (`workflow.GetSignalChannel`), not handlers. Updates use
`SetUpdateHandler` / `SetUpdateHandlerWithOptions` with a read-only Validator.
Prefer Update over Signal+Query for request/response. Prefer
`UpdateWithStartWorkflow` over Signal-With-Start when the caller needs a
result and a running execution.

Before complete or Continue-As-New: `workflow.Await` until
`workflow.AllHandlersFinished(ctx)`. Drain signal channels with
`ReceiveAsync` before Continue-As-New.

## Versioning

Three tools, in this order of preference for new production services:

1. **Worker Versioning** (`worker.DeploymentOptions`) — PINNED for short
   workflows; AUTO_UPGRADE for long ones (still needs `GetVersion` on command
   changes). Field is `BuildID` (not `BuildId`).
2. **`workflow.GetVersion`** — patch a running type when you add/remove/reorder
   commands.
3. **New Workflow type** (`GreetingWorkflowV2`) — rewrites.

Do not use legacy `UseBuildIDForVersioning` / `VersioningIntent`. Do not
patch Activity implementations, retry policies, or timer durations.

## Observability and data

- Client logger: `log.NewStructuredLogger` over `log/slog`. Workflows still
  use `workflow.GetLogger`; Activities use `activity.GetLogger`.
- Tracing: `go.temporal.io/sdk/contrib/opentelemetry` interceptor on the
  client. Do not roll a custom context propagator for traces.
- Visibility: typed search attributes (`temporal.NewSearchAttributeKey*` +
  `workflow.UpsertTypedSearchAttributes`), not the untyped map API.
- Payloads: exported struct fields, default JSON converter. Store large blobs
  by reference (2 MiB/payload, 4 MiB/gRPC, keep history well under 50 MiB).
  Encrypt with `converter.PayloadCodec`, not application-level wrapping.

## LLM traps — never generate these

- `go func()`, `make(chan …)`, native `select`, `time.Now`/`Sleep`/`After` in a workflow
- `ExecuteActivity(ctx, "Greet", …)` when `Greet` is in this module — pass the function
- Mixing `Register*WithOptions{Name: "X"}` with `Execute*(ctx, TheFunc, …)`
- Registering a single struct method (`RegisterActivity(a.Greet)`) instead of the struct
- Struct methods as Workflows
- Activity without `StartToCloseTimeout` / `ScheduleToCloseTimeout`
- `fmt.Println` / `slog` / `log.Println` in workflow code
- `for k, v := range myMap` in a workflow without sorting keys
- Anonymous func as a local activity
- Query handler that mutates state or calls `ExecuteActivity`
- Retry loops around `ExecuteActivity`
- Random UUID as Workflow ID for an entity that should be unique
- `tctl`, `UseBuildIDForVersioning`, `gogo/protobuf`
- Child Workflows across Namespaces — use Nexus
- Cron `workflow.Sleep` loops — use the Schedule API
- Local Activities as the default (they skip the task queue; use only for tiny, local reads)
- `workflow.IsReplaying` to branch business logic
- `http.DefaultClient` inside an Activity (no timeout)
- Swallowing Activity errors with `_ = future.Get(...)`
- Putting file bytes / large JSON in Event History

## Do not

- Restyle function-registered code into string consts. Follow the official
  function-reference style; only introduce `Name` when customizing the type.
- Collapse `workflows/` + `activities/` into one package as a drive-by
  restyle when the repo already split them.
- Enable Worker Versioning in a toy/dev binary without a deployment story.
- Use the CLI dev server (`temporal server start-dev`) as production.
- Introduce Python/TypeScript Temporal code in a Go module.
