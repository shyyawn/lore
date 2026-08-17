# Determinism, replay, and versioning

The Worker does not snapshot workflow memory. On restore it **re-runs the
workflow function from the top** and substitutes recorded Event History for
prior commands. If the new run emits different commands, the workflow task
fails with a non-determinism error and (default) stays blocked until you
fix the code.

Go has no workflow sandbox. `workflowcheck` catches many illegal calls; it
does not catch global mutation or unsorted map ranging in every case. Replay
tests catch the rest.

## Forbidden in workflow functions

Illegal in the workflow function and anything it calls (except through
`workflow.SideEffect` / an Activity):

- `go`, `chan`, native `select`
- `time.Now`, `time.Sleep`, `time.After`, `time.NewTicker`
- `math/rand` global, `crypto/rand`, `uuid.New` (unless inside SideEffect)
- `os` file/network, `net/http`, SQL, gRPC clients
- `log`, `fmt.Println`, `slog` (use `workflow.GetLogger`)
- ranging a map (sort keys first)
- mutating package-level vars
- anonymous functions passed to `ExecuteLocalActivity`

Helpers used from a workflow are workflow code. Do not share a helper between
a workflow and an Activity if it uses the wall clock or I/O.

## Safe replacements

```go
workflow.Go(ctx, func(ctx workflow.Context) { /* … */ })

ch := workflow.NewChannel(ctx) // or NewBufferedChannel
selector := workflow.NewSelector(ctx)
selector.AddReceive(ch, func(c workflow.ReceiveChannel, more bool) {
	var v string
	c.Receive(ctx, &v)
})
selector.Select(ctx)

_ = workflow.Sleep(ctx, time.Minute)
now := workflow.Now(ctx)
timer := workflow.NewTimer(ctx, 5*time.Minute)

logger := workflow.GetLogger(ctx)
logger.Info("started", "orderID", orderID)

var id string
_ = workflow.SideEffect(ctx, func(ctx workflow.Context) any {
	return uuid.New().String()
}).Get(&id)
```

`MutableSideEffect` records a new marker only when the value changes. Use it
for slowly changing local config, not for I/O.

`workflow.IsReplaying(ctx)` is for interceptors/metrics that must not double-
emit. Never branch business logic on it.

## Parallel work

`ExecuteActivity` returns a `Future` immediately. Start many, then `Get`:

```go
futures := make([]workflow.Future, len(items))
for i, item := range items {
	futures[i] = workflow.ExecuteActivity(ctx, ProcessItem, item)
}
results := make([]Result, len(items))
for i, f := range futures {
	if err := f.Get(ctx, &results[i]); err != nil {
		return nil, err
	}
}
```

Do not wrap each call in `workflow.Go` unless you need a selector/timer race.

## workflowcheck

```bash
workflowcheck ./...
```

It walks from every `RegisterWorkflow` and reports non-deterministic callees.
False positives: `//workflowcheck:ignore` on the offending line, or a YAML
config. Do not ignore a real `time.Now` / `http.Get`.

Not caught: global var mutation, some map ranges, logic that only diverges on
replay. Pair with `worker.NewWorkflowReplayer` against exported histories:

```go
replayer := worker.NewWorkflowReplayer()
replayer.RegisterWorkflow(MyWorkflow)
err := replayer.ReplayWorkflowHistoryFromJSONFile(nil, "testdata/hello_history.json")
```

Export: `temporal workflow show --workflow-id ID --output json > history.json`.

## What is a breaking change

These alter the command sequence and need versioning if any execution is still
open:

- add/remove/reorder Activities, timers, child workflows, signals waited on
- change the Activity/child **type name** passed to Execute*
- change Continue-As-New vs return

These are usually safe without a patch:

- Activity **implementation** body
- log lines via `workflow.GetLogger`
- adding a Query or Update handler (additive)
- retry policy / timeout number changes (do not change the command type)
- comments, refactors that do not change command order

## GetVersion

```go
v := workflow.GetVersion(ctx, "charge-via-psp", workflow.DefaultVersion, 1)
if v == workflow.DefaultVersion {
	err = workflow.ExecuteActivity(ctx, ChargeLegacy, in).Get(ctx, &out)
} else {
	err = workflow.ExecuteActivity(ctx, ChargePSP, in).Get(ctx, &out)
}
```

Keep the `GetVersion` call after collapsing to one branch so stale replays
fail fast. Unique `changeID` per change; in loops append the index
(`fmt.Sprintf("step-%d", i)`). Find open patched runs:

```bash
temporal workflow list --query \
  'WorkflowType = "OrderWorkflow" AND ExecutionStatus = "Running" AND TemporalChangeVersion = "charge-via-psp"'
```

## Worker Versioning

Prefer this for production fleets. Pin short workflows; auto-upgrade long
ones. See [workers.md](workers.md).

New Workflow type (`OrderWorkflowV2`) for rewrites. Register both until the
old type has no running executions.

## Continue-As-New

History is bounded (~50 MiB hard; aim far lower). Looping entity workflows
must Continue-As-New:

```go
if workflow.GetInfo(ctx).GetContinueAsNewSuggested() {
	if err := workflow.Await(ctx, func() bool { return workflow.AllHandlersFinished(ctx) }); err != nil {
		return err
	}
	for {
		var v string
		if ok := sig.ReceiveAsync(&v); !ok {
			break
		}
		// apply v
	}
	return workflow.NewContinueAsNewError(ctx, LongRunningWorkflow, nextState)
}
```

Do not Continue-As-New every iteration. Trust `GetContinueAsNewSuggested`.

Pinned long-running workflows that already Continue-As-New can pick up a new
Worker Deployment Version at that boundary with
`NewContinueAsNewErrorWithOptions` and
`ContinueAsNewVersioningBehaviorAutoUpgrade` (Public Preview). Check
`workflow.GetInfo(ctx).GetTargetWorkerDeploymentVersionChanged()` at a task
boundary — not on a busy-poll timer. Idle workflows need a Signal to wake.
