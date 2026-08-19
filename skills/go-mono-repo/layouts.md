# Layouts

Canonical trees. Gate on the earn checklist in [SKILL.md](SKILL.md).

## One module (default)

Most 2024–2026 Go products (Caddy-style, Tailscale-style, this repo's
`go-idioms`). Several binaries, one version, `internal/` as the wall.

```
repo/
  go.mod                 # github.com/org/repo
  go.sum
  cmd/
    api/main.go
    worker/main.go
  internal/
    billing/
    auth/
```

Shared code that must not leak: `internal/<noun>`. A second binary is
`cmd/<name>`, not a second module.

## Encore (backend monorepo)

One `encore.app`. Services are **packages**, not modules.
`encore-go-app-structure`.

```
repo/
  encore.app
  go.mod                 # often encore.app
  hello/                 # service
  world/                 # service
  internal/              # shared helpers, no APIs
  web/                   # optional Svelte app — JS, not a Go module
```

Do not add `hello/go.mod`. Polyglot frontend: `git-repo-setup-typescript`
next to this, one Lefthook.

## Multi-module + workspace

When modules version or publish on their own. Official stitch:
`go.dev/doc/tutorial/workspaces` (play with `golang.org/x/example`).

```
repo/
  go.work                # committed iff lockstep (see SKILL.md)
  go.work.sum
  services/
    api/go.mod           # github.com/org/repo/services/api
    worker/go.mod
  libs/
    auth/go.mod          # github.com/org/repo/libs/auth
```

```
go 1.26

use (
    ./services/api
    ./services/worker
    ./libs/auth
)
```

Local imports resolve from disk. Each `go.mod` still has real `require`
lines so `GOWORK=off` works. After adding a workspace dependency:
`go work sync`.

Tags for a nested module: `libs/auth/v1.2.3` (directory prefix). Module
path majors: `.../libs/auth/v2`.

## Kubernetes staging (do not cargo-cult)

`kubernetes/kubernetes` is one Git repo that **publishes** sibling
modules from `staging/src/k8s.io/...`. Since 2024 it commits `go.work`
so tools work across those modules without GOPATH tricks.

Copy this only if you also publish those directories as their own
repos/modules. For an internal product, one module or a small
`use` list is enough. Do not add `hack/update-vendor.sh`.

## Bazel

Cockroach, parts of Uber/Google: `rules_go` + Gazelle when the build
graph is polyglot and CI time is the product. If there is no
`MODULE.bazel` / `WORKSPACE` already, do not start one.
