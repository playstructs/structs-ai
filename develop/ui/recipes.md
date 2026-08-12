---
description: "The four surfaces you'll actually be asked to build, assembled end to end: dashboard, form, menu, and HUD."
---

# SUI recipes

**Purpose**: The four surfaces agents are actually asked to build — dashboard, form,
menu, HUD — assembled end to end, with the decisions behind each.

Each recipe assumes you have settled the
[scaling model](index.md#decide-the-scaling-model-first) and are loading SUI's CSS in
the right order:

```html
<link rel="stylesheet" href="/css/normalize.css">
<link rel="stylesheet" href="/css/structicons.css">
<link rel="stylesheet" href="/css/sui/sui.css">
<link rel="stylesheet" href="/css/sui-patch.css">   <!-- your local additions, last -->
```

A runnable version of all four is in [examples/starter.html](examples/starter.html).

---

## Dashboard

The most common request. A grid of data cards, each holding a few statistics.

```html
<div class="sui-theme-player dash-grid">

  <div class="sui-data-card">
    <div class="sui-data-card-header sui-text-header">POWER</div>
    <div class="sui-data-card-body sui-mod-spacing-xl">
      <div class="sui-data-card-row">
        <span class="sui-text-label">CAPACITY</span>
        <span class="num sui-text-primary">18,400</span>
      </div>
      <div class="sui-data-card-row">
        <span class="sui-text-label">LOAD</span>
        <span class="num sui-text-warning">17,950</span>
      </div>
    </div>
  </div>

  <div class="sui-data-card">
    <div class="sui-data-card-header sui-text-header">STORES</div>
    <div class="sui-data-card-body sui-mod-spacing-xl">
      <div class="sui-resource"><span class="num">1,204</span><i class="sui-icon sui-icon-sm sui-icon-alpha-matter"></i></div>
      <div class="sui-resource"><span class="num">86</span><i class="sui-icon sui-icon-sm sui-icon-alpha-ore"></i></div>
    </div>
  </div>

</div>
```

```css
.dash-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: var(--spacing-xl); }
.num       { font-variant-numeric: tabular-nums; }
```

Decisions worth copying:

**Colour carries the meaning, not weight.** Capacity is `sui-text-primary` (teal, ours),
load is `sui-text-warning` (amber, watch this). If load exceeded capacity it would be
`sui-text-destructive`. A reader scanning ten cards sees the amber before they read a
number. Never bold a figure to emphasise it.

**`tabular-nums` on every figure.** SUI sets `font-variant-numeric` nowhere, so a
refreshing dashboard jitters column-by-column as digit widths change.

**`minmax(260px, 1fr)`** rather than a fixed column count. Cards below about 260px start
breaking their label/value rows onto two lines.

**Do not wrap statistics in badges.** A grid where every value is a `sui-mod-solid`
badge is unreadable; see [the note on solid](components.md#badge--four-variants-and-only-four).

---

## Form / settings page

```html
<div class="sui-data-card sui-theme-player">
  <div class="sui-data-card-header sui-text-header">SCAN FILTERS</div>
  <div class="sui-data-card-body sui-mod-spacing-xl">

    <label class="sui-input-text"><span>Guild</span>
      <select id="f-guild"><option value="">Any</option></select>
    </label>

    <label class="sui-input-text"><span>Fleet Status</span>
      <div class="sui-checkbox-container">
        <input type="checkbox" class="sui-checkbox" id="f-away">
        <span class="sui-checkbox-display"></span>
        <label for="f-away">Fleet away only</label>
      </div>
    </label>

    <label class="sui-input-text"><span>Minimum Ore</span>
      <div class="sui-input-stepper">
        <button class="sui-screen-btn sui-mod-secondary" data-step="-1">
          <i class="sui-icon sui-icon-md icon-subtract"></i>
        </button>
        <input type="number" id="f-ore" step="1" min="0" max="99" value="0">
        <button class="sui-screen-btn sui-mod-secondary" data-step="1">
          <i class="sui-icon sui-icon-md icon-add"></i>
        </button>
      </div>
    </label>

    <div class="sui-message-inline-alert sui-mod-warning" hidden id="f-error">
      <i class="sui-icon sui-icon-md icon-alert"></i>
      <div class="sui-message-inline-alert-text"></div>
    </div>

    <a class="sui-screen-btn sui-mod-primary" id="f-submit"><span>Scan</span></a>
  </div>
</div>
```

The three contract violations that break this silently, in order of how often they
happen:

1. Putting a class on the `<input>`. SUI styles it as a descendant of
   `label.sui-input-text`; the input itself must be unclassed.
2. Making the checkbox container a `<span>`. Then `label.sui-input-text span` matches it
   and styles it as the field label — the 40px control balloons to about 106px.
3. Wrapping a stepper button in a `<div>` for layout. The
   [stepper JS](runtime.md#suiinputstepper) walks `previousElementSibling`, so the
   buttons stop working with no error.

On the stepper: `SUIInputStepper` binds once at init, so a form built from data after
page load will not be wired. Handle `data-step` yourself:

```js
form.addEventListener('click', (e) => {
  const btn = e.target.closest('[data-step]');
  if (!btn) return;
  const input = btn.parentElement.querySelector('input[type=number]');
  const next = Number(input.value) + Number(btn.dataset.step);
  input.value = Math.min(Number(input.max), Math.max(Number(input.min), next));
});
```

Give the number input real width — it defaults to 25px, which fits two digits.

---

## Menu and navigation

```html
<div class="sui-screen sui-screen-full-width sui-theme-player">
  <div class="sui-screen-nav">
    <div class="sui-screen-nav-items">
      <a class="sui-screen-nav-item sui-mod-active" href="#/overview">Overview</a>
      <a class="sui-screen-nav-item" href="#/roster">Roster</a>
      <a class="sui-screen-nav-item" href="#/energy">Energy</a>
    </div>
    <div class="sui-screen-nav-items">
      <a class="sui-nav-btn" id="refresh"><i class="sui-icon sui-icon-sm icon-refresh-8"></i></a>
    </div>
  </div>
  <div class="sui-screen-body" id="page"></div>
</div>
```

`.sui-screen-nav` is `justify-content: space-between`, so that second `nav-items` block
right-aligns without any work — the idiomatic home for a refresh control or a
last-updated timestamp.

**Watch the item count.** The nav is `overflow-x: scroll`, not wrapping. A seventh tab
does not move to a second line; it becomes invisible, with no scrollbar hint at these
sizes. If you need more destinations than fit, group them into areas with a second level
of sub-navigation rather than letting the bar overflow.

For paginated content below, follow the
[pagination contract](components.md#pagination--a-precise-contract) exactly: five slots
maximum, prev absent on page 1, next absent on the last page, ellipsis as a `<div>`.
Deviating is immediately visible to anyone who also uses the game client.

---

## HUD and overlay

A HUD sits above content, so the [z-index scale](tokens.md#z-index--a-defined-stack-use-it)
matters. Use the tokens rather than inventing values, or your overlay will end up under
the game's own dialogue layer.

```html
<div class="sui-panel sui-theme-player hud">
  <div class="sui-panel-top-fill-background"></div>
  <div class="sui-panel-bottom-fill-background"></div>
  <div class="sui-panel-edge-left"></div>
  <div class="sui-panel-chunk sui-mod-grow sui-mod-shrink">
    <div class="sui-battery sui-theme-player">
      <span class="sui-battery-chunk sui-mod-filled"></span>
      <span class="sui-battery-chunk sui-mod-filled"></span>
      <span class="sui-battery-chunk"></span>
    </div>
    <span class="sui-badge sui-mod-default">READY</span>
  </div>
  <div class="sui-panel-edge-right"></div>
</div>
```

```css
.hud { position: fixed; bottom: 0; left: 0; right: 0; z-index: var(--hud-z-index); }
```

Do not omit the edge and fill divs. They are the pixel-art frame; without them a panel
is a plain rectangle and the HUD stops reading as part of the game.

For a detail drawer, use the [offcanvas](runtime.md#suioffcanvas--the-singleton-drawer)
rather than building a second panel. It is a singleton on `<body>`, which means two
things: you cannot stack drawers, and your app-scoped CSS will not reach it.

**Badge discipline matters most here.** A HUD is glanceable, so `sui-mod-solid` should
mark the one state you want someone to notice from across a room. If every indicator is
solid teal, none of them are.

---

*Verified against structs-webapp `6eec7f7` (2026-07-21). Runnable versions:
[examples/](examples/README.md).*
