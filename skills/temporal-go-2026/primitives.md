# Activities, errors, and messages

## Activity options

Either `StartToCloseTimeout` or `ScheduleToCloseTimeout` is required.

| Field | Meaning |
| --- | --- |
| `StartToCloseTimeout` | Max duration of one attempt. Prefer this. |
| `ScheduleToCloseTimeout` | Wall time including retries and queue wait. |
| `ScheduleToStartTimeout` | Max queue wait. Rarely needed. |
| `HeartbeatTimeout` | Max gap between heartbeats. Required to cancel / detect stuck work. |
| `RetryPolicy` | Exponential backoff. Omit fields you do not have a reason to set. |
| `WaitForCancellation` | Wait for the Activity to finish cleanup after cancel. |

```go
ctx = workflow.WithActivityOptions(ctx, workflow.ActivityOptions{
	StartToCloseTimeout: 10 * time.Minute,
	HeartbeatTimeout:    2 * time.Minute,
	RetryPolicy: &temporal.RetryPolicy{
		NonRetryableErrorTypes: []string{"ValidationError", "PaymentError"},
	},
})
```

Heartbeat timeout should tolerate slow iterations; each heartbeat is an action.
Do not set it to 10s on a 30s loop.

## Heartbeat and cancel

Cancellation is delivered on heartbeat. Activities that never heartbeat run
to completion after a cancel.

```go
func ProcessFile(ctx context.Context, path string) error {
	start := 0
	if activity.HasHeartbeatDetails(ctx) {
		_ = activity.GetHeartbeatDetails(ctx, &start)
		start++
	}
	for i := start; i < n; i++ {
		select {
		case <-ctx.Done():
			return ctx.Err()
		default:
		}
		if err := work(ctx, i); err != nil {
			return err
		}
		activity.RecordHeartbeat(ctx, i)
	}
	return nil
}
```

Use the Activity ID / Workflow ID as the idempotency key to the downstream
API. Heartbeat details resume progress; they do not make a non-idempotent
charge safe.

## Errors

```go
return "", temporal.NewApplicationError("temporary", "ProviderDown")

return "", temporal.NewNonRetryableApplicationError(
	"card declined",
	"PaymentError",
	nil, // cause
)
```

Retryable: network, 429, 5xx, timeouts, "not ready".
Non-retryable: validation, auth, "does not exist", business decline.

In the workflow, unwrap (`var a *Activities` for the method ref):

```go
if err := workflow.ExecuteActivity(ctx, a.Charge, in).Get(ctx, &out); err != nil {
	var app *temporal.ApplicationError
	if errors.As(err, &app) && app.Type() == "PaymentError" {
		return "", fmt.Errorf("charge: %w", err)
	}
	var canceled *temporal.CanceledError
	if errors.As(err, &canceled) || temporal.IsCanceledError(ctx.Err()) {
		disconnected, _ := workflow.NewDisconnectedContext(ctx)
		disconnected = workflow.WithActivityOptions(disconnected, workflow.ActivityOptions{
			StartToCloseTimeout: 5 * time.Minute,
		})
		_ = workflow.ExecuteActivity(disconnected, a.Release, in).Get(disconnected, nil)
		return err
	}
	return "", err
}
```

On Go 1.26+ prefer `errors.AsType[*temporal.ApplicationError](err)`.

Returning an error from the workflow function **fails the workflow**. Go does
not retry the workflow task on a panic/error the way Python/TS retry on
non-`ApplicationError`. Default Worker panic policy is `BlockWorkflow`
(stuck until a fix). Use `FailWorkflow` in tests only.

Do not wrap a retryable Activity error in `NewNonRetryableApplicationError`
unless you intend to fail the workflow without retry.

Benign / expected failures (poll empty, "not yet"): use the SDK's application
error category APIs so they do not page. Do not hide them with `_ = err`.

## Signals, queries, updates

**Signal** — Go uses a channel, not a callback:

```go
ch := workflow.GetSignalChannel(ctx, ApproveSignal)
var in ApproveInput
ch.Receive(ctx, &in) // or ReceiveAsync, or a Selector with a timer
```

**Query** — read-only, non-blocking, no workflow APIs that send commands:

```go
err := workflow.SetQueryHandler(ctx, StatusQuery, func() (Status, error) {
	return status, nil
})
```

**Update** — mutate and return. Validator is query-like (no mutate, no block):

```go
err := workflow.SetUpdateHandlerWithOptions(ctx, AddItemUpdate,
	func(ctx workflow.Context, item string) (int, error) {
		items = append(items, item)
		return len(items), nil
	},
	workflow.UpdateHandlerOptions{
		Validator: func(ctx workflow.Context, item string) error {
			if item == "" {
				return temporal.NewNonRetryableApplicationError("empty item", "ValidationError", nil)
			}
			return nil
		},
	},
)
```

Wait for handlers before exit: `workflow.Await(ctx, func() bool { return workflow.AllHandlersFinished(ctx) })`.

`workflow.Await` / `AwaitWithTimeout` wait on a condition. Prefer them over
spin+sleep.

## Update-With-Start

Atomic "ensure running, then update". Requires
`WorkflowIDConflictPolicy` on the start operation. Prefer this over
Signal-With-Start when the caller needs the update result.

```go
startOp := c.NewWithStartWorkflowOperation(client.StartWorkflowOptions{
	ID:                       "order-" + orderID,
	TaskQueue:                TaskQueue,
	WorkflowIDConflictPolicy: enumspb.WORKFLOW_ID_CONFLICT_POLICY_USE_EXISTING,
}, OrderWorkflow, in)

handle, err := c.UpdateWithStartWorkflow(ctx, client.UpdateWithStartWorkflowOptions{
	UpdateOptions: client.UpdateWorkflowOptions{
		UpdateName:   AddItemUpdate,
		WaitForStage: client.WorkflowUpdateStageCompleted,
	},
	StartOperation: startOp,
})
```

`USE_EXISTING` attaches to a running execution. `FAIL` errors if one is
already running. The call waits until a Worker accepts the update.

## Child workflows vs Nexus

Same-namespace fan-out: `workflow.ExecuteChildWorkflow` with
`ChildWorkflowOptions`. Set `ParentClosePolicy` explicitly (`ABANDON` if the
child must outlive the parent). Wait for start with
`future.GetChildWorkflowExecution().Get` before abandoning.

Cross-namespace / other team: **Nexus**, not children. Define a service
contract, `temporalnexus.NewWorkflowRunOperation` or `nexus.NewSyncOperation`,
`w.RegisterNexusService`, caller uses `workflow.NewNexusClient(endpoint, service).ExecuteOperation`.

## Saga

Register compensation **before** the Activity so a completed-but-failed-return
still rolls back. Run compensations on `NewDisconnectedContext` in reverse.
Compensation Activities are idempotent like every Activity.

## Local Activities

Skip the task queue; run on the workflow Worker. Use only for sub-second,
local, cheap reads when latency matters. Still retried; still must be
idempotent. Named functions only. Default to a normal Activity.

## Async completion

`return "", activity.ErrResultPending` plus `client.CompleteActivity` with the
task token. Prefer a Signal/Update if the external system can call Temporal
and does not need heartbeats. If you set `HeartbeatTimeout`, the completer
must heartbeat.

## Standalone Activities

Public Preview (SDK ≥ 1.41): `client.ExecuteActivity` from a Client **without**
a workflow — job-queue style. Do not call this from inside a workflow
(use `workflow.ExecuteActivity`). Requires ID, TaskQueue, and a timeout.
Same Activity function can serve both paths.
