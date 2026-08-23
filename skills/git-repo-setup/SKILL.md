---
name: git-repo-setup
description: >-
  Bootstraps and retrofits Git repositories to 2026 defaults: main + reftable
  on init, SSH commit signing, .gitignore/.gitattributes/.editorconfig,
  Lefthook hooks, mise-pinned tools, one linter per language, one task runner
  (just; Make if already present), and a shared Cursor/VS Code/Zed debugger.
  Use when creating a new repo, running git init, adding hooks, a Makefile
  or Justfile, lefthook, husky, pre-commit, gitleaks, mise, debug,
  launch.json, debug.json, Zed, or a linter, or when the user asks to set
  up or modernize an existing repository's Git, debugger, or local dev tooling.
---

# Git repo setup (2026)

One committed kit so humans, CI, and agents run the **same gate**. Do not
invent a second Makefile, a second hook runner, or CI steps that diverge from
local recipes.

File contents: [files.md](files.md). Machine `git config`: [gitconfig.md](gitconfig.md).
Debugger: [debug.md](debug.md) (Cursor/VS Code/Zed; overlay fills `launch.json`).
Commit messages: `conventional-commits` skill. Do not restyle those messages here.
Documentation **content**: `create-readme-and-other-markdown-documentation`.
This kit only requires a Develop section to exist.

## First step

1. `git --version` and `git rev-parse --is-inside-work-tree` (and parent dirs).
   Need Git **2.45+** (reftable). Prefer **2.50+** (2.55 is the 2026 current line).
2. Decide **new** vs **existing**:

   | Situation | Path |
   | --- | --- |
   | No `.git` in this tree or parents | New repo workflow |
   | `.git` exists here | Existing repo workflow |
   | `.git` exists in a **parent** | Stop. Do not nest a repo. |

3. Inventory what is already there before writing files: `.gitignore`,
   `.gitattributes`, `.editorconfig`, `lefthook.yml` / `.husky/` /
   `.pre-commit-config.yaml`, `Justfile` / `Makefile` / `Taskfile.yml`,
   `.mise.toml` / `.tool-versions`, `.vscode/`, `.zed/`, `.github/workflows`,
   `.golangci.yml`, `biome.json` / `biome.jsonc`, `eslint.config.*`,
   `.prettierrc*`, Ruff/Black in `pyproject.toml`.
   **Honor a working stack.** One hook manager, one task runner.
4. Language overlay (read that skill; do not invent formatter/test commands):

   | Detect | Overlay |
   | --- | --- |
   | `go.mod` / `*.go` / `encore.app` | `git-repo-setup-go` |
   | `package.json` + TypeScript/JS (`tsconfig.json`, `*.ts`, `*.tsx`, `svelte.config.*`) | `git-repo-setup-typescript` |
   | `pyproject.toml` / `uv.lock` / `*.py` | `git-repo-setup-python` |
   | More than one | Apply each overlay. Still one `lefthook.yml` and one Justfile/Makefile |

## 2026 defaults (new repos)

Pick these. Do not offer a menu.

| Job | Default | Honor instead when |
| --- | --- | --- |
| Default branch | `main` | Remote already uses another name — document it, do not rename unasked |
| Ref storage (new only) | `reftable` via `init.defaultRefFormat` | Git 2.44 or older, or a required local tool cannot open reftable |
| Object hash | `sha1` | Never `sha256` for a GitHub/GitLab/Gitea remote |
| Line endings | `.gitattributes` `* text=auto eol=lf` | File format requires CRLF (`*.bat`, `*.sln`) |
| Editor | `.editorconfig` | Repo already has one |
| Tool pins | [mise](https://mise.jdx.dev/) `.mise.toml` | `.tool-versions` / asdf already in use — keep that file, or migrate to mise if asked |
| Task runner | [just](https://github.com/casey/just) `Justfile` | `Makefile` / `Taskfile.yml` already exists and is the CI entry |
| Git hooks | [Lefthook](https://lefthook.dev/) `lefthook.yml` | husky / pre-commit / a working `core.hooksPath` already wired |
| Commit messages | Conventional Commits (existing skill) | Repo already lints a documented enum |
| Secrets (local) | `gitleaks git --pre-commit --staged` | — |
| Secrets (forge) | GitHub push protection / GitLab secret detection | — |
| Spell-check | [typos](https://github.com/crate-ci/typos) | — |
| Format (code) | Language overlay (`git-repo-setup-go` / `-typescript` / `-python`) | — |
| Lint | Overlay default if that language has none | Honor the linter already gating that language |
| Format (json/md/toml/yaml) | [dprint](https://dprint.dev/) when those files are first-class | Prettier already owns them |
| Debug | Shared `.vscode/launch.json` + `extensions.json` ([debug.md](debug.md)). Zed reads `launch.json` | Merge existing names/ids; honor a committed `.zed/debug.json` |

Do not stack Lefthook with husky or the Python `pre-commit` framework.
Do not put `just` recipes *and* a Makefile that both claim `ci`.
Do not commit `latest` as a mise version — pin what `mise latest <tool>` returns.

## Canonical recipes

Same names whether the file is `Justfile` or `Makefile`:

| Recipe | Does | Who runs it |
| --- | --- | --- |
| `bootstrap` | `mise install`, language deps, `lefthook install --force` | Human / agent after clone |
| `check` | Full-tree lint, format-check, typos, secret scan (no tests) | `just check`; part of `ci` |
| `test` | The project's tests | Human / agent |
| `ci` | Full gate: `check` + `test` | pre-push, GitHub Actions, agents |

Lefthook **pre-commit** is the fast staged-file subset (format, typos,
gitleaks). Lefthook **pre-push**, CI, and agents all run `ci`. If those
lists ever differ, the kit is wrong.

## New repo workflow

Copy this checklist and tick it.

```
New repo:
- [ ] Machine gitconfig is sane (gitconfig.md) — do not --global unless asked
- [ ] git init -b main --ref-format=reftable
- [ ] .gitignore, .gitattributes, .editorconfig
- [ ] .mise.toml (lefthook, just, gitleaks, typos, + language runtime)
- [ ] Language linter (overlay default if that language has none)
- [ ] .vscode/extensions.json + launch.json (debug.md)
- [ ] Justfile with bootstrap / check / test / ci
- [ ] lefthook.yml (pre-commit + commit-msg + pre-push)
- [ ] README (how to bootstrap) and LICENSE if the repo is public
- [ ] .github/PULL_REQUEST_TEMPLATE.md if GitHub
- [ ] CI workflow that runs the ci recipe
- [ ] just bootstrap
- [ ] gitleaks dir --no-banner .   (clean tree before first push)
- [ ] Initial commit, conventional message
```

```bash
git init -b main --ref-format=reftable
```

If `git init` warns that `main` is not the configured default, set
`init.defaultBranch` locally or tell the user to set it globally
([gitconfig.md](gitconfig.md)). Do not leave the repo on `master`.

Write the shared files from [files.md](files.md). Language ignore rules,
Lefthook formatters, and `check`/`test` bodies come from the overlay skill
in step 4. Then:

```bash
just bootstrap   # or: make bootstrap
just ci          # must pass on an empty/new tree
```

First commit is `chore: initial repository kit` (or `chore: bootstrap git hooks and task runner`).
Do not `--no-verify`.

## Existing repo workflow

Additive. Do not rewrite history, rename `master`, replace a Makefile with a
Justfile, or migrate husky → Lefthook unless the user asked.

```
Existing repo:
- [ ] Inventory hook manager, task runner, CI, ignore/attributes/editorconfig
- [ ] Inventory encore.app, go.mod / cmd/, package.json (skip node_modules), pyproject.toml, existing .vscode/ / .zed/
- [ ] Fill gaps only (missing .gitattributes, .editorconfig, secret scan)
- [ ] If no hook manager: add Lefthook, do not also add husky
- [ ] If no task runner: add Justfile (or Makefile if the user asked for make)
- [ ] If a task runner exists: add missing recipe *names*, keep the file
- [ ] Debug: debug.md (launch.json + extensions.json)
- [ ] Lint: overlay default if that language has none
- [ ] `.env.example` and no local env → `cp -n .env.example .env`
- [ ] Point CI at `just ci` / `make ci` if CI currently inlines the same steps
- [ ] lefthook install --force  (or honor the existing manager's install)
- [ ] gitleaks git --no-banner .  (history audit; report only, do not rewrite)
- [ ] Document bootstrap in README if missing
```

**Do not** `git filter-repo` / BFG for line endings or secrets unless the user
explicitly wants history rewritten. A leaked secret that is already on a
remote is a **rotation** problem, not a `.gitignore` problem.

**Do not** convert an existing repo to reftable (`git refs migrate`) or sha256
as part of this skill.

If husky / pre-commit already runs the right gates, leave it. Offer Lefthook
as a migration only when asked.

## Lefthook layout

`lefthook.yml` at the repo root. Install is `lefthook install --force` from
`bootstrap`, not a committed `.git/hooks`. Ignore `lefthook-local.yml`.

| Hook | Runs | Budget |
| --- | --- | --- |
| `pre-commit` | gitleaks staged, typos on staged, language formatter on `{staged_files}` (`stage_fixed: true`) | Seconds. Parallel. |
| `commit-msg` | Conventional Commits (copy from the `conventional-commits` skill) | Instant |
| `pre-push` | `just ci` / `make ci` | As long as tests take |

Do not run the full test suite on every commit. Do not set `core.hooksPath` to
a hand-rolled `.githooks/` *and* Lefthook. Do not `--no-verify` to "finish the
setup".

Templates: [files.md](files.md).

## Make vs just

New repo → **Justfile**. Existing Makefile that already is the gate → **keep
it**, add `bootstrap` / `check` / `test` / `ci` if missing. User asked for
Make → write a Makefile with those names, no Justfile.

`.DEFAULT_GOAL := help` and `## help:` comments if you write Make (same
pattern as this lore repo). `just --list` if you write Just.

## GitHub (when the remote is GitHub)

Committed:

- `.github/PULL_REQUEST_TEMPLATE.md` — remind that squash-merge **titles**
  are Conventional Commits
- `.github/workflows/ci.yml` — `mise` + `just ci` (or `make ci`)
- `.github/dependabot.yml` for GitHub-native bumps; Renovate only if already
  in use. Not both.

Forge settings (tell the user; do not pretend a file enables them): default
branch `main`, squash merge, push protection, branch protection requiring the
`ci` check. `CODEOWNERS` only for a team repo.

## Do not

- Nest a git repo inside another.
- `git config --global` unless the user asked to configure **this machine**.
- Set `init.defaultObjectFormat sha256` (forges are still sha1).
- Commit `.env`, `*.pem`, `credentials.json`, `lefthook-local.yml`, `mise.local.toml`.
- Add Node (`husky`, `commitlint`) to a Go or Python repo just for hooks.
- Duplicate CI steps that already live in `just ci`.
- Ignore hook failure, or document `--no-verify` as the workflow.
- Vendor a second copy of this skill into the target repo.
- Gitignore `.vscode/`, add `.zed/debug.json`, omit `launch.json` / `extensions.json` on a new repo, or overwrite instead of merging.
- Skip the overlay linter when that language has none, or stack a second linter on the same language.

## Old patterns

<details>
<summary>Replace these when doing a greenfield setup; leave them on existing repos unless asked to migrate.</summary>

- Default branch `master`
- Husky + lint-staged (Node-only hook runner)
- Python `pre-commit` framework as the only installer (fine if already working)
- Hand-maintained `.git/hooks` or `core.hooksPath=.githooks` without Lefthook
- `core.autocrlf=true` as the team policy (use `.gitattributes` instead)
- asdf `.tool-versions` without mise, for new repos
- `npm run` / `go test` copy-pasted independently into hooks, Makefile, and CI
</details>
