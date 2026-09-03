---
name: requirement-to-architecture-to-design
description: >-
  Runs the design-time pipeline when there is no code yet: requirements,
  then architecture, then design, without skipping a stage. Use when
  generating, editing, or reviewing a PRD, C4, ADR, system design, or
  design notes before implementation; when the user asks to design a
  system, skip to architecture, or jump to design.
---

# Requirement to architecture to design

Requirements then architecture then design. Do not skip a stage.
Default is **no** on jumping ahead.

Sources: C4 model (`c4model.com/diagrams` — context + container;
component only if a container is too big; code diagrams are not this
pipeline). ADR body: MADR via
`create-readme-and-other-markdown-documentation`. Not TOGAF. Not
Anthropic system-design. Not Clean Architecture folders. Not
Structurizr as a drive-by.

Stages: [stages.md](stages.md). Catalogs 1–7 stay in their skills. Do
not recopy them here.

## First step

1. Inventory what is already there. Honor it.

   PRD / problem doc, `docs/`, ADRs (`docs/decisions/`), Figma, C4 /
   mermaid / Structurizr, existing code.
2. If a more specific skill already owns this, **stop**.

   | Detect | Follow |
   | --- | --- |
   | User said review this / code review | `review-change` |
   | README / MADR file body | `create-readme-and-other-markdown-documentation` |
   | Code already exists; no new system | `review-change` + the language skill |
   | Layout after architecture is chosen | platform app-structure (`encore-go-app-structure`, …) |
3. Start at **requirements** unless a signed problem doc already
   exists — then honor it and enter architecture only if earned.
4. Tick Earn architecture. If every line is no, requirements + design
   notes (catalogs 1–7 on one process) are enough. Do not draw C4.

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Start | requirements | a signed PRD / problem doc already exists |
| Architecture | **no** (earn below) | two+ containers, or a constraint requirements cannot hold |
| Architecture method | C4 context + container | existing diagrams work |
| C4 component | **no** | a container is too big to design as one (`c4model.com/diagrams/component`) |
| C4 code / class / deployment / dynamic | **no** | already there; or a named env difference after containers |
| Diagram tool | honor mermaid / Structurizr / PlantUML already there | none yet → the docs flavor already in the repo |
| Design | catalogs 1–7, pointed not copied | — |
| ADR | **no** (earn below) | architecturally significant; honor Nygard / existing template |
| QPS / capacity theater | **no** | a real SLO exists in requirements |
| Folders | **no** hexagonal / clean-architecture tree | repo already has them |

C4's site recommends context + container for every team. This
pipeline still **earns** architecture. A one-process app stays on
requirements + design notes.

## Division of labor

| Stage | Artifact | Owner |
| --- | --- | --- |
| Requirements | problem, actors, constraints, non-goals | this skill ([stages.md](stages.md)) |
| Architecture | C4 context + container (earned) | this skill |
| Design | apply catalogs 1–7 inside containers | `source-of-truth`, `data-modeling`, `identity`, `api-contracts`, `evolve-safely`, `authz-boundaries`, `choose-collections` |
| ADR file body | MADR in `docs/decisions/` | `create-readme-and-other-markdown-documentation` |
| Earn the ADR | architecturally significant only | this skill |
| Code layout after design | language / platform app-structure | `go-idioms`, `encore-go-app-structure`, `sveltekit-app-structure`, … |

## What this skill owns

| Own | Leave |
| --- | --- |
| Stage order; earn C4; earn the ADR | MADR file body (`create-readme-and-other-markdown-documentation`) |
| Context + container shapes | Catalogs 1–7 (point, do not copy) |
| | Package / route trees (app-structure after design) |

## Earn architecture

Copy this checklist. Tick **yes** on at least two, or stay on
requirements + one-process design.

```
Earn architecture:
- [ ] Two+ containers / processes must talk
- [ ] A constraint requirements cannot hold (tenancy, writer, SLO)
- [ ] More than one team will build it
- [ ] An architecturally significant choice (will earn an ADR)
```

If every line is **no**, do not draw C4. Do not skip to a component
diagram. Design notes on the one process are the next stage.

Default is **no** skip of requirements. The user saying "just
architecture it" does not waive the stage unless they explicitly
waive it.

## Earn an ADR

Copy this checklist. Tick **yes** on at least two, or do not write
one.

```
Earn an ADR:
- [ ] Architecturally significant (hard to reverse)
- [ ] Two real options, not a restyle
- [ ] A later reader will need the why
```

If every line is **no**, put the choice in the design notes. File
body is MADR in `docs/decisions/` —
`create-readme-and-other-markdown-documentation`. Do not invent a
second ADR format.

## Default shapes

Artifact templates: [stages.md](stages.md). Short form:

| Stage | Produce | Do not produce |
| --- | --- | --- |
| Requirements | actors, problem, constraints, non-goals, SLO if real | a 40-page vision; invented QPS |
| Architecture | C4 context + container; one writer per fact at the boxes | QPS theater; component spam; classes as containers |
| Design | ticks against catalogs 1–7 per container | recopied catalogs; hexagonal folders |

A C4 **container** is an application or a data store (API process,
SPA, mobile app, database, bucket) — `c4model.com/diagrams/container`.
Not a class. Not a Go package. Deployment (clusters, load balancers)
is a later diagram, not this one.

Catalogs (point, do not copy):

| When the design touches | Follow |
| --- | --- |
| Writer / GET / cache / outbox | `source-of-truth` |
| Schema / JSONB / types | `data-modeling` |
| Keys / UUID / workflow id | `identity` |
| HTTP / RPC / 4xx | `api-contracts` |
| Migration / rename / v2 | `evolve-safely` |
| Actor / tenant / public | `authz-boundaries` |
| Slice vs map / invent sort | `choose-collections` |

## Hard rules

- Requirements then architecture then design. Do not skip a stage.
- Architecture is earned. Default is **no**.
- Design points at catalogs 1–7. It does not recopy them.
- ADR is earned and MADR-shaped. Not a second template.
- No QPS / interview capacity theater unless a real SLO is in
  requirements.
- No Clean Architecture / hexagonal folders as the output of this
  pipeline.
- Do not mix design (schema, endpoints) into the requirements
  artifact. Do not mix package layout into C4.

## Do not add

| Need | Use | Do not add |
| --- | --- | --- |
| Architecture encyclopedia | C4 context + container | TOGAF, arc42, Anthropic system-design |
| Decision record | MADR via `create-readme-and-other-markdown-documentation` | a second ADR format |
| Code tree | platform app-structure after design | `domain/` `usecase/` `adapter/` from this skill |
| Capacity | real SLO from requirements | interview QPS |
| Diagram tool | the one already there | Structurizr / a second renderer as fashion |

## After every edit

Name the stage you are in. A skipped requirements doc is written
before C4. An unearned architecture diagram is deleted. Design notes
link catalogs; they do not paste them.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| C4 with no actors / problem | skipped requirements |
| Component diagram for a CRUD app | did not earn architecture |
| Classes or packages as C4 containers | a container is a process or store |
| 40-page vision | not the requirements artifact |
| Schema in the PRD | jumped to design |
| Hexagonal folders as the design | wrong output; catalogs 1–7 |
| QPS / "can it scale to 1M" | interview theater; no SLO |
| ADR for a restyle | did not earn |
| Design recopies `source-of-truth` | point, do not copy |
| Two owners of the ADR body | `create-readme-and-other-markdown-documentation` owns the file |
| Load balancer on the container diagram | that is deployment; not this stage |

## LLM traps — never generate these

- Jumping to C4 or code from one sentence
- TOGAF / Zachman / arc42 / Clean Architecture folders
- Anthropic system-design / interview QPS
- A 40-page vision / PRD novel
- Hexagonal `domain/` `usecase/` `adapter/` as the pipeline output
- A second ADR template besides MADR
- Recopying catalogs 1–7 into the design notes
- Waiving requirements because the user said "just design it"
  (unless they explicitly waived the stage)
- UML class / sequence as the architecture diagram
- Structurizr DSL on a one-process app
- User-story theater instead of problem / actors / constraints /
  non-goals

## Do not

- Restyle a working design into C4 as a drive-by.
- Skip a stage because the user said "just architecture it" unless
  they explicitly waived it.
- Recopy catalogs 1–7 or the MADR template here.
- Write `docs/decisions/` with a non-MADR body as a drive-by.
