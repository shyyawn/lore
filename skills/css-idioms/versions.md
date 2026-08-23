# Baseline 2022 → now — what to write

Gate every row on the project's browserslist / Baseline query. Do not
use a feature newer than that pin. Write the **After** form.
[modernizers.md](modernizers.md) is the rewrite catalog.

Dates are **Baseline Newly available** (all core engines), from web.dev
Baseline year pages and Interop wrap-ups. Widely available is Newly
plus 30 months. 2022 rows use interop dates (`@layer`, 2022-03).

## 2022 — `@layer`, `:is()`, `:where()`

| Before | After |
| --- | --- |
| `!important` and selector wars | `@layer` (`reset`, `tokens`, `components`) (interop 2022-03) |
| `h1 ~ h2, h1 ~ h3, h2 ~ h3, …` | `:is(h1, h2, h3) ~ :is(h1, h2, h3)` |
| a reset that must not bump specificity | `:where()` (specificity **zero**) |
| per-control `accent-color` hacks | `accent-color` on the form / `:root` |

## 2023 — nesting, `:has()`, size `@container`

| Before | After |
| --- | --- |
| Sass nesting / repeated parent selectors | native nesting + `&` (Newly 2023-08) |
| JS / extra class for "parent contains X" | `:has()` (Newly 2023-12) |
| viewport `@media` for a card's width | size `@container` (Newly 2023-02) |
| `grid-template` copied onto every child | `grid-template-columns: subgrid` (Newly 2023-12) |
| hex / `rgb` pairs, Sass `mix()` / `darken()` | `oklch()`, `color-mix()` |

Relative color (`oklch(from …)`) waits for the 2024 pin.

## 2024 — `@property`, color functions, entry motion

| Before | After |
| --- | --- |
| untyped `--color` that will not interpolate | `@property --color { syntax: "<color>"; inherits: true; initial-value: … }` (Newly 2024-07) |
| `.dark { --bg: … }` duplicate token sheet | `color-scheme: light dark` + `light-dark(white, black)` |
| `display: none` then pop-in with no first frame | `@starting-style` on the entering rule |
| `text-wrap: wrap` on a heading that orphans | `text-wrap: balance` |

`@property` and `light-dark()` are Baseline 2024. They are **not**
Widely available until 30 months later — skip them on a strict Widely
pin unless the file already has them.

## 2025 — popover, view transitions, content-visibility

| Before | After |
| --- | --- |
| custom tooltip / dropdown JS for a disclosure | `popover` + `:popover-open` (Newly 2025-01) |
| FLIP library / hard navigation cut (same document) | `view-transition-name` + `document.startViewTransition` |
| one name, many transition styles | `view-transition-class` |
| off-screen list still painting | `content-visibility: auto` |
| `invoker` click handlers for `commandfor` | invoker commands when the pin includes them |

Same-document view transitions are Baseline 2025 (Interop 2025).
Cross-document / `:active-view-transition` wait for the 2026 pin.

## 2026 — `@scope`, `shape()`, anchors, style queries

| Before | After |
| --- | --- |
| long prefixed selectors to stay inside a component | `@scope` |
| `path("M 0 0 …")` for a responsive clip | `shape()` on `clip-path` / `offset-path` |
| JS flip / `getBoundingClientRect` for a tether | `anchor-name` + `position-anchor` + `position-area` / `anchor()` |
| overflow clipped tooltip with no fallback | `position-try-fallbacks` (`flip-block`, `flip-inline`) |
| `@container` only for size | style `@container` when a token should restyle children |
| two hardcoded contrast colors | `contrast-color()` |
| `width` hacks on `textarea` / select | `field-sizing: content` |
| `:popover-open` only | also `:open` for the same open state where it applies |
| view-transition active styling in JS | `:active-view-transition` |

Anchor positioning **level 1** is Baseline 2026 (Firefox, 2026-01).
Level 2 (`container-type: anchored`) is **not** all engines — Not yet.

## Not Baseline (do not emit as the only path)

| Feature | Status (2026-08) | Write instead |
| --- | --- | --- |
| `if(style/media/supports)` | Chromium 137+ | `@media` / `@supports` / style CQ |
| `@function` | Chromium 139+ | custom property; honor if already in the file |
| `text-wrap: pretty` | Chromium + Safari; no Firefox | `text-wrap: balance` |
| `@mixin` / `@apply` (CSS mixins) | no engine | nest; do not add Sass for it |
| `sibling-index()` / `sibling-count()` | Chromium 138+, Safari 26.2+, Firefox 154 (2026-08) | `:nth-child` until the pin includes them |
| `corner-shape` / `superellipse()` | Chromium | `border-radius` |
| `interpolate-size: allow-keywords` | Chromium | `grid-template-rows: 0fr` / transform |
| `animation-timeline: scroll()` / `view()` | Interop 2026; not all engines as default | `@media (prefers-reduced-motion)` time animation; honor scroll-driven if already in the file |
| CSS Paint / `paint()` | limited | Canvas 2D or a static `shape()` |
| masonry `grid-template-rows` | not Baseline | JS masonry only if the repo already has it |
