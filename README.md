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
| [go-2026](skills/go-2026) | Idiomatic Go 1.18–1.26 and 2024–2026 layout |
| [encore-go-2026](skills/encore-go-2026) | Encore.go backends |
| [temporal-go-2026](skills/temporal-go-2026) | Temporal Go SDK |

## Install

Cursor can import a GitHub repo whose skills live under `skills/`. Or symlink:

```bash
git clone git@github.com:shyyawn/lore.git
cd lore
mkdir -p ~/.cursor/skills ~/.agents/skills
for s in skills/*; do
  name=$(basename "$s")
  ln -sfn "$(pwd)/$s" "$HOME/.cursor/skills/$name"
  ln -sfn "$(pwd)/$s" "$HOME/.agents/skills/$name"
done
```

`~/.agents/skills` is the portable location (Cursor, Claude Code, Codex). `~/.cursor/skills` is Cursor-only. Symlink both.

Project-local: copy a skill into that repo's `.cursor/skills/` (or `.agents/skills/`).
