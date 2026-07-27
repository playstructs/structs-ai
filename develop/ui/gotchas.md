# SUI gotchas

**Purpose**: The things that cost real debugging time, ordered by how likely you are to
hit them, plus the catalogue of known upstream defects.

Every item here was reproduced against source or measured in a browser. Several
contradict what the markup looks like it should do.

---

## Severity colours the icon but not the text

`.sui-message-inline-alert` has **no severity variants of its own**. The global
`sui-mod-*` utility does set `color:` on the container, so the **icon** — which inherits
`color` — changes. But `.sui-message-inline-alert-text` hard-sets
`color: var(--text-body)`, so **the text never changes**:

```css
.sui-message-inline-alert-text {
  color: var(--text-body);
  text-align: left;
}
```

| Markup | Container `color` | Text `color` |
|---|---|---|
| `.sui-message-inline-alert.sui-mod-warning` | `#F3C878` ✅ | `#C5D7D9` ❌ |
| `.sui-message-inline-alert.sui-mod-destructive` | `#EE7D69` ✅ | `#C5D7D9` ❌ |

Half-severity is worse than none: a red icon beside body-coloured text reads as
decoration, not as an error. Extend it explicitly:

```css
.sui-message-inline-alert.sui-mod-warning .sui-message-inline-alert-text { color: var(--text-warning); }
.sui-message-inline-alert.sui-mod-destructive .sui-message-inline-alert-text { color: var(--text-enemy-primary); }
.sui-message-inline-alert.sui-mod-secondary,
.sui-message-inline-alert.sui-mod-secondary .sui-message-inline-alert-text { color: var(--text-hint); }
```

These four rules are in [examples/sui-patch.css](examples/sui-patch.css).

---

## The whole document is centre-aligned

`sui.css` sets it on `body` itself:

```css
body {
  background: url("/img/sui/page/page-background.png") repeat var(--page-background);
  color: var(--text-body);

  text-align: center;        /* inherited by absolutely everything */
  font-family: 'DirectiveZero', sans-serif;
  font-size: 16px;
  font-weight: 500;
  line-height: 20px;
  image-rendering: pixelated;
}
```

A plain `<div>` inside a `.sui-data-card-body` computes to `text-align: center`. This is
a deliberate choice for the game's short, poster-like HUD strings, and it is wrong for
almost every data surface.

Exactly eleven rules re-assert `text-align: left`. Content inside these is fine:

```
.sui-data-card-row                       .sui-result-row-player-info
.sui-message-inline-alert-text           .sui-message-system-alert-text-container
.sui-message-system-model-frame-center   .sui-screen-dialogue
.sui-tooltip                             .sui-cheatsheet-title-text
.sui-cheatsheet-description              .sui-cheatsheet-contextual-message
.sui-cheatsheet-property-info div
```

Everything else inherits centre. The trap is that this only shows up on content long
enough to wrap, so it ships looking fine and then a three-line explanation renders like
poetry. Left-align prose, tables and log output explicitly, once, on your own classes:

```css
.my-app .sui-data-card-body .note { text-align: left; }
```

Beware `>` child selectors while doing it: a note nested one `<div>` deep won't match a
rule written as `.sui-data-card-body > .note`.

`body` also sets `image-rendering: pixelated` globally. Right for the pixel art, worth
knowing if you ever place a photographic or high-DPI image in a SUI page.

---

## Flex `min-width: auto` is the top cause of overflow

**A flex item will not shrink below its min-content width unless you set
`min-width: 0`.** `word-break` and `overflow-wrap` alone do nothing about it. This
appears in four disguises:

| Symptom | Cause | Fix |
|---|---|---|
| Card 1101px wide in a 441px window; a checkbox pushed off screen | A share URL — one unbreakable token — as a flex item | `min-width: 0` **and** `white-space: normal` |
| Row stretched past its card | A long identifier in `.sui-result-row-player-info` | `min-width: 0` on the section, `overflow-wrap: anywhere` on the text |
| Three-item metric group blowing out a row | `inline-flex` with `nowrap` children | `flex-wrap: wrap; max-width: 100%` |
| An `<input type=number>` clipped to 46px showing `2` instead of `21600` | Flex child, where `width` is only a *basis* | `flex: none` plus an explicit `width` |

Sanity check when something overflows and you can't see why:

```js
[...root.querySelectorAll('*')]
  .filter(e => e.scrollWidth > e.clientWidth + 2 && e.clientWidth > 0)
  .map(e => `${e.className} ${e.clientWidth}/${e.scrollWidth}`);
```

---

## Result-row minimums force wrapping

`.sui-result-row-left-section` has `min-width: 256px` and `.sui-result-row-right-section`
has `224px`. Below roughly 500px of row width they wrap — often mid-content, so stat
chips overlap identity text. Either accept the wrap and set a sensible `gap`, or
override the minimums for narrow layouts.

---

## Composed classes fight each other at equal specificity

If an element carries two of your classes and both set the same property, **the rule
declared later in the stylesheet wins** — not the one you meant. A link with
`class="icon-btn url-display"`, where `.icon-btn { white-space: nowrap }` is declared
after `.url-display { overflow-wrap: anywhere }`, will never wrap.

Set the property explicitly on the more specific class rather than assuming the other
won't apply.

---

## Number inputs default to 25px

`.sui-input-stepper input[type=number]` is `width: 25px` with 16px of horizontal
padding — sized for a one-or-two-digit quantity picker. Give it real width for anything
larger, and remember it is a flex child, so `width` alone is only a basis. Use
`flex: none`.

---

## Asset paths are root-absolute

`sui.css` references assets from the **web root**: `url("/img/sui/…")`,
`url('/fonts/Structicons.woff')`. If your app is served from a subpath or over `file://`,
**every icon and every piece of form art silently disappears** — checkboxes render as
blank space with no console error.

Two options: serve the assets at the root, or rewrite the URLs on the way out. Structs
Desktop does the latter when it serves the Team Ops board under `/board/`; the reference
implementation is `rebase_css_urls` in `src-tauri/src/mcp/web_board.rs`, which prefixes
root-absolute `url()` targets and leaves relative, `data:` and scheme URLs alone.

Verify with `document.fonts.check('16px Structicons')` and a network check on one
`/img/sui/form/*.png`.

---

## Focus outlines are removed globally

```css
input:focus { outline: none; }
```

No replacement is provided. If you care about keyboard accessibility — and an operations
console should — add one back. The `--border-focus-friendly-dark` and
`--border-focus-enemy-dark` tokens exist for exactly this and are otherwise unused.

---

## Smaller ones

- **`.sui-data-card` sets `gap: -1px`**, which is invalid and computes to `0`. Harmless,
  but don't copy it as a technique.
- **`.sui-screen-nav` scrolls rather than wraps.** Items pushed past the edge become
  invisible with no indicator.
- **The offcanvas is a singleton.** No stacked drawers, ever.
- **`sui-icon-value` is not an icon**, it is a `margin-left` utility for a `<span>`.

---

## Known upstream defects

| Where | Defect | Workaround |
|---|---|---|
| `SUIOffcanvas.setPlacement` | Assigns `this.placement` before removing the old class, so both placement classes accumulate | Clear both classes at the call site first |
| `SUIOffcanvas.setTheme` | Same shape, same bug | Same |
| `SUI.js` | `import {SUIOffcanvas} from "./SUIOffcanvas"` is extensionless and fails outside a bundler | Import each class directly with its `.js` extension |
| `sui.css` | `--from-input-height-content` is misspelled | Use the typo |
| `sui.css` | `sui-message-system-model-frame-center` and `-model-overlay` say *model* | Use the typo |
| `sui.css` | `.sui-data-card { gap: -1px }` is invalid | Ignore |
| `sui.css` | `.sui-message-inline-alert` has no severity variants and its text hard-sets `--text-body` | Add the four rules above |
| `sui.css` | `body { text-align: center }` is inherited by everything | Left-align data surfaces explicitly |
| `sui.css` | `input:focus { outline: none }` with no replacement | Add a focus style |
| `sui.css` | All asset URLs are root-absolute | Serve at root, or rewrite |
| `structicons.css` | `.icon-attention` is declared twice | Harmless |

Found something not on this list? [develop/maintenance.md](../maintenance.md) covers how
to get it verified, documented, and reported upstream rather than worked around in
silence.

---

*Verified against structs-webapp `6eec7f7` (2026-07-21), `src/public/css/sui/sui.css`
and `src/js/sui/`.*
