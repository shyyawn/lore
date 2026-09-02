---
name: data-modeling
description: >-
  Generates, edits, and reviews logical database schemas: one fact one
  type, table vs blob vs junction, a named query or GENERATED or earned
  denorm. Use when the change is schema, CREATE TABLE, Prisma, Drizzle,
  TypeORM, jsonb, Json, JSON, json_extract, jsonb(), GENERATED, VIRTUAL,
  STORED, timestamptz, denormalization, many-to-many, or junction; when
  the user mentions EAV, parent_type, UserProfile, or a JSON array of
  children.
---

# Data modeling

Logical **schema**. One fact, one type. Do not store a list you filter
as a JSON blob.

Sources: Karwin SQL Antipatterns (Jaywalking, EAV, clone tables,
polymorphic associations); Postgres `datatype-json`,
`ddl-generated-columns` (18: VIRTUAL is the default — do not bump);
Prisma schema (`Json` is not a relation). Not an index cookbook. Not
EXPLAIN / vacuum / pool size.

Column types by pin: [types.md](types.md). Writer of the row:
`source-of-truth`. Business key on the wire: `identity`. Roll-forward:
`evolve-safely`.

## First step

1. Inventory what is already there. Honor it.

   `CREATE TABLE`, Prisma / Drizzle / TypeORM schema, migrations,
   `GENERATED` columns, unique constraints, FKs, `jsonb` / `Json` /
   `JSON` / SQLite `json_*` / `jsonb()` / Mongo embeds.
2. Read the **pin**. Do not bump it.

   Postgres / MySQL / SQLite version, Prisma `provider`, the types
   already in the schema.
3. If a more specific skill already owns this, **stop**.

   | Detect | Follow |
   | --- | --- |
   | Who writes the row; second store; outbox | `source-of-truth` |
   | Business-key shape, UUID default, idempotency key | `identity` |
   | Add / rename / drop that must not break old binaries | `evolve-safely` |
   | HTTP field names, pagination | `api-contracts` |
   | Who may read or write | `authz-boundaries` |
4. Name each fact. One type. Derived values: a named query,
   `GENERATED` per pin ([types.md](types.md)), or Earn denorm.
5. Name cardinality. 1:1 stays a column. 1:n is a table. m:n is a
   junction. A sealed snapshot ([types.md](types.md)) only if you GET
   it **whole**.

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Fact | One column, one type ([types.md](types.md)) | Existing type works — fill gaps, do not restyle |
| Derived | Named query, or `GENERATED ALWAYS` per pin | Earn denorm (below) |
| Nested blob | **no** (child table) | Sealed snapshot you GET whole and never filter |
| 1:1 extra table | **no** | The child has its own key, lifecycle, or writer |
| Many-to-many | Junction table | Implicit Prisma `A[]` / `B[]` already works |
| Key | Natural `UNIQUE` | Surrogate extra when the natural key is wide or will change |
| Join | `FOREIGN KEY` | Existing schema has no FK and you are not adding tables |
| Instant | `timestamptz` | Clock-less calendar period (`date`, month) |
| Money | integer minor units or `numeric` | — |
| Null | unknown or not-yet | A real domain value — use a type that names it |
| Lists / EAV | Child table | Sealed snapshot (same blob rule) |

## Division of labor

| Artifact | Owner |
| --- | --- |
| Logical schema; column types; blob vs row vs junction | this skill |
| One writer; GET store; outbox | `source-of-truth` |
| Natural vs surrogate on the wire | `identity` |
| Expand/contract, dual-write a column, rollback | `evolve-safely` |
| HTTP / RPC JSON fields | `api-contracts` |
| Tenant in the query | `authz-boundaries` |
| Go store mapping, sqlc rows | `go-backend` |
| Encore `sqldb` migrations as files | `encore-go` |

## Earn a denormalized column

Copy this checklist. Tick **yes** on at least two, or stay on a query
or `GENERATED`.

```
Earn denorm:
- [ ] A named query exists that only this copy serves
- [ ] One writer (source-of-truth)
- [ ] GENERATED / a view cannot do it
- [ ] The join is a measured hot path, not a guess
```

If every line is **no**, do not copy `status` onto the parent, cache a
count on the row, or keep a comma-separated list "for speed". Denorm
without one writer is dual-write — `source-of-truth`.

## Hard rules

- One fact, one type. A second column that means the same fact is
  denorm — earn it.
- Derived columns need a named query only they serve, or
  `GENERATED ALWAYS` per pin ([types.md](types.md)), or an earned
  denorm with **one** writer.
- A sealed snapshot ([types.md](types.md)) is a blob you GET
  **whole**. Rows if you filter, page, or update a child. Postgres
  `jsonb` is not Prisma `Json`, not MySQL `JSON`, not SQLite
  `jsonb()`.
- Many-to-many is a **junction**. Not an array of ids.
- Two parent kinds: two nullable FKs, or two tables. Not
  `parent_type` + `parent_id`.
- Natural key gets `UNIQUE`. `FOREIGN KEY` for joins. A surrogate is
  extra, not the only uniqueness.
- Null is unknown or not-yet. Not false. Not a sentinel. Two meanings
  of null → split the column or name the state.
- Instants are `timestamptz`. A calendar period is `date` or month.
  Money is int minor units or `numeric`. Not `float`.
- A repeating child is a **table**. Not EAV. Not a JSON array you
  `WHERE`.

## Default shapes

| Need | Shape |
| --- | --- |
| Attribute of the entity | column on that table ([types.md](types.md)) |
| Optional 1:1 | nullable column on the entity |
| Child you filter / page / patch | table + FK to parent |
| Many-to-many | junction table + FK to both |
| Two parent kinds | two nullable FKs, or two tables |
| Snapshot you GET whole | pin's blob type ([types.md](types.md)) |
| Derived, deterministic | `GENERATED ALWAYS` per pin ([types.md](types.md)) |
| Derived, earned | extra column, one writer, named query |
| Tree / bill-of-materials | child table with parent FK; not `parent_id` JSON |
| Known attributes as keys | columns. Not EAV rows |

Ideas, not trees. Do not invent `entities` / `attributes` / `values`.

## Do not add

| Need | Use | Do not add |
| --- | --- | --- |
| Filter a child | child table | JSON blob you `WHERE` |
| Many-to-many | junction table | `Json` / `text[]` of foreign ids |
| Optional 1:1 | nullable column | `UserProfile` on day one |
| Child of two parents | two FKs or two tables | `parent_type` + `parent_id` |
| Optional known field | nullable column, or a type that names absence | EAV |
| Speed | Earn denorm, or an index later | a copied column on day one |
| Money | integer cents / `numeric` | `float` / `double` |
| Instant | `timestamptz` | `timestamp` without time zone |
| Prisma nested data | relation. `Json` only if sealed | `Json` as a fake FK |
| Postgres 18 VIRTUAL | honor the pin; `STORED` if you index it | bumping Postgres to unlock VIRTUAL |

## After every edit

Each new fact has one type. Blob fields you filter become tables.
m:n without a junction becomes a junction. A denorm that did not tick
Earn is a query or `GENERATED` instead.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| `WHERE` inside `jsonb` / `Json` / `JSON` / `json_extract` | child table. Not a snapshot |
| Both sides store id arrays | missing junction |
| Can't put a real FK on the parent | `parent_type` + `parent_id`. Two FKs or two tables |
| `User` + `UserProfile`, same lifecycle | unearned 1:1 split |
| Two columns for one fact | unearned denorm, or forgot `GENERATED` |
| Null means three things | split the column; name the state |
| Money is off by 0.01 | `float`. Integer minor units |
| Duplicate natural id | no `UNIQUE` on the business key |
| Orphan child | missing FK |
| Prisma `Json` used as a relation | `Json` is not a relation |
| SQLite `jsonb()` bytes in Postgres | different formats. Do not copy |
| Migration locked old binaries | that is `evolve-safely`, not a type change |

## LLM traps — never generate these

- JSON array of children you filter, page, or patch
- `Json` / `Int[]` / `text[]` of foreign ids for many-to-many
- `parent_type` + `parent_id` with no FK
- `UserProfile` / `AccountDetails` 1:1 table on the first schema
- EAV (`key`, `value` rows) for known attributes
- Comma-separated lists in a `text` column
- `float` / `double` for money
- `timestamp` without time zone for an instant
- UUID as the only uniqueness for a one-per-natural-id entity
- Clone columns (`year_2024`, `year_2025`)
- Prisma `Json` with a fake `id` inside you join on
- SQLite `jsonb()` BLOB copied into Postgres `jsonb`
- Prisma `@db.Json` on Postgres when you meant `jsonb`
- `GENERATED … VIRTUAL` on Postgres 17 and below
- Index / EXPLAIN / vacuum / pool-size cookbook as this skill
- Hexagonal `domain/` tables to match folders
- Dual-write of a denorm with no writer named

## Do not

- Restyle a working schema into a JSON blob or EAV as a drive-by.
- Skip Earn because the user said "denormalize for speed".
- Recopy `source-of-truth` writers or `identity` key strings here.
- Teach an index cookbook or EXPLAIN.
- Bump the database or ORM pin to unlock a type.
