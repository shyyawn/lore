# Events (chooser)

Official payload fields: [extensions](https://pi.dev/docs/latest/extensions).
This file is **which event**. Do not recopy the API.

Register tools and commands in the factory. Events only react.

## Pick one

| Job | Event / API | Do not |
| --- | --- | --- |
| Confirm or block a tool | `tool_call` → `{ block, reason }` | Pattern-match as a sandbox |
| Rewrite tool output | `tool_result` | — |
| Inject or tweak system prompt this turn | `before_agent_start` | Paste a lore catalog |
| Add skill/prompt/theme paths | `resources_discover` | Duplicate `~/.agents/skills` |
| Transform raw `/` input | `input` | Steal skill expansion |
| Trust `.pi` / project skills | `project_trust` (global/`-e` only) | Project-local extension here |
| Init / reconstruct state | `session_start` | Start watchers in the factory |
| Close sockets / watchers | `session_shutdown` | Assume factory runs again |
| Custom compact | `session_before_compact` | — |
| Git stash per turn | `turn_start` | — |
| Status / widget | `ctx.ui.setStatus` / `setWidget` | A second footer without need |
| LLM-callable action | `pi.registerTool` | Bash instructions in a skill when HTTP is the job |
| User slash action | `pi.registerCommand` | A command that only loads a skill |
| File write from a tool | `withFileMutationQueue` | Parallel edit + write on one path |

Seven events cover most house work: `session_start`, `session_shutdown`,
`before_agent_start`, `tool_call`, `tool_result`, `input`,
`resources_discover`.

## Modes

| Mode | `ctx.mode` | `ctx.hasUI` |
| --- | --- | --- |
| Interactive | `tui` | yes |
| RPC | `rpc` | yes (JSON dialogs; `custom()` is undefined) |
| JSON stream | `json` | no |
| Print `pi -p` | `print` | no |

Dialogs: `hasUI`. `ui.custom`: `mode === "tui"`.

## Imports

| Package | For |
| --- | --- |
| `@earendil-works/pi-coding-agent` | `ExtensionAPI`, events, `withFileMutationQueue` |
| `typebox` | `Type` for tool params |
| `@earendil-works/pi-ai` | `StringEnum` |
| `@earendil-works/pi-tui` | custom render |
| `node:fs` / `node:path` | files |

In a `pi` package those four are `peerDependencies` `"*"`. Do not
bundle them.
