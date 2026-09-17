# Freelance profile

A **listing**. Default is pass-along. Not a job CV. Do not paste
Experience-first ATS into Upwork or a friend PDF.

Sources: Upwork freelancer profile tips (title 70, overview fold
250); Damongo Upwork 2026; Fiverr profile/gig guides (About 600);
LinkedIn Services. Not a scrape of seller accounts.
Job CV and ATS contract: [variants.md](variants.md),
[ats.md](ats.md). Tone: [tone.md](tone.md).

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Surface | pass-along | user named Upwork / Fiverr / Toptal |
| Headline | 2–3 services, middots, ≤70 characters | — |
| Offer | inside headline + Summary | Marketplace: named gigs |
| Projects | 3–6 shipped products, **before** Experience | SOURCE has real freelance gigs — say so |
| Experience | short spine; titles collapsed per employer | ATS contract ([variants.md](variants.md)) |
| Skills groups | Backend, Web and mobile, Data, How apps run | SOURCE already groups otherwise |
| Photo in Markdown | **no** | user asked; marketplace: tell them to upload |

No client list in SOURCE → company products as the portfolio.
Do not invent clients, reviews, or an Independent Consultant row.

## Pick the surface

| Ask | Surface | Not |
| --- | --- | --- |
| Pass-along, friend PDF, LinkedIn Services | Pass-along | ATS headings; job title as headline |
| Upwork, Fiverr, Toptal | Marketplace | Pass-along dumped into a gig |
| Contractor JD / ATS contract | ATS CV ([variants.md](variants.md)) | Offer-first marketplace page |
| Job LinkedIn (headline, About, Open to Work) | [linkedin.md](linkedin.md) | Service headline; ATS no-photo |

## Blocks

| Block | Put | Not |
| --- | --- | --- |
| Title / headline | Service, skill first, ≤70 characters | Job title (Staff, SVP, Engineer) |
| Overview / Summary | Available + proof + ask. First two sentences | "Need a …?"; keyword dump |
| Offer / gigs | Headline + Summary. Marketplace: packages | A career; every language |
| Projects (3–6) | Product row: problem → built → result | Skills wall; SVP duties |
| Skills tags | Specific tools (WordPress, Next.js, Expo) | "web development" |
| Reviews / history | SOURCE jobs, ratings, quotes | Invented stars or clients |
| Rate, location, response | SOURCE or omit | Buried after a bio wall |
| Photo / video | Marketplace: face; optional 30–60s | ATS no-photo on the marketplace |

Employment products count as **shipped** apps (site, mobile, API +
VPS). Not infra estates or ringgit unless the buyer is ops or
finance.

Limits (2026): Upwork title 70. Overview first 250 visible, longer
body with SOURCE numbers. Fiverr About 600. Fiverr gig title stays
`I will …` (platform formula).

## Platforms differ

| Surface | Lead with | Trust |
| --- | --- | --- |
| Pass-along | Offer headline. Projects, then a short spine | Company products. No fake consultancy |
| Marketplace | Niche title, tags, portfolio. Fiverr `I will …` | SOURCE reviews only |

## Skip on a first page

- Full SVP / org-size story as the lead
- Cloud cost % and internal revenue unless the buyer is ops / finance
- A consulting umbrella with no client list
- Every language you can touch — pick the offer (web app, mobile
  app, API + VPS)

## Default shapes

Write copy to paste. Do not embed a photo unless asked.

Pass-along (`<folder>/out/base-freelance-pass-along.md`). This is the
shape a first freelance page uses:

```
# Name

Web and mobile applications · Go · low-cost hosting and Kubernetes
City, Country · work auth if SOURCE prints it
email · phone · LinkedIn · GitHub
portfolio

## Summary

I take freelance work on <offer>, including running them at modest
cost (<how they run>).
<N> years in company product teams. Most at home with <niche>; also
<adjacent>. City. On-site there is welcome.
Write to <email>.

## Projects

Product, MM/YYYY–Present or MAU
Result. What was built. Stack.

## Skills

Backend: … (preferred)
Web and mobile: …
Data: …
How apps run: …

## Experience

Title(s), Company, City, MM/YYYY–MM/YYYY
Product surface. Not org size.
- XYZ.

## Education

Degree, school, years.
```

Same employer, several titles → **one** Experience block. List each
title with its dates. Same employer, several products → one row per
product under Projects, one block under Experience.

Marketplace (`<folder>/out/base-freelance-<surface>.md`):

```
# <service title, skill first, ~70 characters>

## About
Available for the offer. One proof line. Write to email
([tone.md](tone.md)). Fiverr gig title may stay `I will …`.

## Services
### <package name>
Deliverables. First milestone. Price only if SOURCE has it.

## Portfolio
### <shipped thing>
Problem. Built. Result. URL.

## Skills
WordPress, Laravel, Next.js, Expo, …

## Working
Rate. Timezone. Replies in X hours. Languages.
```

## Write the profile

Copy this checklist.

```
Freelance profile:
- [ ] Career source inventoried (or asked)
- [ ] Surface picked (pass-along default; marketplace if named)
- [ ] Headline is a service, not a job title
- [ ] Summary is available + proof + polite ask ([tone.md](tone.md))
- [ ] 3–6 Projects before Experience (employment apps allowed)
- [ ] Skill tags are specific tools
- [ ] Experience collapsed, product bullets, not the lead
- [ ] No invented reviews, clients, or Independent Consultant row
- [ ] Tone ticks ([tone.md](tone.md))
- [ ] Rate / timezone / response only from SOURCE (or omitted)
- [ ] Draft written to <folder>/out/<slug>.md
```

1. Pick **2–3** services for the headline from SOURCE.
2. Rank 3–6 products that prove those services. Company apps count.
3. Collapse titles per employer. 2–3 product bullets. Drop the org
   chart.
4. Write Summary last. Available, proof, polite ask
   ([tone.md](tone.md)). No "passionate". No "Need a …?".
5. Marketplace only: tell the user to add a face photo. Optional
   30–60s intro of how they work.

Filenames: `base-freelance-pass-along.md`, `base-freelance-upwork.md`,
`base-freelance-fiverr.md`, `base-freelance-linkedin.md`.
User named a path → honor it.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| Title is Staff / SVP / Engineer | Wrote a job CV into the listing |
| First lines are an org story | Led with employment, not the offer |
| Independent Consultant, no clients | Invented an umbrella |
| Five stars, unnamed buyers | Invented reviews |
| Skills wall, no product rows | Skipped Projects |
| "Web development" as the only tag | Matching is tag search |
| Friend PDF looks like ATS | Applied [ats.md](ats.md) Experience-first |
| Ringgit and cloud % in Summary | Internal ops metrics on a product listing |
| One Experience row per promotion | Did not collapse titles |

## LLM traps — never generate these

- Job title (Staff, SVP, Engineer) as an Upwork / pass-along headline
- A job CV written as a freelance profile
- Invented reviews, clients, or Independent Consultant row
- Projects skipped for a skills wall
- ATS no-photo applied to a marketplace page
