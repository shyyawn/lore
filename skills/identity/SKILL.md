---
name: identity
description: >-
  Generates, edits, and reviews business keys for natural entities: a
  unique business key, explicit request fields, caller-owned
  idempotency keys, UUID as extra uniqueness not the only key. Use when
  generating, editing, or reviewing UUID defaults, slugs, workflow ids,
  composite keys, uuidv7(), uuid(7), or code that infers identity from
  the URL.
---

# Identity

Natural entity → **business** key. Do not hide clocks, tenants, or
close-policy in the string.

Sources: Temporal `workflow-execution/workflowid-runid` (Workflow Id
carries business meaning); Google AIP-122 (collection/id; `uid` is
extra); Stripe `api/idempotent_requests` (caller `Idempotency-Key`);
RFC 9562 (`uuidv7()`, Prisma `uuid(7)`). Not NanoID vs ULID.

Column types: `data-modeling`. Idempotency on the wire:
`api-contracts`. Writer of the row: `source-of-truth`.

## First step

1. Inventory what is already there. Honor it.

   Unique columns, Prisma `@@unique` / `@id`, slugs, workflow IDs,
   `Idempotency-Key`, path params, resource names.
2. Read the **pin**. Do not bump it.

   Postgres version (`uuidv7()` is 18+), Prisma `uuid()` / `uuid(7)`,
   existing `@id`.
3. Name the natural entity. If it already has a business key, **stop**
   — do not add a UUID as a second public id as a drive-by.
4. If a more specific skill already owns this, **stop**.

   | Detect | Follow |
   | --- | --- |
   | `UNIQUE` / FK / column type | `data-modeling` |
   | `Idempotency-Key` header, POST semantics | `api-contracts` |
   | Who writes the keyed row | `source-of-truth` |
   | Tenant in the query | `authz-boundaries` |
   | Temporal Workflow ID reuse / reject-duplicate | `temporal-go` — this skill still owns business-key vs UUID |
5. UUID as the only unique key for a one-per-natural-id entity is the
   wrong default. Add `UNIQUE` on the natural key. Surrogate is extra.

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Natural entity | business key, `UNIQUE` | existing UUID-only and you are not adding the entity |
| Surrogate | extra (`bigint`, or UUIDv7 when the pin has it) | no natural key exists (truly anonymous); v4 when the pin has no v7 |
| Workflow ID | `"{type}-{business-id}"` | Temporal already assigned one — continue it |
| Idempotency | caller-owned key | safe GET; or the business key *is* the idempotency |
| Resource name | collection + id (AIP-122) | existing URL scheme works |
| Slug | explicit request field | inferred once at create and stored |
| Tenant | explicit field, not packed in the id | — |
| Clock / close-policy | explicit fields | — |

## Division of labor

| Artifact | Owner |
| --- | --- |
| Business key vs UUID; slug; workflow id shape | this skill |
| `UNIQUE` / FK / types | `data-modeling` |
| `Idempotency-Key` on the wire, 4xx vs 5xx | `api-contracts` |
| One writer of the keyed fact | `source-of-truth` |
| Tenant isolation | `authz-boundaries` |
| Temporal ID reuse / reject-duplicate | `temporal-go` |

## Hard rules

- Natural entity → business key. One-per-email, one-per-order-number,
  one-per-`(tenant, slug)`.
- Do not hide clocks, tenants, or close-policy in the **business**
  key. Those are fields. The key stays stable when they change. A
  UUIDv7 surrogate may encode time. It is extra, not the public id.
- Request fields are **explicit**. Do not infer the entity from the
  URL and skip the body field the caller must send.
- Idempotency keys are **caller-owned**. Not parsed from the path.
  Not `uuid()` in the handler unless the caller sent it. Not the
  email or other PII.
- UUID as the only unique key for a one-per-natural-id entity is the
  wrong default. Extra surrogate: UUIDv7 when the pin has it
  (`uuidv7()`, `uuid(7)`), else v4. Do not bump the pin.

## Default shapes

| Entity | Key |
| --- | --- |
| User / account | email, or `(tenant, handle)` |
| Order | order number, or `(merchant, number)` |
| Slug page | `(tenant, slug)` stored; slug in the body |
| Temporal entity workflow | `"{type}-{business-id}"` — not `uuid()`; not Run Id |
| Idempotent create | caller `Idempotency-Key`; server stores it |
| AIP resource | `publishers/{publisher}/books/{book}`; system `uid` extra |
| Truly anonymous row | surrogate only — no natural id exists |

Ideas, not trees. Do not bikeshed NanoID vs ULID.

## Composite keys

Parts that must not collide stay **columns**, then one uniqueness.

| Parts | Unique on | Not |
| --- | --- | --- |
| Tenant + slug | `(tenant_id, slug)` | slug unique globally when tenants exist |
| Parent + child | AIP `{parent}/{child}` | child UUID that hides the parent |
| Type + business id | Temporal `"{type}-{id}"` | type packed with a date or `closed` |
| Merchant + number | `(merchant_id, number)` | global serial that leaks across merchants |

The key is stable. Status, close-policy, and clocks are fields. A
rename of a public key is `evolve-safely`, not a silent UUID swap.

## Do not add

| Need | Use | Do not add |
| --- | --- | --- |
| One-per-natural-id | `UNIQUE` on that key | UUID `@id` as the only unique |
| Extra surrogate | v7 when the pin has it, else v4 | bump Postgres / Prisma to unlock `uuidv7()` |
| Idempotent POST | caller key, stored | parse the path; `uuid()` in the handler |
| Tenant | column / request field | `tenant_42_order_7` packed id |
| Close / expire | status + timestamp columns | `order-closed-2026-01-01` in the id |
| Public id | the business key, or both | a second random id as a drive-by |
| Sortable id | UUIDv7 surrogate when the pin has it | packing `created_at` into the business key |

## After every edit

Each new entity names its business key. Packed clocks / tenants /
close-policy come out of the string and become fields. A UUID-only
unique for a one-per-natural-id entity gains `UNIQUE` on the natural
key.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| Two rows, same email | UUID-only unique. Add the business key |
| Workflow ID is a random UUID | entity workflow. Use the business key |
| Re-POST created a second row | no caller idempotency key |
| Id contains `closed` or a date | policy / clock packed in the string |
| Tenant only in the path, not the key | packed or missing; explicit field |
| Handler `uuid()` then treats it as idempotent | caller-owned key |
| Slug inferred from title on every write | slug is a stored field |
| `uuidv7()` on Postgres 17 | pin has no v7. v4, or do not bump |

## LLM traps — never generate these

- Prisma `@id @default(uuid())` as the only unique for a user / order
- `workflow.Execute` with `uuid.New()` for an entity workflow
- Using Temporal Run Id as the business key
- Idempotency parsed from `/orders/{id}`
- Email or order number as the `Idempotency-Key`
- `user-tenantA-2026-closed` as a primary key
- NanoID vs ULID as the decision
- Bumping Postgres to 18 / Prisma for `uuidv7()` / `uuid(7)`
- Inferring the body id from the URL and dropping the field
- A second public UUID "for security" as a drive-by
- Encoding close-policy in the key so reopen cannot keep the id
- Refusing UUIDv7 because RFC 9562 encodes time — that clock is the
  surrogate, not the business key

## Do not

- Restyle working keys into UUIDs as a drive-by.
- Skip the business key because the user said "just use UUID".
- Recopy `data-modeling` types or `api-contracts` headers here.
- Teach NanoID vs ULID fashion.
- Bump the database or ORM pin to unlock v7.
