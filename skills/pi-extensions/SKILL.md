---
name: pi-extensions
description: >-
  Decides whether a Pi coding-agent change is AGENTS.md, a prompt
  template, a skill, or a TypeScript extension, then writes the
  extension when earned. Use when building or editing a Pi extension,
  pi.registerTool, pi.registerCommand, before_agent_start, tool_call
  gates, or a Pi package; when converting a lore skill into an
  extension; when the user asks skill vs extension.
---

# Pi extensions 2026

TypeScript that **runs** in Pi. A skill tells the model what to do.
An extension controls what Pi does. Default is **no**.

Sources: [pi.dev](https://pi.dev/)
[extensions](https://pi.dev/docs/latest/extensions),
[skills](https://pi.dev/docs/latest/skills),
[prompt templates](https://pi.dev/docs/latest/prompt-templates),
[packages](https://pi.dev/docs/latest/packages). Official examples:
`earendil-works/pi` `packages/coding-agent/examples/extensions`.
Not that tree. Not MCP as a default.

Events: [events.md](events.md). Lore mapping: [lore.md](lore.md).

## First step

1. Inventory what is already there. Honor it.

   `~/.pi/agent/` (AGENTS.md, skills, prompts, extensions, settings),
   project `.pi/`, `~/.agents/skills` (`make install` already copies
   lore skills there — Pi loads that path).
2. If the job is lore `SKILL.md` voice, **stop** and follow
   `new-change-lore-skills`.
3. Pick the **layer**. Do not jump to TypeScript.

   | Need | Use |
   | --- | --- |
   | Short rule every session | `AGENTS.md` / `SYSTEM.md` |
   | Typed `/name` that expands Markdown | prompt template |
   | On-demand playbook the model follows | skill (`SKILL.md`) |
   | Code in the harness (block, tool, TUI) | extension — only if Earn |
4. Earn an extension (below). Tick yes on at least two, or stay on
   skill / prompt / AGENTS.md.

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Layer | skill | always-on short → AGENTS.md; `/name` expand → prompt; Earn → extension |
| Place | `~/.pi/agent/extensions/*.ts` | project `.pi/extensions/` after trust |
| Style | one `.ts` file | two+ modules → `*/index.ts`; npm deps → local `package.json` |
| Test | `pi -e ./path.ts` | auto-discover + `/reload` once it lives in a discovery dir |
| Schema | TypeBox `Type` | — |
| Enums | `StringEnum` from `@earendil-works/pi-ai` | — |
| UI dialogs | `ctx.hasUI` first | print/JSON: block or skip — never hang |
| Share | later `pi` package | a lone file that works |

`make install` already publishes lore skills to Pi via
`~/.agents/skills`. Do not copy the same skill into
`~/.pi/agent/skills` as a second tree.

## Division of labor

| Artifact | Owner |
| --- | --- |
| Layer choice; Pi TypeScript; Earn | this skill |
| Lore `SKILL.md` voice | `new-change-lore-skills` |
| Which lore catalogs stay skills | [lore.md](lore.md) |
| Kit files, Go/TS/Python idioms, catalogs 1–7 | those skills — not this file |

## Earn an extension

Copy this checklist. Tick **yes** on at least two, or stay on a
skill.

```
Earn a Pi extension:
- [ ] Must intercept a lifecycle event (block a tool, inject, compact)
- [ ] Must run code the model would otherwise bash/curl (HTTP, parse, write)
- [ ] Must show TUI (confirm, select, custom) or persist session state
- [ ] Must enforce a gate the model cannot be trusted to follow
- [ ] The skill already exists and the mechanical part still fails after
      `/skill:name`
```

If every line is **no**, write or keep the skill. Recopying
`SKILL.md` into `before_agent_start` is **not** an extension.

`/skill:name` already loads a skill. A command that only injects
that Markdown is a prompt template, or nothing.

## What this skill owns

| Own | Leave |
| --- | --- |
| Layer chooser; Earn; factory shape | Official events dump ([events.md](events.md)) |
| Mechanical gap on top of a lore skill | The catalogs themselves ([lore.md](lore.md)) |
| | Pi MCP (default is **no**) |

## Default shapes

Auto-discover (so `/reload` works):

```
~/.pi/agent/extensions/foo.ts          # global
.pi/extensions/foo.ts                  # project, after trust
```

Factory. Copy this, then fill **one** concern:

```typescript
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (ctx.hasUI) ctx.ui.notify("foo loaded", "info");
  });

  pi.registerCommand("foo", {
    description: "One-line what /foo does",
    handler: async (args, ctx) => {
      if (!ctx.hasUI) return;
      ctx.ui.notify(args || "ok", "info");
    },
  });

  pi.registerTool({
    name: "foo_tool",
    label: "Foo",
    description: "What the model should call this for",
    parameters: Type.Object({
      name: Type.String({ description: "Name" }),
    }),
    async execute(_id, params, signal) {
      if (signal?.aborted) {
        return { content: [{ type: "text", text: "Cancelled" }] };
      }
      return {
        content: [{ type: "text", text: `ok ${params.name}` }],
        details: {},
      };
    },
  });
}
```

Test: `pi -e ./foo.ts`. Then move it into a discovery directory.

One extension, one job. A permission gate is not also a `/commit`
command. Split files.

Official recipes (copy from examples, do not vendor here):
`permission-gate.ts`, `protected-paths.ts`, `todo.ts`,
`with-deps/`.

## Hard rules

- Register tools, commands, shortcuts, and flags at **factory**
  top-level. Do not register them inside an event handler.
- Factory must not start watchers, sockets, or timers. Start those
  on `session_start` (or the command that needs them). Close them
  on `session_shutdown`. Idempotent.
- `tool_call` handlers return `{ block: true, reason }` to stop.
  No return means proceed. Handler errors fail-safe **block**.
- Check `ctx.hasUI` before confirm/select/notify. Check
  `ctx.mode === "tui"` before `custom()`. Print and JSON have no
  dialogs.
- File-mutating tools use `withFileMutationQueue()` on the resolved
  absolute path. Tools run in parallel by default.
- Persist tool state in result `details`. Rebuild it on
  `session_start` from the branch. In-memory only dies on `/tree`.
- After `newSession` / `fork` / `switchSession`, use only the
  `withSession` `ctx`. Captured old `pi` / `sessionManager` is
  stale.
- Treat `await ctx.reload()` as terminal for that handler
  (`return` after it).
- Extensions have full system access. Do not install untrusted
  packages. Tokens from env, never from the file.
- Do not bump Pi to unlock an example. Target the installed CLI.

## Do not add

| Need | Use | Do not add |
| --- | --- | --- |
| Always-on short rule | `AGENTS.md` | `before_agent_start` injecting `go-idioms` |
| Reusable slash prompt | `prompts/name.md` | extension command that only expands Markdown |
| On-demand playbook | lore skill (`/skill:name`) | TypeScript that recopies `SKILL.md` |
| Block / confirm / HTTP / TUI | extension | MCP as the default integration |
| Share skills+extensions | `pi` package (`package.json` `pi` key) | a second copy under `~/.pi/agent/skills` |

## After every edit

```bash
pi -e ./path.ts
# auto-discovered: /reload
# print: pi -p -e ./path.ts "…"  — UI paths no-op or block, never hang
```

## When it breaks

| Symptom | Usually means |
| --- | --- |
| Command missing from `/` | Registered inside an event, or file not in a discovery dir |
| `/reload` does nothing | Loaded only via `pi -e` |
| Hang in `pi -p` | Dialog without `ctx.hasUI` |
| Last write wins on the same file | Missing `withFileMutationQueue` |
| State gone after `/tree` | In-memory only; not in `details` |
| Skill never loads in Pi | Not in `~/.agents/skills`; `make install` |
| Full catalog in every turn | `before_agent_start` recopy; use the skill |
| Project extension missing | Project not trusted yet |
| Two copies of the same skill | `~/.agents/skills` **and** `~/.pi/agent/skills` |

## LLM traps — never generate these

- TypeScript that pastes `go-idioms` / catalogs 1–7 into the
  system prompt
- `/go-idioms` command that only calls `/skill:go-idioms`
- MCP client as the first Pi integration
- `registerCommand` inside `session_start`
- Watchers started in the factory
- `ui.confirm` in print mode with no `hasUI` guard
- Zod when TypeBox is the pin
- Fork of `examples/extensions/` into `skills/`
- A lore skill rewritten as an extension "so it runs first"

## Do not

- Convert a working lore skill into an extension as a drive-by.
- Skip Earn because the user said "make it an extension".
- Recopy official events/examples into SKILL.md
  ([events.md](events.md)).
- Hang this under `go-idioms` or `typescript-idioms`.
- Teach a second Pi beside the installed CLI.
- Add `disable-model-invocation` so this skill never auto-fires.
