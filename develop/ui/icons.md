---
title: SUI icon systems and inventories
description: "The two SUI icon systems: 67 tinting glyph icons and 29 fixed-colour sprite icons, both inventoried, plus the rule never to invent one."
---

# SUI icon systems and inventories

**Purpose**: The two icon systems, the complete inventory of both, and the rule that
matters most — never invent one.

SUI has two entirely separate icon systems that happen to share a base class. Knowing
which one you are using determines whether the icon takes your text colour.

---

## Glyph icons — the icon font

67 icons in the `Structicons` font, declared in `src/public/css/structicons.css`.

```html
<i class="sui-icon sui-icon-sm icon-refresh-8"></i>
```

They render as text, so they **inherit `color`** and take severity colour for free:

```html
<i class="sui-icon sui-icon-sm icon-alert sui-mod-warning"></i>
```

### Complete inventory

```
add                 adv-counter        alert              armour
arrow               attention          ballistic-weapon   beacon
blocked             caret-down         caret-left         caret-right
caret-up            chevron-down       chevron-left       chevron-right
chevron-up          close              cmd-post           combat-log
computer            copy               counter            defend
deploy              detected           dmg                edit
enemy-tile          fleet-tile         guild              guild-directory
in-progress         incoming           indirect           info
key                 kinetic-barrier    link-out           member
menu                mine               move               okay
ore-ready           outgoing           phone              planet
planetary-shield    raid               range              refine
refresh-8           refresh-12         send-alpha         signal-jam
smart-weapon        stealth            subtract           success
tip                 transfers          undiscovered-ore   unknown
unknown-territory   unpowered          wreckage
```

Each is prefixed `icon-` in markup: `icon-planetary-shield`, `icon-send-alpha`.

`icon-attention` is declared twice in the stylesheet — 68 declarations, 67 names. The
duplicate is harmless.

---

## Sprite icons — background art

29 icons drawn as pixel art and applied as `background-image`, declared in `sui.css`.

```html
<i class="sui-icon sui-icon-md sui-icon-alpha-matter"></i>
```

They are images, so they **do not inherit `color`**. A sprite icon will not turn red
because its container is red. If you need a hostile variant, check whether one exists
(`enemy-shield-health`, `enemy-deployed-structs`, `enemy-indicator` all do).

### Complete inventory

```
air                        alpha-matter          alpha-ore
armour                     attacker              counter-attack
defended                   defender-block        defender-counter
defending                  deflector-shield      deployed-structs
destroyed                  electronic-warfare-system
enemy-deployed-structs     enemy-indicator       enemy-shield-health
energy                     inert-alpha           land
local                      no-power              player-indicator
players                    shield-health         space
stealth-mode               undiscovered-ore      water
```

Each is prefixed `sui-icon-` in markup: `sui-icon-alpha-ore`, `sui-icon-no-power`.

Note that `armour` and `undiscovered-ore` exist in **both** systems. The glyph version
tints; the sprite version is art. Pick deliberately.

### `sui-icon-value` is not an icon

`span.sui-icon-value` exists in the stylesheet but only sets `margin-left`. It is a
spacing utility for a value sitting beside an icon, not a nineteenth sprite. Do not put
it on an `<i>` expecting art.

---

## Sizes

```
sui-icon-xs   8px     sui-icon-sm   16px    sui-icon-md   24px
sui-icon-lg   32px    sui-icon-xl   48px    sui-icon-xxl  64px
```

Sizing classes need the base class alongside them:
`class="sui-icon sui-icon-md icon-planet"`. A bare `class="icon-planet"` gets the font
but no box.

---

## Rules

**Match the glyph to the size.** `icon-refresh-8` and `icon-refresh-12` both exist
because the art is drawn on an 8px and a 12px grid. Pair grid-8 art with `sui-icon-sm`,
grid-12 with `sui-icon-md`. A mismatch looks blurry, because `body` sets
`image-rendering: pixelated` and non-integer scaling of pixel art is visible.

**Never invent an icon.** No emoji standing in for a glyph, no inline SVG, no icon from
another set. If the concept has no glyph, use a text label. This is a hard rule in the
Structs codebase and the fastest way to make an interface stop looking like Structs.

**Check before you reach.** The two inventories above are complete as of the pinned
revision. The generated copy in
[generated/sui-inventory.md](../../generated/sui-inventory.md) is regenerated from
source and is the one to trust if these ever disagree.

---

*Verified against structs-webapp `6eec7f7` (2026-07-21),
`src/public/css/structicons.css` and `src/public/css/sui/sui.css`.*
