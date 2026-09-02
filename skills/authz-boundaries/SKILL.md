---
name: authz-boundaries
description: >-
  Generates, edits, and reviews authorization boundaries: every read
  and write has an actor and a tenant, tenant is in the query not only
  the path, public vs private is explicit. Use when generating,
  editing, or reviewing auth, tenant isolation, public endpoints,
  IDOR, RLS, authorization checks, or a query that loads a row by id
  alone.
---

# Authz boundaries

Every read and write has an **actor** and a tenant. Tenant is in the
query, not only the path. Do not treat login as authorization.

Sources: Google AIP-211 (permission on the resource, not only
authenticated). Encore `docs/go/primitives/defining-apis`,
`docs/go/develop/auth` (internet / authenticated / internal — the
**idea**, not their tags). Postgres `ddl-rowsecurity` when policies
already exist. Not OWASP Top 10. Not JWT / cookie / session fashion.

Encore syntax: `encore-go`. HTTP 401 vs 403 vs 404: `api-contracts`.
Tenant in the business key: `identity`. Who writes the row:
`source-of-truth`.

## First step

1. Inventory what is already there. Honor it.

   Auth handlers, route groups, Encore access tags, tenant columns,
   sqlc / sqlx / pgx queries, GORM scopes, Prisma / Drizzle `where`,
   RLS policies, public routes, API keys, webhooks.
2. Read the **pin**. Do not bump it.

   Database (Postgres vs MySQL vs SQLite), the tenant column name
   (`tenant_id` / `org_id` / `account_id` / `user_id`), existing
   session / JWT / API key.
3. If a more specific skill already owns this, **stop**.

   | Detect | Follow |
   | --- | --- |
   | Encore `//encore:api` / `expose` / `auth` / `errs.Unauthenticated` | `encore-go` — this skill still owns actor + tenant in the query |
   | 401 vs 403 vs 404 body | `api-contracts` |
   | Tenant packed into the id string | `identity` |
   | Who writes the row | `source-of-truth` |
   | Tenant column type | `data-modeling` |
4. Name actor, tenant, and reach for each new read or write. Public
   is an **explicit** allow, not the unset state.
5. Check the query. Path id is not the tenant filter. List, join,
   subquery, and cache GET use the **same** predicate as get-by-id.

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Actor | required on read and write | explicitly public (no user) |
| Tenant | in the **query** (and usually the key) | single-tenant app, named as such |
| Reach | authenticated for tenant data | explicit public or internal |
| Public route | allow-list (health, marketing, webhook) | Encore `public` / `expose: true` already there |
| Internal-only | other services / cron; not the internet | — |
| Authn | identity of the actor | existing session / JWT / API key — do not restyle |
| Authz | this actor may do this to **this** row | login as the check |
| Client `tenantId` | ignore; use the actor's | named operator path (Earn below) |
| Cross-tenant GET | **no** | named operator path, or a named public catalog |
| Same-tenant deny | 403 (`api-contracts`) | existing envelope 404s forbids |
| Missing in a scoped query | 404 (0 rows) | do not unscoped-get to emit 403 |
| RLS | **no** | Postgres already has `CREATE POLICY` |
| Policy engine | **no** | Casbin / OPA / SpiceDB already there |

sqlc / sqlx / pgx / GORM / Prisma / Drizzle are **readers**. The
filter is in the query. Middleware that only checks "logged in" is
not authz.

## Pin strings

Inventory the database. Do not copy Postgres RLS onto MySQL.

| Pin | Tenant filter |
| --- | --- |
| sqlc / sqlx / pgx | `WHERE id = $1 AND tenant_id = $2` (honor the column name) |
| GORM | `Where` on both; not `First(id)` / `Find(id)` |
| Prisma | `where: { id, tenantId }` — not `findUnique({ where: { id } })` |
| Drizzle | both `eq`; not id alone |
| Postgres | the WHERE. `CREATE POLICY` / `ENABLE ROW LEVEL SECURITY` only if already there. Owner and `BYPASSRLS` are not the app. |
| MySQL 8.4 | the WHERE. `GRANT` is table/column (`access-control`), not a row filter |
| SQLite | the WHERE. No RLS |

## Division of labor

| Artifact | Owner |
| --- | --- |
| Actor + tenant on every read/write; tenant in the query; reach | this skill |
| Encore `public` / `auth` / `private` / `expose` syntax | `encore-go` |
| 401 vs 403 vs 404 | `api-contracts` |
| Tenant as part of the business key | `identity` |
| Tenant column type | `data-modeling` |
| Who writes the fact | `source-of-truth` |
| Cache / projection completeness | `source-of-truth` — GET still filters tenant |

## What this skill owns

| Own | Leave |
| --- | --- |
| Actor + tenant; tenant in the query; public vs private | JWT / session / cookie fashion |
| List / join / subquery / cache use the same filter | Encore auth handler body (`encore-go`) |
| Authn is not authz; client tenant is not the filter | OWASP Top 10 dump; error envelopes (`api-contracts`) |

## Hard rules

- Every read and write has an actor and a tenant, or is explicitly
  **public** / single-tenant.
- Tenant is in the **query**, not only the path. `WHERE id = $1` on a
  tenant-owned row is a bug. List, join, subquery, and cache GET
  use that same predicate.
- Authn names the actor. Authz decides this actor may do this to
  **this** resource. Login is not the check. A role is not the row.
- Public vs authenticated vs internal is an explicit decision per
  endpoint. Do not leave a data route public as the default.
- A guessable or leaked id is not authorization.
- Do not take `tenantId` from the client body or query string. Use
  the actor's tenant. Internal callers still send a tenant that is
  **checked**.
- Same tenant, logged in, not allowed → 403 (`api-contracts`). Do
  not `SELECT` by id alone and then compare tenant in the handler
  (AIP-211: do not probe existence with an unscoped get).

## Earn a cross-tenant path

Copy this checklist. Tick **yes** on at least two, or keep the
query scoped to the actor's tenant.

```
Earn a cross-tenant path:
- [ ] Named operator / admin product requirement
- [ ] An actor still (the operator), not a missing filter
- [ ] Audit of who crossed
```

If every line is **no**, do not `if admin { skip tenant }`. A
tenant admin is still **that** tenant.

## Default shapes

| Surface | Who can call | Tenant in the query |
| --- | --- | --- |
| Marketing / health | internet, no user | no tenant data |
| Logged-in user | internet, identified | actor's tenant (or `user_id`) |
| Tenant admin | identified | still that tenant |
| Internal / cron | other services only | tenant on the payload, checked |
| Webhook | internet, signature | tenant from the signed payload |
| Named operator | authenticated operator | named path; still an actor |

Encore.go `public` / `auth` / `private` and Encore.ts `expose` /
`auth` are this table. Syntax: `encore-go`. Do not recopy the
catalog.

Login and role are not the row filter.

| Check | Not enough |
| --- | --- |
| Logged in | another tenant's row |
| `role = admin` | admin of a **different** tenant |
| Path has the tenant id | query without that id |
| UUID / unguessable id | secrecy is not authz |
| Child `/t/{tid}/orders/{oid}` | child (or join) without tenant |
| Cache GET by id | cache key / query without tenant |

Default for a new data endpoint is **deny** until actor, tenant,
and reach are named.

## Do not add

| Need | Use | Do not add |
| --- | --- | --- |
| Login | the auth already there | a second JWT library |
| Row isolation | tenant in the query | path-only check; handler-side filter after `SELECT *` |
| Public page | explicit public | `auth: false` / `public` on a data GET as a drive-by |
| Security review | this skill + `api-contracts` | OWASP Top 10 pasted into the PR |
| RLS | honor Postgres policies if present | `CREATE POLICY` on MySQL / SQLite / single-tenant |
| ReBAC / policy engine | the query filter | Casbin / OPA / SpiceDB as fashion |

## After every edit

Each new read/write names actor, tenant, and reach. The query
filters tenant (or the route is explicitly public). List, join,
and cache match get-by-id. Path-only checks gain a query
predicate.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| GET `/orders/{id}` returns another tenant's row | tenant not in the query |
| List / search includes other tenants | list missing the same predicate |
| 401 on a forbidden row the user is logged in for | authn used as authz; want 403 |
| Public list of private rows | endpoint not classified |
| Tenant only in the URL | packed id (`identity`) or missing query filter |
| Admin bypasses tenant in SQL | unnamed cross-tenant path |
| Encore `public` / `expose: true` on a mutating API | access tag wrong (`encore-go`) |
| Webhook tenant from the query string | unsigned; tenant belongs in the signed payload |
| Cache returns the wrong tenant | key was only the row id |
| GORM `First(id)` / Prisma `findUnique({ id })` leaks | pin loaded by id alone |

## LLM traps — never generate these

- `WHERE id = $1` on a tenant-owned table
- GORM `First(id)`, Prisma `findUnique({ where: { id } })`, Drizzle
  `eq(id)` without tenant
- `SELECT` by id, then `if row.Tenant != actor` in the handler
- `if admin { skip tenant }` without Earn
- JWT / Passport / NextAuth restyle as the authz work
- OWASP Top 10 checklist as this skill
- `public` data GET because "the id is a UUID"
- Authn middleware with no per-row check
- Recopying Encore `//encore:api` or `expose` / `auth` into this file
- RLS / `CREATE POLICY` as fashion on MySQL, SQLite, or single-tenant
- Trusting `tenantId` from the client body without matching the actor
- Casbin / OPA / SpiceDB / Zanzibar as a drive-by
- Filtering the list in the handler after an unscoped query

## Do not

- Restyle working auth into a new JWT library as a drive-by.
- Skip the query filter because the user said "it's a UUID".
- Recopy `encore-go` auth handlers or `api-contracts` envelopes here.
- Skip Earn because the user said "just make it admin".
- Teach OWASP Top 10 or an IAM permission-string dump.
