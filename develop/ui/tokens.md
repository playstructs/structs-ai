---
description: "Every design token SUI defines: colour, a seven-step spacing scale, dimensions, the z-index stack, and the tokens people expect but won't find."
---

# SUI tokens and typography

**Purpose**: Every design token SUI defines, what each one means, and which ones people
expect to exist but don't.

All tokens are declared on `:root` in `sui.css`. **Always reference the variable, never
the hex.** A colour written as `#43CDB6` is a colour that will not follow a theme change
and will not read as semantic to the next person.

The complete machine-extracted list (72 tokens) is in
[generated/sui-inventory.md](../../generated/sui-inventory.md). This page groups them by
what they are *for*.

---

## Colour

### Accents — interactive state

| Token | Value | Use |
|---|---|---|
| `--accent-primary` | `#43CDB6` | Primary action, teal |
| `--accent-primary-active` | `#C2EFDD` | Primary, pressed |
| `--accent-secondary` | `#94A4E4` | Secondary action, periwinkle |
| `--accent-secondary-active` | `#BBCAEF` | Secondary, pressed |
| `--accent-destructive` | `#EE7D69` | Destructive action, red |
| `--accent-destructive-active` | `#F4A990` | Destructive, pressed |
| `--accent-disabled` | `#7394A5` | Inert control |

### Text

| Token | Value | Use |
|---|---|---|
| `--text-body` | `#C5D7D9` | Default reading colour |
| `--text-hint` | `#A7C0C6` | Secondary, de-emphasised |
| `--text-warning` | `#F3C878` | Amber |
| `--text-player-primary` | `#43CDB6` | Teal — "us" |
| `--text-player-highlight` | `#86DFC6` | Teal, emphasised |
| `--text-player-inverted` | `#133546` | On a teal fill |
| `--text-enemy-primary` | `#EE7D69` | Red — "them" |
| `--text-enemy-highlight` | `#F4A990` | Red, emphasised |
| `--text-enemy-inverted` | `#2E1F3E` | On a red fill |
| `--text-neutral-primary` | `#EBAA49` | Gold — third parties |

### Surfaces

| Token | Value | Use |
|---|---|---|
| `--page-background` | `#1A2029` | Page base (under the tiled background image) |
| `--surface-default` | `#222034` | Default component fill |
| `--surface-player-body` | `#133546` | Friendly panel body |
| `--surface-player-highlight` | `#1C5F6A` | Friendly nav / emphasis |
| `--surface-player-inverted` | `#43CDB6` | Teal fill, e.g. card headers |
| `--surface-enemy-body` | `#2E1F3E` | Hostile panel body |
| `--surface-enemy-highlight` | `#5D0C15` | Hostile emphasis |
| `--surface-enemy-inverted` | `#E64D40` | Red fill |
| `--surface-neutral-body` | `#1E1C2E` | Third-party panel body |
| `--surface-panel` | `#5D7E90` | Panel chrome |
| `--surface-panel-medium` | `#4C6475` | Panel chrome, darker step |

### Borders

| Token | Value | Use |
|---|---|---|
| `--border` | `#5D7E90` | Default |
| `--border-strong` | `#A7C0C6` | Emphasised |
| `--border-subtle` | `#394958` | De-emphasised |
| `--border-player` | `#133546` | Friendly |
| `--border-player-dark` | `#2E1F3E` | Friendly, dark variant |
| `--border-enemy` | `#440D3A` | Hostile |
| `--border-enemy-dark` | `#222034` | Hostile, dark variant |
| `--border-neutral-dark` | `#000000` | Third party, dark variant |
| `--border-focus-friendly-dark` | `#2A9D9B` | Focus ring, friendly |
| `--border-focus-enemy-dark` | `#C11F16` | Focus ring, hostile |

> The two `--border-focus-*` tokens are the closest thing SUI has to a focus indicator,
> and nothing in the stylesheet applies them to `:focus`. If you add keyboard focus
> styling — and you should, see [gotchas](gotchas.md#focus-outlines-are-removed-globally)
> — use these rather than inventing a colour.

### Icons and gauges

| Token | Value | Use |
|---|---|---|
| `--icon-colour-primary` | `#43CDB6` | Glyph icon, friendly |
| `--icon-colour-warning` | `#F3C878` | Glyph icon, caution |
| `--icon-colour-destructive` | `#EE7D69` | Glyph icon, hostile |
| `--icon-dark` | `#394958` | Glyph icon, inert |
| `--struct-health-bar-health` | `#EFB719` | Remaining HP |
| `--struct-health-bar-damage` | `#CC2D2D` | Lost HP |
| `--struct-progress-bar-fill` | `#C5D7D9` | Progress fill |

---

## Spacing — a 7-step scale

```
--spacing-xs: 2px    --spacing-sm: 4px     --spacing-md: 8px    --spacing-lg: 12px
--spacing-xl: 16px   --spacing-xxl: 24px   --spacing-xxxl: 32px
```

Most component gaps are 8–16px. There is no larger step; if a layout wants 48px of air,
it is probably not a Structs layout.

## Dimensions

```
--icon-xs: 8px    --icon-sm: 16px   --icon-md: 24px
--icon-lg: 32px   --icon-xl: 48px   --icon-xxl: 64px
--tile-width: 128px    --tile-height: 128px
--form-input-height-total: 40px
--from-input-height-content: 36px      /* [sic] */
```

> **Copy the typo.** `--from-input-height-content` is misspelled in the source (`from`,
> not `form`). That is the real variable name, and `.sui-screen-btn` uses it for its
> height. Writing `--form-input-height-content` silently resolves to nothing.

## Z-index — a defined stack, use it

| Token | Value |
|---|---|
| `--loading-screen-z-index` | `10000` |
| `--popup-z-index` | `2000` |
| `--notification-dialogue-z-index` | `1500` |
| `--banner-z-index` | `1250` |
| `--menu-page-z-index` | `1000` |
| `--hud-z-index` | `50` |
| `--picture-in-picture-z-index` | `30` |
| `--map-z-index` | `10` |
| `--menu-z-index` | `10` |
| `--menu-page-fill-background-z-index` | `-1` (relative to the menu page) |

---

## Typography

Three families, six roles. Loaded via `@font-face` from `fonts/sui/`; `Inter` comes from
a CDN in the webapp's base template.

| Class | Family | Size / line | Case | Use for |
|---|---|---|---|---|
| `.sui-text-display`, `h1` | ExtremeHazard | 16 / 24 | UPPER | Page titles |
| `.sui-text-header`, `.sui-text-label`, `h2` | ExtremeHazard | 8 / 16 | UPPER | Card headers, field labels, nav, buttons |
| `.sui-text-label-block` | ExtremeHazard | 8 / 16 | UPPER | Same, forced `display: block` |
| `.sui-text-paragraph` | DirectiveZero | 16 / 20 | normal | Body copy |
| `.sui-text-tiny` | DirectiveZero | 8 / 12 | normal | Fine print |
| `.sui-text-ticker` | Inter | 12 / 16 | normal | Tickers, timestamps |

Font weight is `500` for every one of these except `.sui-text-ticker`, which is `400`.
That is the whole weight system — see rule 2 in the [design language](index.md#the-five-rules).

8px sounds unreadable. It isn't, at `scale(2)`. At 1× it is, which is what the
[scaling decision](index.md#decide-the-scaling-model-first) is about.

### Colour-only helpers

`.sui-text-primary`, `-secondary`, `-destructive`, `-disabled`, `-warning`, `-hint` set
`color` and nothing else — no metrics. Combine them with a metric class.

> **`sui-mod-*` doubles as a global colour utility.** `.sui-mod-primary`, `-secondary`,
> `-destructive`, `-disabled` and `-warning` set `color:` on *any* element, not just
> inside components. `<span class="sui-mod-warning">` is amber. This has consequences —
> see [the inline alert trap](gotchas.md#severity-colours-the-icon-but-not-the-text).

---

## Tokens that do not exist

There is **no** `--accent-positive`, `--accent-negative`, or `--accent-warning`. If you
see those in a codebase, someone invented them. Map intent to real tokens:

| Intent | Use |
|---|---|
| good / ours / success | `--text-player-primary` |
| bad / theirs / error | `--text-enemy-primary` or `--accent-destructive` |
| caution | `--text-warning` |
| inert / secondary | `--text-hint` or `--accent-disabled` |

SUI also defines `font-variant-numeric` **nowhere**. In a console full of changing
figures you want `tabular-nums` on every numeric cell, or columns will jitter on each
refresh. That is a sanctioned local addition, not a deviation — see
[examples/sui-patch.css](examples/sui-patch.css).

---

*Verified against structs-webapp `6eec7f7` (2026-07-21), `src/public/css/sui/sui.css`.*
