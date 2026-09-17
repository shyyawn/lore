# LinkedIn (job search)

Discovery. Not a CV paste. Not LinkedIn Services
([freelance.md](freelance.md)). Default is **no**.

Sources: LinkedIn headline / About practice 2026 (headline 220,
About 2,600). Job CV: [ats.md](ats.md). Listing:
[freelance.md](freelance.md). Tone: [tone.md](tone.md).

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Write LinkedIn | **no** | user asked for headline, About, Featured, or Open to Work |
| Headline | Job title first, then 2–4 keywords. Cap 220. First ~60–70 show in search | Freelance service headline ([freelance.md](freelance.md)) |
| About | First person. Cap 2,600. First three lines / ~200–300 before See more | Resume Summary dumped in; Need a …? |
| Photo | **yes** (on LinkedIn) | ATS file — still no ([ats.md](ats.md)) |
| Featured | Talk, ADR, live product URL from SOURCE | Skills wall; invented posts |
| Dates / titles | **same** as the CV | Search-optimized fake titles |
| Open to Work | recruiter-only if employed | Public badge unasked |

## Blocks

| Block | Put | Not |
| --- | --- | --- |
| Headline | Role family (Staff Engineer, EM) plus stack or domain | Gig line; "Passionate leader" |
| About | Lane, one proof, intent. Fold is line 3 ([tone.md](tone.md)) | Keyword dump; I-will gig copy |
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
- [ ] About first three lines: lane + one proof ([tone.md](tone.md))
- [ ] Experience titles and dates match the CV
- [ ] Featured only from SOURCE URLs
- [ ] Tone ticks ([tone.md](tone.md))
- [ ] No invented Open to Work public badge
```

1. Match **dates** and HR titles to the CV first. Then write headline
   and About.
2. Headline starts with the role they want found for. Not the
   freelance service line. Front-load the first 60–70 characters.
3. About last. First person. [tone.md](tone.md). No "passionate".
   No "Need a …?". Fold is the first three lines.
4. Tell them photo and Open to Work live on LinkedIn, not in the
   Markdown CV.

Filename: `<folder>/out/base-linkedin.md`. User named a path → honor
it.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| Headline is a gig / service | Wrote [freelance.md](freelance.md) into a job profile |
| About is two Summary lines | Pasted the CV |
| Dates disagree with the CV | Did not sync |
| Photo in the ATS PDF | Applied LinkedIn hygiene to [ats.md](ats.md) |
| Public Open to Work, still employed | Default was recruiter-only |
| Reads high and mighty | Did not follow [tone.md](tone.md) |
| Headline truncated into nonsense | Buried the role after a slogan |

## LLM traps — never generate these

- A freelance service headline on a job LinkedIn
- LinkedIn rewrite unasked
- Search-optimized fake titles or dates
- Public Open to Work badge unasked
- Photo baked into the ATS PDF
