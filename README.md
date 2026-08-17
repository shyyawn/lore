# cursor-config

Personal [Cursor](https://cursor.com) agent config: skills, and later prompts, rules, and MCP client config.

MCP *servers* (the programs that speak the protocol) live in their own repos — for example [shyyawn/mcp](https://github.com/shyyawn/mcp). This repo only holds the agent-side config that *uses* them.

## Layout

```
skills/          # Cursor Agent Skills (~/.cursor/skills/<name>/)
prompts/         # reserved
rules/           # reserved (.cursor/rules)
mcp/             # reserved (mcp.json / server lists, not server source)
```

## Skills

| Skill | Use |
| --- | --- |
| [go-2026](skills/go-2026) | Idiomatic Go 1.18–1.26 and 2024–2026 layout |
| [encore-go-2026](skills/encore-go-2026) | Encore.go backends |
| [temporal-go-2026](skills/temporal-go-2026) | Temporal Go SDK |

## Install

Copy or symlink into your personal skills directory:

```bash
git clone git@github.com:shyyawn/cursor-config.git
cd cursor-config
for s in skills/*; do
  ln -sfn "$(pwd)/$s" "$HOME/.cursor/skills/$(basename "$s")"
done
```

Project-local install: copy a skill into that repo's `.cursor/skills/`.
