# Files

Which Markdown file, when, where. README bodies: [readme.md](readme.md).
English: [english.md](english.md). Stacks: [stacks.md](stacks.md).

GitHub health files may live in the root, `.github/`, or `docs/`
(precedence: `.github/`, then root, then `docs/`). Issue templates must
be `.github/ISSUE_TEMPLATE/`. `LICENSE` is root only.

## Default vs skip

| File | Default | Skip unless |
| --- | --- | --- |
| `README.md` (root) | Always | — |
| `LICENSE` | Public — ask first (`git-repo-setup`) | Private |
| `CONTRIBUTING.md` | Public that wants PRs | Private team; or README "Develop" is enough |
| `CODE_OF_CONDUCT.md` | Public that wants PRs. Contributor Covenant **3.0** | Private; existing CoC |
| `SECURITY.md` | Public that ships | Private with no reporters |
| `CHANGELOG.md` | Library / versioned product | App with GitHub Releases only, and they want that |
| `AGENTS.md` | When agents will work in the repo | Kit optional row; do not duplicate skills |
| `.github/PULL_REQUEST_TEMPLATE.md` | GitHub remote | `git-repo-setup` stub is enough |
| `.github/ISSUE_TEMPLATE/` | Public with issue traffic | — |
| `SUPPORT.md` | Public with a support channel besides Issues | Issues-only |
| `GOVERNANCE.md` | Project with roles / a steering group | Single maintainer |
| `docs/decisions/*.md` | Architecturally significant choice | No such choice yet |
| `docs/` Diátaxis tree | Earned docs site | Plain `docs/*.md` is enough |
| `CODEOWNERS` | Team repo (`git-repo-setup`) | — |
| `FUNDING.yml` | Public OSS that wants sponsors | — |
| `CITATION.cff` | Citable research / papers | — |
| `llms.txt` | Published docs **site** | Git root of an app |

## Every `.md` file

| Rule | Do |
| --- | --- |
| Title | One `#`. Matches the page, not always the filename (`README.md` H1 is the project) |
| Headings | Sentence case. `##` then `###`. Do not skip. Unique on the page |
| Links | Descriptive text. Not "click here". `docs/x.md` is file-relative; `/docs/x.md` is repo-root |
| Images | Alt text. Absolute `https://` URLs if this file is mirrored to a registry |
| Code | Fenced, with a language tag. Match the pin. Explanation above the fence |
| Command | No `$`. No comment on the same copy-paste line. Placeholders `BRANCH_NAME` |
| Lists | Numbered = sequence. Bullets = unordered. Tables = pairs. Task lists: Issues/PRs, not README |
| Dates | ISO `2026-08-21` |
| Empty | Do not leave a heading with no body. Text between a heading and its subheading |
| HTML | `<details>` only. No `<div align>`, `<center>`, `<br>` as layout |
| Footnotes | Do not. A sentence or a GFM alert |
| Frontmatter | Only if the renderer needs it (MkDocs, Docusaurus, Hugo). Never on GitHub health files |
| Alerts | GFM `> [!NOTE]` only on GitHub-rendered files. Sparingly. Not consecutive |
| Wrap | Honor existing. Do not reflow a working README |

## GFM vs GitHub renderer

[GFM spec](https://github.github.com/gfm/): CommonMark plus tables, task
lists, strikethrough, autolinks, tag filter.

GitHub **also** draws, but these are not the spec: alerts, Mermaid,
math, footnotes. Use them only when the file is GitHub-rendered.
Do not put a mermaid fence or `$math$` in a README that npm, PyPI,
or crates.io mirrors.

GFM alerts: `NOTE`, `TIP`, `IMPORTANT`, `WARNING`, `CAUTION`. MkDocs
uses `!!!`. Docusaurus uses `:::`. Do not mix.

Writing rules GitHub, Google, and GitLab share: [english.md](english.md).
Do not copy `github/docs` Liquid / `AUTOTITLE` into a normal repo.

## `README.md`

[readme.md](readme.md). Root file. GitHub also accepts `.github/README.md`
or `docs/README.md` — use root.

## `CONTRIBUTING.md`

How to change the code. GitHub surfaces it on Issues and PRs.

```markdown
# Contributing

## Develop

Needs [mise](https://mise.jdx.dev/). Then:

    just bootstrap
    just ci

## Changes

1. Branch from `main`.
2. Conventional Commits.
3. Open a PR. Squash title is a Conventional Commit.

## Code of conduct

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
```

Name the real runner (`just` vs `make`). Point at SECURITY for vulns.
Cut the CoC link if that file was skipped. Do not recopy the style
guide into this file.

## `CODE_OF_CONDUCT.md`

Copy [Contributor Covenant 3.0](https://www.contributor-covenant.org/version/3/0/code_of_conduct/).
Fill the reporting address. Do not invent a CoC. Do not put CoC reports
on GitHub Security Advisories — those are for vulns.

## `SECURITY.md`

GitHub Security tab. Supported versions + how to report.

```markdown
# Security

## Supported versions

| Version | Supported |
| --- | --- |
| 2.x | yes |
| 1.x | no |

## Report a vulnerability

Use GitHub private vulnerability reporting (Security advisory).
Do not open a public issue.

We aim to acknowledge within 7 days. There is no SLA.
```

Honor a real policy if they have one. Do not promise a bounty they
do not run.

## `SUPPORT.md`

Where to get help. Link Discussions, Discord, email. Point bugs at
Issues and vulns at SECURITY. Do not recopy the README.

## `GOVERNANCE.md`

Roles, who merges, how decisions are made. Single maintainer: skip.

## `CHANGELOG.md`

[Keep a Changelog 1.1](https://keepachangelog.com/en/1.1.0/). Filename
`CHANGELOG.md`. Not `HISTORY.md` / `NEWS.md` on a new file. Honor those
names if they already work.

```markdown
# Changelog

All notable changes to this project are documented in this file.

The format is [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- …

## [1.0.0] - 2026-08-21

### Added

- …
```

Types: Added, Changed, Deprecated, Removed, Fixed, Security. Latest
first. ISO dates. Humans, not `git log`. Yanked: `## [1.0.1] - 2026-08-21 [YANKED]`.
Do not keep empty type headings.

GitHub Releases may mirror a version section. The file is the portable
source.

## `AGENTS.md`

README for agents. Point at `just bootstrap` and `just ci`. Conventions
the README does not need. Do not duplicate lore skills or `.cursor/rules`.

One body. Nested `AGENTS.md` only in a monorepo package that truly
differs. Existing `CLAUDE.md`: add `@AGENTS.md` or a symlink. Do not
maintain two texts. Do not add `.cursorrules` or
`.github/copilot-instructions.md` if `AGENTS.md` already covers it.

## `docs/` (no site yet)

Plain Markdown. A short `docs/README.md` map is enough. Do not create
empty tutorial/how-to/reference/explanation folders.

## Docs site (earned)

Diátaxis. Four kinds, four jobs. Do not mix them in one page.

| Kind | Job | Tone |
| --- | --- | --- |
| Tutorials | Learning. First success | Numbered. No options |
| How-to | A goal the reader already has | Numbered. One task |
| Reference | Lookup. Accurate, complete | Information, not a lesson |
| Explanation | Why. Concepts | Prose. Not a procedure |

Default tree when a site is earned:

```
docs/
├── tutorials/
├── how-to/
├── reference/
└── explanation/
```

Honor an existing tree. Do not rename `guides/` to `how-to/` as a
drive-by.

## `docs/decisions/` (ADR)

[MADR 4](https://adr.github.io/madr/) **minimal**. File
`nnnn-short-title.md`. Copy their template; do not fork it here.

Need: context, options, outcome, consequences. Skip the full template
until the decision is messy. Nygard ADRs: honor if already there.

## `.github/ISSUE_TEMPLATE/`

YAML issue forms when the public tracker has repeated back-and-forth.
`config.yml` can turn off blank issues. Bug template: what happened,
what you expected, pin / OS, how to reproduce.

## Do not add

| File | Use instead |
| --- | --- |
| `INSTALL.md` / `USAGE.md` | README |
| `HACKING.md` | CONTRIBUTING |
| `AUTHORS.md` / `CREDITS.md` | Git history; optional acknowledgements in README |
| `ROADMAP.md` | Issues or a project board |
| `FAQ.md` as a junk drawer | How-to pages, or a short README FAQ that links out |
| `NEWS.md` (new) | `CHANGELOG.md` |
| `README.rst` beside `README.md` | One README. Honor rST-only if that is the ecosystem |
| `llms.txt` in the Git root of an app | The published site's `/llms.txt` |
| GitHub Wiki | Earned `docs/` or a docs site. Wikis skip the same PR gate |
