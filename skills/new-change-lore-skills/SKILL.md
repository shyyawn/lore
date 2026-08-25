---
name: new-change-lore-skills
description: >-
  Creates and changes Agent Skills in this lore repo (skills/<name>/) to
  the house look: short sentences, one bold word, tables, Do not; one
  rule once; SKILL.md is the spine. Overlay on Cursor's create-skill
  (frontmatter, 500-line cap — lore spines are shorter). Use when adding,
  editing, reviewing, or shortening any skill under skills/ — Go or a
  playbook with none of that (requirement-to-architecture-to-design);
  when the user mentions new-change-lore-skills, lore skill prose, or
  house voice.
---

# New / change lore skills

How **this repo** writes `skills/`. Load this for **any** new or changed
lore skill — stack or playbook. Frontmatter: Cursor `create-skill`.
Look: [voice.md](voice.md). Kinds: [kinds.md](kinds.md). Final form,
names, sources: [family.md](family.md). Do not copy vendor or plugin
skills into `skills/` (README **Who wins**).

`create-skill` defaults `disable-model-invocation: true`. Lore **omits**
it so skills auto-invoke. Do not inline another skill's catalog here.

Canon look: `git-repo-setup`, `go-ddd`, `go-idioms` — copy the
sentences, not the domain. Editing an existing skill: copy **that
file's** headings, not this stub.

## First step

1. Directory `skills/<name>/` = YAML `name` (lowercase hyphens). Durable:
   `go-idioms`, not `go-2026`. Pipeline: stages in the name
   (`requirement-to-architecture-to-design`). [family.md](family.md).
   Write the **final form**. Do not ship a dated mega-skill and split
   later.
2. Pick the kind ([kinds.md](kinds.md)). Closest sibling of **that**
   kind exists → copy **its** headings. No sibling (new playbook) → this
   stub + [voice.md](voice.md). Do not paste `go-idioms` headings onto a
   design skill, or this stub over `encore-go`.
3. Research ([family.md](family.md)). Name **Sources** and what not to
   copy. Inventory what is already there. Honor it. Code: read the pin
   (`go.mod`, lockfile, `encore.app`, SDK). Do not bump it. If a skill
   already owns this, **stop**.
4. Overlay: child **names what it overrides**; parent gets a one-line
   pointer. New domain: a hub or a lone playbook — do not hang it under
   `go-idioms`. README Skills table gets a row.
5. A new fact is a table row, a template, or a Hard-rules bullet. A
   paragraph of why does not belong ([voice.md](voice.md)).

Before editing: `make install` if `~/.cursor/skills` is empty.
After a lore skill change: `make install`.

## Voice

[voice.md](voice.md). Short sentences. One **bold** load-bearing word.
`Do not` is the refusal. Tables for maps; numbered for procedure;
bullets for never-generate. 2–4 line lead, then a heading.

One rule once. Skip a section that has nothing to say. Title may say
`2026`. Directory and YAML `name` must not.

Folded YAML `description: >-`. Third person. WHAT + WHEN. Triggers are
domain terms the agent will see. Overlay adds `Overlay on parent`.
Pipeline adds the stage names. This skill's own name is a trigger
because "lore skill prose" would not find `go-idioms` — do not put
every skill's name in its description.

## `SKILL.md`

````markdown
---
name: example-playbook
description: >-
  WHAT it does. Use when WHEN (triggers).
---

# Example playbook

One sentence what it is. Do not <the obvious failure>.
Sources: official X. Not their tree.
Stages: [stages.md](stages.md).

## First step

1. Inventory what is already there. Honor it.
2. If a more specific skill already owns this, **stop**.

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Artifact | one committed template | Repo already has a working format |

## Do not

- Restyle unrelated files.
- Skip a stage as a drive-by.
````

This stub is the **no-sibling** case (new playbook). A language, kit,
or overlay skill copies the closest canon in [kinds.md](kinds.md), not
this template. Overlay lead: `Follow parent. This file fills **X**.`
plus `Overlay on parent` in the description.

Skip a section that has nothing to say. `VERSION` in templates, never
the string `latest`. Sibling `.md` files hold catalogs and file bodies —
link once, one level deep. Cross-skill JSON that already exists:
`../git-repo-setup-go/debug.md` (kit only). Do not recopy.

create-skill's 500-line cap is the ceiling. Lore spines are shorter:
catalog overlay ~60–80, language ~130–180, hub/platform/app-structure/
playbook ~180–270. If SKILL.md jumps ~80 lines for one topic, that body
belongs in a sibling.

| Section | Holds | Skip unless |
| --- | --- | --- |
| Frontmatter | WHAT + WHEN. Third person | — |
| Title + 2–4 lines | What it is; Sources; pointers | — |
| **First step** | Numbered. Inventory; honor; stop-and-follow | — |
| Defaults table | `Job \| Default \| Honor instead when` | A choice with an escape hatch |
| **Hard rules** | Invariants, not a menu | Compiler / platform / process law |
| **Division of labor** | Who owns which artifact / stage | Pipeline, combined stack |
| **Earn …** | Default-no; tick yes on ≥2 or stop | Next stage is expensive |
| **Choose a layout** / **Growth** / stages | Situation → path; numbered | App-structure, hub, pipeline |
| **What this skill owns** | Own vs Leave | Overlay whose boundary mixes easily |
| **Need \| Use \| Do not add** | Platform/stdlib-first | Language / platform coding |
| Version table | Pin → Always use / Not yet | Language skills |
| **Default shapes** | Concrete artifact from official sources | Platform, app-structure, pipeline |
| Templates | File body the agent writes | Kit / overlay / playbook artifacts |
| **After every edit** | Gate for the **target** (gofmt, encore check) | Skills that edit that target. Lore itself: `make install` |
| **When it breaks** | Symptom → cause | Traps the agent will hit |
| Checklists | Ticks in a fenced block | Workflows and review overlays |
| **Do not add** | Competing tool already covered | Platform / language / playbook method |
| **LLM traps** | Never-generate list | Language, platform, domain, playbook. Hub kit often skips |
| **Do not** | Process (restyle, skip a stage, wrong skill) | — |
| **Old patterns** | `<details>` | Kit hub (`git-repo-setup`). Authoring hub: Final form table |

Kind recipes and sibling filenames: [kinds.md](kinds.md).

Copy and tick:

```
New lore skill:
- [ ] Final form now — not `foo-2026` to rename, not a blob to split later
- [ ] Kind; copy that kind's headings — or this stub + voice.md
- [ ] Looks like lore ([voice.md](voice.md)), even if the domain is new
- [ ] Sources named; inventory existing; not a plugin fork
- [ ] Overlay → parent pointer. New domain → own hub/playbook
- [ ] README Skills row; catalogs in siblings
- [ ] make install

Change lore skill:
- [ ] That skill's headings, not this stub
- [ ] One rule once; fill gaps; honor working stack
- [ ] No unrelated restyle
- [ ] make install
```

## When it breaks

| Symptom | Usually means |
| --- | --- |
| SKILL.md jumped ~80 lines for one topic | Body belongs in a sibling `.md` |
| Overlay Debug section > ~6 lines | JSON already lives in overlay `debug.md` |
| Same sentence in hub + overlay + sibling | Leave it in the hub |
| New skill ignores existing artifacts / the pin | First step did not inventory |
| Two skills own the same rule | Child did not name the override |
| Directory still has a year (`go-2026`) | Dated names were renamed away. Durable noun. |
| New skill is a mega-file "to split later" | Split on pressure **now** ([family.md](family.md#final-form)) |
| Skill restates `create-skill` Examples / Overview | Lore skips those. [voice.md](voice.md). |
| Catalog row grew an essay | One-line action, not a blog |
| New skill reads like a tutorial | Short sentences, table, Do not. No Overview. |
| Design playbook copied `go-idioms` headings | Wrong kind. Workflow kind + this stub. |
| Two owners of the same artifact | Missing **Division of labor** / Earn |

## LLM traps — never generate these

- Year in the directory / YAML `name`; a follow-up "we'll rename it"
- `disable-model-invocation: true` copied from create-skill's default
- Overview / Background / Notes / Examples / "It is important that"
- Bold whole sentences, emoji, ALL CAPS
- A fork of a Cursor plugin or `conventional-commit-message` under `skills/`
- `@latest` in a command the agent will run
- This stub pasted over an existing skill; `go-idioms` headings pasted
  onto a non-Go playbook
- A second copy of a skill instead of an overlay
- Hexagonal / TOGAF / clean-architecture folders as the default lore layout
- RC / beta / preview APIs, `@next` encyclopedias, or ship calendars

## Do not

- Replay this repo's changelog (dated name → rename → split → tighten).
  Write the final form. Pressures: [family.md](family.md#final-form).
- Invent a second skill shape. Copy the sibling of that kind — or this
  stub + [voice.md](voice.md) when there is no sibling.
- Hang a non-code playbook under `go-idioms` / `encore-go`.
- Restate a defaults-table row in Debug or Do not.
- Recite a sibling file (JSON, catalog, artifact template) in SKILL.md.
- Expand catalog rows into essays.
- Fork `create-skill`, `conventional-commit-message`, or a Cursor plugin
  into `skills/`.
- Restyle unrelated skills in the name of a tighten pass.
- Bump a pin (language, SDK, or a playbook's chosen method) to unlock a
  line in the skill.
- Teach a vendor encyclopedia unless the target already has it (and the
  sibling skill already says so).
