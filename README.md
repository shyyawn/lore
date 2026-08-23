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
├── scripts/                   # make setup (lore + vendor skills)
└── mcp.json                   # MCP *client* config when you add it (not committed secrets)
```

| Path | Installs as | What belongs here |
| --- | --- | --- |
| `skills/<name>/` | `~/.cursor/skills/<name>/` | Repeatable domain playbooks. Cursor also loads `.claude/skills` and `.codex/skills`. |
| `rules/*.mdc` | `~/.cursor/rules/` or a project's `.cursor/rules/` | Short always-on or glob-scoped constraints. Dynamic “apply intelligently” rules are skills instead. |
| `agents/` | `~/.cursor/agents/` | Subagent personas. Add when you have one. |
| `scripts/` | not copied | `make setup` and vendor skill install. Not agent knowledge. |
| `mcp.json` | `~/.cursor/mcp.json` or `.cursor/mcp.json` | Which servers to attach. Use `${env:NAME}` for secrets. Never commit keys. |

Slash prompts / `.cursor/commands/` are legacy. New user-invoked workflows are skills with `disable-model-invocation: true` in frontmatter.

## Start here (Cursor)

Three layers. That is the whole agent setup.

1. **This repo's skills** — how we write Go, TypeScript, CSS, Encore, Temporal, and Svelte, plus TypeScript unit tests, e2e policy, a Conventional Commits *overlay* for those languages, and a 2026 Git repo kit.
2. **Official Cursor plugins** — live tooling and vendor how-tos that this repo does not duplicate.
3. **Official vendor skills** — Conventional Commits format; Expo / React Native / EAS; Vercel React performance; Next.js workflows; Playwright CLI. Not Cursor plugins.

On a new machine, clone this repo, then run one command for all scriptable setup:

```bash
git clone git@github.com:shyyawn/lore.git
cd lore
make setup
```

That installs this repo's skills and the vendor packs, then prints the plugin steps. Plugins are not part of `make setup`. User-scope plugins may sync when you sign into Cursor on a new machine. If the plugins are missing, in agent chat:

```
/add-plugin encore
/add-plugin temporal
/add-plugin svelte
```

Vendor commands (`make install-vendor-skills`):

```bash
npx skills add conventional-changelog/conventional-changelog \
  --skill conventional-commit-message -g --agent cursor

npx skills add expo/skills -g --agent cursor

npx skills add vercel-labs/agent-skills \
  --skill vercel-react-best-practices -g --agent cursor

npx skills add vercel/next.js -g --agent cursor

npx --yes @playwright/cli install --skills -g
```

Plugins are user-scope from agent chat. The `npx skills add … -g --agent cursor` lines are user-scope too: they land in `~/.cursor/skills` (every project). Omit `-g` only if you want them in one repo's `.agents/skills/`.

| Source | Covers | Do not also install |
| --- | --- | --- |
| [encore](https://cursor.com/marketplace/encore) plugin | Live MCP against `encore run` (services, DBs, traces, call endpoints), plus Encore's own rules/skills/commands | `npx add-skill encoredev/skills` or a second Encore MCP |
| [temporal](https://cursor.com/marketplace/temporal) plugin | Official Temporal SDK, CLI, and Cloud skill (`temporal-developer`) | `npx skills add temporalio/skill-temporal-developer` or the Temporal docs MCP |
| [svelte](https://cursor.com/marketplace/svelte) plugin | Svelte MCP, skills, and the `svelte-file-editor` agent | Extra Svelte skill packs or a second Svelte MCP |
| [`conventional-commit-message`](https://github.com/conventional-changelog/conventional-changelog/tree/master/skills/conventional-commit-message) skill | Commit *format*: types by release impact, `!` / `BREAKING CHANGE`, scopes, commitlint check | Random skills.sh / Lobe copies; `committing-with-commitlint` globally (only in a repo that already has commitlint) |
| [`expo/skills`](https://github.com/expo/skills) | Expo SDK, Expo Router, native UI, upgrades, EAS (build, submit, hosting, workflows). Router skill is `expo-overview` | Extra Expo packs; Lobe / skills.sh copies; `vercel-react-native-skills` beside this pack |
| [`vercel-react-best-practices`](https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices) | Web React and Next performance (RSC, waterfalls, `Activity`). From [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | The rest of that repo (`writing-guidelines`, `deploy-to-vercel`, …) unless you asked |
| [`vercel/next.js`](https://github.com/vercel/next.js/tree/canary/skills) skills | Next **workflows**: `next-dev-loop`, Cache Components and Partial Prefetching adoption. Framework APIs stay in the project's `AGENTS.md` | Retired [`next-skills`](https://github.com/vercel-labs/next-skills); a lore App Router encyclopedia |
| Official [Playwright skills](https://playwright.dev/docs/getting-started-cli) | Playwright CLI, codegen, traces, session (`playwright-cli install --skills`) | LambdaTest / QASkills Playwright packs; a lore Playwright API dump |

Optional scanner for React changes: [`react-doctor`](https://cursor.com/marketplace/react-doctor) (`/add-plugin react-doctor`, or `npx react-doctor install`). Expo MCP is optional live docs and EAS when you open an Expo app — see [Cursor and Expo](https://docs.expo.dev/agents/cursor). Do not add a second Expo skills pack to get the MCP. Next.js 16.3+: `next dev` writes `AGENTS.md` that points at `node_modules/next/dist/docs/`. That is the pin-matched encyclopedia — see [AI agents](https://nextjs.org/docs/app/guides/ai-agents). Do not install the retired knowledge pack.

That combination covers the stack. You do **not** need more plugins, skill catalogs, or MCP servers to start.

**Who wins when they overlap:** lore skills own Go package layout and Encore+Temporal structure (`encore-go-app-structure`, `temporal-go-app-structure`, `encore-temporal-go-app-structure`), the Svelte **pin and Kit tree** (`svelte`, `sveltekit-app-structure`), TypeScript **what to test** (`typescript-unit-tests`), when to add **journeys** (`e2e-tests`), and the Conventional Commits *overlay* (`conventional-commits`: Go `/v2`, Python/TS releasers, Lefthook without Node). The plugins own live inspection (Encore MCP), official Temporal CLI/SDK encyclopedias, and Svelte runes / autofixer / live docs. `conventional-commit-message` owns the commit format. Official Playwright skills own CLI / codegen / traces. `expo/skills` owns Expo, React Native-with-Expo, EAS, and native Maestro. `vercel-react-best-practices` owns web React and Next performance. Next.js **APIs and App Router** are the project's `AGENTS.md` plus bundled `next` docs. `vercel/next.js` skills own the verify loop and Cache Components / Partial Prefetching workflows. TypeScript language stays `typescript-idioms` — do not flatten Next `app/` or Expo Router `app/` with its `src/<noun>/` tree. CSS language stays `css-idioms`. There is no lore React, Expo, or Next overlay: those vendors already own pin and layout. Do not copy plugin or vendor skills into `skills/` — `make uninstall` would wipe a fork, and you would be maintaining vendor docs.

Plugins are Cursor-only (`/add-plugin` is not available in the Cursor CLI). `npx skills add` works from any terminal. After installing plugins, restart the agent chat if MCP tools do not appear.

Running an app is separate from this setup: Encore CLI, Temporal CLI (`temporal server start-dev`), Docker for local Postgres, Node for Svelte, React, or Next, Expo CLI / EAS when you open an Expo app. Install those when you open a real app, not as agent knowledge.

## Skills

| Skill | Use |
| --- | --- |
| [new-change-lore-skills](skills/new-change-lore-skills) | House look for creating or changing any skill in this repo |
| [conventional-commits](skills/conventional-commits) | Go/Python/TS overlay on the official `conventional-commit-message` skill (install that first — [Start here](#start-here-cursor)) |
| [git-repo-setup](skills/git-repo-setup) | 2026 Git repo kit: init, hooks, mise, just/Make, ignore/attributes, linters, shared debugger |
| [git-repo-setup-go](skills/git-repo-setup-go) | Go overlay: gofmt, go vet, golangci-lint, go test / encore test, Delve `launch.json` |
| [git-repo-setup-typescript](skills/git-repo-setup-typescript) | TypeScript overlay: Biome, tsc, vitest, Playwright `e2e` when present, commitlint, Node / Next / SvelteKit / Expo `launch.json` |
| [git-repo-setup-python](skills/git-repo-setup-python) | Python overlay: uv, ruff, pytest, debugpy `launch.json` |
| [create-readme-and-other-markdown-documentation](skills/create-readme-and-other-markdown-documentation) | README, community health files, changelogs, ADRs, agent files, and docs/ trees |
| [go-idioms](skills/go-idioms) | Idiomatic Go 1.18–1.27 and 2024–2026 layout |
| [go-100-mistakes-avoid](skills/go-100-mistakes-avoid) | Overlay on `go-idioms`: common Go mistakes still in force in 2026 |
| [go-unit-tests](skills/go-unit-tests) | Overlay on `go-idioms`: 2024–2026 Go tests (tables, synctest, fuzz, what to skip) |
| [go-backend](skills/go-backend) | Overlay on `go-idioms`: inside a Go service (handlers, persistence, shutdown) |
| [go-ddd](skills/go-ddd) | Overlay on `go-backend`: DDD Lite when a domain earns an aggregate |
| [go-mono-repo](skills/go-mono-repo) | Overlay on `go-idioms`: one module by default, `go.work` only when modules version apart |
| [typescript-mono-repo](skills/typescript-mono-repo) | Overlay on `typescript-idioms`: one package.json by default, pnpm workspaces when two apps appear, Turborepo only when CI time hurts |
| [typescript-idioms](skills/typescript-idioms) | Idiomatic TypeScript 5–7 and 2024–2026 layout |
| [typescript-unit-tests](skills/typescript-unit-tests) | Overlay on `typescript-idioms`: 2024–2026 TS tests (Vitest / Jest / `node:test`, what to skip) |
| [e2e-tests](skills/e2e-tests) | When to add browser / device journeys (Playwright web; Expo Maestro). Install official Playwright skills first — [Start here](#start-here-cursor) |
| [css-idioms](skills/css-idioms) | Idiomatic CSS Baseline 2022–2026 (`@layer`, nesting, view transitions, anchors). Not Sass or Tailwind |
| [svelte](skills/svelte) | Overlay on the Svelte plugin + `typescript-idioms`: Svelte 5 / Kit 2 pin, experimental default-no |
| [sveltekit-app-structure](skills/sveltekit-app-structure) | SvelteKit `src/routes` / `$lib` layout (coding stays in `svelte` + the plugin) |
| [encore-go](skills/encore-go) | Encore.go backends (never F5 / Zed F4; attach config is `git-repo-setup-go`) |
| [encore-go-app-structure](skills/encore-go-app-structure) | Encore Go package layout |
| [temporal-go](skills/temporal-go) | Temporal Go SDK |
| [temporal-go-app-structure](skills/temporal-go-app-structure) | Temporal Go package layout |
| [encore-temporal-go-app-structure](skills/encore-temporal-go-app-structure) | Encore + Temporal Go layout |

## Install

Cursor plugins are the other half of setup — see [Start here](#start-here-cursor).

Cursor can import a GitHub repo whose skills live under `skills/`. Or install this repo's skills locally:

```bash
git clone git@github.com:shyyawn/lore.git
cd lore
make install
```

For lore + vendor skills on a new machine, use `make setup`. See [Start here](#start-here-cursor).

| Target | Does |
| --- | --- |
| `make setup` | Lore skills + vendor skills; prints Cursor plugin steps (plugins still manual) |
| `make install` | Copy every skill into `~/.cursor/skills` |
| `make install-vendor-skills` | Install official vendor skills (Conventional Commits, Expo, Vercel, Playwright) into `~/.cursor/skills` |
| `make print-cursor-plugins` | Show `/add-plugin` steps only (no install) |
| `make status` | Show which installed copies have drifted from the repo |
| `make uninstall` | Remove this repo's skills from `~/.cursor/skills` |
| `make list` | List the skills in this repo |

`~/.cursor/skills` is Cursor-only. `~/.agents/skills` is the portable location (Cursor, Claude Code, Codex). `install` writes `~/.cursor/skills` only. Re-enable `AGENTS_SKILLS` in the Makefile to write both. Leaves skills it does not own (symlinks to other repos) alone.

These are **copies, not symlinks** — a running agent keeps a stable snapshot while you edit. The trade-off is drift: re-run `make install` after every change, and `make status` reports what is stale. Symlink instead (`ln -sfn`) if you would rather edits go live immediately.

Project-local: copy a skill into that repo's `.cursor/skills/` (or `.agents/skills/`).
