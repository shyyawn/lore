---
name: css-idioms
description: >-
  Writes, restyles, and reviews CSS using idioms from Baseline 2022 through
  2026 (@layer, :is, nesting, :has, container queries, @property, color-mix,
  light-dark, view transitions, @scope, shape, anchor positioning) and
  2024–2026 architecture practices (layers, typed tokens, platform-first).
  Use when generating, editing, reviewing, or modernizing CSS or style
  blocks; when the user mentions idiomatic CSS, 2026 CSS, if(), @function,
  view transitions, or matching browserslist.
---

# CSS 2026

Write CSS as if the project's Baseline / browserslist already allows it.
Do not emit pre-`@layer` tutorial CSS (`!important` wars, Sass-only
nesting, untyped `--color` that must interpolate, a JS tooltip).

Full catalogs: [versions.md](versions.md) (Baseline 2022→now),
[modernizers.md](modernizers.md) (rewrites), [architecture.md](architecture.md)
(2024–2026 structure). Svelte markup: `svelte`. Tailwind already in the
repo: honor it. Expo NativeWind setup: official `expo-tailwind-setup`.
Sources: web.dev Baseline, MDN CSS. Not a Sass 7-1 tree.

## First step

Read `package.json` `browserslist`, `.browserslistrc`, PostCSS /
Lightning CSS targets, and any Stylelint / `eslint-plugin-css` config.
Target that pin. Do not bump browserslist to unlock an idiom.

| Pin | Always use | Not yet |
| --- | --- | --- |
| No pin / `baseline newly available` | everything **Baseline 2022–2026** below | `if()`, `@function`, `@mixin`, `sibling-index()`, `corner-shape`, `interpolate-size`, masonry, CSS Paint |
| `baseline widely available` | `@layer`, `:is()`, `:where()`, nesting, `:has()`, size `@container`, `color-mix()`, `oklch` | Baseline 2024+ not yet widely (`@property`, `light-dark()`, 2025–2026) unless already in the file |
| Baseline 2022 in the pin | `@layer`, `:is()`, `:where()`, `accent-color` | 2023+ |
| Baseline 2023 in the pin | plus nesting, `:has()`, size `@container`, `color-mix()`, `oklch` | 2024+ |
| Baseline 2024 in the pin | plus `@property`, `light-dark()`, `@starting-style`, `text-wrap`, subgrid | 2025–2026; Chromium-only |
| Baseline 2025 in the pin | plus same-document view transitions, popover, `content-visibility`, `view-transition-class` | Baseline 2026-only; Chromium-only |
| Baseline 2026 in the pin | plus `@scope`, `shape()`, `field-sizing`, style `@container`, `contrast-color()`, anchor positioning level 1, `:open` | `if()`, `@function`, `@mixin` (no engine), Paint worklet |
| Chromium-only already in the file | honor `if()` / `@function` behind `@supports` | `@mixin` / `@apply` as CSS mixins |

Experimental flags and Chrome-only drafts are out of scope unless the
file already uses them. Default is **no**.

## After every CSS edit

```bash
npx biome check <files>   # or stylelint / the repo's css script
```

Honor the formatter already there. Do not add Biome or Stylelint to
unlock a gate. Write the modern form the first time.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| Property ignored, no `@supports` | Newer than the pin. Rewrite to the pin; do not bump browserslist |
| `if()` / `--fn()` does nothing in Firefox / Safari | Not Baseline. `@media` / `@supports` / a custom property. Do not ship it as the only path |
| View transition is a hard cut | Missing `view-transition-name` or `document.startViewTransition` / `@view-transition` |
| Tooltip clipped / in the wrong box | `overflow: hidden` ancestor or no `position-anchor`. Not a new wrapper div |
| Colors do not interpolate | Untyped custom property. `@property` with `syntax: "<color>"` |
| Sass file "needed" for nesting | Native nesting is Baseline. Do not add Sass for that |

## What this skill owns

| Own | Leave |
| --- | --- |
| CSS language, cascade, Baseline gate | Tailwind / NativeWind **setup** (`expo-tailwind-setup`) |
| Tokens, `@layer`, nesting in `.css` / `<style>` | Svelte runes (`svelte`); React / Next components |
| Motion that CSS now owns | Canvas 2D / WebGL pixel drawing; RN `StyleSheet` |

## Language (Baseline 2022 → 2026)

- `@layer` for cascade (`reset`, `tokens`, `components`). No `!important`
  to win a layer fight.
- `:is()` / `:where()` for selector lists. `:where()` when specificity
  must stay **zero**.
- Native nesting and `&`. No new Sass file for nesting.
- `:has()` for parent / sibling state. No JS class for "contains X".
- Size `@container` for component width. `@media` for the viewport and
  `prefers-*`.
- `@property` for tokens that interpolate or must stay a type.
- `oklch` / `color-mix()` / relative color (`oklch(from var(--c) l c h)`).
  No new hex-pair light/dark sheets when `light-dark()` is in the pin.
- `color-scheme: light dark` plus `light-dark()` for the two schemes.
- `text-wrap: pretty` on headings / short UI; `balance` when the pin
  has it and `pretty` is not.
- Subgrid when a child must share the parent's tracks.
- Same-document view transitions when the pin is 2025+. Name the
  shared element. Cross-document: `@view-transition { navigation: auto }`
  on the same origin only.
- Popover + CSS, not a new tooltip library, for a disclosure that is
  a popover. Anchor positioning (2026 pin) instead of JS flip.
- `@scope` (2026) to keep a component's selectors inside its root.
- `shape()` for `clip-path` / `offset-path`. Not a Canvas for a clip.
- `field-sizing: content` when a control should size to its value.

## Architecture (2024–2026)

Platform-first: do not add a preprocessor or motion library the cascade
now covers ([architecture.md](architecture.md)).

| Need | Use | Do not add |
| --- | --- | --- |
| Nesting / variables | native `&`, `--token`, `@property` | Sass for those jobs |
| Component breakpoints | `@container` | a `@media` copy per card |
| Light / dark colors | `light-dark()` + `color-scheme` | `.dark` token duplicates |
| Parent state | `:has()` | JS "has-child" classes |
| Overlay position | `popover` + `position-anchor` | Floating UI for new CSS-only UI |
| Page / state morph | view transitions | a FLIP library for the same job |
| Scroll-linked opacity / transform | `animation-timeline` when Baseline | `scroll` listeners for that |
| Inline condition | `@supports` / `@media` / style CQ | `if()` as the only path |
| Reusable value logic | custom property; `@function` only if already in the file | CSS `@mixin` (no engine) |
| Static shapes | `shape()`, `clip-path`, gradients | Canvas 2D |
| Pixel / shader drawing | Canvas 2D / WebGL / OffscreenCanvas | CSS Paint unless the repo has it |
| Utility classes | the repo's CSS | Tailwind as a drive-by |

Layout is earned: one entry sheet plus colocated CSS. No `abstracts/` /
`utilities/` / 7-1 Sass tree unless the repo is already that shape.

## LLM traps — never generate these

- Sass `@mixin` / `@extend` / `$var` in a new `.css` file
- CSS `@mixin` / `@apply` (mixins have **no** engine)
- `if()` or `@function` as the only path
- `float` layout; `!important` to beat `@layer`; long sibling lists instead of `:is()`
- `position: absolute` tooltips when the pin has anchors + popover
- `window.matchMedia` for colors `light-dark()` covers
- Canvas / a chart lib for a `clip-path`
- BEM on a greenfield; a new `styles/helpers.css`
- Tailwind `@apply` in a file that is not Tailwind
- Animating `width` / `height` when `transform` / `opacity` suffice
- Prefix dumps (`-webkit-`) the pin does not need

## Do not

- Restyle unrelated files, or rewrite a working Sass / Tailwind sheet
  as a drive-by.
- Bump browserslist or flip Stylelint off to make an edit parse.
- Add Sass, Less, Stylus, or Tailwind to unlock nesting or tokens.
- Replace NativeWind / Tailwind / StyleSheet as a drive-by restyle.
