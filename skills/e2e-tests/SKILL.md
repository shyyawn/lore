---
name: e2e-tests
description: >-
  Decides when to add browser or device end-to-end tests and writes
  Playwright journeys (web) or stop-and-follows Expo Maestro. Use when
  adding, editing, reviewing, or generating e2e, Playwright, or Cypress
  tests; when the user mentions user flows, getByRole, waitForTimeout,
  or flaky browser tests. Overlay on official Playwright skills (install
  — lore README). Unit tests stay typescript-unit-tests / go-unit-tests.
---

# E2E tests 2026

User-visible journeys in a real browser or device. Default is **no**.
Do not add Playwright to a library with no UI.

Sources: Playwright best-practices, Svelte `svelte/testing` +
`sv add playwright`, Next Testing / Playwright guide (pin), Expo EAS
Maestro. Not a Playwright API dump. Not Cypress / Nightwatch /
Selenium as a new default.

Unit / component: `typescript-unit-tests` or `go-unit-tests`. Official
Playwright skills: install (`playwright-cli install --skills -g`).
Do not copy them into `skills/`.

## First step

1. Inventory what is already there. Honor it.

   `playwright.config.*`, `tests/` / `e2e/`, Cypress, Nightwatch,
   Detox, Maestro (`.maestro/`, `.eas/workflows`), `package.json`
   scripts (`e2e`, `test:e2e`).
2. If a more specific owner already has this, **stop**.

   | Detect | Follow |
   | --- | --- |
   | `*.test.ts` next to source / Vitest / Jest | `typescript-unit-tests` |
   | `*_test.go` / `encore test` | `go-unit-tests` / `encore-go` |
   | `expo` + iOS / Android | This skill (Maestro). Setup: Expo EAS Maestro docs |
   | `next` in `package.json` | This skill + pin Playwright guide. `async` RSC here |
   | Bare React Native, no Expo | **Ignore.** |
   | No UI (library, CLI, CSS, API-only) | **Stop.** Unit / integration only |
3. Earn the suite (below). Tick yes on at least two, or stay on unit
   tests.
4. Web (Svelte, Vite, Next, Expo Web): Playwright. Setup on Svelte:
   `npx sv add playwright`. Next: pin Playwright guide. Else honor
   `npm init playwright`. Expo iOS / Android: Maestro — do not add
   Playwright on the simulator.

## Defaults

| Job | Default | Honor instead when |
| --- | --- | --- |
| Web runner | Playwright | Cypress / Nightwatch already the suite |
| Next (incl. `async` RSC) | Playwright | Cypress already the suite |
| Expo Web | Playwright | — |
| Expo iOS / Android | Maestro on EAS | Detox already the suite |
| Specs | `tests/` (Svelte `sv add`) | `e2e/` already there |
| Locators | `getByRole` / `getByLabel` / `getByText` | `getByTestId` as an explicit contract |
| Browsers (CI) | Chromium | Product requires Safari / Firefox — add that project |
| Auth | Setup project + storage state | Repo already logs in per test |
| Kit recipe | `just e2e` → existing script / `npx playwright test` | — |

Do not add Playwright next to a working Cypress suite. Do not add
Cypress next to a working Playwright suite.

## Division of labor

| Artifact | Owner |
| --- | --- |
| What to unit-test | `typescript-unit-tests` / `go-unit-tests` |
| Playwright CLI, codegen, traces | Official Playwright skills |
| Svelte / Kit pin and `sv add` | `svelte` / `sveltekit-app-structure` |
| Next journeys | This skill (earn, locators). Setup: pin Playwright guide |
| Expo Web journeys | Playwright (this skill) |
| Expo iOS / Android flows | This skill (earn). Setup: Expo EAS Maestro docs; job YAML: `eas-workflows` |
| Encore / Go API, no UI | `encore test` / integration tag. Not this skill |
| Encore + Kit in one workspace | Playwright hits the **UI**. APIs stay `encore test` |
| `just e2e` / gitignore extras | `git-repo-setup-typescript` when `playwright.config.*` exists |
| When to add a journey; house locators | this skill |

## Earn a journey suite

Copy this checklist. Tick **yes** on at least two, or stay on unit /
component tests.

```
Earn e2e:
- [ ] Auth or role-gated UI the user can see
- [ ] Paid or irreversible action (checkout, delete, grant)
- [ ] Multi-step form / wizard the unit table cannot see
- [ ] Two surfaces must agree (browser + real server render)
- [ ] `async` Server Component jsdom cannot render (Next)
```

If every line is **no**, do not add Playwright. A marketing page with
one CTA does not earn a suite. One smoke `goto('/')` is not a suite —
it is optional scaffolding `sv add` already wrote.

## What this skill owns

| Own | Leave |
| --- | --- |
| Earn; locator / wait house rules; which runner per surface | Playwright API encyclopedia (official skills) |
| Web default = Playwright | Vitest browser mode (component — `typescript-unit-tests`) |
| | Next Playwright setup body (pin Testing guide) |
| | Maestro YAML encyclopedia (Expo EAS docs) |
| | Encore / Go integration (`encore-go`, `go-unit-tests`) |

## Hard rules

- Test what the user sees. Not function names, CSS classes, or
  whether a value is an array.
- Isolated context per test. Own cookies, storage, data. Do not
  share a logged-in `page` across files.
- User-facing locators first: `getByRole`, `getByLabel`,
  `getByText`. `getByTestId` is a contract. Not CSS / XPath.
- Web-first assertions: `await expect(locator).toBeVisible()`.
  Not `expect(await locator.isVisible()).toBe(true)`.
- No `waitForTimeout` / `sleep`. Wait on the condition.
- Do not e2e a third-party host. Route-fulfill or hit **your**
  staging.
- Chromium on CI unless another engine is a product requirement.
  Install only the browsers you run.
- Traces on first retry. Not `trace: 'on'` for every test.
- Next `async` Server Components live here, not in jsdom.

## Do not add

| Need | Use | Do not add |
| --- | --- | --- |
| Unit / component | `typescript-unit-tests` | Playwright for a parser |
| Svelte setup | `npx sv add playwright` | Hand-rolled `tests/` + a second config |
| Next setup | Pin Playwright / Testing guide | A lore Next e2e skill |
| Expo native | Maestro (Expo EAS docs) | Playwright on a simulator |
| Expo Web | Playwright | Maestro on the web surface |
| Bare React Native | **Ignore** | Detox / Appium unasked |
| API-only Encore / Go | `encore test` / integration tag | Browser suite |
| Second web runner | The one already there | Cypress + Playwright stacked |

## After every edit

```bash
npx playwright test <files>   # honor the e2e / test:e2e script
# Expo iOS / Android: maestro test <flow>  (or the EAS workflow already there)
```

A test that only passes headed, or only on your machine, is not done.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| Flaky around a spinner / navigation | `waitForTimeout` or a manual `isVisible`. Web-first `expect`. |
| Passes headed, fails on CI | Race, missing `webServer` ready, or Chromium-only assumption. |
| Strict-mode locator error | CSS/XPath or a role that matches twice. Chain / filter. |
| Hits a third-party cookie banner | You e2e'd a host you do not own. |
| Encore API + blank UI assertions | Playwright pointed at the API port. Hit the Kit app. |
| Expo / simulator asked for Playwright | Native flow. Maestro. |
| jsdom / Vitest of an `async` Server Component | Official Next: this skill. |
| Suite is 40 files of CRUD | Did not earn. Delete; keep the journeys that tick the list. |

## LLM traps — never generate these

- `page.waitForTimeout(…)`, `sleep`, `delay` to "let it load"
- `expect(await locator.isVisible()).toBe(true)`
- `page.locator('.btn.btn-primary')` / XPath as the default
- Cypress / Nightwatch / Selenium added next to Playwright
- Playwright added to a Go / Encore API with no UI
- Playwright added to Expo native (Maestro owns that)
- Maestro added to Expo Web (Playwright owns that)
- jsdom tests of `async` Server Components
- Bare React Native / Detox unasked
- Vitest browser mode as the e2e suite
- Logging in at the top of every spec when a setup project exists
- `trace: 'on'` for every test
- `@latest` in a Playwright install the agent will run
- A Page Object tree on the first two specs
- LambdaTest / QASkills Playwright skill packs copied into `skills/`

## Do not

- Restyle a working Cypress suite into Playwright as a drive-by.
- Skip Earn because the user said "add e2e".
- Recite the official Playwright locator catalog or Expo Maestro
  command list in this file.
- Duplicate `typescript-unit-tests` tables here.
- Bump `@playwright/test` to unlock a locator.
