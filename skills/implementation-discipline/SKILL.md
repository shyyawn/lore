---
name: implementation-discipline
description: >-
  Runs evidence-led, checkpointed implementation across multiple mutation
  surfaces. Use for changes involving persistence lifecycles, concurrency,
  migrations, durable jobs, or cross-cutting completion claims. Do not use for
  a small isolated edit or ordinary language and style review.
---

# Implementation discipline

Prove non-trivial changes at their framework and storage seams. Do not turn a
locally green path into a system-wide completion claim.
Sources: repository contract, pin-matched public docs, runtime artifacts, and
observable tests. Patterns: [catalog.md](catalog.md). Close: [sweeps.md](sweeps.md).
Framework routing: [frameworks.md](frameworks.md). Opus 5: `opus5-guide`.

## First step

1. Inventory the request, instructions, pin, schema, tests, commit, and
   worktree. Honor live edits.
2. Restate the outcome, allowed mutations, and stop condition.
3. Load the language, framework, and domain skills for the detected stack.
4. Mark load-bearing claims **verified**, inferred, or proposed.
5. Map create, update, delete, bulk, admin, import, worker, retry, and migration
   paths. Mark absent paths not applicable.
6. Verify the first decision-changing seam before broad implementation.

If lifecycle or persistence is in scope, read the relevant part of
[frameworks.md](frameworks.md). It routes. It does not replace pinned docs.

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Framework | public lifecycle | repository owns a tested extension |
| Shared behavior | pure rule or narrow operation | one service genuinely fits every caller |
| Validation | earliest public error boundary | database must arbitrate a race |
| Error translation | proven expected conflict only | unknown error keeps its identity |
| Concurrency | name anomaly and residual behavior | no shared mutable state |
| Portability | production backends prove semantics | one backend is the declared target |
| Completion | focused gate, then closure sweep | repository has a stricter gate |

One write path means one set of **invariants**. It does not require one
callback, service, authorization policy, or orchestration path.

## Division of labor

| Concern | Owner |
| --- | --- |
| Intent, scope, approval | request and repository instructions |
| Object lifecycle | framework public API |
| Authorization and visibility | entry-point adapter or actor-scoped service |
| Deterministic calculation | pure shared rule |
| Domain transition | narrow domain operation |
| Admin, CLI, worker, migration | each surface's native lifecycle |
| Race and durable integrity | database constraint and transaction |
| External effect | after-commit dispatch or outbox |
| Rollout | migration and release runbook |

Share the rule. Keep surface policy at the edge.

## Framework seam

Copy this before overriding a callback, observer, interceptor, lifecycle hook,
or repository method:

```text
Framework seam:
- [ ] Public hook exists at this stage
- [ ] Expected errors reach a normal error boundary
- [ ] Object state is authoritative here
- [ ] Required relationships or cascades are available
- [ ] Transaction covers every dependent write
- [ ] Create, update, delete, bulk, and retry bypasses were checked
- [ ] Direct DML leaves managed state coherent
- [ ] No private API or unexplained callback suppression is required
```

If a required line is no, **stop**. Move the rule or present the mismatch.

## Invariant map

Use this when two or more mutation surfaces share a rule:

| Invariant | Pure rule | Interactive path | Worker / admin path | Database backstop |
| --- | --- | --- | --- | --- |
| Example | normalized value | request validation | native job / form | unique constraint |

Mechanisms may differ. Meaning must not.

## Hard rules

- Inspect the exact framework path. A hook name is not lifecycle proof.
- Treat bulk update, bulk delete, upsert, direct SQL, and event suppression as
  separate paths until the pin proves otherwise.
- Persist the framework-owned object or refresh it fully. Do not patch selected
  fields from another persisted object.
- Keep relationship writes in the native relationship or cascade stage.
- Compare create and update fields: accepted, defaulted, normalized, immutable,
  preserved, and returned.
- Validate ordinary input before persistence. Keep database constraints as race
  backstops.
- Catch a failed savepoint outside that savepoint. Translate only a proven
  conflict. Re-raise the original error otherwise.
- Send external effects after commit, or persist intent in an outbox. Retried
  effects need a stable idempotency key.
- Name concurrency honestly. Serialization is not stale-write detection.
- Fakes prove caller logic. Production storage proves constraints, rollback,
  locks, ordering, collation, and generated values.
- Separate expand, backfill, verify, and contract. Inspect emitted and applied
  schema on every supported production backend.

## Concurrency claims

| Claim | Required proof |
| --- | --- |
| Serializes writers | lock is inside the transaction that writes |
| Prevents lost update | version or compare-and-swap rejects stale state |
| Keeps version monotonic | increment starts from locked or checked state |
| Makes action idempotent | desired state is checked after serialization |
| Handles insert race | database constraint is the final arbiter |

State whether residual behavior is last-write-wins, reject-stale, merge, or
retry.

## Checkpoint

For each vertical slice:

```text
Implementation checkpoint:
- [ ] Scope still matches the approved plan
- [ ] Framework seam passes
- [ ] Focused tests pass
- [ ] Production-backend gate passes where semantics differ
- [ ] Generated artifacts were inspected
- [ ] Tracker and sibling docs describe reality
- [ ] Diff contains no workaround chain
```

Run [sweeps.md](sweeps.md) before claiming the whole change complete.

## Stop conditions

- A private API is required to preserve the design.
- Callback suppression has no equivalent proven invariant and effect path.
- An ordinary input error first escapes after the public validation stage.
- One surface must impersonate another surface's policy or lifecycle.
- A lock is described more strongly than the anomaly it prevents.
- An error translator cannot prove the conflict.
- A worker would overwrite user-owned fields.
- Promised durable work can finish without durable terminal status.
- A fake is the only evidence for production storage behavior.
- A second workaround is needed to support the first.
- New evidence invalidates the plan.

Stop means report. Do not silently replace the approved design.

## LLM traps — never generate these

- “Best practice” without the repository pin and runtime path
- One service forced through UI, admin, CLI, worker, and migration lifecycles
- Private hooks that make hidden state fit a preferred abstraction
- A pessimistic lock called optimistic concurrency
- Every persistence error translated into the nearest friendly conflict
- A fake used as proof of SQL or race behavior
- A completion claim before the closure sweep
- More prose added to defend code that fights the framework

## Do not

- Copy a remedy from one framework into another.
- Generalize one incident into a universal ban.
- Restyle or rewrite unrelated code as part of a review.
- Revert, commit, push, or mutate data without authorization.
- Keep coding after a stop condition appears.
