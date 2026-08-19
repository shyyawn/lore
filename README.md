# lore

Agent knowledge as files. Skills now; rules, subagents, and MCP client config when they exist.

MCP *servers* (the processes) stay in their own repos — for example [shyyawn/mcp](https://github.com/shyyawn/mcp). This repo only holds what the agent should read.

## Layout

Matches how public skill libraries are published ([anthropics/skills](https://github.com/anthropics/skills), skills.sh) and where Cursor actually loads files.

```
lore/
├── skills/<name>/SKILL.md     # Agent Skills (required name + description)
├── rules/*.mdc                # always-on or glob-scoped rules
├── agents/                    # subagent definitions
└── mcp.json                   # MCP *client* config when you add it (not committed secrets)
```

| Path | Installs as | What belongs here |
| --- | --- | --- |
| `skills/<name>/` | `~/.cursor/skills/<name>/` and `~/.agents/skills/<name>/` | Repeatable domain playbooks. Cursor also loads `.claude/skills` and `.codex/skills`. |
| `rules/*.mdc` | `~/.cursor/rules/` or a project's `.cursor/rules/` | Short always-on or glob-scoped constraints. Dynamic “apply intelligently” rules are skills instead. |
| `agents/` | `~/.cursor/agents/` | Subagent personas. Add when you have one. |
| `mcp.json` | `~/.cursor/mcp.json` or `.cursor/mcp.json` | Which servers to attach. Use `${env:NAME}` for secrets. Never commit keys. |

Slash prompts / `.cursor/commands/` are legacy. New user-invoked workflows are skills with `disable-model-invocation: true` in frontmatter.

## Start here (Cursor)

Three layers. That is the whole agent setup.

1. **This repo's skills** — how we write Go, TypeScript, Encore, and Temporal, plus a Conventional Commits *overlay* for those languages and a 2026 Git repo kit.
2. **Three official Cursor plugins** — live tooling and vendor how-tos that this repo does not duplicate.
3. **One official vendor skill** — Conventional Commits format, from conventional-changelog. Not a Cursor plugin.

Install this repo (`make install` below), then:

```
/add-plugin encore
/add-plugin temporal
/add-plugin svelte
```

```bash
npx skills add conventional-changelog/conventional-changelog \
  --skill conventional-commit-message -g --agent cursor
```

Plugins are user-scope from agent chat. The `npx skills add … -g --agent cursor` line is user-scope too: it lands in `~/.cursor/skills/conventional-commit-message` (every project). Omit `-g` only if you want it in one repo's `.agents/skills/`.

| Source | Covers | Do not also install |
| --- | --- | --- |
| [encore](https://cursor.com/marketplace/encore) plugin | Live MCP against `encore run` (services, DBs, traces, call endpoints), plus Encore's own rules/skills/commands | `npx add-skill encoredev/skills` or a second Encore MCP |
| [temporal](https://cursor.com/marketplace/temporal) plugin | Official Temporal SDK, CLI, and Cloud skill (`temporal-developer`) | `npx skills add temporalio/skill-temporal-developer` or the Temporal docs MCP |
| [svelte](https://cursor.com/marketplace/svelte) plugin | Svelte MCP, skills, and the `svelte-file-editor` agent | Extra Svelte skill packs or a second Svelte MCP |
| [`conventional-commit-message`](https://github.com/conventional-changelog/conventional-changelog/tree/master/skills/conventional-commit-message) skill | Commit *format*: types by release impact, `!` / `BREAKING CHANGE`, scopes, commitlint check | Random skills.sh / Lobe copies; `committing-with-commitlint` globally (only in a repo that already has commitlint) |

That combination covers the stack. You do **not** need more plugins, skill catalogs, or MCP servers to start.

**Who wins when they overlap:** lore skills own Go package layout and Encore+Temporal structure (`encore-go-app-structure`, `temporal-go-app-structure`, `encore-temporal-go-app-structure`), and the Conventional Commits *overlay* (`conventional-commits`: Go `/v2`, Python/TS releasers, Lefthook without Node). The plugins own live inspection (Encore MCP), official Temporal CLI/SDK encyclopedias, and Svelte UI. `conventional-commit-message` owns the commit format. Do not copy plugin or vendor skills into `skills/` — `make uninstall` would wipe a fork, and you would be maintaining vendor docs.

Plugins are Cursor-only (`/add-plugin` is not available in the Cursor CLI). `npx skills add` works from any terminal. After installing plugins, restart the agent chat if MCP tools do not appear.

Running an app is separate from this setup: Encore CLI, Temporal CLI (`temporal server start-dev`), Docker for local Postgres, Node for Svelte. Install those when you open a real app, not as agent knowledge.

## Skills

| Skill | Use |
| --- | --- |
| [conventional-commits](skills/conventional-commits) | Go/Python/TS overlay on the official `conventional-commit-message` skill (install that first — [Start here](#start-here-cursor)) |
| [git-repo-setup](skills/git-repo-setup) | 2026 Git repo kit: init, hooks, mise, just/Make, ignore/attributes |
| [git-repo-setup-go](skills/git-repo-setup-go) | Go overlay: gofmt, go vet, go test / encore test |
| [git-repo-setup-typescript](skills/git-repo-setup-typescript) | TypeScript overlay: Biome, tsc, vitest, commitlint |
| [git-repo-setup-python](skills/git-repo-setup-python) | Python overlay: uv, ruff, pytest |
| [go-idioms](skills/go-idioms) | Idiomatic Go 1.18–1.26 and 2024–2026 layout |
| [typescript-idioms](skills/typescript-idioms) | Idiomatic TypeScript 5–7 and 2024–2026 layout |
| [encore-go](skills/encore-go) | Encore.go backends |
| [encore-go-app-structure](skills/encore-go-app-structure) | Encore Go package layout |
| [temporal-go](skills/temporal-go) | Temporal Go SDK |
| [temporal-go-app-structure](skills/temporal-go-app-structure) | Temporal Go package layout |
| [encore-temporal-go-app-structure](skills/encore-temporal-go-app-structure) | Encore + Temporal Go layout |

## Install

Cursor plugins are the other half of setup — see [Start here](#start-here-cursor). This section is only the skills in this repo.

Cursor can import a GitHub repo whose skills live under `skills/`. Or install locally:

```bash
git clone git@github.com:shyyawn/lore.git
cd lore
make install
```

| Target | Does |
| --- | --- |
| `make install` | Copy every skill into `~/.cursor/skills` and `~/.agents/skills` |
| `make status` | Show which installed copies have drifted from the repo |
| `make uninstall` | Remove this repo's skills from both locations |
| `make list` | List the skills in this repo |

`~/.agents/skills` is the portable location (Cursor, Claude Code, Codex). `~/.cursor/skills` is Cursor-only. `install` writes both, and leaves skills it does not own (symlinks to other repos) alone.

These are **copies, not symlinks** — a running agent keeps a stable snapshot while you edit. The trade-off is drift: re-run `make install` after every change, and `make status` reports what is stale. Symlink instead (`ln -sfn`) if you would rather edits go live immediately.

Project-local: copy a skill into that repo's `.cursor/skills/` (or `.agents/skills/`).
