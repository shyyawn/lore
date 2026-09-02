# Stages

Three artifacts. Honor a signed one that already exists. Do not skip
ahead. Architecture and ADR are earned in SKILL.md.

## Requirements

Write this. Stop if a signed PRD already holds it.

```
Requirements:
- Problem (one paragraph)
- Actors
- Constraints (tenant, writer, compliance, pin)
- Non-goals
- SLO / capacity — only if a real number exists; else omit
```

Do not write a 40-page vision. Do not invent QPS. Do not put schema
or endpoints here — that is design.

## Architecture

Only if Earn architecture ticked. C4 context (people + systems) and
container (processes / stores). A container is an application or a
data store (`c4model.com/diagrams/container`). One box, one writer
(`source-of-truth`).

```
Architecture:
- Context: actors and the other systems
- Containers: processes and stores; arrows are calls or facts
- Writer per fact (name the store)
- Tenant / public boundary (name it)
```

Do not draw components until a container is too big to design as
one (`c4model.com/diagrams/component`). Do not draw hexagonal
layers. Do not draw classes. Do not draw clusters / load balancers
(deployment is not this stage).

## Design

Per container, tick catalogs 1–7. Point at the skill. Do not paste
its tables.

```
Design (per container):
- [ ] source-of-truth — writer / GET / second store
- [ ] data-modeling — schema / JSONB / types
- [ ] identity — business key / UUID
- [ ] api-contracts — 4xx vs 5xx / pagination / idempotency
- [ ] evolve-safely — first migrate / additive wire
- [ ] authz-boundaries — actor / tenant in the query
- [ ] choose-collections — in-memory / stdlib / SQL
```

If a tick is no, write **n/a** and why (one clause). Language and
layout after this: the platform app-structure skill, not this file.

## ADR

Only if Earn an ADR ticked. Path and body:
`create-readme-and-other-markdown-documentation` — MADR minimal in
`docs/decisions/`. This file does not hold the template.
