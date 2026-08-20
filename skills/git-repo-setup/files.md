# Committed files

Write these at the **repository root** unless noted. Substitute the language
runtime and formatter; keep recipe names and Lefthook hook names.

Pin mise versions at bootstrap: `mise latest lefthook just gitleaks typos`
(and the language). Never commit the string `latest`.

## `.gitignore`

Start from [github/gitignore](https://github.com/github/gitignore) for the
language, then always add:

```gitignore
# secrets — never commit
.env
.env.*
!.env.example
*.pem
*.p12
credentials.json

# local overrides (not the shared config)
lefthook-local.yml
mise.local.toml
mise.toml.local

# direnv / OS / editors
.direnv/
.DS_Store
*.swp
.idea/

# language build output (keep what github/gitignore already covers)
```

Do not ignore `.vscode/`. Commit shared `extensions.json` and `launch.json`
([debug.md](debug.md); overlay fills them). Ignore personal `*.code-workspace`
either way. Do not commit `settings.json` unless the team already shares it.

After writing, `git check-ignore -v -- .env` must match.

## `.gitattributes`

```gitattributes
* text=auto eol=lf

*.bat text eol=crlf
*.cmd text eol=crlf
*.sln text eol=crlf

*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.webp binary
*.ico binary
*.pdf binary
*.woff binary
*.woff2 binary
*.zip binary

# generated / vendored — adjust paths to the repo
# encore.gen/** linguist-generated=true
# dist/** linguist-generated=true
# vendor/** linguist-vendored=true
```

This is the line-ending policy. Do not also set `core.autocrlf=true` in the
repo. Windows checkouts stay LF except the CRLF exceptions above.

## `.editorconfig`

```editorconfig
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

[*.go]
indent_style = tab
indent_size = 8

[*.py]
indent_size = 4

[Makefile]
indent_style = tab

[*.md]
trim_trailing_whitespace = false
```

Match `indent_size` to the language formatter already in the repo.

## `.mise.toml`

```toml
# Pin exact versions. Resolve with: mise latest lefthook just gitleaks typos
[tools]
lefthook = "VERSION"
just = "VERSION"
gitleaks = "VERSION"
typos = "VERSION"
# go = "1.26"
# node = "24"
# python = "3.13"
```

mise pins tools. Recipes live in the Justfile/Makefile, not `[tasks.*]` here.

Ignore `mise.local.toml` (personal pins). Commit this file.

Optional `.envrc` if the user uses direnv:

```bash
use mise
```

Then they `direnv allow .`. Do not add direnv as a hard requirement.

## `Justfile` (default task runner)

Lefthook `pre-commit` formats **staged** files on a developer commit.
`just check` / `just ci` must pass on a **clean tree with nothing staged**
(CI, agents). Those recipes therefore use full-tree, non-mutating commands
— not `lefthook run pre-commit`.

```just
set dotenv-load := false

default:
    @just --list

bootstrap:
    mise install
    lefthook install --force
    # language deps: go mod download / npm ci / uv sync

check:
    typos
    gitleaks dir --no-banner .
    # language overlay: git-repo-setup-go / -typescript / -python

test:
    # language overlay

ci: check test
```

`gitleaks dir` is the working tree. Do not put `gitleaks git` (full
history) in `check` on an existing long-history repo — run it once as an
audit. On a brand-new repo, history is short; `gitleaks git --no-banner`
as an extra audit is fine.

Fill `test` and the language lines in `check` from `git-repo-setup-go`,
`git-repo-setup-typescript`, or `git-repo-setup-python`. Keep the recipe
**names**.

## `Makefile` (only if Make is the runner)

```makefile
SHELL := /bin/bash
.DEFAULT_GOAL := help
.PHONY: help bootstrap check test ci

## help: list targets
help:
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/^## /  /'

## bootstrap: install tools and git hooks
bootstrap:
	mise install
	lefthook install --force

## check: full-tree lint, typos, secrets (no tests)
check:
	typos
	gitleaks dir --no-banner .

## test: run the test suite (language overlay)
test:
	# git-repo-setup-go / -typescript / -python

## ci: the gate CI and pre-push run
ci: check test
```

Same recipe names as Just. Language lines change; names do not.

## `lefthook.yml`

```yaml
pre-commit:
  parallel: true
  commands:
    gitleaks:
      run: gitleaks git --pre-commit --staged --redact --no-banner
      # older gitleaks (pre-8.19 hidden alias): gitleaks protect --staged --redact --no-banner
    typos:
      run: typos {staged_files}
    # formatters: git-repo-setup-go / -typescript / -python — do not copy all three

commit-msg:
  commands:
    conventional:
      run: |
        msg=$(head -n1 {1})
        echo "$msg" | grep -qE '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9][a-z0-9._/-]*\))?(!)?: .+|^Merge |^Revert '

pre-push:
  commands:
    ci:
      run: just ci
      # run: make ci
```

- `{staged_files}` — Lefthook expands to staged paths. The command is skipped
  when the glob matches nothing.
- Format commands live in the language overlay skills. Do not paste Go, TS,
  and Python formatters into one greenfield `lefthook.yml`.
- `stage_fixed: true` — restage formatter output. Required, or the commit
  stores the unformatted file.
- `commit-msg` regex stays aligned with the `conventional-commits` skill.
  TypeScript repos that already have commitlint: use that snippet from
  `conventional-commits` / `tooling.md` instead of this regex.
- `pre-push` calls **`just ci` or `make ci`**, never a third copy of the
  steps.

If `.github/workflows` exists, add:

```yaml
    actionlint:
      glob: ".github/workflows/*.{yml,yaml}"
      run: actionlint
```

only when `actionlint` is pinned in mise.

## README bootstrap section

```markdown
## Develop

Needs [mise](https://mise.jdx.dev/). Then:

    mise install
    just bootstrap   # hooks + language deps
    just ci          # same gate as CI and git push
```

Name the real recipe file (`just` vs `make`). Do not list Lefthook
commands for humans — `bootstrap` installs them.

Debug: Run and Debug uses the committed `.vscode/launch.json` (overlay
[debug.md](debug.md)). Do not document a personal F5 config in README.

## GitHub Actions

`.github/workflows/ci.yml`:

```yaml
name: ci
on:
  push:
    branches: [main]
  pull_request:

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: jdx/mise-action@v2
      - run: just ci
```

Use `make ci` if Make is the runner. Pin action SHAs if the repo already
pins actions; otherwise `@v2` / `@v4` is fine for a first kit.

## `.github/PULL_REQUEST_TEMPLATE.md`

```markdown
## Summary

<!-- Conventional Commits subject; squash-merge uses this title. -->

## Test plan

- [ ] `just ci` (or `make ci`) passes locally
```

## `LICENSE`

Do not invent a license. Public repo with no LICENSE: ask. Personal public
default if they say so: MIT. Private: skip.

## `.git-blame-ignore-revs`

Create only when you make a bulk format commit:

```
# gofmt the tree
<full sha>
```

Then `git config blame.ignoreRevsFile .git-blame-ignore-revs` is documented
in README, or set in a Lefthook `post-checkout` only if the team wants it
automatic. Do not set it globally from this skill.

## `.vscode/extensions.json`

Language overlay fills `recommendations`. Empty array is wrong — the
overlay always has at least Go (`golang.go`) or Python (`ms-python.python`).
TypeScript may be `[]` (Cursor already debugs Node).

```json
{
  "recommendations": []
}
```

## `.vscode/launch.json`

Language overlay fills `configurations`. Polyglot: concatenate, unique
`name`. Honor existing named configs.

```json
{
  "version": "0.2.0",
  "configurations": []
}
```

## Optional, not default

| File | When |
| --- | --- |
| `AGENTS.md` | Point agents at `just bootstrap` and `just ci`. One short page. Do not duplicate skills. |
| `CODEOWNERS` | Team repo |
| `.github/dependabot.yml` | GitHub, no Renovate yet |
| `.gitleaks.toml` | Allowlist false positives; extend the default config, do not copy the whole rule set |
| `typos.toml` | Project allow-list for names |
| Git LFS | Large binaries that must be versioned; never "just in case" |
