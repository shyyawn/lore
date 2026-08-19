---
name: conventional-commits
description: >-
  Overlay on conventional-changelog's conventional-commit-message skill:
  Go/Python/TypeScript scopes, Go module majors vs changelog majors, and
  commit-msg tooling that is not Node. Use when committing, amending, or
  writing a squash PR title in a Go, Python, or TypeScript repo.
---

# Conventional Commits (stack overlay)

The format lives in
[`conventional-commit-message`](https://github.com/conventional-changelog/conventional-changelog/blob/master/skills/conventional-commit-message/SKILL.md)
(conventional-changelog org). Install it; do not fork it into this repo.
This skill only adds Go / Python / TypeScript rules that skill does not.

Install (user scope, every project): see the lore README **Start here**
section, or:

```bash
npx skills add conventional-changelog/conventional-changelog \
  --skill conventional-commit-message -g --agent cursor
```

Do not also install `committing-with-commitlint` globally. Use it only in
a repo that already has commitlint.

Release and hook recipes: [tooling.md](tooling.md).

## First step

Follow `conventional-commit-message` for type, `!`, footers, changelog
wording, backticks, and commitlint validation.

Then apply this file: HEREDOC commit, language scopes, Go `/v2`, no Node
toolchain on a Go or Python repo.

## Commit mechanics

Pass the message via a **quoted** HEREDOC. The quotes on `'EOF'` are the
safety: the shell does not expand `$VAR`, `` `cmd` ``, or `$(cmd)` in the
body. The official skill wraps identifiers in backticks, so this is not
optional.

```bash
git commit -m "$(cat <<'EOF'
fix(auth): reject expired JWT before hitting the handler

The previous check ran after the DB lookup, so expired tokens
still paid for a round trip.

EOF
)"
```

That leak is real. `git commit -m "fix: handle `set`"` or `<<EOF` without
quotes runs `set` (or `printenv`, …) in the shell and can paste the
environment into the commit. Never `-m` twice, never unquoted `<<EOF`,
never `--no-verify`. Do not pass `--trailer`. Do not put `Authored by`,
`Co-authored-by`, `Made-with`, or any Cursor / Claude / Copilot /
generator banner in the message. Those are opt-in: add them only when
the user explicitly asks.

Honor leftover commitlint / Lefthook / commitizen in the repo. If the
hook rewrites files, new commit — do not amend a failed one unless the
repo's amend rules are all met. Squash-merge: the **PR title** is the
conventional commit that lands on the default branch.

## Scopes

| Stack | Scope is | Examples |
| --- | --- | --- |
| Go | package or command, not the module path | `feat(http):`, `fix(cmd/lore):` |
| Python | import package or extra | `feat(cli):`, `fix(lore.api):` |
| TypeScript | workspace package or area | `feat(ui):`, `fix(eslint-plugin):` |

Omit the scope when the change is repo-wide. Multiple scopes only when
the repo's commitlint config allows them.

## Breaking changes are not the same across languages

`feat!` / `BREAKING CHANGE` is a *contract* break. Language versioning
may need extra work:

| Stack | Means | Extra constraint |
| --- | --- | --- |
| TypeScript | SemVer major of the published package | Public `exports` / types, not private files |
| Python | Major of the distribution (PEP 440) | Public import surface, not tests |
| Go | A contract break for importers | A Go *module* major also requires `/v2` (or next) in the module path and import paths. A `feat!` that does not change the module path is a changelog major only — do not pretend the module is now `v2`. |

Apps that are not published still use `!` when you break callers (CLI
flags, env vars, HTTP, persisted files).

## Do not

- Copy the official skill into `skills/` or rewrite its type table here.
- Add Node / commitlint to a Go or Python repo just to lint messages.
- Pass `--trailer` or add agent authorship (`Authored by Cursor`,
  Claude, Copilot, `Co-authored-by`, generator banners) unless the
  user asks.
- Use Gitmoji as the type.
- Use `<<EOF` (unquoted), `git commit -m "..."`, or printf/echo that lets
  the shell expand the message. Always `<<'EOF'`.
