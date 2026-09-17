---
name: customize-cv
description: >-
  Writes a software CV (IC, Manager) or a freelance profile from a
  career source, tailored to a job description when one exists,
  otherwise a base variant, as Markdown. Use when writing, customizing,
  or reviewing a CV, resume, application, Upwork, Fiverr, Toptal,
  LinkedIn Services, or freelance profile; when the user mentions ATS,
  Staff Engineer, Principal, Software Architect, Engineering Manager,
  VP, SVP, LinkedIn headline, About, Open to Work, freelance, gig,
  marketplace, contract CV, base CV, tailor resume, cover letter,
  SOURCE.md, career dump, LinkedIn export, or export PDF / docx.
---

# Customize CV 2026

One **file** per ask. Job CV, listing, job LinkedIn, letter, or
`SOURCE.md`. Do not dump a career onto a CV. Do not write a derived
file when the ask is the source.

Sources: Laszlo Bock XYZ (`Accomplished [X] as measured by [Y] by
doing [Z]`); Jobscan ATS anatomy 2026 (single column, standard
headings); DORA (`dora.dev`) five delivery metrics for Manager;
Larson Staff Engineer archetypes for the IC lane. Job LinkedIn:
headline / About practice. Freelance listing: Upwork profile tips,
Fiverr profile/gig guides, LinkedIn Services. Not Canva.

Variants: [variants.md](variants.md). Profile:
[freelance.md](freelance.md). LinkedIn: [linkedin.md](linkedin.md).
Parse: [ats.md](ats.md). Tone: [tone.md](tone.md). Cover:
[cover.md](cover.md). Career source: [career.md](career.md).
`<folder>` is the directory that holds `SOURCE.md` (usually
`career/`).

## First step

1. Inventory what is already there. Honor it.

   `career/SOURCE.md` (or `career/*.md`), `cv/`, `resume/`, `CV.md`,
   `RESUME.md`, an existing file under `<folder>/out/`.
2. Freelance profile / Upwork / Fiverr / Toptal / LinkedIn Services /
   pass-along / "freelance page" → **stop** the job-CV workflow.
   Follow [freelance.md](freelance.md). Do not apply [ats.md](ats.md).
3. Job LinkedIn (headline, About, Featured, Open to Work) →
   [linkedin.md](linkedin.md). Do not apply ATS no-photo. Do not use
   [freelance.md](freelance.md) unless they asked for Services.
4. Reviewing an existing **job** CV → [ats.md](ats.md) Before send.
   Honor the file. Do not rewrite as a drive-by.
5. If a more specific skill already owns this, **stop**.

   | Detect | Follow |
   | --- | --- |
   | README / ADR / docs body | `create-readme-and-other-markdown-documentation` |
   | Lore `skills/*/SKILL.md` | `new-change-lore-skills` |
   | Cover letter (asked or required) | [cover.md](cover.md) |
   | `SOURCE.md` / career dump | [career.md](career.md) |
6. No career source → **stop** and ask for an existing CV, a LinkedIn
   export, or notes. A paste is enough. Ask is `SOURCE.md` only →
   [career.md](career.md). **Stop.** Do not invent. Do not put that
   file in this lore repo.
7. Job CV: JD present → split must-haves from nice-to-haves. No JD →
   **base**. Name the variant ([variants.md](variants.md)). IC lane
   from the JD title, else SOURCE Lanes, else ask. VP/SVP is Manager
   org-shape, not a fourth variant.
8. Copy the matching workflow. Tick it. Letter asked or required →
   [cover.md](cover.md) after the CV.

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Career source | `career/SOURCE.md` | paste for one file; `career/*.md` / `cv/` already there |
| Tone | [tone.md](tone.md) | user named a different voice |
| Artifact | job CV (IC / Manager) | freelance → [freelance.md](freelance.md); job LinkedIn → [linkedin.md](linkedin.md) |
| Mode | tailor to the JD | no JD in the ask → base |
| Variant | from the JD | user named; else SOURCE Lanes (ask if several) |
| IC lane | JD title (Staff / Principal / Architect / Senior) | user named; else SOURCE Lanes |
| Manager sub-lane | EM | JD or SOURCE says Head / VP / SVP → org-shape ([variants.md](variants.md)) |
| Pages | **one** | Earn a second page (job CV only) |
| Layout | reverse chronological, single column | job CV only. Profile: [freelance.md](freelance.md) |
| File to write | Markdown in `<folder>/out/` | user named a path |
| Slug | `<company>-<role>-<variant>.md` | no JD → `base-<variant>.md`; else the sibling |
| Export | Markdown only | PDF when asked; portal → `.docx` |
| PDF tool | `pandoc` + an engine on PATH (typst, weasyprint, pdflatex) | — |
| Cover letter | **no** | portal requires it, or the user asked |

## Division of labor

| Artifact | Owner |
| --- | --- |
| Career facts (dates, titles, metrics) | `career/` or the user's paste |
| Variant, lane, which evidence ships | this skill |
| Job CV ATS parse and headings | this skill ([ats.md](ats.md)) |
| Freelance profile copy | this skill ([freelance.md](freelance.md)) |
| Job LinkedIn copy | this skill ([linkedin.md](linkedin.md)) |
| Tone on every artifact | this skill ([tone.md](tone.md)) |
| Cover letter when earned | this skill ([cover.md](cover.md)) |
| README / docs Markdown | `create-readme-and-other-markdown-documentation` |
| Markdown file; `pandoc` export | this skill |

## Earn a second page

Copy this checklist. Tick **yes** on at least two, or stay on one
page.

```
Earn a second page:
- [ ] 10+ years of relevant roles
- [ ] Staff / Principal / Architect / EM evidence a one-pager would cut
- [ ] Current role already has 4–6 dense bullets (not padding older jobs)
```

Padding is not a second page.

## What this skill owns

| Own | Leave |
| --- | --- |
| One job CV per ask (tailor or base); pick evidence; ATS shape | Inventing a career |
| Freelance profile (pass-along or marketplace) | A fourth variant (Director, Founder) unasked |
| Job LinkedIn when asked ([linkedin.md](linkedin.md)) | Portfolio website; interview loops; LinkedIn rewrite unasked |
| Cover letter when asked or required ([cover.md](cover.md)) | Always-on letter; Canva / Teal / Resume Worded |

## Hard rules

- Career source is the **writer**. The file is derived. Do not add a
  skill, employer, date, or number that is not in the source.
- One variant per file. Do not mix Manager people-metrics into an IC
  page "for completeness".
- Listing and job LinkedIn follow their siblings. Do not apply
  [ats.md](ats.md) Experience-first or no-photo there.
- With a JD: must-have terms appear only where the source can defend
  them. Mirror the posting's spelling when it is true. Do not paste
  JD sentences.
- Every bullet is XYZ. No metric → ask, or use a scope the source
  already has. Do not fabricate percents.
- Job CV: first half page does the work — lane, domain, one metric,
  current role. A keyword wall above Experience fails.
- When a PDF is written, it is **text** you can select. Same words
  as the `.md`. Not a scan. Not a two-column template.

## Do not add

| Need | Use | Do not add |
| --- | --- | --- |
| PDF / `.docx` | `pandoc` + engine on PATH | TeX Live; a resume CLI |
| Layout | single-column Markdown | Canva / two-column; Teal / Resume Worded |
| ATS check | [ats.md](ats.md) Before send | Jobscan product; a made-up match % |
| Cover letter | [cover.md](cover.md) when earned | always-on letter; the CV in prose |
| LinkedIn | [linkedin.md](linkedin.md) when asked | rewrite unasked |

## Default shapes

Career file: [career.md](career.md). Output:

```
# Name
City · email · phone · LinkedIn · GitHub

## Summary
Two lines: lane, domain, years if known, one metric.

## Skills
Grouped plain text (Languages, Platforms, Data, Practices).
Only skills in bullets or true JD must-haves (base: bullets + lane).

## Experience
Title, Company, Location, MM/YYYY–MM/YYYY
One scope line (surface, team size, domain) when IC or Manager.
- XYZ
- XYZ

## Education
Degree, school, year. No coursework wall.
```

Freelance profile: [freelance.md](freelance.md). Job LinkedIn:
[linkedin.md](linkedin.md). Do not use that job CV shape for those
asks. Artifacts only when they prove the lane.

## Write the CV

Job CV only. Profile → [freelance.md](freelance.md). LinkedIn →
[linkedin.md](linkedin.md). Stop this checklist. Copy it.

```
Customize CV:
- [ ] Career source inventoried (or asked)
- [ ] Artifact is a job CV (not a freelance profile)
- [ ] Mode: tailor (JD) or base (no JD)
- [ ] JD must-haves vs nice-to-haves listed (n/a if base)
- [ ] Variant + IC lane picked
- [ ] Evidence selected (not dumped)
- [ ] Draft written to <folder>/out/<slug>.md
- [ ] Tone ticks ([tone.md](tone.md))
- [ ] ATS + density ticks ([ats.md](ats.md))
```

1. Tailor: map each must-have to one piece of evidence. A must-have
   with no evidence is a gap — tell the user. Do not print it on
   the page ([tone.md](tone.md)). Do not paper it with a keyword.
   Base: rank SOURCE tags for this variant / lane. Same
   density.
2. Ship the top of the current role first. Older roles shrink.
   Irrelevant roles become one line or drop.
3. Write Summary last. Two lines. No "passionate". No Objective.
4. Skills is a short grouped list, not a paragraph of forty tools.
5. Run [ats.md](ats.md) Before send.

## After every edit

- Every number and title still matches the career source.
- Tone ticks ([tone.md](tone.md)).
- Paste the Markdown into a plain-text view. Order must read top to
  bottom. If it scrambles, you used a table or a column
  ([ats.md](ats.md)).
- First 8–12 lines: lane + one metric + current title. If not, cut
  above Experience. Profile: [freelance.md](freelance.md) instead.
- Export only the formats Defaults earn:

```bash
pandoc <slug>.md -o <slug>.docx
pandoc <slug>.md -o <slug>.pdf --pdf-engine=typst
```

Use `--pdf-engine=weasyprint` or `pdflatex` if that is the engine on
PATH. No `pandoc` or no engine → **stop**. Select text in the PDF.
If you cannot, the engine wrote an image.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| Parser empty / dates missing | Columns, tables, headers, or footer contact ([ats.md](ats.md)) |
| Recruiter bounce in seconds | First half page is a keyword wall or a brand sentence |
| Wrong artifact | Did not follow [freelance.md](freelance.md) / [linkedin.md](linkedin.md) / [cover.md](cover.md) |
| Interview cannot defend a number | Invented or rounded-up metric |
| Two pages of old jobs | Did not earn; did not shrink older roles |
| Perfect and generic | 2026 AI-polish reject. Add a proper noun the source has |
| Base page is the whole career | Did not pick evidence |
| PDF text not selectable | Image / scanned PDF. Not a two-column template |
| `pandoc` PDF fails | Missing `--pdf-engine` (typst / weasyprint / pdflatex) |

## LLM traps — never generate these

- Dates, titles, employers, or metrics not in the career source
- A fake JD invented so the tailor path can run
- All three variants on one page, or all three files unasked
- A skills wall of every tool ever touched
- "Passionate engineer" / Objective / References on request
- Padding a second page with 2014 tickets
- `@latest` "ATS score 100" theatre; a made-up match percentage
- A scanned or image-only PDF
- A software README (Install, Develop, badges) as the CV

Parse: [ats.md](ats.md). Lane: [variants.md](variants.md). Listing:
[freelance.md](freelance.md). Diction: [tone.md](tone.md).

## Do not

- Invent a career because the user said "just write a CV".
- Dump the whole source onto one page.
- Write a job CV into a freelance listing as a drive-by.
- Restyle a working CV into Canva as a drive-by.
- Write the CV as a software README. ATS shape stays in this skill.
- Recite Jobscan or Larson as an encyclopedia.
- Put personal career facts into this lore repo.
- Bump the method to a fashion (always-on DEI bullet, always-on
  "AI tooling" bullet). Honor it when the source has it, and the JD
  asks — or there is no JD and it proves the lane.
