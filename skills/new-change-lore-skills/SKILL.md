---
name: new-change-lore-skills
description: >-
  Creates and changes skills in this lore repo (skills/<name>/) to the
  house voice: defaults table, file template, one-line rule, short Do not;
  one rule once; SKILL.md is the spine. Overlay on Cursor's create-skill
  (frontmatter, 500-line cap). Use when adding, editing, reviewing, or
  shortening a lore skill; when the user mentions new-change-lore-skills
  or skill prose.
---

# New / change lore skills

How **this repo** writes `skills/`. Frontmatter and discovery: Cursor
`create-skill`. Voice: `git-repo-setup` and overlays, `go-idioms`,
`go-100-mistakes-avoid`, `encore-go`, `typescript-idioms`. Do not copy
vendor or plugin skills into `skills/` (README **Who wins**).

This file is the authoring bar. Domain catalogs stay in those skills.

## First step

1. Directory `skills/<name>/` = YAML `name` (lowercase hyphens).
2. Open the sibling this skill overlays or sits next to. Copy **its**
   headings (Hard rules, After every edit, LLM traps — only if that
   sibling has them). Do not paste this stub over `go-idioms`.
3. Hub owns kit-wide rules. Overlay fills that language's commands and
   file bodies. Child **names what it overrides** on the parent
   (`encore-go` on `go-idioms`: layout, HTTP, log, tests).
4. Read the pin (`go.mod`, `package.json` `typescript`, `encore.app`).
   Do not bump it to unlock an idiom. Match existing shape. Existing
   repos: fill gaps; honor a working stack.
5. A new fact is a table row or a template. A paragraph of why does not
   belong. If X is already in the tree, **stop** and follow that skill
   (`go.temporal.io/sdk` → `encore-temporal-go-app-structure`).

After a lore skill change: `make install`.

## `SKILL.md`

````markdown
---
name: example-overlay
description: >-
  WHAT it does. Use when WHEN (triggers). Overlay on parent-skill.
---

# Example overlay

Follow `parent-skill` for the kit. This file fills **X**.
Catalog: [catalog.md](catalog.md).

## First step

1. Read `go.mod` / lockfile / `encore.app`. Do not bump the pin.
2. Honor what is already there.

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Format | `gofmt` | `gofumpt` already in `tool` |

## After every edit

```bash
gofmt -w <files>
```

## Do not

- Restyle unrelated files.
````

Skip a section that has nothing to say. No Overview / Background / Notes.
`VERSION` in templates, never the string `latest`. Sibling `.md` files
hold catalogs and file bodies — link once, one level deep.

| Section | Holds | Skip unless |
| --- | --- | --- |
| Frontmatter | WHAT + WHEN. Third person | — |
| Title + 2–4 lines | What it is, pointers to siblings and peers | — |
| **First step** | Numbered. Read the pin; match existing shape | — |
| Defaults table | `Job \| Default \| Honor instead when` | Use **Hard rules** when the sibling is Encore layout (compiler invariants), not a menu |
| Templates | File body (`mise`, Lefthook, JSON) | Kit / overlay skills |
| **After every edit** | The bash gate (`gofmt`, `encore check`, `go test`) | Domain skills that edit code |
| **When it breaks** | Symptom → cause | Traps the agent will hit |
| Checklists | Ticks in a fenced block | Workflows (`git-repo-setup`, `go-100-mistakes-avoid`) |
| **LLM traps** | Never-generate list | Language skills (`go-idioms`, `go-100-mistakes-avoid`) |
| **Do not** | Short bullets | — |
| **Old patterns** | `<details>` | Hub skills only |

| Kind | Fills | Does not |
| --- | --- | --- |
| Hub | Inventory, new vs existing, one hook manager, one task runner | Language commands |
| Language overlay | Formatter, test, linter config, overlay JSON | Repeat the hub |
| Domain overlay | The extra catalog | Duplicate the parent catalog |
| App-structure | Package layout; sources = official docs, not a fork | Recite the coding skill |

Polyglot: `also apply X. One lefthook.yml, one Justfile.` Language ticks
live in the overlay, not the hub checklist.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| SKILL.md jumped ~80 lines for one topic | Body belongs in a sibling `.md` |
| Overlay Debug section > ~6 lines | JSON already lives in overlay `debug.md` |
| Same sentence in hub + overlay + sibling | Leave it in the hub |
| New skill ignores `encore.app` / `go.mod` | First step did not read the pin |
| Two skills own the same layout rule | Child did not name the override |

## Do not

- Invent a second skill shape. Copy the sibling.
- Restate a defaults-table row in Debug or Do not.
- Recite JSON that already lives in a sibling `debug.md`.
- Expand catalog rows into essays (`go-100-mistakes-avoid`).
- `disable-model-invocation: true` unless the user asked for slash-only.
- Fork `create-skill`, `conventional-commit-message`, or a Cursor plugin
  into `skills/`.
- Leave `@latest` in a command the agent will run.
- Restyle unrelated skills in the name of a tighten pass.
- Bump `go` / `typescript` / Encore to unlock a line in the skill.
