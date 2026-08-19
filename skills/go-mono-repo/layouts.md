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
`cmd/<name>`, not a second module. Do **not** add `libs/`, `lib/`,
`pkg/`, `shared/`, or `common/` as a bucket — those names are `util` by
another spelling. The directory is the noun (`internal/auth`). Official:
[Organizing a Go module](https://go.dev/doc/modules/layout). Split that
package into its **own module** only when another Git repo must `go get`
it at its own semver (`gopls/`, Vault `api/`).

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
`go.dev/doc/tutorial/workspaces`. Nested examples on GitHub:
`golang.org/x/tools/gopls` (tags `gopls/v0.x`), Vault `api/` (tags
`api/v1.x`). Not a `libs/` folder of tiny `go.mod`s.

```
repo/
  go.work                # committed iff lockstep (see SKILL.md)
  go.work.sum
  cmd/
    api/go.mod           # github.com/org/repo/cmd/api   (only if this binary publishes alone)
  auth/go.mod            # github.com/org/repo/auth      — the noun is the module
```

Prefer **one extra module at a named directory**, not `services/` +
`libs/` ceremony. Most products never get here.

```
go 1.26

use (
    .
    ./auth
)
```

Local imports resolve from disk. Each `go.mod` still has real `require`
lines so `GOWORK=off` works. After adding a workspace dependency:
`go work sync`.

## Tags

Go versions **are git tags**. `go.work` does not version anything.

| `go.mod` location | Tag for 1.2.3 | `require` |
| --- | --- | --- |
| Repo root | `v1.2.3` | `github.com/org/repo v1.2.3` |
| Directory `auth/` | `auth/v1.2.3` | `github.com/org/repo/auth v1.2.3` |

Root `v1.2.3` does not version a nested module. A nested tag does not
version the root. Wrong prefix → `unknown revision` and a
`v0.0.0-yyyymmdd-hash` pseudo-version. Majors: `/v2` in the **module
path**; tag stays `auth/v2.0.0` (prefix is the directory, not `/v2`).

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
