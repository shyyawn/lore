# Clients, workers, tests, and CLI

## Client

```go
c, err := client.Dial(client.Options{
	HostPort:  addr,
	Namespace: ns,
	Logger:    log.NewStructuredLogger(slog.Default()),
})
```

`defer c.Close()`. `client.DialContext` when a parent context already exists
(process shutdown). Pass `context.Context` as the first argument on every
client call after Dial.

Production config from env: `go.temporal.io/sdk/contrib/envconfig`
(`envconfig.MustLoadDefaultClientOptions()`). Do not invent a second YAML
config stack for host/namespace/TLS if envconfig already covers it.

OpenTelemetry:

```go
tracing, err := opentelemetry.NewTracingInterceptor(opentelemetry.TracerOptions{})
// client.Options{Interceptors: []interceptor.ClientInterceptor{tracing}}
```

Metrics: `contrib/tally` or the SDK metrics handler. Do not start a second
Prometheus registry beside the one the process already uses.

## Worker

```go
w := worker.New(c, "greeting-task-queue", worker.Options{})
w.RegisterWorkflow(workflows.GreetingWorkflow)
w.RegisterActivity(&activities.Activities{HTTP: httpClient, DB: db})
return w.Run(worker.InterruptCh())
```

Tune when you have evidence (schedule-to-start latency, CPU):

- `MaxConcurrentActivityExecutionSize` / `MaxConcurrentWorkflowTaskExecutionSize`
- poller counts, or the poller autoscaler / worker tuner APIs on recent SDKs

Default panic policy is `BlockWorkflow` — keep that in production. Dead
workers during deploy: drain with `WorkerStopTimeout`, do not `os.Exit`
mid-task.

All pollers of a queue must register the same types. Split queues when
workflow tasks and heavy activities need different hardware — not for
"clean architecture."

Sessions (`EnableSessionWorker`, `workflow.CreateSession`) pin Activities to
one host. They die with the process. Prefer one long Activity with
heartbeats unless you truly need local disk/GPU across several Activities.

## Worker Versioning

Legacy `UseBuildIDForVersioning` / `VersioningIntent` are deprecated. Use:

```go
w := worker.New(c, TaskQueue, worker.Options{
	DeploymentOptions: worker.DeploymentOptions{
		UseVersioning: true,
		Version: worker.WorkerDeploymentVersion{
			DeploymentName: "order-service",
			BuildID:        os.Getenv("BUILD_ID"), // git SHA
		},
		DefaultVersioningBehavior: workflow.VersioningBehaviorPinned,
	},
})
```

`BuildID`, not `BuildId` (renamed in SDK 1.37).

| Behavior | When |
| --- | --- |
| `VersioningBehaviorPinned` | Short workflows; simplest deploys |
| `VersioningBehaviorAutoUpgrade` | Weeks/months long; still patch command changes |

Ramp with `temporal worker deployment set-current-version`. Keep old
versions until pinned runs complete. Query:

```bash
temporal workflow list --query \
  'TemporalWorkerDeploymentVersion = "order-service:abc123" AND ExecutionStatus = "Running"'
```

Unversioned → versioned: run both, then activate the versioned deployment.
Idle workflows need a Signal to move.

Do not turn this on for a local sample.

## Schedules

Use `c.ScheduleClient().Create` (intervals or cron). Do not write
`for { workflow.Sleep(24*time.Hour); run() }` as a substitute. Pause /
trigger / delete via the handle. Calendar specs belong on the Schedule, not
in workflow code.

## Priority and fairness

Public Preview. Set `temporal.Priority` on start / Activity options:

- `PriorityKey` 1–5 (lower is higher). Default 3.
- `FairnessKey` + `FairnessWeight` for multi-tenant queues so one tenant
  cannot fill a FIFO backlog.

Recommend fairness when the user is building multi-tenant dispatch. Skip it
when there is no backlog.

## Data

Default converter: nil → bytes → protojson → proto → JSON. Structs need
exported fields. Same converter on every client and worker.

Typed search attributes (preferred since 1.26):

```go
var OrderStatusKey = temporal.NewSearchAttributeKeyKeyword("OrderStatus")

_ = workflow.UpsertTypedSearchAttributes(ctx, OrderStatusKey.ValueSet("paid"))
```

Register the attribute on the cluster before upserting. Untyped
`UpsertSearchAttributes(map[string]any)` is the old path.

Payload codec for encryption. Large objects: store externally, pass a
reference. gogo/protobuf compatibility only if you still read pre-1.26
payloads (`LegacyTemporalProtoCompat`).

## Tests

`go.temporal.io/sdk/testsuite`. Function-style, stdlib `testing`, unless the
package already uses testify suites (do not rip those out):

```go
func TestGreetingWorkflow(t *testing.T) {
	var s testsuite.WorkflowTestSuite
	env := s.NewTestWorkflowEnvironment()
	env.RegisterActivity(&activities.Activities{})

	env.ExecuteWorkflow(GreetingWorkflow, "Ada")
	if !env.IsWorkflowCompleted() {
		t.Fatal("workflow did not complete")
	}
	if err := env.GetWorkflowError(); err != nil {
		t.Fatal(err)
	}
	var result string
	if err := env.GetWorkflowResult(&result); err != nil {
		t.Fatal(err)
	}
	if result != "Hello, Ada!" {
		t.Fatalf("got %q", result)
	}
}
```

The Workflow itself does not need `RegisterWorkflow` on the test env.
Register every Activity the workflow schedules, or mock it.

- Mock: `env.OnActivity(a.Greet, mock.Anything, mock.Anything).Return(...)`
  when testify/mock is already a dep. Otherwise register a fake implementation.
- Signals/Updates: `env.RegisterDelayedCallback` + `env.SignalWorkflow` /
  `env.UpdateWorkflow`.
- Isolated Activity: `NewTestActivityEnvironment`.
- Replay: `worker.NewWorkflowReplayer` + checked-in histories for workflows
  you will change while they run.
- Time-skipping is built into the test env; do not `time.Sleep` to wait.
- Deadlock detector: `worker.Options.DeadlockDetectionTimeout` caps how long a
  workflow task may run, in **real** time, and defaults to 1s. Exceeding it
  fails the task as `[TMPRL1101] Potential deadlock detected`. The message
  names your workflow, so it reads like a determinism bug; confirm the code is
  genuinely non-blocking before believing that. A test suite is the one place
  where a correct workflow trips it routinely, because tests run many
  executions on a contended machine — raise it on the env there rather than
  changing working code:
  `env.SetWorkerOptions(worker.Options{DeadlockDetectionTimeout: time.Minute})`.

Unique Task Queues in integration tests. `//go:build integration` for tests
that need a real server.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| `[TMPRL1101] Potential deadlock detected` | A workflow task exceeded `worker.Options.DeadlockDetectionTimeout` (default **1s**), measured in real time. Suspect blocking workflow code first — I/O, `time.Sleep`, a native lock or channel, a tight CPU loop. Only once the code is demonstrably non-blocking is a starved CPU the explanation; then raise the timeout instead of rewriting correct code. |
| `unknown activity type` / `unknown workflow type` | Not registered on a Worker polling that Task Queue. Every Worker on a queue registers the same types. |
| Non-determinism error on replay after a deploy | The command sequence changed for in-flight runs. `workflow.GetVersion`, or a new Workflow type — never an in-place edit. |
| Duplicate start of a business-key Workflow ID | Do **not** write a `WorkflowExecutionAlreadyStarted` handler by reflex: `WorkflowExecutionErrorWhenAlreadyStarted` defaults to **false**, so `ExecuteWorkflow` returns a handle to the current or last run instead of erroring. To tell a fresh start from an attach, compare the returned `RunID`. Set `WorkflowIDConflictPolicy` (defaults to `Fail`) to `UseExisting` to have the server attach to a *running* execution, and `WorkflowIDReusePolicy` for the *completed* case. Only opt into the error explicitly. |
| Query is stale, or errors on a finished run | Queries need a live Worker on that queue and history that has not aged out. Do not build reporting on Queries — project to a database. |
| Activity retries forever on a bad argument | The error is retryable by default. Mark permanent failures with `temporal.NewNonRetryableApplicationError`. |

## CLI (developer loop)

```bash
temporal server start-dev                 # local only; --db-filename to persist
temporal workflow start --type GreetingWorkflow --task-queue greeting-task-queue --workflow-id greeting-1 --input '"Ada"'
temporal workflow execute --type GreetingWorkflow --task-queue greeting-task-queue --input '"Ada"'
temporal workflow signal --workflow-id greeting-1 --name approve --input 'true'
temporal workflow query  --workflow-id greeting-1 --type get-status
temporal workflow update execute --workflow-id greeting-1 --name add-item --input '"sku"'
temporal workflow show --workflow-id greeting-1 --output json
```

`temporal workflow update` is a **command group** (`execute` / `start` /
`result` / `describe`). `--wait-for-stage` on `update start` only accepts
`accepted`.

Never point production traffic at the dev server.

## Dynamic registration

`RegisterDynamicWorkflow` / `RegisterDynamicActivity` are a default for
**unrecognized** types on that Worker — not a replacement for explicit
`RegisterWorkflow` / `RegisterActivity` of known types.
