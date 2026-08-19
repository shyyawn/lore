# Tooling (Go / Python / TypeScript)

The official skill owns the *message* and commitlint validation in JS
repos. This file is what to attach in application repos. A skills
library does not need Lefthook, commitlint, or Release Please.

Do not add a Node toolchain to a Go or Python repo just to lint messages.

## What to use

| Job | Default | When not |
| --- | --- | --- |
| Spec / message | Official `conventional-commit-message` skill | Never fork it |
| Type enum | Angular / `@commitlint/config-conventional` | Repo already documents a different enum — honor it |
| Local `commit-msg` hook | [Lefthook](https://lefthook.dev/) | Repo already has husky / pre-commit. Do not stack runners |
| Message lint (TS/JS) | `commitlint` + `@commitlint/config-conventional` | Official skill already runs the local binary when present |
| Message lint (Go / Python) | Lefthook regex, or [commitizen](https://github.com/commitizen-tools/commitizen) in Python | Do not pull in `commitlint` unless Node is already first-class |
| Release (GitHub, any language) | [Release Please](https://github.com/googleapis/release-please) | — |
| Release (published TS library) | Release Please or [semantic-release](https://github.com/semantic-release/semantic-release) | Multi-package TS: [Changesets](https://github.com/changesets/changesets) |
| Release (Python package) | [python-semantic-release](https://python-semantic-release.readthedocs.io/) or commitizen `bump` | Release Please `python` type is fine for GitHub-only |
| Release (Go module) | Git tag `vX.Y.Z`. Changelog via Release Please `go`. Binaries via [GoReleaser](https://goreleaser.com/) on that tag | Do not invent a `VERSION` file unless a tool already requires it |
| Changelog only | [git-cliff](https://git-cliff.org/) | — |

CI must lint commit messages (or the squash PR title) even if local hooks
exist. Hooks are a convenience; CI is the gate.

## Changesets

[Changesets](https://github.com/changesets/changesets) versions packages
from `.changeset/` files, not from commit types. Right for multi-package
TypeScript monorepos. Still write Conventional Commits. Do not run
semantic-release and Changesets on the same packages.

## Lefthook `commit-msg` (Go / Python)

Lefthook is a git-hook runner (Go binary). It refuses a bad message. It
does not write messages, install skills, or bump versions. Skip it in
this knowledge repo.

```yaml
commit-msg:
  commands:
    conventional:
      run: |
        msg=$(head -n1 {1})
        echo "$msg" | grep -qE '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9][a-z0-9._/-]*\))?(!)?: .+|^Merge |^Revert '
```

## TypeScript: commitlint + Lefthook

```bash
npm i -D @commitlint/cli @commitlint/config-conventional
```

```js
export default { extends: ["@commitlint/config-conventional"] };
```

```yaml
commit-msg:
  commands:
    commitlint:
      run: npx --no -- commitlint --edit {1}
```

Honor extra rules already in the repo. Do not silently relax them.

## Release Please

Releasable units: `feat`, `fix`, usually `perf` / `deps`. Hidden types
do not bump. `!` / `BREAKING CHANGE` → major.

| Language | `release-type` | Version lives in |
| --- | --- | --- |
| Go | `go` | git tag `vX.Y.Z` (`/v2` in the module path is a separate, manual change) |
| Python | `python` | `pyproject.toml` / package version |
| TypeScript | `node` | `package.json` |

## Language notes

**Go.** The module version *is* the tag. GoReleaser builds from the tag;
it does not parse commits. A `feat!` that does not also change the module
path to `/v2` (etc.) is not a Go module major.

**Python.** python-semantic-release and commitizen both default to the
conventional parser and write PEP 440. Do not mix commitizen bumps with
python-semantic-release in one repo.

**TypeScript.** `semantic-release` is the npm-native pipeline. Release
Please if GitHub Releases are the product. Changesets if many packages.

## Honor the repo

If the repo already has commitlint, commitizen, husky, pre-commit, or a
regex hook, use that. Do not add a second linter.
