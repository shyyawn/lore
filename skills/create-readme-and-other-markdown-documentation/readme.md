# README shapes

Root `README.md` is the forge homepage and often the registry page.
One sentence what it does, then install, then one example. Do not make
it the wiki. Files that are not README: [files.md](files.md). Stack:
[stacks.md](stacks.md).

GitHub truncates past 500 KiB. GitHub builds a heading outline — skip a
hand-maintained TOC unless the file is genuinely long.

## Above the fold

Every README, in this order:

1. `#` project name (not `README`)
2. One sentence: what it is. Why it exists, if that is not obvious
3. Install or run (copy-paste). User-facing, not `just bootstrap`
4. One usage example that works on the pin
5. Link to more docs if they exist

Then, as needed: Develop (`git-repo-setup` stub), contributing link,
license name. Badges: few, live, CI + license + registry. No vanity
row.

## By repo kind

| Kind | README does | Does not |
| --- | --- | --- |
| Public library | Install from the registry, one call, link to API docs | Full API, every option |
| Public CLI | Install, one command, `--help` pointer, exit-status notes if they matter | Man page dump |
| Public app / SaaS | What the product is, who it is for, screenshot or GIF, how to try it | Internal runbooks |
| Private app | What it is, how to run locally, who owns it | CoC, FUNDING, marketing |
| Monorepo root | Map of packages, how to bootstrap the workspace | Each package's API |
| Publishable package in a monorepo | That package's install + example | Workspace kit commands |
| Template / cookiecutter | What you get, how to use the template | The generated app's user docs |
| Skill / agent library | What the skills cover, how to install | A copy of every `SKILL.md` |
| Research / academic | Abstract, how to reproduce, citation (`CITATION.cff`) | A paper dump |
| Docs-only repo | Map of the site, how to preview | Duplicate the site homepage |

Private: skip CoC, FUNDING, usually CONTRIBUTING. Keep README + Develop.
SECURITY still if outsiders can report.

Public that wants contributors: link CONTRIBUTING, CoC, SECURITY. Do
not paste those files into README.

## User install vs Develop

Two audiences. Do not merge them into one command list.

| Section | Reader | Commands |
| --- | --- | --- |
| Install / Usage | Someone consuming the project | `go install`, `uv add`, `npm i`, download a binary |
| Develop | Someone changing the project | `just bootstrap` then `just ci` (`git-repo-setup`) |

Encore / Temporal apps: "run" is `encore run` / worker + dev server.
That is Usage for an app, not library install. Kit bootstrap still
sits under Develop.

## Registry mirrors

npm, PyPI, and crates.io render `README.md`. pkg.go.dev renders **godoc**,
not README.

| Registry | README is | Watch |
| --- | --- | --- |
| npm | `README.md` at the package root | Relative images break. Use absolute URLs |
| PyPI | `readme` in `pyproject.toml` (often the same file) | Same image rule. rST still common — honor it |
| crates.io | `readme = "README.md"` in `Cargo.toml` | rustdoc is separate ([stacks.md](stacks.md)) |
| pkg.go.dev | Package comment | Do not treat README as API docs |
| GitHub | Root `README.md` | Relative links are rewritten per branch |

Point at `package.json` / `go.mod` / `pyproject.toml` for versions. Do
not hard-code "requires Node 18" in prose that will rot.

## Nested README

Allowed in a package directory that is published or is a real
subproject. It describes **that** package. Kit commands stay on the
root README. Do not copy the root README into every folder.

## Optional sections (below the fold)

| Section | When |
| --- | --- |
| Features | A library with three+ distinct jobs; bullets, not essays |
| Configuration | A table of the env vars / flags people hit first. Full list → reference |
| Architecture | One paragraph + link to ADRs or explanation docs |
| Contributing | One sentence + link to `CONTRIBUTING.md` |
| License | SPDX name + link to `LICENSE` |
| Citation | Link to `CITATION.cff` |
| Acknowledgments | Third-party work you must credit |

Skip: Roadmap, full changelog, CoC body, security-reporting procedure,
maintainer diary.

## Default skeleton

Public library. Cut sections the kind table says to skip.

````markdown
# short-name

One sentence what it does.

## Install

```bash
go get example.com/short-name
```

## Usage

```go
package main

func main() {
	// One working call. Match go.mod.
}
```

## Develop

Needs [mise](https://mise.jdx.dev/). Then:

    just bootstrap
    just ci

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. See [LICENSE](LICENSE).
````

Name the real install command and license
([stacks.md](stacks.md)). Do not leave the Go snippet in a Python repo.
Do not write MIT if they have not chosen a license.
