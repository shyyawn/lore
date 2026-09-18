# ATS

Parse first, then a human in seconds. Job CVs only. A base CV still
follows this format. Do not treat keywords as a game.

Freelance listing: `customize-cv-freelance`. Job LinkedIn:
`customize-cv-linkedin`. Do not apply this file to an Upwork
page, a pass-along listing, or a LinkedIn About.

Sources: Jobscan ATS anatomy 2026. Not a scanner product. Not their
admin trees. Semantic screeners score **meaning**. Exact strings
still matter for recruiter search and older ATS.

## Format

| Rule | Do | Do not |
| --- | --- | --- |
| Columns | One column, full width | Sidebar, two-column, text boxes |
| Headings | `## Summary`, `## Skills`, `## Experience`, `## Education` | "What I bring", "Core competencies" as a H1 |
| Contact | First lines of the body. No `\|` pipes | Header, footer, icon row, a Markdown table |
| Dates | `MM/YYYY–MM/YYYY` or `MM/YYYY–Present` | Year-only (`2019`) or `2019-Present` |
| Fonts | Arial, Calibri, Georgia, Garamond, Times, 10–12 pt | Decorative fonts, skill bars |
| Margins | 0.5–1 in | Packed 0.3 in walls |
| Bullets | Markdown `-` or plain circles | Checkmarks, arrows, custom symbols |
| Graphics | None | Photo, logo, chart, icon |
| Tables | None in the CV | Skills in a grid |
| File | Markdown. Export: SKILL.md Defaults | Scanned PDF, `.pages`, image PDF |

Jobscan: single column, standard headings, contact in the body.
Columns, headers, and tables scramble the reading order. Two pages
parse. A second page is still earned in SKILL.md. `## Experience`
is the house heading. Do not invent "My Journey".

Experience is the spine. Do not add a Projects-first block — that
is `customize-cv-freelance`. Staff+ fold shipped products into
Experience bullets. Certifications only if SOURCE has them.

Working file is Markdown. Export is `.docx` or a text PDF when
Defaults earn it. Reverse chronological. Not functional /
skills-first.

## Keywords

Skip this section on a **base** CV. Skills come from bullets that
prove the lane, plus SOURCE inventory those bullets already use.

Hybrid 2026: overlap on must-haves, not a score. Exact spelling for
tools and credentials the source can defend. Semantic overlap for
responsibilities. A skill listed only in Skills, never in a bullet,
fails both. Schellmann (NPR): some tools throw out near-copies of
the posting. Mirror terms in XYZ bullets. Do not paste sentences.
White text is detected.

1. List JD must-haves (tools, domains, level words).
2. Keep those the career source supports.
3. Place each in Experience (preferred) or Skills. Once or twice in
   context. Not ten times.
4. Expand on first use when the JD uses both (`CI/CD` after
   `continuous integration`).
5. Title: Experience keeps the HR title. Summary lane matches the
   JD. A parenthetical only if it maps without lying (`Staff Engineer
   (Platform / Identity)`). Do not relabel VP/SVP as Staff in
   Experience.

Skills groups are plain comma lists. Empty groups omit.

## Before send

```
ATS + density:
- [ ] Single column; no table, text box, photo, header/footer contact
- [ ] Standard headings
- [ ] MM/YYYY on every role
- [ ] Each JD must-have is in a bullet or Skills, or told to the
  user as a gap — not printed (n/a if base)
- [ ] No pasted JD sentence
- [ ] Current role is the densest block
- [ ] Every number is in the career source
- [ ] Plain-text paste still reads in order
```

A made-up "87% ATS match" is not a tick.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| Parser empty / dates missing | Columns, tables, headers, or contact in the footer |
| Rejected for JD copy | Pasted posting; AI overlap trap |
| Skills never appear in bullets | Listed for density; no proof |
| Recruiter bounce in seconds | Keyword wall above Experience |

## LLM traps — never generate these

- Two-column résumé template (Canva, moderncv)
- Contact in header or footer
- Functional resume as the default
- White-text keywords or prompt injection
- JD sentences pasted into Summary or bullets
- Projects-first block on a job CV
- `@latest` "ATS score 100" theatre
