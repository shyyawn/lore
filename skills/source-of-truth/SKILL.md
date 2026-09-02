---
name: source-of-truth
description: >-
  Generates, edits, and reviews which store writes a fact and which
  store a GET hits: one writer per fact, caches and projections only
  when they can answer every claimed read, dual-write only with an
  outbox. Use when the change is CQRS, projection, cache, dual-write,
  outbox, derived data, CDC, Redis+DB, Prisma+queue, workflow+table,
  or event+row; when the user mentions source of truth, system of
  record, query both, or an incomplete projection.
---

# Source of truth

One **writer** per fact. A GET of that fact hits one store. Do not
dual-write without an outbox.

Sources: Kleppmann DDIA (single-leader replication; derived data);
Kleppmann `2015/05/27/logs-for-data-infrastructure` (dual writes);
Helland CIDR 2005 Data on the Outside vs Inside, CIDR
2007 `cidr07p15` (no 2PC; at-least-once); Temporal
`design-patterns/entity-workflow`. Not CQRS folders. Not Anthropic
system-design.

Column types: `data-modeling`. Keys: `identity`. HTTP bodies:
`api-contracts`. Go `Save` + outbox: `go-ddd`. Column expand/contract:
`evolve-safely`.

## First step

1. Inventory what is already there. Honor it.

   Tables, Prisma / Drizzle models, Redis, queues, search indexes,
   Temporal workflows, caches, event rows, CDC / replica slots.
2. For each fact this change touches, name the **writer** and the GET
   store. If they are already one store, **stop** — stay there.
3. If a more specific skill already owns this, **stop**.

   | Detect | Follow |
   | --- | --- |
   | SQL types, blob vs child table | `data-modeling` |
   | Business-key shape, UUID default | `identity` |
   | HTTP 4xx vs 5xx body | `api-contracts` |
   | Rename / add column in one store | `evolve-safely` |
   | Go aggregate `Save` + outbox in one tx | `go-ddd` — this skill still owns whether a second store is earned |
   | Encore + Temporal seam | `encore-temporal-go-app-structure` (workflow never touches `sqldb`) |
4. Earn a second store (below). Tick yes on at least two, or stay on
   one writer and one GET.

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Writer | One store per fact | A second store ticked Earn |
| GET of that fact | That same store | A complete projection / cache that can answer every claimed read |
| Dual-write | **no** | Outbox (or one transactional writer) in the same commit |
| CQRS / second DB | **no** | The write model cannot answer the read without wrecking it |
| Cache / search / replica | Follow the leader log | It is already the complete GET store you named |
| Workflow + table | Workflow owns orchestration; table owns the business row | One of them is a projection of the other, with an outbox |

## Division of labor

| Artifact | Owner |
| --- | --- |
| Which store writes a fact; which store a GET hits | this skill |
| SQL / Prisma types, JSONB vs row | `data-modeling` |
| Natural key vs UUID vs idempotency key | `identity` |
| HTTP / RPC error bodies, status codes | `api-contracts` |
| Expand/contract of columns and JSON fields | `evolve-safely` |
| Who may read or write the row | `authz-boundaries` |
| Go `Save` + outbox in one tx | `go-ddd` |
| Encore `outbox.Bind` / `outbox` table | `encore-go` (`how-to/pubsub-outbox`) |
| Workflow vs `sqldb` on the seam | `encore-temporal-go-app-structure` |

## Earn a second store

Copy this checklist. Tick **yes** on at least two, or stay on one
store.

```
Earn a second store:
- [ ] A read cannot use the write store without wrecking it
- [ ] The second store can answer every read you will route there
- [ ] Dual-write has an outbox (or one transactional writer)
- [ ] A named query exists that only the second store serves
```

If every line is **no**, do not add Redis next to Postgres, a queue
next to Prisma, or a "read model" folder. Incomplete projection is
**not** CQRS. A cache that misses as not-found is a second writer
pretending to be a GET.

Wild Workouts introduced CQRS in a later refactor, not on day one.
Copy that order.

## Hard rules

- One writer per fact. Two handlers that `INSERT` the same noun are
  two writers.
- A GET of that fact hits **one** store. Do not query both and merge.
- A cache or projection is allowed only if it can answer every read
  you claim. Miss → the write store, or the read is not offered.
- Dual-write needs an **outbox** (same transaction as the write) or
  it is a bug. Publish-after-commit is dual-write. CDC / replica from
  the writer's log is following the leader — not a second writer in
  the handler.
- Derived stores take **no** writes. They follow the leader (outbox
  row, CDC, replication log).
- A business **no** (declined, closed, conflict) is stored data. It
  does not fail the process so the fact disappears.
- Delivery is at-least-once. Consumers are idempotent. A poison
  message goes to a dead-letter after N — it does not block the
  queue forever.

## Do not add

| Need | Use | Do not add |
| --- | --- | --- |
| Cache | Earn; miss goes to the writer | Redis `SET` in the same handler as the `INSERT` |
| Search | Outbox → index; existence GET stays the table | the index as source of truth |
| CQRS | Earn a second store | `read/` / `write/` folders |
| Async reaction | Outbox, or a Temporal workflow | `Publish` after `Save` |
| Dual-write fix | Outbox / CDC from the leader | XA / 2PC across DB and broker |
| Encore + Temporal | seam; workflow never touches `sqldb` | both writing the same column |

## Default shapes

| Shape | Writer | GET |
| --- | --- | --- |
| One table / one Prisma model | that row | that row |
| Cache in front | the table | the cache only when complete; else the table |
| Projection | write store + outbox | the projection, only for queries it covers |
| Search index | the table via outbox | search queries; existence/GET still the table |
| CDC / replica | the leader table | consumers of that log, for queries they cover |
| Temporal entity workflow | workflow for orchestration state; table for the business row | each GET names one of those, not both |
| Event + row | the row; event is derived | the row (or a complete projection of the event) |

Ideas, not trees. Do not add `write/` / `read/` folders to earn this.

## Failure as data

| Outcome | Store | Do not |
| --- | --- | --- |
| Declined / rejected | a row or event with that outcome | crash the handler so the attempt is gone |
| Already closed / conflict | a conflict or closed status | crash so the close is lost |
| Duplicate at-least-once | idempotent upsert / ignore | a second insert that forks the fact |
| Poison message | dead-letter after N | retry forever on the hot queue |

The process stays up. The fact records the no.

## After every edit

Name the writer and the GET store for each fact you touched. A second
store that did not tick Earn is deleted or demoted to a cache with an
explicit miss path.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| GET sometimes Redis, sometimes the DB | two sources. Pick one |
| Cache miss returned as not-found | incomplete projection treated as truth |
| Consumer missed the event | publish after commit. Outbox |
| Declined payment is a 500 | failure as process crash, not data |
| Poison message blocks the queue | no dead-letter / no idempotent consumer |
| Handler writes Postgres and Redis | dual-write without an outbox |
| "CQRS" folder, same model twice | did not earn. One store |
| Workflow and table disagree on the same field | two writers. Name one |
| DB and Kafka "fixed" with XA | 2PC across stores. Outbox |

## LLM traps — never generate these

- Redis + DB both written in the handler
- Query both and merge
- CQRS / `read/` / `write/` folders on the first endpoint
- Elasticsearch GET for "does this exist" when the index is incomplete
- `eventual consistency` as cover for two writers
- Publish after `Save` as the reliable path
- A business no as an unhandled error that rolls back the fact
- Infinite retry of a poison payload
- Anthropic system-design QPS theater; CQRS because a blog said so
- Hexagonal `domain/` + a second DB to look like CQRS
- Temporal workflow and `sqldb` both updating the same column
- XA / two-phase commit across Postgres and the broker
- CDC in the handler *and* a Redis `SET`

## Do not

- Restyle a working one-store design into CQRS as a drive-by.
- Skip Earn because the user said "add a cache".
- Recopy `data-modeling` types or `api-contracts` error bodies here.
- Teach a CQRS folder schema (ideas, not trees).
