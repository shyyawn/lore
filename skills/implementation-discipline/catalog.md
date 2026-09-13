# Implementation failure catalog

Match the symptom, verify it in the current stack, then apply the correction.

## Planning and abstraction

| Pattern | Failure | Correction |
| --- | --- | --- |
| Comprehensive one-shot | breadth hides unfinished seams | checkpoint one vertical slice at a time |
| Detailed plan treated as proof | prose outruns runtime behavior | verify lifecycle and generated artifacts |
| New evidence, old plan | probe becomes commentary only | revise the affected decision immediately |
| “One write path” | every surface is forced through one API | share invariants; keep orchestration native |
| Actor and explicit owner fused | customer authorization leaks into admin or jobs | separate actor-scoped policy from owner-explicit operation |
| Second fix supports first fix | workaround chain becomes architecture | stop and move the invariant to the right seam |
| Required gate outside CI | manual evidence decays | automate it or call it manual |

## Lifecycle and persistence

| Pattern | Failure | Correction |
| --- | --- | --- |
| Error raised from late save hook | expected input becomes a server error | detect it at public validation boundary |
| Related lifecycle skipped | associations, cascades, or callbacks disappear | use the normal related-write path |
| Private validation override | upgrade-fragile hidden-field trick | validate cross-field state explicitly |
| Alternate object persisted | framework instance remains stale | persist it or fully refresh authoritative state |
| Single-record path only | bulk, delete, import, or quiet paths bypass rules | inventory every mutation primitive |
| Create reviewed alone | update fields behave differently | diff create and update field-by-field |
| Claimed hoist without search | old caller or duplicate helper survives | search old symbols and behavior |
| Fake proves persistence | fake semantics differ from SQL | add a real-store contract test |

## Concurrency and errors

| Pattern | Failure | Correction |
| --- | --- | --- |
| Lock called stale protection | old input still overwrites new state | submit and compare a version |
| Version increment from stale state | versions collide or regress | increment from locked or checked state |
| Savepoint caught too early | transaction remains unusable | catch outside the failed inner boundary |
| No-op changes representation | ETag or timestamp changes without semantics | bump consistently or skip persistence |
| Broad integrity translation | unrelated corruption looks friendly | prove expected conflict; otherwise re-raise |
| Backend message parsing | messages and constraint labels differ | prefer structured metadata or exact state query |
| Race path only | ordinary validation fails differently | cover validation and database arbitration |
| Long work under request context | success cannot be recorded after cancellation | transfer ownership to a durable job deliberately |

## Data and time

| Pattern | Failure | Correction |
| --- | --- | --- |
| Range checked before narrowing | destination integer still overflows | validate destination range first |
| Timestamp-only ordering | equal keys duplicate or vanish | add a unique tie-breaker and test page two |
| Oldest-first capped feed | new work is permanently excluded | newest-first or durable cursor / watermark |
| Refetch overwrites owner edits | retry destroys newer user state | update only producer-owned fields |
| Create/update asymmetry | rule applies only at birth or edit | compare accepted, defaulted, normalized, preserved |
| Local and database time mixed | rows move across boundaries | use explicit UTC/session policy and test conversion |

## Transactions and effects

| Pattern | Failure | Correction |
| --- | --- | --- |
| Annotation assumed active | call never crosses proxy/interceptor | verify actual call path and boundary |
| Callback sends before commit | consumer observes state that rolls back | after-commit dispatch or transactional outbox |
| After-commit failure treated as rollback | database already committed | persist retry intent and surface delivery failure |
| Bulk DML with managed objects | in-memory state contradicts database | clear, refresh, or isolate persistence context |
| Callback queries arbitrary state | ordering and flush timing become nonportable | move orchestration to a service boundary |

## Backend, migration, and operations

| Pattern | Failure | Correction |
| --- | --- | --- |
| ORM type assumed from name | backend maps it differently | inspect generated type and DDL |
| Model state treated as schema | applied default or collation differs | inspect database metadata |
| Contract ships behind expand | ordinary deploy skips backfill | preflight and targeted rollout |
| Hyperscale tool proposed early | complexity replaces measurement | measure first |
| Fast backend proves locks | test backend may omit semantics | run the production-backend gate |
| Ambient target | routine command mutates wrong environment | require and display exact target |
| Machine fact becomes docs | durable truth goes stale | keep observations in dated investigation |

## Review and completion

| Pattern | Failure | Correction |
| --- | --- | --- |
| Explain before inspect | confident story anchors review | read exact diff and runtime path first |
| Review moving files as final | findings race the writer | snapshot commit and worktree state |
| Minor edge drives redesign | scope grows without user value | rank by impact and probability |
| “All fixed” after prose | implementation retains old seam | verify code and behavior |
| Rule exists only in docs | no enforcement point exists | name function, constraint, and test |
| Sibling defect ignored | same bug survives nearby | search by defect class |
| Swallowed error | failure has no state or signal | return, persist, metric, or structured log |
