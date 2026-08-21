# English

Default: [Google developer documentation style guide](https://developers.google.com/style).
Not a fork of that site. Honor `STYLE.md` / Vale if the repo already
has one.

Microsoft, Apple, IBM: honor when that product already owns the
repo. Do not mix two guides in one tree.

## Which guide

Both Google and Microsoft want **you**, active voice, present tense,
sentence-case headings, inclusive language, and alt text. That is the
shared 2024–2026 floor. They are not the same book.

| Situation | Guide |
| --- | --- |
| OSS, Google Cloud, Android, no `STYLE.md` | Google developer (this skill) |
| Azure, .NET, Windows, Office, Vale Microsoft package | [Microsoft Writing Style Guide](https://learn.microsoft.com/style-guide/welcome/) |
| `github/docs` / docs.github.com | Microsoft as **their** fallback. Not a normal repo README |
| Apple platforms | Apple Style Guide |
| Red Hat / IBM product docs | Honor theirs. Do not switch a README to IBM |

Google is a **developer-docs** guide. Microsoft is all product writing
(apps, websites, white papers). Open-source READMEs and API docs use
Google. GitLab's own styleguide cites both, then overrides. Vale ships
both packages — pick the one that matches the product. Do not run both.

| Axis | Google (default) | Microsoft |
| --- | --- | --- |
| UI verb | `click` (desktop), `tap` (mobile) | `select` (any input) |
| Tone | Spare. No pre-announce | Warmer. `we` for the company |
| Placeholders | `PROJECT_ID` in code font | Same idea; follow their word list |
| Scope | Software developers | All Microsoft communication |

Do not mix `click` and `select` in one repo. Stay on the chosen guide.

Merriam-Webster for spelling. Chicago for nontechnical questions
Google does not cover.

## Pick these

| Axis | Do | Do not |
| --- | --- | --- |
| Person | Second person: "you" | "we will", "the user should" |
| Voice | Active. Present tense | Passive; "will be" for what is true now |
| Locale | American English, serial comma | Mix UK/US spelling |
| Headings | Sentence case. Unique on the page | Title Case; two `## Example` |
| Order | Condition, then instruction | "Click Save if you are done" |
| Links | Descriptive (`see Contributing`) | "click here", "the following link" |
| Dates | `2026-08-21` | `08/21/26`, `21 August` |
| Code | Code font for filenames, flags, types | Bold as fake code |
| Placeholder | `PROJECT_ID`, `BRANCH_NAME` | `foo`, `your-project`, `<angle-brackets>` |
| Command | No `$`. Explanation **above** the fence | `$ git clone`; comments on the same copy-paste line |
| UI | Bold for UI labels. `click` (Google) | Code font for buttons; mixing `select` in a Google repo |
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

Kit spellcheck is `typos` (`git-repo-setup`). Vale is optional for a
docs-heavy repo. Google package on Google; Microsoft package on
Microsoft. Do not add Vale to unlock this skill. `markdownlint`: honor
if present. Do not enable MD013 line-length as a drive-by.

## This skill vs lore voice

Lore `SKILL.md` follows `new-change-lore-skills` (short, one bold word,
`Do not`). Target-repo docs follow **this** file. Do not write a
README in lore house voice, and do not write a lore skill in Google
tutorial prose.
