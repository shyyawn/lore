# Architecture and practices (2024–2026)

Trends that settled once Baseline closed the preprocessor gaps —
layers, typed tokens, container-first components. Not a Sass 7-1
fashion tree and not a Tailwind encyclopedia.

TypeScript 2024–2026 has the same instinct: platform-first
(`typescript-idioms`). Apply that here. Do not copy `src/<noun>/`.

## Platform-first

The cascade closed the jobs that used to justify Sass and a motion kit:

- native nesting → Sass nesting
- `--token` + `@property` → Sass `$var`
- `color-mix()` / relative color / `light-dark()` → Sass color APIs
- `:has()` → JS parent-state classes
- size `@container` → viewport media copies on every card
- `popover` + anchors → tooltip / flip libraries for CSS-only UI
- view transitions → FLIP kits for the same morph
- `shape()` → SVG `path()` strings for a clip

Add a library when CSS will not do the job (a design-token build the
repo already has, Canvas 2D, WebGL). Do not add Sass or Tailwind to
unlock nesting.

Tailwind / NativeWind / Sass stay if the project already has them.
Do not replace them as a drive-by. Expo setup: `expo-tailwind-setup`.

## Layers and files

One entry sheet. Colocate the rest. Grow a tokens file when a second
surface shares color / type / space.

```
src/
  app.css                 # @layer + @property tokens + reset
  routes/foo/+page.svelte # Svelte: styles stay in the component
  ui/button.css           # only if more than one consumer
```

| Need | Put it |
| --- | --- |
| Reset, fonts, `color-scheme` | entry `@layer reset` |
| Typed tokens | entry `@layer tokens` + `@property` |
| One component's rules | nest next to that component |
| Shared by two+ routes | a named sheet, not `helpers.css` |

No `abstracts/`, `utilities/`, `base/`, `vendors/` 7-1 tree unless the
repo is already that shape. No `!important` to skip a layer.

`@layer reset, tokens, components;` once at the top of the entry file.
Later files add to those names. Do not invent a fourth layer for one
override.

## Tokens

Register what must interpolate or stay a type:

```css
@property --color-bg {
  syntax: "<color>";
  inherits: true;
  initial-value: oklch(99% 0 0);
}

html {
  color-scheme: light dark;
  --color-bg: light-dark(oklch(99% 0 0), oklch(20% 0.02 280));
}
```

Untyped `--gap: 1rem` is fine when it will not animate. Do not
`@property` every token.

## Motion

Prefer compositor properties (`transform`, `opacity`, `filter`).
Honor `prefers-reduced-motion: reduce` — cut or shorten, do not ignore.

View transitions: name the shared element, start the transition, style
`::view-transition-old(*)` / `::view-transition-new(*)` only when the
default crossfade is wrong.

Scroll-driven timelines: only when the pin has them or the file
already uses them. They are not a replacement for a short enter
animation on a Widely-available pin.

## Canvas and drawing

| Need | Use |
| --- | --- |
| Clip, blob, responsive path | `shape()`, `clip-path`, `offset-path` |
| Gradient / grain / simple ornament | CSS gradients, `border-image` |
| Pixels, charts, shaders, video frames | Canvas 2D, OffscreenCanvas, WebGL |

CSS Paint (`paint()`) is **not** the default. Honor it if the repo
already registers a worklet.

## Conditionals

Order: `@supports` / `@media` / size or style `@container`, then a
custom property toggle. `if()` is Chromium — enhancement inside
`@supports (if(1: 1))` only when the file already uses it.

`@function` is the same gate. CSS `@mixin` does not exist in any
engine. Do not emit it.
