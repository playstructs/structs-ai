---
description: The four optional behaviours SUI ships, how to load them without breaking, and the upstream bugs in each.
---

# The SUI JavaScript runtime

**Purpose**: The four optional behaviours SUI ships, how to load them without breaking,
and the upstream bugs in each.

SUI's CSS works with no JavaScript at all. Four behaviours are optional add-ons in
`src/js/sui/`: an input stepper, a tooltip, a cheatsheet overlay, and an offcanvas
drawer.

---

## Loading them

`SUI.js` bundles all four behind `new SUI().autoInitAll()`. **Do not use it outside a
bundler.**

```js
// src/js/sui/SUI.js
import {SUIInputStepper} from "./SUIInputStepper.js";
import {SUITooltip} from "./SUITooltip.js";
import {SUICheatsheet} from "./SUICheatsheet.js";
import {SUIOffcanvas} from "./SUIOffcanvas";   // ← extensionless
```

That fourth import has no `.js` extension. Webpack resolves it; a browser loading a
plain `<script type="module">` does not — it 404s and takes the whole module down with
it, including the three behaviours that would otherwise have worked.

Import the classes you actually need, directly:

```html
<script type="module">
  import { SUIInputStepper } from './sui/SUIInputStepper.js';
  import { SUIOffcanvas }    from './sui/SUIOffcanvas.js';

  const stepper = new SUIInputStepper();  stepper.autoInitAll();
  const oc      = new SUIOffcanvas();     oc.autoInitAll();
  window.SUIRuntime = { offcanvas: oc };
</script>
```

This is what the Structs Desktop Team Ops board does. The webapp, which runs through
Webpack, uses the bundled `SUI` facade and exposes it as `MenuPage.sui`.

---

## SUIInputStepper

Wires the ± buttons on a numeric input.

- **Selector:** `.sui-input-stepper input[type=number]`.
- **Contract:** takes `previousElementSibling` as decrement and `nextElementSibling` as
  increment. **Any wrapper element around a button breaks it silently** — no error, the
  buttons just do nothing.
- Clamps to `min`/`max` on input and disables the buttons at the bounds.
- **Binds once, at `autoInitAll()`.** It calls `querySelectorAll` a single time. Steppers
  you create later are not wired.

That last point matters more than it sounds. Any UI that renders steppers from data —
a settings page, a filter panel, anything paginated — creates them after page load. For
those, implement your own ± handlers against the same markup and skip this module. You
keep the visual contract and lose nothing.

---

## SUITooltip

- **Trigger:** `data-sui-tooltip="text"` on any element.
- **Press-and-hold, not hover.** The tooltip appears 100ms after `mousedown` or
  `touchstart`. Users who expect hover will conclude it is broken.
- Optional `data-sui-mod-placement="bottom"`; the default is above.
- Delegated on `document.body`, so dynamically added triggers work — the one behaviour
  here that does survive re-rendering.

Two things to watch:

**It sets `position: relative` on the trigger's *parent*** (if that parent computes to
`static`) and appends the tooltip there. Give each trigger its own wrapper, or tooltips
land in odd places relative to a shared ancestor.

**Content is injected with `innerHTML`.** Escape untrusted text before it reaches a
`data-sui-tooltip` attribute. Player names and guild names are user-controlled — see
[agent-security](../../awareness/agent-security.md) on adversarial UGC.

---

## SUICheatsheet

A long-press overlay showing contextual reference content, used in the game's deploy
picker to explain struct types. It has its own content builder and renderer
(`SUICheatsheetContentBuilder.js`, `SUICheatsheetRenderer.js`) and appends to
`<body>` as `#sui-cheatsheet-container`.

It is tightly coupled to game concepts. Most companion apps will not want it, but if you
have long-press interactions elsewhere, know that its open delay competes with yours.

---

## SUIOffcanvas — the singleton drawer

```js
oc.setHeader('Player 1-194');
const body = oc.offcanvasElm.querySelector('.sui-offcanvas-body');
body.innerHTML = '';
body.appendChild(node);
oc.setPlacement('right');
oc.open();          // oc.open('narrow') for the narrow variant
oc.close();
```

- **One instance per document**, `id="sui-offcanvas"`, appended to `<body>`. It builds
  its own panel, nav and body internally. There is no stacking two drawers.
- `setContent()` takes an HTML **string**. To append nodes, query `.sui-offcanvas-body`
  directly, as above.
- Closes on outside click. The listener is attached inside a `setTimeout(0)` so the click
  that opened it doesn't immediately close it — a nice detail worth copying.

### Upstream bug in `setPlacement`

```js
setPlacement(placement) {
  this.placement = placement;                                     // assigned first
  this.offcanvasElm.classList.remove(`sui-mod-${this.placement}`); // removes the NEW class
  this.offcanvasElm.classList.add(`sui-mod-${this.placement}`);
}
```

It removes the class it is about to add, so the *previous* placement is never dropped
and the element accumulates both `sui-mod-left` and `sui-mod-right`. Work around it at
the call site:

```js
oc.offcanvasElm.classList.remove('sui-mod-left', 'sui-mod-right');
oc.setPlacement('right');
```

`setTheme` has the identical shape and the identical bug.

### It lives on `<body>`

Any CSS you scoped to your app root (`#my-app .foo`) does not reach the drawer.
Duplicate those selectors for `#sui-offcanvas`. The same applies to whatever scaling you
chose — `#sui-offcanvas` needs it too, and the stylesheet already targets it by ID
(`#sui-offcanvas.sui-mod-narrow`).

---

*Verified against structs-webapp `6eec7f7` (2026-07-21), `src/js/sui/`.*
