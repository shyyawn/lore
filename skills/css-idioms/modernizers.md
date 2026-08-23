# Rewrites (Baseline 2022 → 2026)

CSS has no `go fix`. Write these forms directly. Stylelint / Biome /
the repo CSS lint is the backstop. Version meaning of each rewrite:
[versions.md](versions.md).

Do not "modernize" by bumping browserslist or adding Sass.

## Preprocessor jobs the language now owns

| Before | After |
| --- | --- |
| Sass / Less nesting | native nesting + `&` |
| `$brand: #06f` | `--brand` + `var(--brand)`; `@property` on a 2024+ pin when it must interpolate |
| Sass `@mixin` for a token block | nest, or a shared `@layer tokens` file |
| Sass `darken()` / `mix()` | `oklch(from var(--c) calc(l - 0.1) c h)`, `color-mix(in oklch, var(--c) 80%, black)` |
| `@extend` | nest or a shared class. Do not `@extend` |

## Selectors and cascade

| Before | After |
| --- | --- |
| `.card--has-image` set from JS | `.card:has(img)` |
| `.parent .child` repeated | nest `.child` under `.parent` |
| `h1 ~ h2, h1 ~ h3, h2 ~ h3, …` | `:is(h1, h2, h3) ~ :is(h1, h2, h3)` |
| a reset selector that wins too often | `:where(h1, h2, h3)` |
| `#id` / `!important` to win | `@layer` order; one layer bump |
| unscoped `.title` leaking | `@scope (.card) { .title { } }` on a 2026 pin |

## Color and theme

| Before | After |
| --- | --- |
| `:root { --bg: #fff } .dark { --bg: #111 }` | `html { color-scheme: light dark; --bg: light-dark(white, black); }` |
| two contrast hexes | `color: contrast-color(var(--bg))` on a 2026 pin |
| `currentColor` hacks for a derived hue | `oklch(from var(--accent) l c calc(h + 120))` |

## Layout and UI chrome

| Before | After |
| --- | --- |
| `@media (min-width: 400px)` on a card | `@container (min-width: 24rem)` |
| `position: absolute` + JS flip | `position-anchor` + `position-area` + `position-try-fallbacks` (2026) |
| `title` / a tooltip library | `popover` + invoker / `:popover-open` (2025) |
| `height: auto` animation that jumps | transform / opacity; `interpolate-size` only if already in the file |
| `textarea` JS autosize | `field-sizing: content` (2026) |
| `clip-path: path("M…")` | `clip-path: shape(…)` (2026) |

## Motion

| Before | After |
| --- | --- |
| `scroll` listener setting `opacity` / `transform` | `animation-timeline: view()` when the pin has it; else a short time animation |
| FLIP / `getBoundingClientRect` morph | `view-transition-name` + `startViewTransition` (2025) |
| full-page cut on same-origin MPA | `@view-transition { navigation: auto }` (2026 pin) |
| `:nth-child(1) { animation-delay: 0.1s }` … | `animation-delay: calc(sibling-index() * 80ms)` only when the pin has tree counting |
| no first frame on `display` / popover | `@starting-style` |

## Do not rewrite these as a drive-by

- A working Sass module the build already compiles
- Tailwind / NativeWind utility sheets
- RN `StyleSheet` objects
- Canvas / WebGL scenes (not CSS)
