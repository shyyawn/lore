# Voice

How lore sounds. Domain-agnostic. A future
`requirement-to-architecture-to-design` uses this file even though it
has no Go in it. Headings and kinds: [SKILL.md](SKILL.md),
[kinds.md](kinds.md).

Canon look (copy the sentences, not the domain): `git-repo-setup`
lead, `go-ddd` "Default is **no**", `go-idioms` "Read `go.mod`. Target
that version."

## Sentence

One clause. Then a period. Then the contrast.

| Shape | Example |
| --- | --- |
| Imperative. Imperative. | `Read go.mod. Target that version.` |
| Claim. Contrast. | `Rich domain only. Default is **no**.` |
| Do X. Do not Y. | `Write the modern form the first time. Do not write old Go and wait.` |
| Fragment punch | `Pick these. Do not offer a menu.` |
| Stop. | `If every line is "no", stop.` |

Wrap prose ~76 cols. Two clauses is the ceiling. No "This section
explains", "It is important", "Note that", "simply", "feel free".

Colon introduces a table or a fence, not an essay. Em dash for a tight
aside (`Default is no — earn the aggregate first`). Semicolon almost
never.

## Emphasis

Tone is a **few** marked words, not a louder paragraph.

| Mark | For | Not |
| --- | --- | --- |
| `**bold**` | One load-bearing word: **no**, **stop**, **same gate**, **Honor**, **not** | A whole sentence or heading |
| `` `code` `` | Files, commands, skill names, identifiers | Emphasis or jargon (`the \`gate\`` as a metaphor) |
| *italic* | Almost never (one contrast: `just` recipes *and* a Makefile) | Warnings, titles |
| `Do not` | The refusal verb | "Avoid", "Please don't", "You shouldn't", "It's recommended that" |

One bold per sentence. Never emoji, never ALL CAPS, never a bold
paragraph. Backticks are names, not stress.

House verbs: Honor, fill gaps, drive-by, stop, earn, overlay, fills
**X**, one rule once, working stack, concrete. Use them. Do not define
them.

## Table, list, fence

Pick one shape. Do not say the same fact in a paragraph *and* a table.

| Shape | When |
| --- | --- |
| Table | Mapping, choosing, comparing (Job/Default/Honor; Need/Use/Do not add; Symptom/cause; Situation/path; Own/Leave) |
| Numbered | Ordered procedure (**First step**, growth stages) |
| `-` bullets | Never-generate / **Do not**. One line each |
| Fenced ticks | Copy-and-tick workflow. Label the fence (`Earn DDD Lite:`) |
| Fenced code / tree | The artifact to write. `VERSION`, never `latest` |
| `<details>` | Old patterns. Hub only |
| 2–4 line lead | Right under the title. What it is, pointers, Sources. Then a heading |

A paragraph of why does not belong. If a row needs a gloss, one short
contrast after the table, not a preamble.

## Lead

After `# Title`, two to four lines:

```
One sentence what it is. Do not <the obvious failure>.
Pointers: `peer-skill`, [catalog.md](catalog.md).
Sources: official X, starter Y. Not their tree.
```

No Overview. No Background. No "In this skill we will".

Overlay lead: `Follow parent for the kit. This file fills **X**.`

Pipeline lead: `Requirements then architecture then design. Do not skip
a stage. Default is **no** on jumping ahead.`

## Default vs invariant

| Kind of fact | Shape |
| --- | --- |
| A choice with an escape hatch | `Job \| Default \| Honor instead when` |
| Compiler / platform / process law | **Hard rules** bullets, not a menu |
| Competing tool the platform already covers | **Do not add** table (`Need \| Use \| Do not add`) |
| Code the model will emit unasked | **LLM traps** |
| Process (restyle, skip a stage, wrong skill) | **Do not** |

Pick these. Do not offer a menu. Honor what is already there.

## Contrast pairs

The second sentence does the work of a paragraph of why:

- `X. Not Y.`
- `Use A. Do not add B.`
- `Sources: official docs. Not their tree.`
- `Ideas, not trees.`
- `Fill gaps. Honor a working stack.`
- `Do not restyle … as a drive-by.`

If the contrast is gone, the sentence is probably filler. Cut it.
