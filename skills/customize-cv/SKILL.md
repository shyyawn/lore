---
name: customize-cv
description: >-
  Writes a software job CV (IC or Manager) from a career source,
  tailored to a job description when one exists, otherwise a base
  variant, as Markdown. Use when writing, customizing, or reviewing a
  CV, resume, application, ATS, Staff Engineer, Principal, Software
  Architect, Engineering Manager, VP, SVP, base CV, tailor resume,
  cover letter, SOURCE.md, career dump, or export PDF / docx. Listing:
  customize-cv-freelance. Job LinkedIn: customize-cv-linkedin.
---

# Customize CV 2026

One **job CV** per ask. Do not dump a career onto a page. Do not
write a derived file when the ask is the source.

Sources: Laszlo Bock XYZ (`Accomplished [X] as measured by [Y] by
doing [Z]`); Jobscan ATS anatomy 2026 (single column, standard
headings); DORA (`dora.dev`) five delivery metrics for Manager;
Larson Staff Engineer archetypes for the IC lane. Not Canva.

Variants: [variants.md](variants.md). Parse: [ats.md](ats.md).
Tone: [tone.md](tone.md). Cover: [cover.md](cover.md). Career
source: [career.md](career.md). Listing:
`customize-cv-freelance`. Job LinkedIn: `customize-cv-linkedin`.
`<folder>` holds `SOURCE.md` (usually `career/`).

## First step

1. Inventory what is already there. Honor it.

   `career/SOURCE.md` (or `career/*.md`), `cv/`, `resume/`, `CV.md`,
   `RESUME.md`, an existing file under `<folder>/out/`.
2. If a more specific owner already has this, **stop**.

   | Detect | Follow |
   | --- | --- |
   | Ask is `SOURCE.md` / career dump only | [career.md](career.md). **Stop.** |
   | Upwork / Fiverr / Toptal / LinkedIn Services / pass-along / freelance profile | `customize-cv-freelance` |
   | Headline / About / Open to Work (job search) | `customize-cv-linkedin` |
   | README / ADR / docs body | `create-readme-and-other-markdown-documentation` |
   | Lore `skills/*/SKILL.md` | `new-change-lore-skills` |
   | Cover letter asked or required | [cover.md](cover.md) after the CV |
   | Reviewing an existing **job** CV | [ats.md](ats.md) Before send. Honor the file. Do not rewrite as a drive-by |
3. No career source → **stop** and ask for an existing CV, a
   LinkedIn export, or notes. A paste is enough. Do not invent.
   Do not put that file in this lore repo.
4. Job CV: JD present → tailor. No JD → **base**. Name the variant
   ([variants.md](variants.md)). IC lane from the JD title, else
   SOURCE Lanes, else ask. VP/SVP is Manager org-shape, not a
   fourth variant. Copy the ticks below.

`SOURCE.md` on disk is inventory. It is **not** stop unless the
ask is the dump.

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Career source | `career/SOURCE.md` | paste for one file; `career/*.md` / `cv/` already there |
| Tone | [tone.md](tone.md) | user named a different voice |
| Artifact | job CV (IC / Manager) | listing → `customize-cv-freelance`; job LinkedIn → `customize-cv-linkedin` |
| Mode | tailor to the JD | no JD in the ask → base |
| Variant | from the JD | user named; else SOURCE Lanes (ask if several) |
| IC lane | JD title (Staff / Principal / Architect / Senior) | user named; else SOURCE Lanes |
| Manager sub-lane | EM | JD or SOURCE says Head / VP / SVP → org-shape ([variants.md](variants.md)) |
| Pages | **one** | Earn a second page |
| Layout | reverse chronological, single column | listing / LinkedIn overlays |
| File to write | Markdown in `<folder>/out/` | user named a path |
| Slug | `<company>-<role>-<variant>.md` | no JD → `base-<variant>.md` |
| Export | Markdown only | PDF when asked; portal → `.docx` |
| PDF tool | `pandoc` + an engine on PATH (typst, weasyprint, pdflatex) | — |
| Cover letter | **no** | portal requires it, or the user asked |

## Division of labor

| Artifact | Owner |
| --- | --- |
| Career facts (dates, titles, metrics) | `career/` or the user's paste ([career.md](career.md)) |
| Variant, lane, which evidence ships | this skill ([variants.md](variants.md)) |
| Job CV ATS parse and headings | this skill ([ats.md](ats.md)) |
| Tone on every artifact | this skill ([tone.md](tone.md)) |
| Cover letter when earned | this skill ([cover.md](cover.md)) |
| Freelance listing | `customize-cv-freelance` |
| Job LinkedIn | `customize-cv-linkedin` |
| README / docs Markdown | `create-readme-and-other-markdown-documentation` |

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
| `SOURCE.md` when that is the ask ([career.md](career.md)) | Listing (`customize-cv-freelance`) |
| Cover letter when asked or required | Job LinkedIn (`customize-cv-linkedin`) |
| | A fourth variant (Director, Founder) unasked |
| | Portfolio website; interview loops; Canva / Teal |

## Hard rules

- Career source is the **writer**. The file is derived. Do not add a
  skill, employer, date, or number that is not in the source.
- One variant per file. Do not mix Manager people-metrics into an IC
  page "for completeness".
- With a JD: must-have terms appear only where the source can defend
  them. Mirror the posting's spelling when it is true. Do not paste
  JD sentences.
- Every bullet is XYZ. Shape: [variants.md](variants.md). No metric
  → ask, or use a scope the source already has. Do not fabricate
  percents.
- Job CV parse: [ats.md](ats.md). Do not apply it to a listing or
  job LinkedIn.
- When a PDF is written, it is **text** you can select. Same words
  as the `.md`. Not a scan.

## Do not add

| Need | Use | Do not add |
| --- | --- | --- |
| PDF / `.docx` | `pandoc` + engine on PATH | TeX Live; a resume CLI |
| Layout | single-column Markdown | Canva / two-column; Teal / Resume Worded |
| ATS check | [ats.md](ats.md) Before send | Jobscan product; a made-up match % |
| Cover letter | [cover.md](cover.md) when earned | always-on letter; the CV in prose |
| Listing / job LinkedIn | the overlay | this file's Experience-first shape |

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

## Write the CV

Copy this checklist.

```
Customize CV:
- [ ] Career source inventoried (or asked)
- [ ] Artifact is a job CV (not a listing or job LinkedIn)
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
   the page ([tone.md](tone.md)). Base: rank SOURCE tags for this
   variant / lane. Same density.
2. Ship the top of the current role first. Older roles shrink.
   Irrelevant roles become one line or drop.
3. Write Summary last. Two lines. No Objective.
4. Skills is a short grouped list, not a paragraph of forty tools.
5. Run [ats.md](ats.md) Before send.

## After every edit

- Every number and title still matches the career source.
- Paste the Markdown into a plain-text view. Order must read top to
  bottom ([ats.md](ats.md)).
- Tone ticks ([tone.md](tone.md)).
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
| Recruiter bounce in seconds | First half page is a keyword wall ([ats.md](ats.md)) |
| Wrong artifact | Did not follow `customize-cv-freelance` / `customize-cv-linkedin` / [cover.md](cover.md) |
| Interview cannot defend a number | Invented or rounded-up metric |
| Two pages of old jobs | Did not earn; did not shrink older roles |
| Perfect and generic | Add a proper noun the source has ([tone.md](tone.md)) |
| Base page is the whole career | Did not pick evidence |
| PDF text not selectable | Image / scanned PDF |
| `pandoc` PDF fails | Missing `--pdf-engine` (typst / weasyprint / pdflatex) |
| Polished SOURCE instead of a CV | Treated `SOURCE.md` on disk as the ask |

## LLM traps — never generate these

- Dates, titles, employers, or metrics not in the career source
- A fake JD invented so the tailor path can run
- All three variants on one page, or all three files unasked
- A skills wall of every tool ever touched
- Objective / References on request
- Padding a second page with 2014 tickets
- `@latest` "ATS score 100" theatre; a made-up match percentage
- A scanned or image-only PDF
- A software README (Install, Develop, badges) as the CV
- A listing or job LinkedIn written as this Experience-first page

## Do not

- Invent a career because the user said "just write a CV".
- Dump the whole source onto one page.
- Follow [career.md](career.md) when the ask is a job CV.
- Restyle a working CV into Canva as a drive-by.
- Write the CV as a software README.
- Recite Jobscan or Larson as an encyclopedia.
- Put personal career facts into this lore repo.
- Bump the method to a fashion (always-on DEI bullet, always-on
  "AI tooling" bullet). Honor it when the source has it, and the JD
  asks — or there is no JD and it proves the lane.
