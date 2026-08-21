# Stacks

Language, framework, and renderer. README kind first
([readme.md](readme.md)). Then this file. Honor the pin. Do not bump it
to unlock a snippet.

## Detect

| Detect | Docs that are not Markdown | README / extra |
| --- | --- | --- |
| `go.mod` | Godoc comments (`go.dev/doc/comment`) | README is human; pkg.go.dev is godoc |
| `encore.app` | Generated API explorer | README: `encore run`. Layout: `encore-go-app-structure` |
| `go.temporal.io/sdk` | docs.temporal.io | README: worker + dev server. Do not recopy the SDK |
| `pyproject.toml` / `*.py` | Docstrings (PEP 257). Sphinx or MkDocs when earned | PyPI readme = this README unless they set another |
| `package.json` + TS/JS | TSDoc / JSDoc for public API | npm renders README. `exports` / `types` in package.json, not prose |
| `svelte.config.*` | Svelte component docs in `.svelte` | README is the app. Do not fork the Svelte tutorial |
| `Cargo.toml` | rustdoc | README = why; rustdoc = how. Do not `include_str!` by default |
| `*.csproj` / `*.fsproj` | XML docs | Honor existing DocFX / docfx.json |
| `mkdocs.yml` | MkDocs Markdown + `!!!` admonitions | Do not write GFM alerts in those pages |
| `docusaurus.config.*` | MDX + `:::` admonitions | Frontmatter required by the site. Not on GitHub health files |
| `hugo.toml` / `hugo.yaml` | Hugo flavor | Honor archetypes |
| `*.rst` / `*.adoc` | rST / AsciiDoc | Honor. Do not convert unasked |

## Go

README: what the module is, `go get`, one working snippet. API lives in
doc comments. Every exported name has a comment. Package comment sets
the story. Syntax: [Go doc comments](https://go.dev/doc/comment) — a
Markdown subset, headings with `#`, no raw HTML.

Do not generate `README.md` from godoc as the default. Two audiences.
Example in README; details in comments. `Example` functions in `_test.go`
show on pkg.go.dev — prefer those over a second copy in README.

Commands (`package main`): README is the CLI shape. Godoc is still the
import docs if the module exposes a library.

## Encore

README Usage: `encore run`. Do not document provisioned infra as YAML.
Do not recopy encore.dev. Link the language docs. App layout stays in
`encore-go-app-structure` / `encore-temporal-go-app-structure`. Generated
API docs are the reference; README does not duplicate every endpoint.

## Temporal

README: how this worker starts, which task queue, how to run the
dev server. Link [docs.temporal.io](https://docs.temporal.io). Do not
paste SDK encyclopedias. Workflow determinism stays in `temporal-go`.

## Python

README: `uv add` / `pip install` from the real package name. PyPI
long description is the README when `pyproject.toml` says so. Docstrings
are the API. Sphinx (`docs/conf.py`) or MkDocs: honor. Earned site +
no SSG yet → MkDocs Material.

Do not add a second README in rST if Markdown already publishes.

## TypeScript / npm

README: `npm i <name>` / `pnpm add` matching the repo's package manager.
One import + call. Types: TSDoc on the public surface. Do not paste
`tsc` flags the `tsconfig` already sets.

Monorepo package: package README for npm; root README for the workspace
kit.

## Svelte / SvelteKit

README: what the app is, `pnpm dev`, env vars in a table. Component
contracts stay next to the component. Do not copy the Svelte tutorial
into `docs/`. Honor `svelte-file-editor` / the Svelte plugin for `.svelte`
files.

## Rust

README: why this crate, `cargo add`, one example. rustdoc: how, with
intra-doc links. Default is **two** texts. Do not
`#![doc = include_str!("../README.md")]` unless the crate is tiny and
the README has no GitHub-only images.

## Docs site already there

Follow that site's flavor and sidebar. Fill gaps. Do not add a parallel
`docs/` tree, and do not switch SSG as a drive-by.

| Site | Flavor | Admonition |
| --- | --- | --- |
| GitHub only | GFM | `> [!NOTE]` |
| MkDocs Material | MkDocs Markdown | `!!! note` |
| Docusaurus | MDX | `:::note` |
| VitePress | MD + Vue | containers per their docs |
| Sphinx | rST (or MyST) | Honor |

## OpenAPI / protobuf / GraphQL

The spec is the reference. Markdown how-to may **link** it. Do not
hand-write an endpoint table that will drift. Generated human pages
(Redoc, SpectaQL): honor; do not recopy into README.
