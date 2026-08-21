---
name: create-readme-and-other-markdown-documentation
description: >-
  Writes and restyles repository Markdown: README.md, community health
  files, changelogs, ADRs, agent files, and docs/ trees, in Google
  developer English and GitHub-flavored Markdown. Use when creating or
  editing README, CONTRIBUTING, SECURITY, CODE_OF_CONDUCT, CHANGELOG,
  SUPPORT, GOVERNANCE, AGENTS.md, CLAUDE.md, docs/, ADRs, llms.txt, or
  other .md files; when the user asks for documentation, a docs site,
  technical English, or Diátaxis.
---

# Create README and other Markdown documentation

Repo Markdown for humans and forges. Do not dump a wiki into
`README.md`. English: [english.md](english.md). Files:
[files.md](files.md). README shapes: [readme.md](readme.md). Language
and framework: [stacks.md](stacks.md).

Sources: Google developer documentation style guide, GitHub
writing-on-GitHub (GFM), community health files, Diátaxis, Keep a
Changelog 1.1, MADR 4, Contributor Covenant 3.0, AGENTS.md. Not
`github/docs` Liquid, not their trees, not a Docusaurus starter.

Kit bootstrap section: `git-repo-setup`. Lore `SKILL.md`:
`new-change-lore-skills`. Commit format: `conventional-commits`.

## First step

1. Inventory what is already there. Honor it.

   `README.md`, `docs/`, `.github/`, `.gitlab/`, `CHANGELOG.md` / `HISTORY.md` /
   `NEWS.md`, `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`,
   `AGENTS.md` / `CLAUDE.md`, `LICENSE`, `STYLE.md` / Vale, the docs
   site config (`mkdocs.yml`, `docusaurus.config.*`, `hugo.toml`).
2. If a more specific skill already owns this, **stop**.

   | Detect | Follow |
   | --- | --- |
   | `skills/*/SKILL.md` in this lore repo | `new-change-lore-skills` |
   | Only the Develop/bootstrap stub is missing | `git-repo-setup` [files.md](../git-repo-setup/files.md) |
   | Commit / squash-PR title wording | `conventional-commits` |
3. Pick the repo kind and stack ([readme.md](readme.md),
   [stacks.md](stacks.md)). Write the matching shape. Do not paste a
   library README onto a private app.
4. Fill gaps. Do not restyle a working page as a drive-by.

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| English | Google developer style ([english.md](english.md)) | `STYLE.md`, Vale, or a Microsoft/Apple product already sets the guide |
| Flavor | Forge Markdown (GitHub = GFM; GitLab = GLFM) | Docs site already on MDX, rST, or AsciiDoc |
| README | Shape for this kind ([readme.md](readme.md)) | Existing README works — fill gaps only |
| Health files | Public: CONTRIBUTING, CoC, SECURITY | Private: skip CoC / FUNDING / usually CONTRIBUTING |
| Changelog | Keep a Changelog `CHANGELOG.md` | `HISTORY.md` / Releases-only already works |
| ADR | MADR minimal in `docs/decisions/` | An ADR template is already there |
| Agent file | One root `AGENTS.md` | Existing `CLAUDE.md` — point it at `AGENTS.md`; do not fork the body |
| Docs site | **no** | Earned below, or already present |
| Code in snippets | Match the pin | Do not bump `go.mod` / lockfile to unlock a sample |

## Division of labor

| Artifact | Owner |
| --- | --- |
| README Develop / `just bootstrap` / `just ci` | `git-repo-setup` [files.md](../git-repo-setup/files.md) |
| README and every other `.md` body | this skill |
| `.github/PULL_REQUEST_TEMPLATE.md` kit stub | `git-repo-setup`; expand here if asked |
| `AGENTS.md` existence | `git-repo-setup` optional row; body here |
| `LICENSE` | `git-repo-setup` (ask; do not invent) |
| Lore `SKILL.md` | `new-change-lore-skills` |
| Commit / squash title | `conventional-commits` |

## Earn a docs site

Copy this checklist. Tick **yes** on at least two, or stay on root
Markdown (and plain `docs/` files if needed).

```
Earn a docs site:
- [ ] Public library whose API will not fit above the fold
- [ ] Two+ audiences (user vs contributor vs operator)
- [ ] Versioned docs (v1 and v2 both published)
- [ ] A renderer is required (search, i18n, tabs) that GitHub cannot do
```

If every line is **no**, do not add Docusaurus / MkDocs / VitePress.
If yes: honor the SSG already there. None yet and Python → MkDocs
Material. None yet and already a JS app → ask. Diátaxis folders:
[files.md](files.md).

## Hard rules

- One fact, one place. README **links**. It does not recopy
  CONTRIBUTING, SECURITY, or the changelog.
- GitHub health files: GFM. Docs-site pages: that site's flavor. Do
  not mix MDX or MkDocs `!!!` into `README.md`.
- One `#` title. Then `##`. Do not skip heading levels.
- Examples compile against the pin. Commands the reader is told to run
  must work. No `$` in a copy-paste fence.
- Relative links for in-repo files (`docs/x.md` vs `/docs/x.md`).
  Absolute image URLs when the README is mirrored (npm, PyPI, crates.io).
- Mermaid, math, and GFM alerts only on GitHub-rendered files. Not in
  a README a registry mirrors.
- Do not invent a license, a CoC, or a security policy. Copy the
  official template and fill placeholders.

## Do not add

| Need | Use | Do not add |
| --- | --- | --- |
| Docs site | SSG already there; else earn, then MkDocs Material if Python | A second SSG; Docusaurus unasked |
| Agent instructions | One `AGENTS.md` | A second body in `CLAUDE.md` / `.cursorrules` |
| Changelog | `CHANGELOG.md` | `git log`; a new `NEWS.md` |
| API reference | Godoc, rustdoc, TSDoc, OpenAPI | Endpoint tables in README |

## After every edit

- Click-test new relative links (the path exists).
- Snippets match the pin. No `latest` in a command the reader will run.
- No `TBD`, `TODO`, `Coming soon`, or lorem.
- Spellcheck is the kit `typos`. Do not add Vale as a drive-by.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| README is a novel | Split per [files.md](files.md). README keeps above-the-fold |
| npm/PyPI README has broken images | Relative paths on a mirrored file. Use absolute URLs |
| GitHub and the docs site disagree | GFM alerts mixed into MDX / MkDocs |
| Two install sections | Develop belongs to `git-repo-setup`; user install belongs in README Usage |
| CoC or SECURITY looks made-up | Did not copy the official template |
| `CLAUDE.md` contradicts `AGENTS.md` | Two sources of truth. One body |
| Package README fights the root | Nested README is for that package only ([readme.md](readme.md)) |
| Changelog is a git log | Keep a Changelog is curated. Not `git log` |

## LLM traps — never generate these

- A badges wall, emoji headings, or "Welcome to the …"
- `$ git clone`, `foo` / `<YourName>` placeholders, two `## Example`
- Title Case headings; British/American mix; "simply" / "just" / "easy"
- A mermaid fence or footnotes in a README that npm/PyPI also renders
- A GitHub Wiki as the docs site; an `html` fence around a directory tree
- A "features yet to be added" task list in README
- Recopying CONTRIBUTING or the API into README
- `INSTALL.md` + `USAGE.md` + `HACKING.md` beside a README that should
  hold those
- `ROADMAP.md` that will rot; put plans in issues
- Docusaurus on a three-file repo
- Generating README from godoc / rustdoc as the default
- Divergent `AGENTS.md` + `CLAUDE.md` + `.cursorrules`
- Pre-announcing unshipped features
- Hexagonal `docs/domain/` trees as Diátaxis fashion

## Do not

- Restyle unrelated files, or rewrite a working MkDocs site into
  Docusaurus as a drive-by.
- Skip inventory because the user said "just write a README".
- Restyle lore `SKILL.md` with this skill.
- Document commands the kit does not have (`lefthook` for humans —
  `bootstrap` installs hooks).
- Bump a pin to make a snippet compile.
- Convert rST / AsciiDoc to Markdown unasked.
