# Family, names, sources

How lore skills relate, what to call a new one, and how they were
researched. Shape: [SKILL.md](SKILL.md). Look: [voice.md](voice.md).
Kinds: [kinds.md](kinds.md).

## Final form

Write the **final form** the first time. Same rule as `go-idioms`: do
not emit `go-2026` and wait for a rename.

The Aug 17–19 path (dated name → troubleshooting → split layout →
hub/overlay → catalog overlays → tighten) is **paid-for pressure**.
Do not replay it as a lifecycle. Apply the pressure **while authoring**.

| Pressure (do this now) | Not (we already did this) |
| --- | --- |
| Durable name (`go-idioms`). Title may say 2026 | Directory `go-2026` / `encore-go-2026` |
| Coding skill + app-structure when layout fights coding | One mega file that scaffolds *and* restyles |
| Combined skill when two platforms meet | Stuff Temporal into `encore-go` |
| Overlay / don't fork vendor | Copy a plugin or `conventional-commit-message` into `skills/` |
| Table / template / one-line rule | Essay SKILL.md, "tighten later" |
| Sibling when one topic is ~80 lines | Blob SKILL.md, "split later" |
| Child names the override; parent points back | Silent contradiction; copied catalogs |
| Overlay drops rows the parent already solved | Language-fixed mistakes restated |
| Debug JSON in overlay `debug.md` | Recite JSON in SKILL.md |
| Hub + language overlay; one Lefthook, one Justfile | A kit per language, stacked hook runners |
| `When it breaks` for traps the agent will hit | No troubleshooting until the first incident |
| Earn / default **no** for an expensive next stage | Always-on DDD / always-on second `go.mod` |

How to land on that form in **one pass**:

1. Research ([Sources](#sources-research)). Inventory. Honor existing.
2. Durable name. Kind ([kinds.md](kinds.md)). New domain → hub or
   playbook, not a hang-off `go-idioms`.
3. Spine in [voice.md](voice.md). Lead, First step, table or Hard rules,
   Do not. Catalogs in siblings from the first write.
4. Two jobs or ~80 lines for one topic → split **in this pass**.
5. Parent pointer + README row + `make install`.

Tighten is for a **change** to a skill that already drifted. It is not
a planned phase of a new skill.

## New domain

The overlay table below is this repo's **current** stack. A skill that
is not Go, TypeScript, Encore, Temporal, or Svelte does **not** hang
under `go-idioms`. It is a hub, a lone playbook, or the start of a new
family.

| Situation | Do |
| --- | --- |
| Same job, narrower fill | Overlay. Child names the override. Parent points back. |
| New job, no parent | Lone playbook. Stub + [voice.md](voice.md). |
| New job that will grow overlays | Hub **now** (`git-repo-setup` shape). A later overlay is a **new** skill when that facet exists — not a phase of the hub |
| Two jobs that meet | Combined skill (`encore-temporal-go-app-structure` shape). |
| Already owned in the tree | **Stop.** Follow that skill. |

Example: `requirement-to-architecture-to-design` is a workflow playbook.
It is not an overlay on `encore-go`. A later
`requirement-to-architecture-to-design-encore` would overlay it.

## Overlay family (current stack)

Do not invent a parallel `go-idioms`, a second `encore-go`, or a second
`svelte`. Find the cell. Add a child. Point both ways.

| Skill | Kind | Parent | Overrides / fills |
| --- | --- | --- | --- |
| `new-change-lore-skills` | authoring | Cursor `create-skill` | House voice. Not a fork of create-skill. |
| `conventional-commits` | vendor overlay | `conventional-commit-message` (install, don't copy) | Go/Python/TS scopes, HEREDOC, no Node on Go/Python |
| `git-repo-setup` | hub | — | Kit: init, Lefthook, mise, just/Make, ignore, debugger policy |
| `git-repo-setup-go` | language overlay | `git-repo-setup` | Go commands + Delve JSON |
| `git-repo-setup-typescript` | language overlay | `git-repo-setup` | Biome/tsc/vitest + Node JSON |
| `git-repo-setup-python` | language overlay | `git-repo-setup` | uv/ruff/pytest + debugpy JSON |
| `create-readme-and-other-markdown-documentation` | workflow / playbook | — | README and other Markdown. Kit still owns bootstrap existence |
| `go-idioms` | language | — | Go 1.18–1.26 + 2024–2026 flatten layout |
| `typescript-idioms` | language | — | TypeScript 5–7 + 2024–2026 flatten layout |
| `svelte` | platform | `typescript-idioms` + Svelte plugin | Pin, experimental default-no, `$app/state`. Not a fork of the plugin |
| `sveltekit-app-structure` | app-structure | `svelte` | `src/routes` / `$lib`. Coding stays in `svelte` + plugin |
| `go-100-mistakes-avoid` | domain overlay | `go-idioms` | Still-in-force mistakes. Not language-fixed rows. |
| `go-unit-tests` | domain overlay | `go-idioms` | Tables, synctest, fuzz, what to skip. Encore runner stays `encore-go`. |
| `go-backend` | domain overlay | `go-idioms` | Inside a service. Encore still owns process layout. |
| `go-ddd` | domain overlay | `go-backend` | Aggregates. Default is no. |
| `go-mono-repo` | domain overlay | `go-idioms` | How many `go.mod`. Encore stays one `encore.app`. |
| `encore-go` | platform | `go-idioms` | Layout, HTTP, log, errors, tests |
| `temporal-go` | platform | `go-idioms` | Inside workflow functions: determinism |
| `encore-go-app-structure` | app-structure | `encore-go` | Package layout. Coding stays in `encore-go`. |
| `temporal-go-app-structure` | app-structure | `temporal-go` | samples-go / OMS trees. Coding stays in `temporal-go`. |
| `encore-temporal-go-app-structure` | combined | both app-structure skills | Seam service. Use when `encore.app` **and** `go.temporal.io/sdk`. |

Stop-and-follow (already in the tree → that skill, not a new one):

| Detect | Follow |
| --- | --- |
| `encore.app` | `encore-go` + `encore-go-app-structure` (not `go-idioms` `cmd/`) |
| `go.temporal.io/sdk` without `encore.app` | `temporal-go` + `temporal-go-app-structure` |
| Both | `encore-temporal-go-app-structure` |
| `svelte.config.*` + `@sveltejs/kit` | `svelte` + `sveltekit-app-structure` |
| `svelte.config.*` without Kit | `svelte` (Vite). Do not add Kit as a drive-by |
| `encore.app` + `svelte.config.*` | Encore skills for the API; `svelte` + `sveltekit-app-structure` for the UI |
| Several `go.mod` / `go.work` | `go-mono-repo` |
| Commit message / squash PR title | `conventional-commits` (official skill first) |
| Hooks, mise, just, `launch.json`, Zed debugger | `git-repo-setup` + language overlay |
| `README.md` / health files / `docs/**/*.md` content | `create-readme-and-other-markdown-documentation` |

## Naming

Directory = YAML `name`. Lowercase hyphens. Max 64 chars.

| Pattern | Example | Not |
| --- | --- | --- |
| Durable noun | `go-idioms`, `encore-go`, `temporal-go`, `svelte` | `go-2026`, `svelte-typescript` |
| Pipeline | `requirement-to-architecture-to-design` | `rta`, `design-2026`, `helper` |
| Hub | `git-repo-setup` | `git-kit`, `repo-helpers` |
| Hub + facet | `git-repo-setup-go` | `go-git-hooks` (hides the hub) |
| Domain overlay | `go-unit-tests`, `go-backend`, `go-ddd` | Fusing into the parent |
| Avoid catalog | `go-100-mistakes-avoid` | `go-mistakes` (vague) |
| App-structure | `encore-go-app-structure`, `sveltekit-app-structure` | `encore-go-layout`, `svelte-ui-kit-typescript` |
| Combined | `encore-temporal-go-app-structure` | Stuffing B into A's file |

Title may include the current line (`# Go 2026`). The **directory**
must survive next year.

Vague names (`helper`, `utils`, `tools`) are create-skill anti-patterns
here too.

## Sources (research)

1. **Official docs first.** Name the path in SKILL.md.
2. **Named starters / case studies**, then say what **not** to copy
   (ideas, not trees). Current stack:

   | Source | Take | Leave |
   | --- | --- | --- |
   | Encore `uptime`, `trello-clone`, `booking-system` | Service = package, systems as directories | A second `encore.app` |
   | `temporalio/samples-go`, `reference-app-orders-go` (OMS) | File split, Task Queue ownership, roles | OMS HTTP servers inside Encore |
   | `ardanlabs/service` | Data-oriented types, wiring at the edge, consumer-side interfaces | `api/` / `business/` / `foundation/` tree, Makefile, k8s kit |
   | Three Dots Labs Wild Workouts **DDD Lite** articles | Aggregates, VOs, events as values, Get/Save | `app/` / `domain/` / `adapters/`, Watermill, Firebase |
   | kubernetes `go.work` + `staging/` | Lockstep publish siblings | Copy unless you actually publish |
   | github/gitignore, Lefthook, mise, just docs | File bodies and pin commands | A second hook runner |
   | Svelte `kit/project-structure`, `sv create` | `src/routes`, `$lib`, `$lib/server` | Plugin runes catalog; Kit 3 `@next` trees |

   A playbook: name the method (C4, ADR template, a named case study).
   Leave the vendor encyclopedia and the blog's folder schema.

3. **Version-gate on the pin** (code skills). Teach versions that exist.
   Do not bump `go.mod` / `typescript` / the SDK to unlock a line.
   Playbooks: do not bump the chosen method to unlock a fashion.
4. **Write the modern form the first time.** Do not emit the old form
   and wait for a fixer.
5. **Solved vs still-in-force.** Overlay catalogs drop rows the parent
   already solved.
6. **Override, named.** Invariants are Hard rules. A child that fights
   the parent names the override.
7. **Do not fork vendor docs.** Plugins and
   `conventional-commit-message` stay upstream. Overlay the gap. README
   **Who wins**.

Formula on the SKILL.md lead:

```
Sources: <official docs>, starter <name>. Not their tree.
```

Stdlib-first / platform-first is the same instinct: **Need | Use | Do
not add**. Playbooks: do not add a second method the current one covers.

## Parent pointer and README

Adding an overlay is not only the new directory.

1. One line in the **parent** SKILL.md (and any sibling that would
   otherwise duplicate): `Service internals: go-backend.` Do not restyle
   those files.
2. A row in the lore README Skills table.
3. `make install` (copies, not symlinks).

Changing a skill: fill the gap in **that** file. Do not drive-by
rewrites of peers "for consistency" unless the user asked for a tighten
pass on those names.

## Who wins (do not vendor)

| Source | Owns | Do not also |
| --- | --- | --- |
| This repo | Practice in `skills/` (stack or playbook) | Copy plugin encyclopedias into `skills/` |
| Encore / Temporal / Svelte Cursor plugins | Live MCP, official vendor how-tos | `npx add-skill` of the same vendor |
| Svelte plugin | Runes, autofixer, live docs | A lore `svelte-core-bestpractices` |
| This repo `svelte` / `sveltekit-app-structure` | Pin, experimental default-no, Kit tree | Kit 3 `@next`; a runes catalog |
| `conventional-commit-message` | Commit **format** | A lore fork of its type table |

`make uninstall` would wipe a fork. You would be maintaining vendor
docs. Overlay the gap (`conventional-commits`) or point at the plugin.

## Install

Skills live at repo-root `skills/<name>/` (public skill-library layout).
`make install` copies each directory to `~/.cursor/skills`. Re-run after
every change. `make status` reports drift. Do not create skills in
`~/.cursor/skills-cursor/`.
