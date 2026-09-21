# Lore skills vs Pi extensions

`make install` copies `skills/` to `~/.agents/skills`. Pi already
loads that directory. The catalog is **available**. Do not recopy it
into TypeScript so it "runs first".

Judgment stays in the skill. An extension, if earned, runs the
**mechanical** bit (gate, HTTP, file body, TUI).

## Stay a skill

| Family | Why an extension is the wrong artifact |
| --- | --- |
| Language (`go-idioms`, `typescript-idioms`, `python-idioms`, `css-idioms`) | Pin-gated catalog. The model must read it. |
| Platform + app-structure (Encore, Temporal, Svelte, Django, FastAPI, Nest) | Layout and overrides. Not a lifecycle hook. |
| Domain overlays (`go-backend`, `go-ddd`, unit tests, mono-repo, 100-mistakes) | Earn checklists and review ticks. |
| Staff 1–7 (`source-of-truth` … `choose-collections`) | Design rules. Grepping `WHERE id=` is a fake gate. |
| `requirement-to-architecture-to-design` | Stage order. |
| `customize-cv` + freelance / LinkedIn | Writing. SOURCE is the writer. |
| `create-readme-and-other-markdown-documentation` | Prose. |
| `e2e-tests` | When to add journeys. Official Playwright owns CLI. |
| `new-change-lore-skills` | House voice for Markdown skills. |
| This skill | Chooser + factory. |

## Prompt template (not an extension)

| Skill | If you want a slash | Shape |
| --- | --- | --- |
| `review-change` | `/review` | Expand the tick list. Still load the skill for catalogs. |
| `requirement-to-architecture-to-design` | `/design` | Expand the stage stub. |

A prompt template is `prompts/<name>.md`. Do not write TypeScript
that only `sendUserMessage`s that Markdown.

## Maybe later — mechanical gap only

Tick Earn on [SKILL.md](SKILL.md). Keep the skill. Extension fills
**one** gap.

| Skill | Mechanical gap | Not |
| --- | --- | --- |
| `git-repo-setup` + overlays | Tool that writes `files.md` bodies the user already chose | Restyling a working kit; a second Lefthook |
| `conventional-commits` | `/commit` that runs quoted HEREDOC `git commit` | Fork of the official type table |
| Language "After every edit" | `tool_result` on `write`/`edit` of `*.go` / `*.py` / `*.ts` that runs the pin formatter | Injecting the idiom catalog every turn |
| `review-change` | Prompt template `/review` | An orchestrator tool that pastes catalogs 1–7 |

Do not start these as a drive-by from this mapping. Earn, then one
file, one job.

## Do not convert

- Recopy `SKILL.md` into `before_agent_start` so it "runs first"
- `/go-idioms` as a wrapper around `/skill:go-idioms`
- One mega-extension that loads every lore skill
- A second install into `~/.pi/agent/skills` beside `~/.agents/skills`
