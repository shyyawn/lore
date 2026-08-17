# lore

What the agent should know: skills now; prompts, rules, and MCP client config later.

MCP *servers* stay in their own repos (for example [shyyawn/mcp](https://github.com/shyyawn/mcp)). This repo is only the agent-side lore that *uses* them.

## Layout

```
lore/
├── skills/                    # → ~/.cursor/skills/<name>/
│   ├── go-2026/
│   ├── encore-go-2026/
│   └── temporal-go-2026/
├── prompts/                   # reusable prompts / commands
├── rules/                     # always-on rules → .cursor/rules/
└── mcp/                       # which servers to attach (mcp.json), not server source
```

| Directory | Maps to | Add when |
| --- | --- | --- |
| `skills/<name>/SKILL.md` | `~/.cursor/skills/<name>/` or a project's `.cursor/skills/` | the agent should load domain knowledge on trigger |
| `prompts/` | Cursor prompts / custom commands | you have a repeatable prompt that is not a skill |
| `rules/` | `.cursor/rules/*.mdc` | guidance that should apply without being invoked |
| `mcp/` | Cursor MCP client config | you are wiring servers, not implementing them |

## Skills

| Skill | Use |
| --- | --- |
| [go-2026](skills/go-2026) | Idiomatic Go 1.18–1.26 and 2024–2026 layout |
| [encore-go-2026](skills/encore-go-2026) | Encore.go backends |
| [temporal-go-2026](skills/temporal-go-2026) | Temporal Go SDK |

## Install

```bash
git clone git@github.com:shyyawn/lore.git
cd lore
for s in skills/*; do
  ln -sfn "$(pwd)/$s" "$HOME/.cursor/skills/$(basename "$s")"
done
```

Project-local: copy a skill into that repo's `.cursor/skills/`.
