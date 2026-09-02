# Kinds

Pick the closest canon. Copy **its** headings. No canon yet →
[SKILL.md](SKILL.md) stub + [voice.md](voice.md). Do not mix a hub
checklist into a language skill, `go-idioms` headings into a design
pipeline, or the docs playbook's file catalog onto a requirements
pipeline.

| Kind | Canon | Sibling files |
| --- | --- | --- |
| Authoring | this skill | `voice.md`, `kinds.md`, `family.md` |
| Workflow / playbook | `create-readme-and-other-markdown-documentation` (also `e2e-tests`, staff playbooks, `requirement-to-architecture-to-design`) | create-readme: `files.md`, `readme.md`, `english.md`, `stacks.md`; staff: `types.md`, `collections.md`, `algorithms.md`, `stages.md` |
| Language idiom | `go-idioms`, `typescript-idioms`, `css-idioms` | `versions.md`, `modernizers.md`, `architecture.md` |
| Platform coding | `encore-go`, `temporal-go`, `svelte` | Encore/Temporal catalogs; `svelte`: none (plugin owns runes) |
| App-structure | `encore-go-app-structure`, `temporal-go-app-structure`, `sveltekit-app-structure` | usually none — trees live in SKILL.md |
| Combined stack | `encore-temporal-go-app-structure` | none — seam + division of labor in SKILL.md |
| Hub kit | `git-repo-setup` | `files.md`, `gitconfig.md`, `debug.md` |
| Language overlay on hub | `git-repo-setup-go` / `-typescript` / `-python` | overlay `debug.md` (the JSON) |
| Domain overlay | `go-backend`, `go-ddd`, `go-unit-tests`, `typescript-unit-tests`, `go-100-mistakes-avoid`, `go-mono-repo`, `typescript-mono-repo` | `internals.md`, `lite.md`, `methods.md`, `domains.md`, `catalog.md`, `layouts.md` |
| Vendor overlay | `conventional-commits` | `tooling.md` |

Look is always [voice.md](voice.md). Authoring is this skill — do not
write a second one. Language idiom and below are the **current** stack,
not a requirement that every new skill hang under Go. Svelte hangs
under `typescript-idioms` + the plugin, not under `go-idioms`.

## Three lists

| List | Holds | Example |
| --- | --- | --- |
| **Do not add** | Competing tool already covered | gin next to `//encore:api`; a second architecture framework |
| **LLM traps** | What the model will emit unasked | `interface{}`; a 40-page vision doc; hexagonal folders |
| **Do not** | Process: restyle, skip a stage, wrong skill | Drive-by restyle; load DDD for CRUD; skip requirements |

Do not merge them. A Hard-rules bullet is not also an LLM trap unless
the model will actually generate that thing.

## Workflow / playbook

Open: `create-readme-and-other-markdown-documentation`. No language
required. Stages, artifacts, earn-the-next. Also `e2e-tests` (same
headings, thinner). Staff playbooks and
`requirement-to-architecture-to-design` (same headings).
Copy the shapes below, not their docs or Go content.

1. Lead ([voice.md](voice.md)): what the pipeline is. Pointers. Sources.
   Not a vendor encyclopedia (TOGAF dump, a blog "architecture process").
2. **First step**: inventory existing artifacts (PRD, ADRs, Figma,
   `docs/`). Honor them. **Stop** if a more specific skill owns this.
3. **Division of labor** or stage table: who owns which artifact.
4. **Earn** a later stage when it is expensive (architecture, DDD).
   Default is **no** skip of an earlier stage. Fenced checklist; tick
   yes on ≥2 to enter the expensive stage, or stay. Do not copy
   go-ddd's two-ticks onto "write the PRD" — that stage is the start.
5. **Default shapes**: the artifact template. Long bodies →
   `artifacts.md` / `stages.md`.
6. **When it breaks**: skipped a stage, two owners of the same artifact.
7. **LLM traps**: inventing architecture from one sentence; 40-page
   vision; a second process beside a working one.
8. **Do not**: drive-by restyle of a working design; skip a stage
   because the user said "just design it" unless they explicitly waived
   it.

Same look as `go-ddd` earn and `git-repo-setup` new vs existing. Not
Encore Hard rules, not a `go.mod` version table.

## Language idiom

Open: `go-idioms`. Title may say the current line (`# Go 2026`).

1. Lead: write as if `go fix` / `tsc` already ran. Do not emit tutorial
   Go / pre-5 TypeScript.
2. Pointers to `versions.md` / `modernizers.md` / `architecture.md`.
3. **First step**: read the pin. Version table (`Always use` / `Not yet`).
   Experimental `GOEXPERIMENT` APIs are out of scope unless the module
   already enables them.
4. **After every … edit**: the bash gate. "Write the modern form the
   first time."
5. **When it breaks**: compiler / flag symptoms.
6. Language bullets; Architecture + **Need | Use | Do not add**;
   errors / tests as short sections that **point** at overlays
   (`go-unit-tests`, `go-backend`) instead of reciting them.
7. **LLM traps** + **Do not**.

`versions.md` is Before / After per language version. Gate every row on
the pin. `architecture.md` is 2024–2026 structure, not hexagonal fashion.

## Platform coding

Open: `encore-go`, `temporal-go`, or `svelte`.

- Follow the language skill, then **overrides** on named axes (Encore:
  layout, HTTP, log, tests; Temporal workflows: no `slog` / `go` /
  `time.Now`; Svelte: pin, experimental default-**no**, `$app/state`).
  Bidirectional: language `architecture.md` points at the platform
  skill for that layout.
- **Hard rules** (compiler / runtime), not a defaults table.
- **Default shapes**: concrete code from official docs / samples.
  `svelte` skips this — the plugin owns runes.
- **Do not add** table. **LLM traps**. Catalogs in siblings. `svelte`
  has none.
- Encore traps that are not JSON: short `debug.md`, pointing at
  `git-repo-setup-go` debug.md for attach.
- `svelte` is also a vendor overlay: install the Svelte plugin; do not
  fork `svelte-core-bestpractices`.

## App-structure

Open: `encore-go-app-structure` or `sveltekit-app-structure`. Coding
idioms stay in the sibling coding skill. This file is layout and
package / route boundaries.

- **Sources:** official docs + named starters. Not a fork of the coding
  skill.
- **Hard rules**. **Choose a layout** (situation → tree). Small vs large
  official trees. **Growth** stages. **After layout changes**.
- **Do not**: restyle a working flat app into the large tree as a
  drive-by. Apply `go-idioms` `cmd/` to Encore HTTP, or
  `typescript-idioms` `src/<noun>/` to `src/routes`.

If `go.temporal.io/sdk` is already in an Encore app, **stop** and follow
`encore-temporal-go-app-structure`. Do not duplicate that seam here.

## Combined stack

Open: `encore-temporal-go-app-structure`. Only when both platforms are
in the tree.

- **Division of labor** table (who owns HTTP, who owns orchestration).
- Default seam layout from official how-to + example. Scale-out from
  OMS **on top of** the how-to, not instead of it.
- Point at `encore-go`, `encore-go-app-structure`, `temporal-go`. Do not
  recopy determinism or `//encore:api` catalogs.

## Hub kit

Open: `git-repo-setup`.

- One committed kit. Humans, CI, and agents run the **same gate**.
- **First step**: new vs existing vs nested-repo stop. Inventory. Honor
  a working stack. One hook manager, one task runner.
- Defaults table. Canonical recipe **names** (`bootstrap` / `check` /
  `test` / `ci`) whether the file is Justfile or Makefile.
- New-repo and existing-repo **checklists** (fenced). Existing is
  additive: do not rename `master`, replace Makefile, or migrate husky
  unless asked.
- **Old patterns** in `<details>` — hub only.
- File bodies: `files.md`. Machine gitconfig: `gitconfig.md`. Debugger
  **policy**: hub `debug.md`. Overlay fills JSON.

## Language overlay on hub

Open: `git-repo-setup-go`.

```
Follow `git-repo-setup` for the kit. This file fills the **Go**
commands and [debug.md](debug.md). Language idioms stay in `go-idioms`.
```

- Defaults table for that language. Honor the formatter/linter already
  gating it. **One** formatter.
- Templates: mise (pins, never `latest`), gitignore extras, Lefthook
  language commands, recipes, linter config.
- Debug section is a pointer (~6 lines). JSON lives in overlay
  `debug.md`.
- Do not repeat hub rules (one Lefthook, one Justfile, do not nest
  repos). Do not add Node/husky/commitlint to a Go or Python-only repo.
- Polyglot: also apply the other overlay. Still one `lefthook.yml`, one
  Justfile, one `.vscode/launch.json` at the Git root. Zed reads that
  file. Do not add `.zed/debug.json`.

### Debug split

| File | Holds |
| --- | --- |
| Hub `debug.md` | One `launch.json` (Cursor / VS Code / Zed), scan extensions, `dlv` / `cue` install, do not gitignore `.vscode/`, do not add `.zed/debug.json` |
| Overlay `debug.md` | That language's JSON (Encore attach, `cmd/` launch, vitest, debugpy) |
| Platform `debug.md` (`encore-go`) | Traps only. Point at the overlay JSON |

## Domain overlay

Open: `go-backend` / `go-ddd` / `go-mono-repo` / `typescript-mono-repo`
/ `go-100-mistakes-avoid` / `go-unit-tests` / `typescript-unit-tests`.

- Lead: Overlay on `parent`. What the parent still owns. Catalog link.
- **What this skill owns** (Own / Leave) when the boundary is easy to
  mix up (`go-backend` vs `encore-go`).
- **Earn …** when the default is **no** (`go-ddd`, `go-mono-repo`,
  `typescript-mono-repo`):
  fenced checklist, tick yes on at least two, or stop.
- Review workflow: fenced ticks. Fix in place. Do not add comments that
  only restate the catalog title.
- **Do not**: duplicate the parent catalog; expand rows into essays;
  restyle unrelated files in the name of this pass; load a richer
  overlay for CRUD (`go-ddd`).

`go-100-mistakes-avoid` `catalog.md`: one-line **2026 action** per row.
Language-fixed items stay out (they live in `go-idioms`).

## Vendor overlay

Open: `conventional-commits`.

- Install the official skill; **do not fork** it into `skills/`.
- This file only adds what that skill does not (HEREDOC, scopes, Go
  `/v2`, no Node toolchain on Go/Python).
- Do not rewrite the official type table here.

## Sibling filenames

Semantic, not create-skill's `reference.md` / `examples.md`.

| Name | Holds |
| --- | --- |
| `stages.md` / `artifacts.md` | Pipeline stages and templates (playbook) |
| `versions.md` | Language version catalog (Before / After) |
| `modernizers.md` | Rewrites (`go fix`, TS flags) |
| `architecture.md` | 2024–2026 structure |
| `catalog.md` | Numbered don't-do-this, one-line actions |
| `methods.md` / `domains.md` | How / where to test |
| `internals.md` / `lite.md` | Overlay recipes |
| `layouts.md` | Trees |
| `files.md` / `gitconfig.md` | File bodies the agent writes (hub). Docs playbook: which `.md` file |
| `types.md` | Column types (`data-modeling`) |
| `collections.md` / `algorithms.md` | In-memory chooser (`choose-collections`) |
| `readme.md` / `english.md` / `stacks.md` | README shapes, Google English, language/renderer |
| `debug.md` | JSON or traps (see Debug split) |
| `primitives.md` / `infrastructure.md` / `determinism.md` / `workers.md` | Platform catalogs |
| `tooling.md` | Vendor-overlay recipes |

Link them from SKILL.md once. Keep references one level deep.
