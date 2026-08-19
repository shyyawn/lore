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

Two layers. That is the whole agent setup.

1. **This repo's skills** — how we write Go, TypeScript, Encore, and Temporal (layout and 2024–2026 idioms).
2. **Three official Cursor plugins** — live tooling and vendor how-tos that this repo does not duplicate.

Install the skills (`make install` below), then in Cursor agent chat run these three commands (user scope, so they apply in every project):

```
/add-plugin encore
/add-plugin temporal
/add-plugin svelte
```

| Plugin | Covers | Do not also install |
| --- | --- | --- |
| [encore](https://cursor.com/marketplace/encore) | Live MCP against `encore run` (services, DBs, traces, call endpoints), plus Encore's own rules/skills/commands | `npx add-skill encoredev/skills` or a second Encore MCP |
| [temporal](https://cursor.com/marketplace/temporal) | Official Temporal SDK, CLI, and Cloud skill (`temporal-developer`) | `npx skills add temporalio/skill-temporal-developer` or the Temporal docs MCP |
| [svelte](https://cursor.com/marketplace/svelte) | Svelte MCP, skills, and the `svelte-file-editor` agent | Extra Svelte skill packs or a second Svelte MCP |

That combination covers the stack. You do **not** need more plugins, skill catalogs, or MCP servers to start.

**Who wins when they overlap:** lore skills own Go package layout and Encore+Temporal structure (`encore-go-app-structure`, `temporal-go-app-structure`, `encore-temporal-go-app-structure`). The plugins own live inspection (Encore MCP), official Temporal CLI/SDK encyclopedias, and Svelte UI. Do not copy plugin skills into `skills/` — `make uninstall` would wipe them, and you would be forking vendor docs.

Plugins are Cursor-only (`/add-plugin` is not available in the Cursor CLI). After installing, restart the agent chat if MCP tools do not appear.

Running an app is separate from this setup: Encore CLI, Temporal CLI (`temporal server start-dev`), Docker for local Postgres, Node for Svelte. Install those when you open a real app, not as agent knowledge.

## Skills

| Skill | Use |
| --- | --- |
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
