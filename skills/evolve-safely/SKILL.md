---
name: evolve-safely
description: >-
  Generates, edits, and reviews schema and API change so old binaries
  keep working: expand/contract, dual-write then read then drop, roll
  forward and back. Use when generating, editing, or reviewing
  migrations, add column, rename field, ALTER TYPE, SET NOT NULL,
  AutoMigrate, API v2, rollback, or expand-contract.
---

# Evolve safely

Expand, then contract. Roll **forward** and back. Do not lock the
table in a way that breaks old binaries.

Sources: Fowler `bliki/ParallelChange`; Prisma Data Guide
`types/relational/expand-and-contract-pattern` (the pattern, not
their CLI); AIP-180, AIP-185 (`v1` in the path); Postgres
`ddl-generated-columns`, `sql-altertable` Notes; MySQL 8.4
`create-table-generated-columns`, `innodb-online-ddl-operations`.
Not a migrator encyclopedia.

Additive wire: `api-contracts`. Types: `data-modeling`. Two stores:
`source-of-truth`. sqlc mapping: `go-backend`.

## First step

1. Inventory what is already there. Honor it.

   golang-migrate / goose / atlas / Encore `sqldb`, sqlc / sqlx /
   pgx queries, GORM, Drizzle / Prisma if present, expand already
   in flight, API versions, dual-written columns, `.proto`.
2. Read the **pin**. Do not bump it.

   Database (Postgres / MySQL / SQLite), the migrator already there,
   existing API version scheme.
3. If a more specific skill already owns this, **stop**.

   | Detect | Follow |
   | --- | --- |
   | New optional JSON field, no rename | `api-contracts` (additive) |
   | New type / JSONB vs table on a greenfield | `data-modeling` |
   | Two stores for one fact | `source-of-truth` |
   | Business-key rename | `identity` + this skill |
   | sqlc / `pgxpool` mapping | `go-backend` (sequence stays here) |
4. Name the old binary and the new binary. Every step must be safe if
   you **roll back** the new one.
5. Expand/contract (below). Earn API v2. Do not rename in place.

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Add column | nullable or with a non-volatile default; old binaries ignore it | — |
| Rename column / JSON field | expand (add new) → dual-write → switch read → drop old | existing name stays |
| Type of a live column | new typed column; dual-write | binary-compatible widening the pin already no-ops |
| NOT NULL | backfill, then constrain | — |
| Unique / FK / CHECK | pin's online add (below) | existing blocking add and you are not adding the constraint |
| Index on a live table | pin's online index (below) | — |
| Drop | after no binary reads it | — |
| API change | additive field (`api-contracts`) | Earn v2 (below); honor an existing version pin |
| Same name, new meaning | new field (AIP-180) | — |
| Default (column or omitted JSON) | write the new value explicitly | — |
| Migration runner | the one already there | — |
| ORM AutoMigrate / schema push | **no** on a live DB | empty greenfield, or that is already production |
| Client name only | remap queries / `@map` | column itself must move — expand/contract |
| Lock / rewrite table | **no** | you measured, and old binaries still work |
| Dual-write a column | both columns, same transaction | outbox if the copy is another store (`source-of-truth`) |

sqlc / sqlx / pgx are **readers**. Expand the SQL the same way as
the column. Do not invent a second migrator.

## Pin strings

Inventory the database. Do not copy one engine's DDL onto another.

| Pin | Online add / index | Rewrite that breaks old binaries |
| --- | --- | --- |
| Postgres | nullable add; non-volatile `DEFAULT`; `CREATE INDEX CONCURRENTLY`; `NOT VALID` then `VALIDATE CONSTRAINT` | `SET DATA TYPE`; volatile `DEFAULT`; `GENERATED … STORED`; `ACCESS EXCLUSIVE` scan. Rewrites are not MVCC-safe (`sql-altertable` Notes) |
| MySQL 8.0.12+ / 8.4 | `ALGORITHM=INSTANT` add (default 8.0.12+); `LOCK=NONE` when `INPLACE` allows concurrent DML | `ALGORITHM=COPY`; changing data type; `GENERATED … STORED` add is not in-place (`innodb-online-ddl-operations`, `alter-table-generated-columns`) |
| SQLite | add a nullable column | most other `ALTER` rebuilds the table |

Do not bump the pin to unlock `INSTANT` or Postgres 18 VIRTUAL.

## Division of labor

| Artifact | Owner |
| --- | --- |
| Expand/contract sequence; rollback safety | this skill |
| Additive new field, 4xx vs 5xx | `api-contracts` |
| Types, JSONB vs row | `data-modeling` |
| One writer when the copy is a second store | `source-of-truth` |
| Encore `sqldb` file layout | `encore-go` |
| sqlc / pgx mapping | `go-backend` |
| Public key string | `identity` |

## What this skill owns

| Own | Leave |
| --- | --- |
| Expand → dual-write → read new → contract | Type choice (`data-modeling`) |
| Roll forward *and* back; no lock that breaks old binaries | Error envelope (`api-contracts`) |
| Earn API v2 | Dual-write of two stores (`source-of-truth`) |

## Hard rules

- Expand first. Contract last. Never rename / drop / `NOT NULL` /
  change type in the same step the new binary ships.
- Dual-write the **new** column, then read it, then drop the old.
  Same transaction when both columns are one store.
- Every migrate-up must be safe with the **old** binary still running.
  Every migrate-down (or binary rollback) must be safe with the new
  schema.
- Do not lock or rewrite the table in a way that breaks old binaries.
  Name the pin's strings (above).
- Change on the wire is additive until you Earn v2. Expand/contract
  the JSON the same way as a column. Do not change a default or a
  field's meaning in place (AIP-180).
- Proto: `reserved` the old number. Never reuse a tag
  (`protobuf.dev/best-practices/dos-donts`).
- A feature flag is not a backfill. Dual-write stored columns
  anyway.

## Expand / contract

Numbered. Do not skip a step.

1. **Expand.** Add the new column or JSON field. Nullable or a
   non-volatile default. Old binaries ignore it.
2. **Backfill.** Write the new fact for old rows. Online, batched.
   Do not lock the table.
3. **Dual-write.** New binaries write old and new. One transaction.
4. **Read new.** Switch readers to the new field (sqlc / sqlx /
   pgx queries too). Old binaries still write the old one.
5. **Stop writing old.** Only after every binary is new.
6. **Contract.** Drop the old column or stop sending the old JSON
   field. This is a new deploy, not step 1.

Roll back: if you abort at 3 or 4, the old binary still reads the old
field. If you already dropped (6), you cannot roll the old binary
back — restore first.

## Earn API v2

Copy this checklist. Tick **yes** on at least two, or stay on v1
plus expand/contract.

```
Earn API v2:
- [ ] Expand/contract cannot keep old clients working
- [ ] Two representations cannot coexist on one URL
- [ ] A shipped client cannot be updated in lockstep
```

If every line is **no**, do not add `/v2`. Additive fields and
parallel JSON names are cheaper. Honor `/v1`, a date pin, or a
protobuf package already there.

## Default shapes

| Change | Expand | Contract |
| --- | --- | --- |
| Rename column | add `new`; dual-write; read `new` | drop `old` |
| Rename JSON field | send both names | stop sending `old` |
| Required field | add optional; backfill | then require |
| Split column | add pieces; dual-write | drop original |
| Merge columns | add combined; dual-write | drop pieces |
| Change column type | add `new` typed column; dual-write | drop `old` — not `SET DATA TYPE` / `MODIFY` / `USING` while old binaries run |
| Enum label | `ADD VALUE`; rename = new label + dual-write | drop old label |
| Proto field | new number; `reserved` the old | never reuse the number |
| Client-only rename | remap sqlc / queries / `@map` | leave the column |
| `GENERATED` add | MySQL: VIRTUAL is already the default. Postgres 17: `STORED` (rewrite). Postgres 18: VIRTUAL default, no rewrite; `STORED` rewrites — do not bump | `STORED` when you will index / filter it (`data-modeling`) |

Honor the migrator already there. `VERSION` in a migration name,
never `latest`. Do not dump that migrator's command list here.

## Do not add

| Need | Use | Do not add |
| --- | --- | --- |
| Rename | expand/contract | `ALTER … RENAME` while old binaries run |
| Type change | expand/contract | in-place type rewrite while old binaries run |
| Unique on live data | pin's online add | a blocking unique that rewrites / exclusive-locks |
| API break | Earn v2 | `/v2` as fashion |
| Second store copy | `source-of-truth` outbox | dual-write two databases in the handler |
| Migrator | the one already there | a second one; AutoMigrate next to migrate files |
| Client-only rename | remap queries / `@map` | a column rename to match the client |
| Proto delete | `reserved` | reuse the field number |

## After every edit

Name the old binary. If it would error on this migration, split the
step. A drop, `NOT NULL`, or type change without a backfill is undone.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| Old binary 500s after migrate | contracted too early, or `NOT NULL` with no default |
| Rollback failed | dropped a column the old binary reads |
| Two columns diverge | dual-write skipped, or two writers (`source-of-truth`) |
| Table locked / app timed out | rewrite (`COPY`, `SET DATA TYPE`, volatile default). Add a column instead |
| Concurrent reads see an empty table | Postgres rewrite (`sql-altertable` Notes). Split the step |
| `/v2` on a rename | did not earn. Expand/contract the field |
| sqlc still selects `old` after contract | readers were not migrated in step 4–5 |
| AutoMigrate dropped / renamed a live column | ORM push is not expand/contract |
| `CREATE INDEX CONCURRENTLY` failed in the migrate | it cannot run inside a transaction. Customize the migration |

## LLM traps — never generate these

- `ALTER TABLE … RENAME` while old binaries run
- `SET DATA TYPE` / `MODIFY` / `USING` on a populated live column
- `NOT NULL` on a populated table with no default and no backfill
- Drop column in the same PR that ships the new reader
- `/v2` because a field changed name
- Table rewrite (`COPY`, `ACCESS EXCLUSIVE` scan) as the default
- GORM `AutoMigrate`, Prisma `db push`, Drizzle `push` on a live DB
- Dual-write two databases without an outbox
- Reusing a protobuf field number
- Changing a JSON default while clients omit the field
- Feature-flag the reader with no dual-write
- A migration encyclopedia (Flyway, Liquibase, Atlas, Prisma CLI)
  as this skill
- `latest` in a migrate command the agent will run

## Do not

- Restyle a working v1 into `/v2` as a drive-by.
- Skip expand because the user said "just rename the column".
- Recopy `api-contracts` envelopes or `data-modeling` types here.
- Teach a migrator encyclopedia.
