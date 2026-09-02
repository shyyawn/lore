---
name: api-contracts
description: >-
  Generates, edits, and reviews HTTP and RPC contracts: domain outcomes
  as 4xx with a stable machine id, crashed process as 5xx, pagination,
  idempotency on the wire, additive change. Use when generating,
  editing, or reviewing endpoints, status codes, problem+json,
  pagination, pageToken, Idempotency-Key, or breaking JSON fields.
---

# API contracts

HTTP/RPC. A domain **no** is 4xx with a stable code. A crashed process
is 5xx. Do not fail 500 when the business declined.

Sources: Google AIP-193 (errors), AIP-158 (pagination); Stripe
`api/errors`, `api/idempotent_requests`; RFC 9457
`application/problem+json` when no envelope exists yet. Not OpenAPI
fashion. Not a second Encore `errs` dump — `encore-go` owns that.

Expand/contract of fields: `evolve-safely`. Caller-owned keys:
`identity`. Stored business no: `source-of-truth`.

## First step

1. Inventory what is already there. Honor it.

   Routes, protobuf / Connect / gRPC, error envelopes, pagination
   fields, `Idempotency-Key`, version in the path, Encore `errs`.
2. If a more specific skill already owns this, **stop**.

   | Detect | Follow |
   | --- | --- |
   | Encore `*errs.Error` / `errs.B()` | `encore-go` — this skill still owns 4xx vs 5xx |
   | Expand/contract, API v2, rename field | `evolve-safely` |
   | Who writes; declined as stored data | `source-of-truth` |
   | Business-key / UUID in the path | `identity` |
   | Tenant / public vs auth | `authz-boundaries` |
3. Classify each outcome: domain no → 4xx + stable code. Crash → 5xx.
4. Lists paginate. Mutating POSTs that must not double are
   **idempotent** on the wire.

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Domain no | 4xx + stable machine code | existing envelope works |
| Crash | 5xx; log; do not leak internals | — |
| Error body | honor the envelope already there | none yet → RFC 9457 `problem+json`; Encore → `errs`; Stripe-shaped `{error:{type,code,message}}` → keep it |
| List | opaque `pageToken` / `page_token` | offset already the contract; Stripe-shaped `starting_after` already the contract |
| Unbounded list | **no** | existing dump and you are not adding the route |
| Idempotent mutate | `Idempotency-Key` (caller-owned) | GET / DELETE; or the business key is the idempotency |
| Change | additive (new optional field) | `evolve-safely` expand/contract |
| RPC | same 4xx-vs-5xx idea; status codes map | existing gRPC / Connect codes |

## Division of labor

| Artifact | Owner |
| --- | --- |
| Status; error envelope; pagination; wire idempotency | this skill |
| Expand/contract, dual-read a field, API v2 | `evolve-safely` |
| Caller-owned key shape | `identity` |
| Declined as a stored fact | `source-of-truth` |
| Encore `errs` mapping | `encore-go` |
| Go handler decode → map sentinels | `go-backend` |
| Authn / tenant / public | `authz-boundaries` |

## Hard rules

- Domain outcome → **4xx** with a stable machine id (`code`, RFC 9457
  `type`, or AIP `reason`). Human `message` / `detail` / `title` may
  change. The id does not.
- Crashed process → **5xx**. Log it. Do not put internals in the body.
- A business no is not a 500. If the fact must survive, store it
  (`source-of-truth`) and return 4xx.
- Lists are bounded. Opaque page token by default. Honor offset or
  `starting_after` if that is already the contract. Adding pagination
  later is a break (AIP-158).
- Idempotency on the **wire**: caller sends the key; same key + same
  body replays the same result; same key + different body is 409.
  Do not send the header on GET / DELETE.
- Change is **additive**. Remove, rename, or change meaning is
  `evolve-safely` — do not ship it as a silent field edit.

## Default shapes

| Outcome | HTTP | RPC idea |
| --- | --- | --- |
| Validation / bad request | 400 | invalid argument |
| Missing auth | 401 | unauthenticated |
| Authz deny | 403 | permission denied |
| Unknown id | 404 | not found |
| Idempotency key + different body | 409 | aborted / already exists |
| Conflict / already exists | 409 | already exists |
| Declined / closed (business no) | 4xx + stable id | failed precondition / aborted |
| Rate limit | 429 | resource exhausted |
| Unbounded or huge list | 400, or paginate | — |
| Bug / dependency down | 500 / 503 | internal / unavailable |

Envelope (honor the one already there). None yet — RFC 9457,
`Content-Type: application/problem+json`:

```json
{
  "type": "https://example.com/errors/already-exists",
  "title": "Already exists",
  "status": 409,
  "detail": "order number taken"
}
```

`type` is the stable machine id. Do not invent a second envelope next
to Encore `errs` or Stripe `error.code`.

Pagination: `pageSize` + `pageToken` in, `nextPageToken` out (honor
`page_size` / `page_token` if that is the wire). Empty token is the
end. Tokens are opaque. Do not return the whole table.

## Do not add

| Need | Use | Do not add |
| --- | --- | --- |
| Encore errors | `encore.dev/beta/errs` | a parallel JSON error type |
| OpenAPI file | honor one if present | OpenAPI as fashion on a working API |
| Page through rows | opaque page token | unbounded `findMany()`; a parseable offset token |
| Money / create twice | `Idempotency-Key` | infer from the path |
| New field | optional add | rename in place |
| RFC 7807 | honor if already there | a new 7807 envelope; 9457 obsoletes it |

## After every edit

Each new outcome is 4xx+stable id or 5xx. New lists paginate. Mutating
endpoints that must not double declare the idempotency key. Removed
or renamed fields go to `evolve-safely`, not this commit.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| Client sees 500 on declined / not-found | domain no as a crash. Map it |
| `code` / `type` changed across deploys | the id is the contract. Message is not |
| Second create with the same POST | no `Idempotency-Key` replay |
| Response is 12k rows | no pagination |
| Clients increment `pageToken` as an int | token was not opaque |
| Field vanished from JSON | not additive. `evolve-safely` |
| Encore 400 on a bare `error` | map sentinels (`encore-go`) |
| Idempotency parsed from the URL | that is `identity` — caller-owned header |
| `application/json` problem body | missing `application/problem+json` |

## LLM traps — never generate these

- `500` for not-found, conflict, or declined
- Unbounded list / `findMany()` with no page
- Rename a JSON field in place
- A second error envelope next to Encore `errs`
- OpenAPI dumped as the design
- `Idempotency-Key` generated in the handler
- `Idempotency-Key` on GET / DELETE as a new requirement
- Changing `code` / `type` strings as a restyle
- Offset pagination as a new default on a large table
- Page tokens clients are told to parse
- Recopying the Encore `errs` table into this file
- RFC 7807 as the new default (9457 obsoletes it)

## Do not

- Restyle a working envelope into AIP or Stripe as a drive-by.
- Skip pagination because the user said "just return the list".
- Recopy `encore-go` primitives or `evolve-safely` here.
- Teach an OpenAPI file as the contract when the routes already work.
