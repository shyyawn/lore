---
name: go-mono-repo
description: >-
  Structures Go monorepos: one module (cmd/internal) by default, Encore as
  one encore.app, multi-module plus go.work only when modules version or
  publish independently. Use when the repo has more than one go.mod, a
  go.work file, staging modules, or the user mentions Go monorepo, Go
  workspace, go work, GOWORK, or splitting a module. Overlay on go-idioms.
  Encore: encore-go-app-structure. Do not add Bazel or a second encore.app.
---

# Go monorepo 2026

How many `go.mod` files, and whether to add `go.work`. Language and flatten
layout: `go-idioms`. Inside a service: `go-backend`. Encore services as
packages: `encore-go-app-structure`. Hooks/CI recipes: `git-repo-setup-go`.
Trees: [layouts.md](layouts.md).

Sources: `go.dev/ref/mod#workspaces`, the official workspace tutorial
(`golang.org/x/example`), Kubernetes 2024 `go.work` + `staging/` (publish
siblings — do not copy unless you publish). Not Nx, Turborepo, or Bazel
for a new app.

## First step

1. Count `go.mod` files and look for `encore.app` and `go.work`.
2. If `encore.app` exists: that **is** the backend monorepo. Stop and
   follow `encore-go-app-structure`. Do not add a second `encore.app` or
   a second `go.mod` for another Encore service.
3. Match the shape that is already there. Do not split a working single
   module into many as a drive-by.

## Earn a second module

Default is **one module** for the whole Git repo (`cmd/`, `internal/`).
Tick **yes** on at least two, or stay on one `go.mod`.

```
Earn a second go.mod:
- [ ] Independent version / tag (library consumers pin v1.2.3)
- [ ] Independent publish (another Git repo must `go get` this path)
- [ ] Different `go` line or a dependency the rest of the repo must not take
- [ ] A binary that must not import the rest of the tree even via internal/
```

Two HTTP services that ship together are **packages** (or Encore
services), not modules. `internal/` already stops outsiders. That is the
boundary until you publish.

## Choose a layout

| Situation | Layout |
| --- | --- |
| One product, several binaries | One module — `go-idioms` `architecture.md` |
| Encore backend | One `encore.app`, services = packages |
| Encore + Svelte (or other `package.json`) | One Go module + JS workspace. `git-repo-setup-go` + `git-repo-setup-typescript`. Not `go.work` |
| Lockstep modules that publish separately | Multi-module + committed `go.work` |
| Published libraries, most people work on one | Multi-module; gitignore `go.work` or ship `go.work.example` |
| Hermetic polyglot at Google/Uber scale | Bazel (`rules_go`, Gazelle). Do not invent for a greenfield app |

Trees: [layouts.md](layouts.md).

## `go.work`

Replaces `replace` in every `go.mod` for **local siblings**. Introduced
1.18. Commands:

```bash
go work init ./mod-a ./mod-b
go work use ./mod-c          # go work use -r . to discover
go work sync                 # copy the workspace build list into each go.mod
```

From the workspace root, `go test ./...` and `go build ./...` see every
`use`d module.

### Commit it or not

Official (`go.dev/ref/mod`): generally **do not** commit `go.work` — it
overrides a parent workspace and can make CI test the wrong versions.

**Commit** `go.work` **and** `go.work.sum` when every contributor develops
these modules in lockstep (internal product, Kubernetes-style). Then
github/gitignore's `go.work` / `go.work.sum` lines must **not** apply.

**Gitignore** them when developers compose their own `use` list, or when
the file is only a personal overlay of clones on disk. A
`go.work.example` may be committed as a template.

Either way: **CI that claims a module is releasable** runs with
`GOWORK=off` inside that module, so it resolves like an external
consumer. A separate job may test the workspace together.

Do not put sibling paths in `replace` in `go.mod` when `go.work` already
lists them. `replace` stays for forks and unpublished patches.

## Hard rules

- One Git repo may still be one module. "Monorepo" ≠ many `go.mod`s.
- Nested module tags are `subdir/v1.2.3`, not a root `v1.2.3` for that
  module. Majors are `/v2` in the **module path** (`conventional-commits`).
  Full table: [layouts.md](layouts.md).
- Name directories for the **noun** (`internal/auth`, module `auth/`).
  No `libs/`, `lib/`, `pkg/`, `shared/`, `common/` buckets (`go-idioms`).
- `internal/` is per-module. A sibling module **cannot** import another
  module's `internal/`. Shared-and-private stays `internal/<noun>` in the
  **one** module until another repo must import it.
- Do not nest a `go.mod` under a package that already belongs to a parent
  module (broken import paths).
- Vendoring: one `vendor/` per module. Workspace vendoring exists (k8s
  needed it); do not add `vendor/` to a module that does not already vendor.
- Tools: `tool` in the module that runs them (1.24+), not a fake
  `tools/` module unless the repo already has one.

## After every layout edit

```bash
gofmt -w <files>
# one module / workspace:
go vet ./...
go test ./...
# each published module:
GOWORK=off go test ./...     # run inside that module
go work sync                 # if go.work is in play and require lines drifted
```

Encore: `encore test ./...`. Do not `go work` the Encore app unless the
repo already has extra modules beside it.

## Review workflow

```
Go monorepo:
- [ ] encore.app → encore-go-app-structure; no second encore.app / go.mod for services
- [ ] One go.mod unless the earn checklist passed
- [ ] go.work only for 2+ modules; replace not used for in-repo siblings
- [ ] Commit go.work iff lockstep; else gitignore + optional go.work.example
- [ ] Releasable modules tested with GOWORK=off
- [ ] No import of another module's internal/
- [ ] Shared code is `internal/<noun>`, not libs/pkg/shared
- [ ] Polyglot JS is pnpm/npm, not a Go module per frontend package
```

## LLM traps — never generate these

- A `go.mod` per Encore service or per `cmd/` binary
- `replace ../sibling` in every `go.mod` instead of `go.work`
- Splitting `internal/` into modules so two services "look like microservices"
- A `libs/`, `lib/`, `pkg/`, or `shared/` directory as the place shared code goes
- Nx / Turborepo / Pants / Bazel on a new Go app
- Kubernetes `staging/` + publish scripts without actually publishing
- Copying github/gitignore `go.work` ignore while also committing `go.work`
- `GO111MODULE=off` or GOPATH staging trees
- A second `encore.app` for "the monorepo"

## Do not

- Restyle a working single-module repo into `go.work` as a drive-by.
- Duplicate `encore-go-app-structure` service layout here.
- Teach Bazel/Gazelle unless the repo already has `WORKSPACE` / `MODULE.bazel`.
