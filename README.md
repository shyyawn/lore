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

## Skills

| Skill | Use |
| --- | --- |
| [go-idioms](skills/go-idioms) | Idiomatic Go 1.18–1.26 and 2024–2026 layout |
| [encore-go](skills/encore-go) | Encore.go backends |
| [temporal-go](skills/temporal-go) | Temporal Go SDK |

## Install

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
