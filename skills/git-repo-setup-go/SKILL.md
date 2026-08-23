---
name: git-repo-setup-go
description: >-
  Go overlay for git-repo-setup: gofmt, go vet, golangci-lint v2, go test
  (encore test when encore.app exists), go.mod tool pins, Go gitignore,
  Cursor/VS Code/Zed Delve launch.json. Use when bootstrapping or
  retrofitting Git hooks / just / Make / Lefthook in a Go module, or when
  the repo has go.mod, *.go, or encore.app, or the user asks to debug Go
  in Zed.
---

# Git repo setup — Go

Follow `git-repo-setup` for the kit (init, Lefthook, mise, just/Make, ignore
basics, debugger). This file fills the **Go** commands and
[debug.md](debug.md). Language idioms stay in `go-idioms`. How to write tests
stays in `go-unit-tests`. Encore layout stays in `encore-go` /
`encore-go-app-structure`. Several `go.mod` files or a `go.work`:
`go-mono-repo` (test with `GOWORK=off` per published module).

## First step

1. Apply `git-repo-setup` (new vs existing, one hook manager, one task runner).
2. Read `go.mod` (`go` version). Do not bump `go` to unlock a linter.
3. If `encore.app` exists, tests are `encore test`, not `go test`.
4. If there is more than one `go.mod`, stop and follow `go-mono-repo`
   for workspace vs `GOWORK=off` before writing Just/Lefthook recipes.

Polyglot (Go + a `package.json` app): also apply `git-repo-setup-typescript`.
One `lefthook.yml`, one Justfile, both formatters.

## 2026 Go defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Runtime pin | mise `go` = the `go` line in `go.mod` | — |
| Format | `gofmt` | `goimports` / `gofumpt` already in `tool` or Lefthook |
| Vet | `go vet ./...` | — |
| Lint | [golangci-lint](https://golangci-lint.run/) v2 (`mise` pin + `.golangci.yml`) | Already in `tool` / CI, or staticcheck/revive already the extra gate |
| Vuln | `go tool govulncheck ./...` if `tool` lists it | Do not `curl | sh` golangci or govulncheck |
| Test | `go test ./...` | `encore.app` → `encore test ./...` |
| Race | `go test -race ./...` on `ci` when packages start goroutines | Existing CI already races (or cannot, e.g. some CGO) |
| Commit-msg | Lefthook regex (`conventional-commits` / `tooling.md`) | — |
| Debug | `.vscode/launch.json` ([debug.md](debug.md)) | Honor existing named configs |

Do not add Node, husky, or commitlint. `go get -tool` for govulncheck when
the module is serious CI; skip it on a throwaway.

## mise

```toml
[tools]
lefthook = "VERSION"
just = "VERSION"
gitleaks = "VERSION"
typos = "VERSION"
go = "1.26"   # exact: the go.mod `go` line
golangci-lint = "VERSION"   # mise latest golangci-lint
```

Private modules (`go.mod` on a host the public proxy cannot see):

```toml
[env]
GOPRIVATE = "gitlab.com/org"
```

Module prefix, not the whole site. Skip for `encore.app` and public
`github.com/…`. Honor an existing `GOPRIVATE`. SSH `insteadOf`: `gitconfig.md`.

## `.gitignore` extras

On top of `git-repo-setup` secrets/local-overrides, use
[github/gitignore Go.gitignore](https://github.com/github/gitignore/blob/main/Go.gitignore) plus:

```gitignore
bin/
dist/
*.exe
*.test
coverage.out
coverage.html
vendor/
__debug_bin*
```

Commit `vendor/` only if the module already vendors. Then mark it
`vendor/** linguist-vendored=true` in `.gitattributes`. Encore:
`encore.gen/** linguist-generated=true`. sqlc output (if committed):
`**/*.sql.go linguist-generated=true`.

[github/gitignore Go.gitignore](https://github.com/github/gitignore/blob/main/Go.gitignore)
ignores `go.work` and `go.work.sum`. That is correct for a personal
workspace overlay. If `go-mono-repo` says **commit** the workspace (lockstep
modules), delete those ignore lines so `go.work` / `go.work.sum` are tracked.
A `go.work.example` is the template when `go.work` stays gitignored.

## Lefthook (Go commands)

Keep gitleaks, typos, commit-msg, pre-push from `git-repo-setup`. Add:

```yaml
pre-commit:
  commands:
    fmt-go:
      glob: "*.go"
      run: gofmt -w {staged_files}
      stage_fixed: true
```

`gofmt` is the pre-commit budget. `go vet`, golangci-lint, and tests belong
in `just check` / `just test`, not every commit.

## `.golangci.yml`

v2 config. `default: standard`. Do not copy a 40-linter `enable` list.

```yaml
version: "2"

linters:
  default: standard
```

Encore (`encore.app`): exclude generated trees and compiler-owned
`initService` / `config.Load` (`unused` does not see the compiler).

```yaml
version: "2"

linters:
  default: standard
  exclusions:
    generated: lax
    paths:
      - encore\.gen
      - \.encore
    rules:
      - linters:
          - unused
        text: "initService is unused"
      - linters:
          - unused
        source: "config\\.Load"
```

Honor an existing `.golangci.yml`. Do not replace it. Do not `enable-all`.

## Codegen (only if the tree already has it)

Detect `sqlc.yaml`, `buf.yaml`, or `//go:generate`. Then:

- Recipe `generate`: `go generate ./...` (not on every `check` unless CI
  already does that).
- Pin sqlc / migrate / oapi-codegen / mock generators with `tool` in
  **this** `go.mod`. Do not add an `internal/tools` module.
- Do not add those tools to a repo with no queries, OpenAPI spec, or
  generate directives.

## Recipes

```just
bootstrap:
    mise install
    go mod download
    lefthook install --force
    # if .env.example exists: cp -n .env.example .env  (or .env.local if that is the name)

check:
    typos
    gitleaks dir --no-banner .
    test -z "$(gofmt -l .)"
    go vet ./...
    golangci-lint run

test:
    go test ./...

ci: check test
```

Encore: `test` is `encore test ./...`. `gofmt`, `go vet`, and
`golangci-lint run` still run. Do not put `go test` in the Encore recipe.

If `go.mod` has `govulncheck` as a tool, add `go tool govulncheck ./...` to
`check` (or `ci` if it is too slow for `check`).

Existing Makefile: add these **names**, keep Make. `go test` line becomes
`encore test` when `encore.app` is present.

## Debug

[debug.md](debug.md). `command -v dlv` ([hub](../git-repo-setup/debug.md#dlv)).
Encore: **Connect to Encore**, never F5 / Zed F4.

## Do not

- Add Node, husky, or commitlint to a Go-only repo.
- `go test` for Encore API packages.
- Pre-commit `go test ./...` (that is `pre-push` / `ci`).
- A second formatter (`gofumpt` + `gofmt`) unless the repo already standardized.
- `tools.go` — `tool` in `go.mod` (`go-idioms`). golangci-lint is the mise pin.
- golangci-lint `enable-all`. `default: standard`.
- Omit `.vscode/launch.json` on a new Go repo, or overwrite instead of merging.
- Omit golangci-lint when the repo has no extra linter. Do not stack it next to staticcheck/revive already in CI.
