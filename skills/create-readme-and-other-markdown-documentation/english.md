# English

Default: [Google developer documentation style guide](https://developers.google.com/style).
Not a fork of that site. Honor `STYLE.md` / Vale if the repo already
has one.

Microsoft Writing Style Guide: Microsoft / Azure / Windows product, or
Vale already uses that package. Apple Style Guide: Apple platforms.
Merriam-Webster for spelling. Chicago for nontechnical questions Google
does not cover.

## Pick these

| Axis | Do | Do not |
| --- | --- | --- |
| Person | Second person: "you" | "we will", "the user should" |
| Voice | Active. Name the actor | Passive padding |
| Locale | American English, serial comma | Mix UK/US spelling |
| Headings | Sentence case | Title Case Headings |
| Order | Condition, then instruction | "Click Save if you are done" |
| Links | Descriptive (`see Contributing`) | "click here", "the following link" |
| Dates | `2026-08-21` | `08/21/26`, `21 August` |
| Code | Code font for filenames, flags, types | Bold as fake code |
| UI | Bold for UI labels (Google) | Code font for buttons |
| Tone | Direct. Conversational, not cute | "simply", "just", "easy", "awesome" |
| Announce | Document what shipped | "Coming soon", pre-announce |
| Global | Short sentences. No idiom | Jokes, sports metaphors, slang |
| Inclusive | allowlist, main, primary | whitelist, master/slave (unless a real git branch name you must cite) |

RFC 2119 MUST / SHOULD: protocol and API contracts only. Not tutorials
and not README Usage.

Contractions are fine when they sound like speech. Do not force them.

## Accessibility

Alt text that states the function of the image. Do not skip headings.
Do not use emoji or color alone to mean "required" or "supported".
`yes` / `no` in tables, not emoji checkmarks.

## Vale and lint

Kit spellcheck is `typos` (`git-repo-setup`). Vale + Google package is
optional for a docs-heavy repo. Do not add Vale to unlock this skill.
`markdownlint`: honor if present. Do not enable MD013 line-length as a
drive-by.

## This skill vs lore voice

Lore `SKILL.md` follows `new-change-lore-skills` (short, one bold word,
`Do not`). Target-repo docs follow **this** file. Do not write a
README in lore house voice, and do not write a lore skill in Google
tutorial prose.
