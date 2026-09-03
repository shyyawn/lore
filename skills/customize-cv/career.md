# Career source

One **writer** for facts. Derived CVs live in `<folder>/out/` next
to `SOURCE.md`. Do not edit dates or metrics only in the CV.

Prefer `career/` in the current workspace. `<folder>` is that
directory — the one that holds `SOURCE.md`. Else `cv/` / `resume/` /
`CV.md`. Else ask for a paste. Do not invent. Do not commit this
tree into the lore repo.

## Build

1. Create `career/SOURCE.md` in the workspace where CVs will be
   written. Not this lore repo.
2. Gather **one** dump in `career/`: existing CV, LinkedIn export, or
   notes. Dates, titles as HR had them, numbers, stack, team size.
   Rough is fine.
3. Map onto the headings below. One fact, one place. Do not polish
   into CV prose here.
4. Tag each fact `ic` / `manager` / `freelance`. Two tags allowed.
5. Gaps stay gaps. Ask rather than guess a percent.
6. Then write the CV (base if no JD, tailored if there is one).
   Do not skip this file and "just generate".

## Default file

`career/SOURCE.md`. Honor several `career/*.md` if they already split
roles and evidence.

```
# Career source

## Identity
Name, city, email, phone, LinkedIn, GitHub, portfolio.
Work authorization only if the user wants it on CVs.

## Lanes
Which of IC / Manager / Freelance they actually want.
IC sub-lane if they have one (Staff platform, Architect, …).

## Roles
Reverse chronological. Per role:
- Employer, title (as HR had it), location, MM/YYYY–MM/YYYY
- Scope: team size, surface, domain
- Stack actually used
- Facts: what changed, numbers, artifacts (ADR, RFC, talk)
- Tag evidence: ic / manager / freelance (a fact may have two tags)

## Freelance
Entity name if any. Clients (or "fintech client") and whether the
name may appear. Engagement dates and outcomes.

## Skills
Honest inventory with years or last-used if known.
Not a wish list.

## Artifacts
Talks, OSS, patents, public writing, notable ADRs — with a URL if
public.

## Constraints
Visa, notice, location, salary — not printed unless the user says so.
```

## Derived CVs

`<folder>/out/<company>-<role>-<variant>.md` when a JD exists.
`<folder>/out/base-<variant>.md` when it does not (add the IC lane to
the slug if SOURCE has more than one).

Do not copy a derived CV back over SOURCE.md. New facts learned
while writing go into SOURCE.md first, then the CV.
