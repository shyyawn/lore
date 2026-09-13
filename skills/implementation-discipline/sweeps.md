# Implementation closure sweeps

Run after the narrow implementation works. Record **pass**, **not applicable**,
or a finding for every applicable row.

## Claims and enforcement

| Question | Evidence |
| --- | --- |
| What makes each documented rule true? | exact enforcement path |
| What fails if enforcement disappears? | behavioral test name |
| Does “all”, “only”, “central”, or “never” appear? | search for exceptions |
| Does implementation still match the plan? | claims compared with callers |
| Did status move only after gates passed? | gate output and current diff |

Rewrite an inaccurate claim instead of distorting code to preserve it.

## Path matrix

Compare paths field-by-field. Do not infer symmetry from shared names.

| Path | Check |
| --- | --- |
| Create | accepted fields, defaults, normalization, ownership, timestamps |
| Full update | replacement, immutable fields, validation, version |
| Partial update | omitted fields preserved; stale related data not replayed |
| Delete | dependent rows, versions, audit, cache, and external effects |
| Bulk / admin / import | invariants through that surface's native lifecycle |
| Retry / second run | no duplicate, reversal, or newer-state overwrite |
| Failure then retry | transaction and job context remain usable |

After a hoist, search for the old helper, direct persistence, and every former
caller. “All callers migrated” needs a zero-result search or exception list.

## Lifecycle bypasses

Search the pinned stack for primitives that skip normal behavior:

- bulk update, bulk delete, upsert, direct SQL;
- quiet save, event suppression, validation bypass;
- callbacks, observers, interceptors, and repository defaults;
- cascades, association writes, and join-table persistence;
- managed-object refresh after direct or bulk DML.

For every use, list which validations, events, timestamps, versions, cascades,
and in-memory state updates still happen. Never guess from the method name.

## Ordered and bounded data

- Trace page one, an insertion or deletion, then page two.
- Add a stable unique tie-breaker to non-unique ordering keys.
- Test equal timestamps and equal names.
- For capped feeds, ask whether oldest-first permanently excludes newer work.
- Validate integer conversions against the destination type before narrowing.

## Repetition and ownership

Ask who owns every field written by an updater, synchronizer, worker, or upsert.

| Situation | Required decision |
| --- | --- |
| Producer reruns | which fields may it rewrite? |
| User edits after import | which values must it preserve? |
| Refetch after conflict | merge, replace, or reject? |
| Idempotent action | desired state or unsafe toggle? |
| Partial failure | retry unit and durable progress marker? |

Do not let a producer overwrite owner-managed fields merely because its create
payload originally populated them.

## Time, cancellation, and effects

- Trace request, transaction, worker, and external-call deadlines separately.
- If durable work promises terminal status, ensure cancellation cannot erase
  the status write.
- Let work outlive a request only through deliberate, bounded ownership
  transfer.
- Verify database and session timezone behavior against the application policy.
- Test daylight-saving ambiguity when local civil time is a domain input.
- Confirm external effects occur after commit or through a durable outbox.
- Define retry behavior when the database committed but delivery failed.
- Give retried effects a stable idempotency key; state whether delivery is
  at-least-once or effectively-once at the consumer boundary.
- Every ignored error needs durable state, a return value, metric, or log.

## Real semantics

Fakes prove caller logic. They do not prove storage behavior. Use every
production backend the repository supports to prove applicable constraints,
rollback, locks, collation, ordering, pagination, `NULL`, upsert conflicts,
database time, and generated values.

If a backend-specific test is called required, CI or a protected release gate
must invoke it. Otherwise label it manual and name who runs it.

## Operational target

Before a persistent, shared, destructive, or production-capable mutation,
record:

```text
Target:
- environment / account:
- database / namespace / project:
- exact command:
- expected affected rows/resources:
- dry-run or preview result:
- recovery path:
- confirmation required:
```

Never let a generic environment file, ambient credential, current CLI context,
or default namespace silently choose a production-capable target.

## Documentation closure

Update the README, setup guide, decision record, implementation plan, tracker,
examples, environment templates, CI workflow, and release runbook wherever the
change affects them.

Keep machine-specific versions, cache contents, row counts, and personal paths
out of durable project truth unless it is a dated investigation.

Finish by searching sibling functions, alternate entry points, bulk paths, and
the next abstraction layer for the same defect class. Fix repeats only when
they fit the approved scope. Report the rest.
