---
name: customize-cv-linkedin
description: >-
  Overlay on customize-cv: job-search LinkedIn headline, About,
  Featured, and Open to Work from a career source. Default is no.
  Use when the user asks for LinkedIn headline, About, Featured,
  Open to Work, or a job LinkedIn profile. LinkedIn Services stay
  customize-cv-freelance. Job CV stays customize-cv.
---

# Customize CV — LinkedIn

Follow `customize-cv` for SOURCE, dates, titles, and tone. This file
fills **job LinkedIn**. Default is **no**. Do not paste a CV Summary
into About. Do not write it unasked.

Sources: LinkedIn headline / About practice 2026 (headline 220,
About 2,600). Job CV: `customize-cv`. Listing:
`customize-cv-freelance`. Tone:
[`../customize-cv/tone.md`](../customize-cv/tone.md).

## First step

1. Follow `customize-cv` First step inventory (SOURCE, honor, no
   invent).
2. User did not ask for headline, About, Featured, or Open to Work
   → **stop**.
3. If a more specific owner already has this, **stop**.

   | Detect | Follow |
   | --- | --- |
   | LinkedIn Services / gig / pass-along | `customize-cv-freelance` |
   | Job CV / ATS / tailor | `customize-cv` |
   | Ask is `SOURCE.md` only | `customize-cv` [career.md](../customize-cv/career.md) |

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Write LinkedIn | **no** | user asked for headline, About, Featured, or Open to Work |
| Headline | Job title first, then 2–4 keywords. Cap 220. First ~60–70 show in search | Freelance service headline (`customize-cv-freelance`) |
| About | First person. Cap 2,600. First three lines / ~200–300 before See more | Resume Summary dumped in |
| Photo | **yes** (on LinkedIn) | ATS file — still no (`customize-cv` ats.md) |
| Featured | Talk, ADR, live product URL from SOURCE | Skills wall; invented posts |
| Dates / titles | **same** as the CV | Search-optimized fake titles |
| Open to Work | recruiter-only if employed | Public badge unasked |

## What this skill owns

| Own | Leave |
| --- | --- |
| Job-search LinkedIn copy when asked | LinkedIn Services listing (`customize-cv-freelance`) |
| | Job CV ATS file (`customize-cv`) |
| | Rewrite unasked; fake titles; public Open to Work unasked |

## Blocks

| Block | Put | Not |
| --- | --- | --- |
| Headline | Role family (Staff Engineer, EM) plus stack or domain | Gig line; "Passionate leader" |
| About | Lane, one proof, intent. Fold is line 3 | Keyword dump; I-will gig copy |
| Experience | Same employers, titles, dates as the CV | Conflicting dates; relabeled HR titles |
| Featured | One or two URLs the source has | Empty; a Canva CV |
| Skills | Terms the CV already proves | Forty endorsements of unused tools |

## Write the profile

Copy this checklist.

```
LinkedIn (job search):
- [ ] User asked for LinkedIn (else stop)
- [ ] Career source inventoried
- [ ] Headline is a job title, then keywords
- [ ] About first three lines: lane + one proof
- [ ] Experience titles and dates match the CV
- [ ] Featured only from SOURCE URLs
- [ ] Tone ticks (customize-cv tone.md)
- [ ] No invented Open to Work public badge
```

1. Match **dates** and HR titles to the CV first. Then write
   headline and About.
2. Headline starts with the role they want found for. Not the
   freelance service line. Front-load the first 60–70 characters.
3. About last. First person. Fold is the first three lines.
4. Tell them photo and Open to Work live on LinkedIn, not in the
   Markdown CV.

Filename: `<folder>/out/base-linkedin.md`. User named a path → honor
it.

## After every edit

- Dates and HR titles still match the CV / SOURCE.
- Headline is a job title, not a gig line.
- Tone ticks (`customize-cv` [tone.md](../customize-cv/tone.md)).

## When it breaks

| Symptom | Usually means |
| --- | --- |
| Headline is a gig / service | Wrote `customize-cv-freelance` into a job profile |
| About is two Summary lines | Pasted the CV |
| Dates disagree with the CV | Did not sync |
| Photo in the ATS PDF | Applied LinkedIn hygiene to `customize-cv` |
| Public Open to Work, still employed | Default was recruiter-only |
| Headline truncated into nonsense | Buried the role after a slogan |

## LLM traps — never generate these

- A freelance service headline on a job LinkedIn
- LinkedIn rewrite unasked
- Search-optimized fake titles or dates
- Public Open to Work badge unasked
- Photo baked into the ATS PDF

## Do not

- Write LinkedIn because this skill exists.
- Recopy `customize-cv` ATS catalogs here.
- Restyle a job CV photo rule onto LinkedIn, or the reverse.
