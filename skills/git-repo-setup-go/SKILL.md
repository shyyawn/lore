---
name: git-repo-setup-go
description: >-
  Go overlay for git-repo-setup: gofmt, go vet, golangci-lint v2, go test
  (encore test when encore.app exists), go.mod tool pins, Go gitignore,
  Cursor/Delve launch.json. Use when bootstrapping or retrofitting Git
  hooks / just / Make / Lefthook in a Go module, or when the repo has
  go.mod, *.go, encore.app, or the user asks to debug Go, set breakpoints,
  add launch.json, or add a Go linter.
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
3. If there is no extra linter (no `.golangci.yml`, no golangci-lint /
   staticcheck / revive in `tool` or CI), add golangci-lint (mise +
   `.golangci.yml`). Honor the extra gate that already exists.
4. If `encore.app` exists, tests are `encore test`, not `go test`.
5. If there is more than one `go.mod`, stop and follow `go-mono-repo`
   for workspace vs `GOWORK=off` before writing Just/Lefthook recipes.

Polyglot (Go + a `package.json` app): also apply `git-repo-setup-typescript`.
One `lefthook.yml`, one Justfile, one `launch.json`, one `extensions.json`.
golangci-lint **and** Biome (one linter per language).

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
| Debug | `.vscode/launch.json` ([debug.md](debug.md)): Encore attach, Launch `cmd/`, `mode: test` for packages without Encore init | Honor existing named configs |

Do not add Node, husky, or commitlint. `go get -tool` for govulncheck when
the module is serious CI; skip it on a throwaway. golangci-lint is the
**linter bar**, not throwaway-optional: add it when missing.

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

Private modules (`go.mod` path is `gitlab.com/…` or another host the
public proxy cannot see): set mise `[env] GOPRIVATE` to that **module
prefix**, not `gitlab.com` for the whole site.

```toml
[env]
GOPRIVATE = "gitlab.com/org"
```

Do not set `GOPRIVATE` for `encore.app` or public `github.com/…` modules.
Honor an existing `GOPRIVATE`. Machine `insteadOf` for SSH: `gitconfig.md`.

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
symbols (`initService`, `config.Load`). The compiler calls those; `unused`
does not.

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

Write `.vscode/extensions.json` + `launch.json` from [debug.md](debug.md)
on greenfield. Encore: **Connect to Encore**, never F5 Launch Package.
Tests: `mode: test` for packages without Encore init; `encore test` for
service packages. Polyglot: one `launch.json`, one `extensions.json`, merge.
One linter per language.

## Do not

- Add Node, husky, or commitlint to a Go-only repo.
- `go test` for Encore API packages.
- Pre-commit `go test ./...` (that is `pre-push` / `ci`).
- A second formatter (`gofumpt` + `gofmt`) unless the repo already standardized.
- `tools.go` or a second `internal/tools` `go.mod` — `tool` in the app `go.mod`; golangci-lint is the mise pin.
- golangci-lint `enable-all` / a 40-linter enable list. `default: standard`.
- Omit `.vscode/launch.json` or `extensions.json` on a new Go or Encore repo, or overwrite an existing one instead of merging named configs.
- Omit golangci-lint on a Go repo that has no extra linter. Do not add it next to staticcheck/revive already in CI. Do not `curl | sh` the binary.
- Commit `.vscode/settings.json` with `go.alternateTools` pointing at a home mise shim. Activate mise in the shell; the path is per-machine.
