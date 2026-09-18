# Career source

One **writer** for facts. Derived files live in `<folder>/out/`
next to `SOURCE.md`. Do not polish this into a CV. Do not invent.
Do not commit this tree into the lore repo.

Prefer `career/` in the current workspace. Else `cv/` / `resume/` /
`CV.md`. Else a paste is enough to build this file. Job CV:
`customize-cv`. Listing: `customize-cv-freelance`. Job LinkedIn:
`customize-cv-linkedin`. Tone on derived files: [tone.md](tone.md).

## First step

1. Inventory what is already there. Honor it.

   `career/SOURCE.md`, `career/*.md`, `cv/`, `resume/`, a paste,
   LinkedIn export, old CV.
2. Ask is only `SOURCE.md` / career dump → this file. **Stop** after
   it writes. Do not emit a CV, listing, or letter as a drive-by.
3. No dump at all → **stop** and ask for an existing CV, a LinkedIn
   export, or notes. A paste is enough.

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Path | `career/SOURCE.md` | `career/*.md` already split; user named a path |
| Shape | headings below | working `SOURCE.md` — fill gaps only |
| Prose | notes, fragments, HR titles | XYZ / Summary polish (that is the CV) |
| Gaps | leave blank; ask | Guess a percent or a client |

## Build

Copy this checklist.

```
Build SOURCE:
- [ ] Dump inventoried (CV, LinkedIn export, notes, or paste)
- [ ] Not this lore repo
- [ ] Headings mapped (Identity, Lanes, Roles, Freelance, Skills,
      Artifacts, Constraints)
- [ ] Each role has employer, HR title, location, MM/YYYY–MM/YYYY
- [ ] Each fact tagged `ic` / `manager` / `freelance` (two allowed)
- [ ] Numbers and names are in the dump. Gaps asked, not filled
- [ ] No CV Summary, no spearheaded, no invented clients
- [ ] Written to career/SOURCE.md (or the path already there)
```

1. `career/` exists, or the user asked for `SOURCE.md` → write it
   here. Not this lore repo.
2. Gather **one** dump. Dates and titles as HR had them. Rough is
   fine. Do not merge two contradictory dumps without asking.
3. Map onto the headings. One fact, one place.
4. Tag each fact, not only the role.
5. Gaps stay gaps.
6. Stop. A derived file only if this ask named one.

## Default file

Honor several `career/*.md` if they already split roles and
evidence.

```
# Career source

## Identity
Name, city, email, phone, LinkedIn, GitHub, portfolio.
Work authorization only if the user wants it on CVs.

## Lanes
IC / Manager / Freelance they actually want.
IC sub-lane if they have one (Staff platform, Architect, …).
Manager sub-lane if they have one (EM vs Head / VP / SVP).

## Roles
### Employer, Title, City, MM/YYYY–MM/YYYY
Scope: team size, surface, domain.
Stack: tools actually used.
- Fact. Number if the dump has it. Artifact (ADR, talk). `ic`
- Fact. `manager`

## Freelance
Entity name if any. Clients (or "fintech client") and whether the
name may appear. Engagement dates and outcomes. Offers they
actually sell. Public product URLs / MAU. Rate, timezone,
languages, response window. Reviews only if they exist.

## Skills
Honest inventory with years or last-used if known.
Not a wish list.

## Artifacts
Talks, OSS, patents, public writing, notable ADRs — URL if public.

## Constraints
Visa, notice, location, salary — not printed unless the user says so.
```

## After every edit

- Every date, title, employer, and number is in the dump.
- Facts are tagged. Roles are reverse chronological.
- Reads as notes. If it reads as a CV, strip the polish.
- Still not in the lore repo.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| Percents the user cannot defend | Invented to fill a gap |
| SOURCE reads like a Summary | Polished into CV prose |
| Every fact is untagged | Tagged the role, not the fact |
| Independent Consultant, no clients | Invented freelance |
| Wrote `career/` into lore | Did not follow path |
| Emitted a CV after SOURCE | Did not stop |

## LLM traps — never generate these

- Dates, titles, employers, metrics, or clients not in the dump
- XYZ bullets, Summary, or spearheaded / leveraged in SOURCE
- A wish-list Skills section
- Filling Constraints with a made-up salary
- A sample career so the headings are not empty
- `career/` committed to the lore repo

## Do not

- Invent a career because the user said "just make SOURCE.md".
- Polish notes into derived copy here.
- Write a CV, listing, or letter as a drive-by after SOURCE.
- Copy a derived CV back over `SOURCE.md`. New facts go here first.
