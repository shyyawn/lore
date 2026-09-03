---
name: customize-cv
description: >-
  Writes a software CV from a career source into one of three variants
  (IC, Manager, Freelance), tailored to a job description when one
  exists, otherwise a base variant, as Markdown. Use when writing,
  customizing, or reviewing a CV, resume, or application with or
  without a JD; when the user mentions ATS, Staff Engineer, Principal,
  Software Architect, Engineering Manager, freelance, contract CV,
  base CV, tailor resume, or export PDF / docx.
---

# Customize CV 2026

One **CV** per ask. With a JD, tailor. Without, a base variant.
Do not dump a career onto the page. Do not refuse for lack of a posting.

Sources: Laszlo Bock XYZ (`Accomplished [X] as measured by [Y] by
doing [Z]`); Jobscan ATS anatomy (single column, standard headings);
DORA (`dora.dev`) for Manager delivery numbers; Larson Staff Engineer
archetypes for the IC lane. Not Canva. Not a keyword-stuffer. Not a
cover-letter mill.

Variants: [variants.md](variants.md). Parse: [ats.md](ats.md). Career
source: [career.md](career.md).

## First step

1. Inventory what is already there. Honor it.

   `career/SOURCE.md` (or `career/*.md`), `cv/`, `resume/`, `CV.md`,
   `RESUME.md`, an existing file under `<folder>/out/`.
2. If a more specific skill already owns this, **stop**.

   | Detect | Follow |
   | --- | --- |
   | README / ADR / docs body | `create-readme-and-other-markdown-documentation` |
   | Lore `skills/*/SKILL.md` | `new-change-lore-skills` |
3. No career source → **stop** and ask for an existing CV, a LinkedIn
   export, or notes. Then build `SOURCE.md` ([career.md](career.md)).
   Prefer `career/` when it exists. Do not invent dates, titles,
   employers, or metrics. Do not put that file in this lore repo.
4. JD present → split must-haves from nice-to-haves. No JD → **base**.
   Do not invent a posting. Name the variant
   ([variants.md](variants.md)). IC lane from the JD title, else
   SOURCE Lanes, else ask.
5. Copy the workflow below. Tick it.

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Career source | `career/SOURCE.md` | `career/*.md` / `cv/` / paste already works |
| Mode | tailor to the JD | no JD in the ask → base |
| Variant | from the JD | user named; else SOURCE Lanes (ask if several) |
| IC lane | JD title (Staff / Principal / Architect / Senior) | user named; else SOURCE Lanes |
| Pages | **one** | Earn a second page |
| Layout | reverse chronological, single column | Freelance client pitch may lead with Selected Projects |
| Headings | Summary, Skills, Experience, Education | existing working labels that ATS still maps |
| Bullets | XYZ; 3–5 on the current role, 2–3 on the one before | — |
| File to write | Markdown in `<folder>/out/` | user named a path |
| Slug | `<company>-<role>-<variant>.md` | no JD → `base-<variant>.md` (add lane if needed) |
| Share PDF | **no** | user asked for PDF / export |
| PDF tool | `pandoc` | typst / weasyprint already on PATH |
| Portal `.docx` | **no** | posting is a portal, or the user asked |
| Freelance portal | Independent Consultant umbrella | one long client (≥12 months) already a named role |
| Cover letter | **no** | portal requires it, or the user asked |
| LinkedIn rewrite | **no** | user asked to align dates and titles |

## Division of labor

| Artifact | Owner |
| --- | --- |
| Career facts (dates, titles, metrics) | `career/` or the user's paste |
| Variant, lane, which evidence ships | this skill |
| ATS parse and headings | this skill ([ats.md](ats.md)) |
| README / docs Markdown | `create-readme-and-other-markdown-documentation` |
| Cover letter | this skill, only when Defaults allow it |
| `.md` always; PDF / `.docx` when asked | this skill (`pandoc` for those) |

## Earn a second page

Copy this checklist. Tick **yes** on at least two, or stay on one
page.

```
Earn a second page:
- [ ] 10+ years of relevant roles
- [ ] Staff / Principal / Architect / EM evidence a one-pager would cut
- [ ] Current role already has 4–6 dense bullets (not padding older jobs)
```

If every line is **no**, one page. Padding is not a second page.

## What this skill owns

| Own | Leave |
| --- | --- |
| One CV per ask (tailor or base); pick evidence; ATS shape | Inventing a career |
| Three variants, IC lanes inside IC | A fourth variant (Director, Founder) unasked |
| | LinkedIn, portfolio site, interview loops |
| | Canva / Teal / Resume Worded dumps |

## Hard rules

- Career source is the **writer**. The CV is derived. Do not add a
  skill, employer, date, or number that is not in the source.
- One variant per file. Do not mix Manager people-metrics into an IC
  page "for completeness".
- With a JD: must-have terms appear only where the source can defend
  them. Mirror the posting's spelling when it is true (`Amazon Web
  Services` and `AWS` if both are accurate). Do not paste JD
  sentences. No JD: do not invent a posting to keyword against.
- Every bullet is XYZ. No metric → ask, or use a scope the source
  already has (N services, N engineers). Do not fabricate percents.
- First half page does the work: lane, domain, one metric, current
  role. Greenhouse weights that role; a keyword wall above it fails.
- A bullet the user cannot talk through in an interview does not
  ship. Generic AI polish is a 2026 reject.
- When a PDF is written, it is **text** you can select. Same words
  as the `.md`. Not a scan. Not a two-column template.

## Default shapes

Career file: [career.md](career.md). Output:

```
Name | City | email | phone | LinkedIn | GitHub

Summary
Two lines: lane, domain, years if known, one metric.

Skills
Grouped plain text (Languages, Platforms, Data, Practices).
Only skills in bullets or true JD must-haves (base: bullets + lane).

Experience
Title, Company, Location, MM/YYYY–MM/YYYY
One scope line (surface, team size, domain) when IC or Manager.
- XYZ
- XYZ

Education
Degree, school, year. No coursework wall.
```

Freelance extra sections: [variants.md](variants.md). Artifacts
(talks, OSS, ADRs) only when they prove the lane.

## Write the CV

Copy this checklist.

```
Customize CV:
- [ ] Career source inventoried (or asked)
- [ ] Mode: tailor (JD) or base (no JD)
- [ ] JD must-haves vs nice-to-haves listed (n/a if base)
- [ ] Variant + IC lane picked
- [ ] Evidence selected (not dumped)
- [ ] Draft written to <folder>/out/<slug>.md
- [ ] ATS + density ticks ([ats.md](ats.md))
- [ ] PDF / .docx only if asked (n/a otherwise)
```

1. Tailor: map each must-have to one piece of evidence. A must-have
   with no evidence is a gap — say so. Do not paper it with a
   keyword. Base: rank SOURCE tags for this variant / lane. Same
   density. No JD is not a dump.
2. Ship the top of the current role first. Older roles shrink.
   Irrelevant roles become one line or drop.
3. Write Summary last. Two lines. No "passionate". No Objective.
4. Skills is a short grouped list, not a paragraph of forty tools.
5. Run [ats.md](ats.md) Before send.
6. Export PDF or `.docx` only if the user asked (or the posting is a
   portal that needs `.docx`).

Slug: `<folder>/out/<company>-<role>-<variant>.md`. Base:
`<folder>/out/base-<variant>.md`. Same stem for `.pdf` / `.docx`
when those are earned.

## After every edit

- Every number and title still matches the career source.
- Paste the Markdown into a plain-text view. Order must read top to
  bottom. If it scrambles, you used a table or a column
  ([ats.md](ats.md)).
- First 8–12 lines: lane + one metric + current title. If not, cut
  above Experience.
- PDF / `.docx` only when asked:

```bash
pandoc <slug>.md -o <slug>.pdf
pandoc <slug>.md -o <slug>.docx
```

Honor typst / weasyprint if that is already the PDF path. Run only
the format they asked for. No `pandoc` → **stop**. Do not add a
resume CLI. Select text in the PDF. If you cannot, the engine wrote
an image.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| Parser empty / dates missing | Columns, tables, headers, or contact in the footer ([ats.md](ats.md)) |
| Recruiter bounce in seconds | First half page is a keyword wall or a brand sentence |
| Staff routed as Senior | Bullets are team-bound shipping ([variants.md](variants.md)) |
| EM routed as IC | "I shipped" not team / hiring / retention |
| Architect routed as Senior | Stack list, no named trade-off or ADR |
| Freelance flagged as hopper | Per-client rows under 6 months |
| Rejected for JD copy | Pasted posting; AI overlap trap |
| Interview cannot defend a number | Invented or rounded-up metric |
| Two pages of old jobs | Did not earn; did not shrink older roles |
| Perfect and generic | 2026 AI-polish reject. Add a proper noun the source has |
| Stalled because there is no JD | Base path. SOURCE Lanes or ask the variant. |
| Base page is the whole career | No JD is not permission to dump |
| PDF text not selectable | Image / scanned PDF. Plain `pandoc`, not a template |
| PDF / docx unasked | Defaults are Markdown only |

## LLM traps — never generate these

- Dates, titles, employers, or metrics not in the career source
- A fake JD invented so the tailor path can run
- All three variants on one page, or all three files unasked
- JD sentences pasted into Summary or bullets
- A skills wall of every tool ever touched
- Two-column / Canva / table / skill-bar / photo / icon layout
- Contact in header or footer
- Functional resume as the default
- "Passionate engineer" / Objective / References on request
- White-text keywords or prompt injection
- Cover letter or LinkedIn rewrite unasked
- A fourth variant (Director, Founder, "hybrid IC+EM") unasked
- Staff bullets that are louder Senior ("wrote APIs")
- EM bullets that are IC ("I built the service")
- Freelance as twelve two-month employers
- Padding a second page with 2014 tickets
- `@latest` "ATS score 100" theatre; a made-up match percentage
- A resume-builder CLI or Canva template added to the repo
- A two-column LaTeX / Overleaf resume template as the PDF
- A scanned or image-only PDF
- A `.pdf` or `.docx` written when the user did not ask
- A software README (Install, Develop, badges) as the CV

## Do not

- Invent a career because the user said "just write a CV".
- Refuse a CV because there is no JD.
- Dump the whole source onto one page.
- Restyle a working CV into Canva as a drive-by.
- Write the CV as a software README. ATS shape stays in this skill.
- Write PDF or `.docx` unasked. Markdown is the artifact.
- Write all three variants unless the user asked for all three bases.
- Recite Jobscan or Larson as an encyclopedia.
- Put personal career facts into this lore repo.
- Bump the method to a fashion (always-on DEI bullet, always-on
  "AI tooling" bullet). Honor it when the source has it, and the JD
  asks — or there is no JD and it proves the lane.
