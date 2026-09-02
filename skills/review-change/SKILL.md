---
name: review-change
description: >-
  Orchestrates a staff review of a change: load playbooks 1–7 plus the
  language skill for the pin, tick which apply. Use when generating,
  editing, or reviewing a diff the user asked to review; when the user
  says review this, code review, or does this match how we write
  services.
---

# Review change

Thin **orchestrator**. Load 1–7 plus the language skill for the pin.
Tick which apply. Do not recopy their catalogs.

If every catalog is **no**, the language skill is enough. Do not OWASP.
Do not Anthropic code-review.

Sources: Google eng-practices `review/reviewer` (this change, pin
style, not perfect). Catalogs 1–7 plus the language pin. Not their
CL tooling. Not OWASP Top 10. Not Anthropic code-review.

Design-time with no code: `requirement-to-architecture-to-design`.
Markdown body: `create-readme-and-other-markdown-documentation`.

## First step

1. Inventory the change. Honor what is already there.

   Diff, pin (`go.mod`, lockfile, `encore.app`, `svelte.config.*`),
   existing tests, existing schema.
2. Read the **pin**. Do not bump it. Load the language skill for
   that pin (`go-idioms`, `typescript-idioms`, `css-idioms`, …).
   Platform overlays next (`encore-go`, `svelte`, `temporal-go`).
   Both Encore and Temporal: `encore-temporal-go-app-structure`.
3. If a more specific owner already has the whole job, **stop**.

   | Detect | Follow |
   | --- | --- |
   | No code yet; design a system | `requirement-to-architecture-to-design` |
   | README / ADR / docs body | `create-readme-and-other-markdown-documentation` |
   | Commit message only | `conventional-commits` |
   | `*_test.go` / `*.test.ts` as the change | `go-unit-tests` / `typescript-unit-tests` |
   | Playwright / Maestro journeys | `e2e-tests` |
4. Tick the review list below. Skip a row that does not apply. Do
   not recopy that skill's tables.
5. If every catalog row is **no**, stop after the language skill.

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Scope | this diff, not the repo | user asked for a wider pass |
| Language | pin-matched idiom skill | — |
| Staff catalogs | tick 1–7; skip n/a | — |
| Security | `authz-boundaries` + `api-contracts` | OWASP dump |
| Tests | point at `go-unit-tests` / `typescript-unit-tests` / `e2e-tests` | — |
| Style | the pin skill | a second style guide; personal preference |
| Comments | fix in place | comments that restate a catalog title |
| Restyle around the diff | **no** | user asked to restyle the file |

## Division of labor

| Artifact | Owner |
| --- | --- |
| Which catalogs apply; order of loading | this skill |
| Writer / GET / outbox | `source-of-truth` |
| Schema / types | `data-modeling` |
| Business keys | `identity` |
| HTTP / RPC contract | `api-contracts` |
| Expand/contract | `evolve-safely` |
| Actor / tenant | `authz-boundaries` |
| In-memory collections | `choose-collections` |
| Pin-matched code | language / platform / domain overlay / unit-test skills |
| Design-time pipeline | `requirement-to-architecture-to-design` |
| README / ADR body | `create-readme-and-other-markdown-documentation` |

## Review workflow

Copy this checklist. Tick **n/a** when the diff does not touch that
layer. Load the skill only for a yes.

```
Review change:
- [ ] Language / platform skill for the pin (always)
- [ ] source-of-truth — second store, dual-write, cache, outbox
- [ ] data-modeling — schema, JSONB, types, denorm
- [ ] identity — UUID-only, slug, workflow id, packed key
- [ ] api-contracts — 4xx vs 5xx, pagination, Idempotency-Key
- [ ] evolve-safely — rename, NOT NULL, drop, API v2
- [ ] authz-boundaries — actor, tenant in the query, public route
- [ ] choose-collections — slice vs map, custom sort, load-the-table
```

Fix in place. Do not add comments that only restate the catalog
title. Do not paste the catalog into the review.

The review names the pin and the ticks. Findings point at a skill.
They do not recopy its tables.

## Default shapes

| Produce | Do not produce |
| --- | --- |
| Pin skill named; 1–7 ticked or **n/a** | Every catalog ticked on a one-line change |
| Fixes in the diff | A pasted catalog; comments that restate a title |
| Pointer to the owning skill | Google looking-for / OWASP as a second rubric |

## What this skill owns

| Own | Leave |
| --- | --- |
| Load order; which of 1–7 apply | The catalogs themselves |
| Stop when every catalog is no | OWASP; Anthropic code-review; Google looking-for dump |
| | Unit / e2e method (`go-unit-tests`, `e2e-tests`) |
| | Language spelling (`go-idioms`, …) |

## Hard rules

- Load the **pin** language skill first. Always. Then tick 1–7.
- Tick **n/a** when the diff does not touch that layer. Load a
  catalog only for a yes.
- Review **this** diff. Do not restyle the rest of the file, or the
  repo, as a drive-by.
- Fix in place. Do not leave a comment that only names a catalog.
- Style is the pin skill. Personal preference is not a finding.
- If every catalog is **no**, the language skill is enough.

## Do not add

| Need | Use | Do not add |
| --- | --- | --- |
| Language review | pin skill | a second style guide |
| Security | `authz-boundaries` + `api-contracts` | OWASP Top 10 in the PR |
| Design of a greenfield | `requirement-to-architecture-to-design` | this skill as a PRD |
| Tests in the same change | the unit / e2e skill | a test encyclopedia here |
| Code-review encyclopedia | this tick list | Anthropic / Google looking-for pasted as a second rubric |

## After every edit

The review names the pin skill and the catalog ticks. A pasted
catalog is replaced with a pointer. OWASP / interview checklists are
deleted. Unrelated restyle is undone.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| Review is a dump of seven skills | did not tick; recopied |
| Every row ticked on a CSS change | catalogs do not apply; language skill enough |
| OWASP / JWT fashion | wrong security owner |
| Design C4 in a code review | that is `requirement-to-architecture-to-design` |
| Comments restating "one writer" | fix the code; do not comment the catalog |
| Two reviews, two owners | this skill orchestrates; catalogs own the rule |
| Reformatted the whole file in the review | restyle mixed with the diff |
| Skipped `go.mod` / lockfile | did not load the pin |

## LLM traps — never generate these

- Pasting `source-of-truth` (or any of 1–7) into the review
- OWASP Top 10, JWT restyle, Anthropic code-review
- Ticking every catalog on a one-line change
- Hexagonal / Clean Architecture as the review rubric
- A 40-comment nit pass that restates catalog titles
- Skipping the language pin (`go.mod` / lockfile)
- Google looking-for (naming, complexity, g3doc) as a second rubric
- Blocking on personal style the pin skill does not require

## Do not

- Restyle unrelated files in the name of this review.
- Recopy catalogs 1–7 here or into the PR.
- Load `requirement-to-architecture-to-design` for an existing
  diff unless the user asked to redesign.
- Skip the pin because the user said "just review it".
