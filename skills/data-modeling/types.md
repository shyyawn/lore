# Column types

Gate on the database and ORM you have. Do not bump Postgres, SQLite,
Prisma, or MySQL to unlock a type.

The **rule** is sealed snapshot vs child table. The type **name**
changes with the pin.

## Sealed snapshot (GET whole)

Same rule as SKILL.md. Filter, page, or patch a child → a table (or a
Mongo collection), not a blob.

| Pin | Use | Not |
| --- | --- | --- |
| Postgres | `jsonb` | `json` unless you must keep byte-exact text (whitespace, key order, duplicate keys) |
| Prisma `Json` | `Json` — connector maps it (PG → `jsonb`, MySQL → `JSON`, SQLite → JSONB, Mongo → BSON, Cockroach → `JSONB`) | `Json` as a relation; `@db.Json` on Postgres (that's `json`, not `jsonb`) |
| Prisma + Mongo embed | composite `type` you still GET / replace **whole** | composite as a fake `@relation` |
| Drizzle on PG | `jsonb()` | `json()` unless byte-exact |
| TypeORM on PG | column type `jsonb` | `json` unless byte-exact |
| MySQL 8 | `JSON` (one binary type) | `TEXT` you parse |
| SQLite 3.45+ | `TEXT` + `json_valid` as the default | treating SQLite `jsonb()` as Postgres `jsonb` (different bytes; internal BLOB) |
| SQLite before 3.45 | `TEXT` + `json_valid` | a JSON column type SQLite does not have |
| Mongo | one document you replace whole, or a collection | a nested array you filter / page / patch as if it were a table |
| Cockroach | `JSONB` | — |
| SQL Server | **no** JSON type — columns, or honor `nvarchar` JSON already there | EAV to fake JSON |

SQL Server JSON functions on `nvarchar` are not a reason to invent
EAV. Honor what is there.

SQLite `jsonb()` (3.45+) is a faster on-disk parse tree. It is **not**
wire-compatible with Postgres `jsonb`. Do not copy bytes across.

## Scalar types

| Fact | Use | Do not |
| --- | --- | --- |
| Instant (happened at) | `timestamptz` (Postgres / Cockroach) | `timestamp`; epoch `int` as the default |
| Calendar day | `date` | `timestamptz` at midnight |
| Calendar month | `date` first-of-month, or `(year, month)` | a `text` month name |
| Duration | `interval` (Postgres) or integer seconds | `float` hours |
| Money | integer minor units, or `numeric` | `float` / `double` / `real` |
| Quantity | integer, or `numeric` when fractional | `float` |
| Boolean | `boolean` | `char(1)`, `0/1` `int`, null as false |
| Enum of known states | enum type or a check constraint | free `text` for a closed set |
| Natural key | `text` / domain type + `UNIQUE` | UUID as the only unique column |
| Surrogate | extra `bigint`, or UUID (v7 when the pin has it — `identity`) | the only uniqueness |
| FK | same type as the referenced key + `FOREIGN KEY` | untyped `text` id |
| Email / URL | `text` + check / app parse | a dedicated column type you do not have |
| Child you filter | table (or Mongo collection) | blob / `text[]` you `WHERE` |
| Small closed tags | child table, or `text[]` you never update in part | JSON array of objects |
| Binary | `bytea` / `BLOB` | `text` base64 as the default |
| Derived, Postgres 17 and below | `GENERATED ALWAYS AS (…) STORED` | a trigger that copies |
| Derived, Postgres 18+ | `GENERATED ALWAYS AS (…)` (VIRTUAL is the default) | bumping to 18 to unlock VIRTUAL; `STORED` when you index or filter it |

Do not bump the database or ORM pin to unlock `uuidv7()` or VIRTUAL
generated. Target the pin. `identity` owns v7 vs v4 as the extra
surrogate.
