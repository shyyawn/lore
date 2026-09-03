---
name: git-repo-setup-python
description: >-
  Python overlay for git-repo-setup: uv, ruff format/check, pytest, Python
  gitignore, Lefthook without Node, Cursor/VS Code/Zed debugpy launch.json.
  Use when bootstrapping or retrofitting Git hooks / just / Make / Lefthook
  in a Python project, or when the repo has pyproject.toml, uv.lock, *.py,
  or Poetry/requirements files, or the user asks to debug Python, set
  breakpoints, or add launch.json.
---

# Git repo setup — Python

Follow `git-repo-setup` for the kit. This file fills the **Python** commands
and [debug.md](debug.md). Language idioms stay in `python-idioms`.
Commit-msg regex: `conventional-commits` / `tooling.md` (no commitlint
unless Node is already first-class).

## First step

1. Apply `git-repo-setup`.
2. Read `pyproject.toml` and the lockfile (`uv.lock`, `poetry.lock`,
   `pdm.lock`, `requirements.txt`). Honor the installer already in use.
3. Read Ruff/Black/isort/flake8/pylint config in `pyproject.toml`.
   **One formatter + linter.** If none, add Ruff. Do not add Ruff next to
   Black or flake8.

Polyglot: also apply the Go or TypeScript overlay. One `lefthook.yml`, one
Justfile.

## 2026 Python defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Runtime pin | mise `python` from `requires-python` | — |
| Installer | [uv](https://docs.astral.sh/uv/) | Poetry / PDM / pip-tools already locking the repo |
| Format + lint | [Ruff](https://docs.astral.sh/ruff/) (`format` + `check`) | Black + isort + flake8 already the gate |
| Test | `pytest` | `unittest` already the suite |
| Commit-msg | Lefthook regex | commitizen already in the project — honor it, do not stack |
| Types | `ty` / `pyright` / `mypy` only if already configured | Do not add a typechecker as part of git bootstrap |
| Debug | `.vscode/launch.json` ([debug.md](debug.md)): current file + pytest | Honor existing named configs |

Do not add Node, husky, or commitlint to a Python-only repo.

## mise

```toml
[tools]
lefthook = "VERSION"
just = "VERSION"
gitleaks = "VERSION"
typos = "VERSION"
python = "3.13"   # pin requires-python, not latest
uv = "VERSION"
```

Ruff comes in via uv (`uv add --dev ruff pytest`) or mise `ruff = "VERSION"`.
Prefer the project's `pyproject.toml` `[dependency-groups] dev` so CI and
humans share one lockfile. Pinning ruff **only** in mise (not in the project)
is a drift source — do not.

## `.gitignore` extras

On top of the shared secrets/local-overrides, use
[github/gitignore Python.gitignore](https://github.com/github/gitignore/blob/main/Python.gitignore) plus:

```gitignore
.venv/
__pycache__/
*.py[cod]
.ruff_cache/
.pytest_cache/
.mypy_cache/
dist/
*.egg-info/
```

Commit `uv.lock`. Ignore `.venv/`.

## Lefthook (Python commands)

Keep gitleaks, typos, commit-msg regex, pre-push from `git-repo-setup`. Add:

```yaml
pre-commit:
  commands:
    fmt-py:
      glob: "*.py"
      run: uv run ruff format {staged_files}
      stage_fixed: true
    lint-py:
      glob: "*.py"
      run: uv run ruff check --fix {staged_files}
      stage_fixed: true
```

If the project does not use uv: `ruff format` / `ruff check --fix` on PATH
(mise pin). Same commands, no `uv run`.

`pytest` is not a pre-commit command. It belongs in `just test` / `ci`.

## Recipes

```just
bootstrap:
    mise install
    uv sync --all-groups
    lefthook install --force

check:
    typos
    gitleaks dir --no-banner .
    uv run ruff format --check .
    uv run ruff check .

test:
    uv run pytest

ci: check test
```

Poetry: `poetry install` / `poetry run ruff` / `poetry run pytest`. Keep
recipe **names**. Do not add uv beside a working Poetry lock.

## Debug

[debug.md](debug.md). App: Current File. Tests: pytest (or unittest).

## Do not

- Black + Ruff format on the same files.
- `pip install` without a lockfile on `bootstrap`.
- commitlint / husky in a Python-only tree.
- A typechecker added "because the git kit should be complete".
- Omit `.vscode/launch.json` or `extensions.json` on a new Python repo, or overwrite instead of merging.
