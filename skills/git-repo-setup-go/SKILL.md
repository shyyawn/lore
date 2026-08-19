---
name: git-repo-setup-go
description: >-
  Go overlay for git-repo-setup: gofmt, go vet, go test (encore test when
  encore.app exists), go.mod tool pins, Go gitignore. Use when bootstrapping
  or retrofitting Git hooks / just / Make / Lefthook in a Go module, or when
  the repo has go.mod, *.go, or encore.app.
---

# Git repo setup — Go

Follow `git-repo-setup` for the kit (init, Lefthook, mise, just/Make, ignore
basics). This file fills the **Go** commands. Language idioms stay in
`go-idioms`. Encore layout stays in `encore-go` / `encore-go-app-structure`.

## First step

1. Apply `git-repo-setup` (new vs existing, one hook manager, one task runner).
2. Read `go.mod` (`go` version). Do not bump `go` to unlock a linter.
3. If `encore.app` exists, tests are `encore test`, not `go test`.

Polyglot (Go + a `package.json` app): also apply `git-repo-setup-typescript`.
One `lefthook.yml`, one Justfile, both formatters.

## 2026 Go defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Runtime pin | mise `go` = the `go` line in `go.mod` | — |
| Format | `gofmt` | `goimports` / `gofumpt` already in `tool` or Lefthook |
| Vet | `go vet ./...` | — |
| Vuln | `go tool govulncheck ./...` if `tool` lists it | Do not `curl | sh` golangci or govulncheck |
| Lint extra | none | `golangci-lint` already in `tool` or CI |
| Test | `go test ./...` | `encore.app` → `encore test ./...` |
| Race | `go test -race ./...` on `ci` when packages start goroutines | Existing CI already races (or cannot, e.g. some CGO) |
| Commit-msg | Lefthook regex (`conventional-commits` / `tooling.md`) | — |

Do not add Node, husky, or commitlint. Do not add golangci-lint to a greenfield
module unless asked. `go get -tool` for govulncheck when the module is serious
CI; skip it on a throwaway.

## mise

```toml
[tools]
lefthook = "VERSION"
just = "VERSION"
gitleaks = "VERSION"
typos = "VERSION"
go = "1.26"   # exact: the go.mod `go` line
```

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
```

Commit `vendor/` only if the module already vendors. Then mark it
`vendor/** linguist-vendored=true` in `.gitattributes`. Encore:
`encore.gen/** linguist-generated=true`.

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

`gofmt` is the pre-commit budget. `go vet` and tests belong in `just check` /
`just test`, not every commit.

## Recipes

```just
bootstrap:
    mise install
    go mod download
    lefthook install --force

check:
    typos
    gitleaks dir --no-banner .
    test -z "$(gofmt -l .)"
    go vet ./...

test:
    go test ./...

ci: check test
```

Encore: `test` is `encore test ./...`. `go vet ./...` and `gofmt` still run.
Do not put `go test` in the Encore recipe.

If `go.mod` has `govulncheck` as a tool, add `go tool govulncheck ./...` to
`check` (or `ci` if it is too slow for `check`).

Existing Makefile: add these **names**, keep Make. `go test` line becomes
`encore test` when `encore.app` is present.

## Do not

- Add Node, husky, or commitlint to a Go-only repo.
- `go test` for Encore API packages.
- Pre-commit `go test ./...` (that is `pre-push` / `ci`).
- A second formatter (`gofumpt` + `gofmt`) unless the repo already standardized.
- `tools.go` — `tool` in `go.mod` (`go-idioms`).
