---
name: go-ddd
description: >-
  Reviews and rewrites Go when the domain has invariants worth protecting
  (DDD Lite: aggregates, value objects, domain events, repositories as
  collections). Use when the user mentions DDD, aggregate, bounded context,
  ubiquitous language, domain events, or CQRS; not for CRUD endpoints.
  Overlay on go-backend. Default is no — earn the aggregate first. Encore
  bounded context = service package.
---

# Go DDD Lite 2026

Rich domain only. Default is **no**. Internals and flatten layout:
`go-backend`. Language: `go-idioms`. Tests: `go-unit-tests`. Encore
service = bounded context: `encore-go-app-structure`. Patterns:
[lite.md](lite.md).

Sources: Three Dots Labs Wild Workouts and the **DDD Lite** articles
(aggregates, value objects, domain events, repositories). Not their
`app/` / `domain/` / `adapters/` trees, Watermill, Firebase, or Cloud Run.

## First step

1. Read `go.mod` / `encore.app`. Match the package that is already there.
2. Run the earn checklist below. If every line is "no", stop and stay on
   `go-backend`.
3. Put new types **in that package** (or a sub-package without APIs). Do
   not add hexagonal folders on a greenfield app.

## Earn an aggregate

Copy this checklist. Tick **yes** on at least two, or stop.

```
Earn DDD Lite:
- [ ] Two+ fields must change together or the entity is invalid
- [ ] A rule HTTP/SQL would forget (capacity, already-cancelled, paid-twice)
- [ ] Identity that outlives a single request
- [ ] Another package must react without importing this one (domain event)
- [ ] Read model has actually diverged from the write model (CQRS — later)
```

CRUD with required-field validation is **not** an aggregate. A struct
with getters is not DDD. A folder named `domain` is not a bounded context.
The same service may mix a CRUD corner and one aggregate. Do not DDD the
CRUD to look consistent.

## DDD Lite (do these)

| Pattern | Meaning in Go |
| --- | --- |
| Bounded context | Encore **service**, Temporal subsystem, or `internal/<noun>` that compiles without `net/http` |
| Aggregate | One type whose methods are the only way to mutate a cluster. Unexported fields when an invariant exists. Constructor `NewX` returns `X, error`. Methods named in the ubiquitous language (`Cancel`, not `SetStatus`) |
| Value object | `Money`, `Email`, `ItemID` — equal by value, no identity, invalid states unrepresentable |
| Repository | Collection of **aggregates**: `Get` / `Save`. Not `Store[T]`, not per-column setters. sqlc rows map here, they do not leak |
| Domain event | A **value returned** from the method that caused it (`(Event, error)`; `nil` event = nothing). No bus inside the aggregate |
| Application / command | Encore API or `go-backend` handler: load → call method → `Save` (aggregate + outbox, one tx). No rules here |

Full shapes: [lite.md](lite.md).

## Do not reach for (yet)

| Skip | Until |
| --- | --- |
| CQRS, two models, separate read DB | A query cannot be answered from the write model without wrecking it |
| Process manager / saga class | You already have Temporal workflows (`temporal-go`) or a real multi-step process |
| Event bus for in-process calls | A function call still works |
| Hexagonal `domain/` `usecase/` `adapter/` | The repo already has them, or an import cycle forced a port |
| Shared `internal/common` kernel | Duplicate a 10-line `Email` before coupling two contexts |
| Aggregate per table | Tables that always change together stay one aggregate |

Wild Workouts introduced CQRS in a **later** refactor, not on day one.
Copy that order.

## Where it lives

```
# Encore — still one service package
trainings/
  trainings.go           # //encore:api: load, call, save
  training.go            # aggregate + VOs + events
  store.go               # Get/Save the aggregate
  migrations/

# Plain Go
internal/training/
  training.go
  store.go
```

The domain file must not import Encore, `net/http`, SQL drivers, or a
logger. Persistence maps `ErrNotFound`; it does not decide "can cancel".

## Review workflow

```
Go DDD Lite:
- [ ] Earn checklist passed — else revert to go-backend
- [ ] Mutation only through aggregate methods; NewX validates
- [ ] VOs for money/IDs/status with rules; integer cents, not float
- [ ] Repository Get/Save of the aggregate, not CRUD of rows
- [ ] Events are values **returned** from methods; Save persists aggregate + outbox in one tx
- [ ] Consumers of events are idempotent (at-least-once)
- [ ] Bounded context = existing service / internal/<noun>, not new folders
- [ ] No CQRS unless read/write models already diverged
- [ ] encore.app → no cmd/, no adapters/ tree, no Watermill
```

## LLM traps — never generate these

- Hexagonal trees on a greenfield Encore or `go-idioms` module
- Anemic "entity" (`SetStatus`, exported fields, no constructor check)
- `type Repository[T any] interface { Get, List, Update, Delete }`
- Domain package importing `encore.dev`, `database/sql`, or `net/http`
- Event bus / Watermill / NATS for a call in the same process
- Publishing after `Save` as the reliable path (dual-write). Outbox in the same tx
- Clock interfaces on 1.25+ just to freeze time — `testing/synctest`
- Returning sqlc row types as the aggregate
- CQRS + separate read DB on the first endpoint
- Copying Wild Workouts `internal/common` or Firebase auth
- Getters/setters for DDD flavour (`go-100-mistakes-avoid` #4)
- A second Encore service so two services share the aggregate's tables

## Do not

- Load this skill for a health check, CRUD list, or config change.
- Duplicate `go-backend` handler/shutdown recipes or `encore-go` primitives.
- Restyle a working flat service into DDD as a drive-by.
- Teach Evans encyclopedia (sagas, anti-corruption layers, event sourcing)
  unless the repo already has them.
