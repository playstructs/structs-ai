# SUI components

**Purpose**: The required DOM shape for every SUI component, the traps in each, and an
honest list of what SUI does not give you.

Every component here has a **markup contract**. SUI styles descendants and siblings, so
wrapping an element in an extra `<div>`, or moving a control outside its label, can
silently unstyle it. There is no error — it just renders wrong.

---

## Panel — the outer chrome

```html
<div class="sui-panel sui-theme-player">
  <div class="sui-panel-top-fill-background"></div>
  <div class="sui-panel-bottom-fill-background"></div>
  <div class="sui-panel-edge-left"></div>
  <div class="sui-panel-chunk sui-mod-grow sui-mod-shrink">
    <!-- content -->
  </div>
  <div class="sui-panel-edge-right"></div>
</div>
```

The edges and fills are pixel-art borders. Omit them and you get a bare box.

## Screen and nav — the tab bar

```html
<div class="sui-screen sui-screen-full-width">
  <div class="sui-screen-nav">
    <div class="sui-screen-nav-items">
      <a class="sui-screen-nav-item sui-mod-active" href="#/a">Alpha</a>
      <a class="sui-screen-nav-item" href="#/b">Beta</a>
    </div>
  </div>
</div>
```

- `.sui-screen-nav` is `justify-content: space-between`, so a second child right-aligns
  — useful for a refresh button or a timestamp.
- It also has `overflow-x: scroll`. **Items scroll out of view rather than wrapping**,
  with no indicator that anything is hidden. Keep the item count low, or hide right-hand
  extras at narrow widths.
- Active state is `sui-mod-active`.

## Data card — the workhorse container

```html
<div class="sui-data-card sui-theme-player">
  <div class="sui-data-card-header sui-text-header">GUILD POWER</div>
  <div class="sui-data-card-body sui-mod-spacing-xl">
    <div class="sui-data-card-row"><span>Label</span><span>Value</span></div>
  </div>
</div>
```

- The header is a **teal fill with inverted text**, centre-justified.
- `sui-mod-spacing-xl` is the **only** spacing modifier that exists. It changes padding
  from `8px 16px` to `16px` and gap from `0` to `16px`. Without it, body children sit
  flush against each other.
- **The body centres its text.** `.sui-data-card-row` re-asserts `text-align: left`, so
  label/value pairs are fine — but a bare `<div>` you drop into the body is not. See
  [gotchas](gotchas.md#the-whole-document-is-centre-aligned).

## Result row — the list idiom

SUI has **no table component**. This is what lists look like.

```html
<div class="sui-result-rows sui-result-table">
  <div class="sui-result-row">
    <div class="sui-result-row-left-section">
      <div class="sui-result-row-portrait">
        <div class="sui-result-row-portrait-icon">
          <i class="sui-icon sui-icon-md icon-planet"></i>
        </div>
      </div>
      <div class="sui-result-row-player-info">
        <div class="sui-text-label-block">NAME<br><span class="sui-text-hint">subtitle</span></div>
      </div>
    </div>
    <div class="sui-result-row-right-section">
      <div class="sui-result-row-resources">
        <div class="sui-resource"><span>42</span><i class="sui-icon sui-icon-sm sui-icon-alpha-ore"></i></div>
      </div>
    </div>
  </div>
</div>
```

- `.sui-result-rows` gives an 8px gap. Adding `.sui-result-table` sets the gap to 0 and
  uses borders instead.
- Both sections are `flex: 1 0 0` with `min-width: 256px` (left) and `224px` (right).
  **Those minimums cause most narrow-window overflow** — see
  [gotchas](gotchas.md#result-row-minimums-force-wrapping).
- The row is header-less by design: each row self-describes.

## Form fields — `label.sui-input-text` wraps everything

This is the contract most people get wrong. `label.sui-input-text` is not just for text
inputs. Its `<span>` labels **any** control.

```html
<!-- text -->
<label class="sui-input-text"><span>Name</span><input type="text"></label>

<!-- select -->
<label class="sui-input-text"><span>Guild</span>
  <select><option>Any</option></select>
</label>

<!-- checkbox, nested inside the label -->
<label class="sui-input-text"><span>Fleet Status</span>
  <div class="sui-checkbox-container">
    <input type="checkbox" class="sui-checkbox" id="x">
    <span class="sui-checkbox-display"></span>
    <label for="x">Fleet Away</label>
  </div>
</label>

<!-- stepper -->
<label class="sui-input-text"><span>Min Ore</span>
  <div class="sui-input-stepper">
    <button class="sui-screen-btn sui-mod-secondary"><i class="sui-icon sui-icon-md icon-subtract"></i></button>
    <input type="number" step="1" min="0" max="99" value="0">
    <button class="sui-screen-btn sui-mod-secondary"><i class="sui-icon sui-icon-md icon-add"></i></button>
  </div>
</label>
```

Three things that will bite:

1. SUI styles inputs by **descendant selector** (`label.sui-input-text input[type=text]`),
   so the control must sit **inside** the label and carry **no class of its own**. A bare
   `<input class="sui-input-text">` gets none of the styling.
2. **The checkbox container must be a `<div>`.** Using a `<span>` makes
   `label.sui-input-text span` match it and style it as the field *label* — a 40px
   control balloons to roughly 106px.
3. The stepper's ± buttons must be the input's literal `previousElementSibling` and
   `nextElementSibling`. Any wrapper breaks the JS silently — see
   [runtime](runtime.md#suiinputstepper).

`label.sui-input-text` has `min-width: 256px` and `width: 100%`.

## Buttons

```html
<a class="sui-screen-btn sui-mod-secondary" href="javascript: void(0)">
  <i class="sui-icon sui-icon-sm icon-send-alpha"></i><span>Send</span>
</a>
```

| Class | What it is |
|---|---|
| `.sui-screen-btn` | The standard button. Fixed 36px height, ExtremeHazard 8px uppercase, `margin: 2px` |
| `.sui-nav-btn` | Nav and back links, no frame |
| `.sui-panel-btn` | 44×48 pixel-art HUD buttons |

`.sui-screen-btn` takes `sui-mod-primary`, `-secondary`, `-destructive`, `-disabled`,
and `-align-flex-end`, each with a hover state. `.sui-panel-btn` takes `sui-mod-default`,
`-pressed`, `-active-defense`, `-active-offense`, `-disabled`.

It works on `<button>` *and* `<a>` — `:link` and `:visited` are both covered, so anchors
don't turn purple.

> **Fixed height plus a wrapping label equals overflow.** A two-word label wraps to
> three lines inside an unyielding 36px box. Put `white-space: nowrap` on the button's
> `<span>` and let the button grow sideways.

## Badge — four variants, and only four

```html
<span class="sui-badge sui-mod-default">READY</span>
```

| Modifier | Look |
|---|---|
| `sui-mod-default` | Teal outline, teal text |
| `sui-mod-warning` | Amber outline, amber text |
| `sui-mod-destructive` | Red outline, red text |
| `sui-mod-solid` | **Filled teal, inverted text** |

There is **no** `sui-mod-secondary` badge. The modifier exists globally and will set the
text colour, but you get no border and no badge shape.

> **`sui-mod-solid` is the loudest thing on a page.** Do not use it for the common case.
> A list where every row says SUCCESS in filled teal draws the eye to the least
> informative thing on screen. Outline for routine, amber for "didn't happen", red for
> failed.

## Messages — three levels

```html
<!-- inline: within a card -->
<div class="sui-message-inline-alert sui-mod-warning">
  <i class="sui-icon sui-icon-md icon-alert"></i>
  <div class="sui-message-inline-alert-text">Charge is low.</div>
</div>

<!-- system alert: page-level banner -->
<div class="sui-message-system-alert">
  <div class="sui-message-system-alert-icon-container">…</div>
  <div class="sui-message-system-alert-text-container">…</div>
  <div class="sui-message-system-alert-close-container">…</div>
</div>

<!-- system modal: blocking confirmation -->
<div class="sui-message-system-modal">
  <div class="sui-message-system-modal-frame">
    <div class="sui-message-system-modal-frame-left">
      <div class="sui-message-system-modal-frame-left-top"></div>
      <div class="sui-message-system-modal-frame-left-middle">
        <i class="sui-icon sui-icon-md icon-attention"></i>
      </div>
      <div class="sui-message-system-modal-frame-left-bottom"></div>
    </div>
    <div class="sui-message-system-model-frame-center">…</div>   <!-- "model" [sic] -->
  </div>
  <div class="sui-message-system-modal-cta">
    <div class="sui-message-system-modal-cta-btn-wrapper">
      <a class="sui-screen-btn sui-mod-secondary">Cancel</a>
    </div>
    <div class="sui-message-system-modal-cta-btn-wrapper">
      <a class="sui-screen-btn sui-mod-destructive">Send</a>
    </div>
  </div>
</div>
```

> **Two typos to copy verbatim.** `sui-message-system-model-frame-center` and
> `sui-message-system-model-overlay` say **model**, not modal.
>
> **The modal has no backdrop of its own.** Wrap it in your own fixed overlay.

The inline alert has a severity trap that costs everyone an hour —
[gotchas](gotchas.md#severity-colours-the-icon-but-not-the-text).

## Pagination — a precise contract

```html
<div class="sui-pagination">
  <a><i class="sui-icon sui-icon-md icon-chevron-left"></i></a>
  <div class="sui-pagination-numbers">
    <a class="sui-pagination-number sui-mod-active">1</a>
    <a class="sui-pagination-number">2</a>
    <div class="sui-pagination-number">...</div>
    <a class="sui-pagination-number">16</a>
  </div>
  <a><i class="sui-icon sui-icon-md icon-chevron-right"></i></a>
</div>
```

From the shipping `src/js/view_models/templates/partials/Pagination.js`:

- **Exactly 5 number slots, always.** Never more.
- **Prev is omitted entirely on page 1; next is omitted on the last page** — not
  disabled, absent from the DOM.
- **Ellipsis is a `<div>`, not an `<a>`**, because it isn't clickable.
- Slot logic: 5 or fewer pages shows them all. Current page ≤ 3 gives `1 2 3 … last`.
  Deep in the middle gives `1 … current … last`. Near the end gives `1 … n-2 n-1 n`.

## Resource chip

```html
<div class="sui-resource"><span>1,204</span><i class="sui-icon sui-icon-sm sui-icon-alpha-matter"></i></div>
```

Value first, icon second. `min-height: 32px`. Works as an `<a>` too.

## Battery and progress

```html
<div class="sui-battery sui-theme-player">
  <span class="sui-battery-chunk sui-mod-filled"></span>
  <span class="sui-battery-chunk"></span>
</div>

<div class="sui-action-bar-progress-bar-wrapper">
  <div class="sui-action-bar-progress-bar">
    <div class="sui-action-bar-progress-bar-chunk sui-mod-filled"></div>
  </div>
</div>
```

Battery chunks are 4×16px PNGs, themed by the ancestor `sui-theme-*`. Add
`sui-mod-animated` to the progress bar for an indeterminate marquee. At small row
heights the PNG chunks are heavy; a CSS-only meter is a reasonable local substitute.

---

## Themes

`sui-theme-player` (teal), `sui-theme-enemy` (red/purple), `sui-theme-neutral` (gold).
Set one on an **ancestor**; components read it via descendant selectors:

```css
.sui-theme-player .sui-screen-nav { background: var(--surface-player-highlight); }
.sui-theme-enemy  .sui-battery-chunk.sui-mod-filled { background-image: url(".../battery-chunk-enemy.png"); }
```

Some components accept the theme on themselves *or* an ancestor
(`.sui-theme-player.sui-battery` and `.sui-theme-player .sui-battery` are both handled).
`sui-theme-player` is the default for operator-facing UI.

---

## What SUI does not give you

Budget for these. They are all yours to build:

- **No table, sort control, or column header**
- **No row hover or row-selected state**
- **No sticky headers, no virtualisation**
- **No empty state, skeleton, or spinner**
- **No toast or snackbar** — there is an alert, but no queue and no auto-dismiss
- **No date, time, or number formatting**
- **No `tabular-nums` anywhere**
- **No responsive utilities** — the one breakpoint family in `main.css` is tied to the
  game's scaling, not to component layout
- **No focus-visible ring.** `input:focus { outline: none }` with no replacement, so SUI
  actively *removes* the default focus indicator

**The sanctioned way to build a real table** is to keep `.sui-result-row`'s border and
padding and swap its two `flex: 1 0 0` sections for a CSS grid. You get true columns
without inventing a new visual language.

---

## Modifier reference

**Global colour utilities**, valid on any element: `sui-mod-primary`,
`sui-mod-secondary`, `sui-mod-destructive`, `sui-mod-disabled`, `sui-mod-warning`.

| Modifier | Applies to |
|---|---|
| `sui-mod-active` | Nav item, pagination number, panel button |
| `sui-mod-active-defense`, `-active-offense`, `-pressed` | Panel button |
| `sui-mod-align-flex-end` | Screen button |
| `sui-mod-animated` | Progress bar |
| `sui-mod-default` | Badge, panel button |
| `sui-mod-disabled-active` | Panel button, pressed while disabled |
| `sui-mod-filled` | Battery chunk, progress chunk |
| `sui-mod-grow`, `sui-mod-shrink` | Panel chunk |
| `sui-mod-header` | Offcanvas header nav item |
| `sui-mod-inverted` | Inverted-fill text |
| `sui-mod-left`, `-right`, `-top`, `-bottom` | Offcanvas placement, tooltip placement |
| `sui-mod-minimized` | Status bar |
| `sui-mod-narrow` | Offcanvas width |
| `sui-mod-show` | Tooltip visibility (set by JS) |
| `sui-mod-solid` | Badge only |
| `sui-mod-spacing-xl` | Data card body — the only spacing modifier |

---

*Verified against structs-webapp `6eec7f7` (2026-07-21), `src/public/css/sui/sui.css`
and `src/js/view_models/templates/partials/Pagination.js`.*
