---
title: Building with SUI
description: Build an interface that looks and behaves like Structs, using SUI, the design system the game itself is built with. Start here.
permalink: /develop/ui/
---

# Building with SUI

**Purpose**: Build an interface that looks and behaves like Structs, using the same
design system the game itself is built with.

SUI is the Structs UI design system: one stylesheet, two icon systems, three display
fonts, and four optional JavaScript behaviours. No build step, no preprocessor, no
framework.

> **The single most useful sentence:** SUI is a component sheet, not a framework. It
> gives you painted parts. Layout, state, data flow, tables, sorting and virtualisation
> are yours.

For how a Structs client actually *works* — signing transactions, proof-of-work,
real-time events — see [develop/client/](../client/index.md).

---

## Orientation

| | |
|---|---|
| Stylesheet | `src/public/css/sui/sui.css` — one file, 2,701 lines |
| Icon fonts | `src/public/css/structicons.css` (67 glyphs) + 29 sprite icons in `sui.css` |
| Display fonts | `ExtremeHazard` (chrome/labels), `DirectiveZero` (content/numbers), `Inter` (tickers) |
| JS runtime | `src/js/sui/` — four optional behaviours, ES modules |
| Naming | `.sui-<component>[-<part>]` + `.sui-mod-<variant>` + `.sui-theme-<faction>` |
| Mental model | Sci-fi terminal HUD. Hard edges, no radii, uppercase chrome, pixel-art assets |

Paths are relative to a [structs-webapp](../repos.md) checkout, the canonical source.
The extracted inventory of every token, icon, class and modifier lives in
[generated/sui-inventory.md](../../generated/sui-inventory.md).

---

## Decide the scaling model first

The game renders its entire UI at `transform: scale(2)` above 1152px and `scale(4)`
above 2304px, with `transform-origin: 0 0`. That is why 8px labels and 25px inputs are
sane *in the game*: on screen they are 16px and 50px.

**If you build a companion app that does not scale, SUI's dimensions are half size or
less.** Three options:

| Option | Trade-off |
|---|---|
| Apply the same scaling | Most faithful; costs you CSS-pixel layout maths |
| Run at 1× and override sizes locally | Keep SUI's colours, borders and structure; bump font sizes and control widths where legibility demands. Document each override |
| Mix | Scale the game-like surfaces, run dense data views at 1× |

Whichever you choose, decide it **before writing markup**. Retrofitting is a long tail
of "why is this control 8px tall". The Structs Desktop Team Ops console took option two
and its overrides run to about 80 lines of CSS.

Note that `#sui-offcanvas` and `#sui-cheatsheet-container` append themselves to
`<body>`, so they need the same treatment as your app root.

---

## The five rules

Break these and it stops reading as Structs even if every class name is right.

1. **Nothing is rounded.** `border-radius: 0` appears explicitly throughout. Hard edges
   and 1–2px borders.
2. **Emphasis is colour and case, never weight.** Font weight is `500` almost
   everywhere. To emphasise, change the colour token or use an uppercase ExtremeHazard
   label. Do not reach for `font-weight: 700`.
3. **Chrome is uppercase and tiny; content is normal case and larger.** Nav items,
   buttons, card headers, field labels: ExtremeHazard, 8px, uppercase. Body copy:
   DirectiveZero, 16px.
4. **Colour is semantic, from tokens.** Never a hex literal. Teal is *you*, red is *the
   enemy*, amber is *warning*, gold is *third parties*, grey-blue is *hint*.
5. **Density over whitespace.** This is an operations console. Spacing tokens top out
   at 32px and most gaps are 8–16px.

And one inherited default that will surprise you: `sui.css` sets `text-align: center`
on `body`. Every string in your app is centred until you say otherwise — see
[gotchas](gotchas.md#the-whole-document-is-centre-aligned).

---

## Where to go next

| You want to | Read |
|---|---|
| Look up a colour, size, or z-index | [tokens.md](tokens.md) |
| Find an icon that exists | [icons.md](icons.md) |
| Get the markup right for a card, form, row, badge | [components.md](components.md) |
| Wire up steppers, tooltips, or the drawer | [runtime.md](runtime.md) |
| Understand why your layout is broken | [gotchas.md](gotchas.md) |
| Keep a multi-page console coherent | [patterns.md](patterns.md) |
| Build a dashboard, form, menu, or HUD | [recipes.md](recipes.md) |
| Copy something that already runs | [examples/](examples/README.md) |

---

## Read the CSS, not the docs

Several documented behaviours contradict what the markup looks like it should do. Every
claim on these pages was verified against source, and the pages say which revision they
describe. When in doubt, open `sui.css` — and when it disagrees with anything here,
`sui.css` wins. If you find a divergence, [develop/maintenance.md](../maintenance.md)
explains how to get it corrected.

The published component gallery at <https://structs.design> is useful for seeing parts
rendered, but it is served from the [structs-ui](../repos.md) repo, which lags the
webapp considerably.

---

*Verified against structs-webapp `6eec7f7` (2026-07-21). Inventory:
[generated/sui-inventory.md](../../generated/sui-inventory.md).*
