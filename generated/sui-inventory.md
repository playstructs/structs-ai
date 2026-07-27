---
kind: ui
authority: source
verified_against: structs-webapp @ 6eec7f761df1 (2026-07-21)
verified_at: 2026-07-27
volatility: high
generated_by: scripts/gen-sui-inventory.sh
---

# SUI inventory

> Generated from `structs-webapp` — the canonical source for the Structs UI
> design system. Do not hand-edit. Regenerate with `scripts/gen-sui-inventory.sh`;
> diff against upstream with `scripts/check-webapp-drift.sh`.

Source commit: `6eec7f761df1a314e17f3a69ed3e2f15cf674362` (2026-07-21)

| Inventory | Count |
|---|---|
| `:root` tokens | 72 |
| Glyph icons (icon font) | 67 |
| Sprite icons (background art) | 29 |
| Component classes | 138 |
| Modifiers | 27 |

## Tokens

| Token | Value |
|---|---|
| `--accent-primary` | `#43CDB6` |
| `--accent-primary-active` | `#C2EFDD` |
| `--accent-secondary` | `#94A4E4` |
| `--accent-secondary-active` | `#BBCAEF` |
| `--accent-destructive` | `#EE7D69` |
| `--accent-destructive-active` | `#F4A990` |
| `--accent-disabled` | `#7394A5` |
| `--border` | `#5D7E90` |
| `--border-enemy` | `#440D3A` |
| `--border-enemy-dark` | `#222034` |
| `--border-focus-enemy-dark` | `#C11F16` |
| `--border-focus-friendly-dark` | `#2A9D9B` |
| `--border-neutral-dark` | `#000000` |
| `--border-player` | `#133546` |
| `--border-player-dark` | `#2E1F3E` |
| `--border-strong` | `#A7C0C6` |
| `--border-subtle` | `#394958` |
| `--icon-colour-destructive` | `#EE7D69` |
| `--icon-colour-primary` | `#43CDB6` |
| `--icon-colour-warning` | `#F3C878` |
| `--icon-dark` | `#394958` |
| `--page-background` | `#1A2029` |
| `--struct-health-bar-health` | `#EFB719` |
| `--struct-health-bar-damage` | `#CC2D2D` |
| `--struct-progress-bar-fill` | `#C5D7D9` |
| `--surface-enemy-body` | `#2E1F3E` |
| `--surface-enemy-highlight` | `#5D0C15` |
| `--surface-enemy-inverted` | `#E64D40` |
| `--surface-neutral-body` | `#1E1C2E` |
| `--surface-player-highlight` | `#1C5F6A` |
| `--surface-player-inverted` | `#43CDB6` |
| `--surface-player-body` | `#133546` |
| `--surface-default` | `#222034` |
| `--surface-panel` | `#5D7E90` |
| `--surface-panel-medium` | `#4C6475` |
| `--text-enemy-primary` | `#EE7D69` |
| `--text-enemy-highlight` | `#F4A990` |
| `--text-enemy-inverted` | `#2E1F3E` |
| `--text-neutral-primary` | `#EBAA49` |
| `--text-player-primary` | `#43CDB6` |
| `--text-player-highlight` | `#86DFC6` |
| `--text-player-inverted` | `#133546` |
| `--text-body` | `#C5D7D9` |
| `--text-hint` | `#A7C0C6` |
| `--text-warning` | `#F3C878` |
| `--form-input-height-total` | `40px` |
| `--from-input-height-content` | `36px` |
| `--icon-xs` | `8px` |
| `--icon-sm` | `16px` |
| `--icon-md` | `24px` |
| `--icon-lg` | `32px` |
| `--icon-xl` | `48px` |
| `--icon-xxl` | `64px` |
| `--tile-height` | `128px` |
| `--tile-width` | `128px` |
| `--loading-screen-z-index` | `10000` |
| `--popup-z-index` | `2000` |
| `--notification-dialogue-z-index` | `1500` |
| `--banner-z-index` | `1250` |
| `--menu-page-z-index` | `1000` |
| `--hud-z-index` | `50` |
| `--picture-in-picture-z-index` | `30` |
| `--map-z-index` | `10` |
| `--menu-z-index` | `10` |
| `--menu-page-fill-background-z-index` | `-1` |
| `--spacing-xs` | `2px` |
| `--spacing-sm` | `4px` |
| `--spacing-md` | `8px` |
| `--spacing-lg` | `12px` |
| `--spacing-xl` | `16px` |
| `--spacing-xxl` | `24px` |
| `--spacing-xxxl` | `32px` |

## Glyph icons

Icon-font classes from `src/public/css/structicons.css`. These inherit `color`.

`icon-add` `icon-adv-counter` `icon-alert` `icon-armour` `icon-arrow` 
`icon-attention` `icon-ballistic-weapon` `icon-beacon` `icon-blocked` 
`icon-caret-down` `icon-caret-left` `icon-caret-right` `icon-caret-up` 
`icon-chevron-down` `icon-chevron-left` `icon-chevron-right` 
`icon-chevron-up` `icon-close` `icon-cmd-post` `icon-combat-log` 
`icon-computer` `icon-copy` `icon-counter` `icon-defend` `icon-deploy` 
`icon-detected` `icon-dmg` `icon-edit` `icon-enemy-tile` `icon-fleet-tile` 
`icon-guild` `icon-guild-directory` `icon-in-progress` `icon-incoming` 
`icon-indirect` `icon-info` `icon-key` `icon-kinetic-barrier` `icon-link-out` 
`icon-member` `icon-menu` `icon-mine` `icon-move` `icon-okay` 
`icon-ore-ready` `icon-outgoing` `icon-phone` `icon-planet` 
`icon-planetary-shield` `icon-raid` `icon-range` `icon-refine` 
`icon-refresh-12` `icon-refresh-8` `icon-send-alpha` `icon-signal-jam` 
`icon-smart-weapon` `icon-stealth` `icon-subtract` `icon-success` `icon-tip` 
`icon-transfers` `icon-undiscovered-ore` `icon-unknown` 
`icon-unknown-territory` `icon-unpowered` `icon-wreckage`

Declared more than once in the stylesheet: `icon-attention`

## Sprite icons

`i.sui-icon-*` rules carrying a `background-image` in `sui.css`. These are pixel
art and do **not** inherit `color`.

`air` `alpha-matter` `alpha-ore` `armour` `attacker` `counter-attack` 
`defended` `defender-block` `defender-counter` `defending` `deflector-shield` 
`deployed-structs` `destroyed` `electronic-warfare-system` 
`enemy-deployed-structs` `enemy-indicator` `enemy-shield-health` `energy` 
`inert-alpha` `land` `local` `no-power` `player-indicator` `players` 
`shield-health` `space` `stealth-mode` `undiscovered-ore` `water`

## Icon sizes

`sui-icon-lg` `sui-icon-md` `sui-icon-sm` `sui-icon-xl` `sui-icon-xs` 
`sui-icon-xxl`

## Themes

`sui-theme-enemy` `sui-theme-neutral` `sui-theme-player`

## Modifiers

`sui-mod-active` `sui-mod-active-defense` `sui-mod-active-offense` 
`sui-mod-align-flex-end` `sui-mod-animated` `sui-mod-bottom` 
`sui-mod-default` `sui-mod-destructive` `sui-mod-disabled` 
`sui-mod-disabled-active` `sui-mod-filled` `sui-mod-grow` `sui-mod-header` 
`sui-mod-inverted` `sui-mod-left` `sui-mod-minimized` `sui-mod-narrow` 
`sui-mod-pressed` `sui-mod-primary` `sui-mod-right` `sui-mod-secondary` 
`sui-mod-show` `sui-mod-shrink` `sui-mod-solid` `sui-mod-spacing-xl` 
`sui-mod-top` `sui-mod-warning`

## Component classes

`sui-action-bar-bottom-row` `sui-action-bar-btn-group` 
`sui-action-bar-panel-switch-group` `sui-action-bar-progress-bar` 
`sui-action-bar-progress-bar-chunk` `sui-action-bar-progress-bar-wrapper` 
`sui-badge` `sui-battery` `sui-battery-chunk` `sui-cheatsheet` 
`sui-cheatsheet-content` `sui-cheatsheet-contextual-message` 
`sui-cheatsheet-cost` `sui-cheatsheet-costs` `sui-cheatsheet-description` 
`sui-cheatsheet-property` `sui-cheatsheet-property-icon` 
`sui-cheatsheet-property-info` `sui-cheatsheet-property-section` 
`sui-cheatsheet-title` `sui-cheatsheet-title-text` `sui-cheatsheet-top-frame` 
`sui-checkbox` `sui-checkbox-container` `sui-checkbox-display` 
`sui-data-card` `sui-data-card-body` `sui-data-card-header` 
`sui-data-card-row` `sui-dialogue-btn-chunk` `sui-dialogue-btn-chunk-col` 
`sui-flip-horizontal` `sui-form-element-group-label` 
`sui-form-element-label-group` `sui-hud-indicator` `sui-hud-indicator-icon` 
`sui-icon` `sui-input-stepper` `sui-input-text` `sui-input-text-warning` 
`sui-message-inline-alert` `sui-message-inline-alert-text` 
`sui-message-system-alert` `sui-message-system-alert-close-container` 
`sui-message-system-alert-icon-container` 
`sui-message-system-alert-text-container` `sui-message-system-modal` 
`sui-message-system-modal-cta` `sui-message-system-modal-cta-btn-wrapper` 
`sui-message-system-modal-frame` `sui-message-system-modal-frame-left` 
`sui-message-system-modal-frame-left-bottom` 
`sui-message-system-modal-frame-left-middle` 
`sui-message-system-modal-frame-left-top` 
`sui-message-system-model-frame-center` `sui-message-system-model-overlay` 
`sui-nav-btn` `sui-offcanvas-body` `sui-page-body-screen` 
`sui-page-body-screen-content` `sui-page-header` `sui-page-header-resources` 
`sui-pagination` `sui-pagination-number` `sui-pagination-numbers` `sui-panel` 
`sui-panel-bottom-fill-background` `sui-panel-btn` `sui-panel-chunk` 
`sui-panel-chunk-spacer-btn-a` `sui-panel-chunk-spacer-btn-b` 
`sui-panel-chunk-spacer-indicator` `sui-panel-connector` 
`sui-panel-edge-left` `sui-panel-edge-right` 
`sui-panel-style-default-to-medium` `sui-panel-style-medium-to-default` 
`sui-panel-top-fill-background` `sui-panel-wrapper-fit-content` 
`sui-planet-card` `sui-planet-card-alert` `sui-planet-card-body` 
`sui-planet-card-body-content` `sui-planet-card-header` 
`sui-planet-card-header-label` `sui-planet-card-header-label-title` 
`sui-planet-card-loading` `sui-planet-card-loading-animation` 
`sui-planet-card-message` `sui-planet-card-status-group` 
`sui-planet-card-status-group-col` `sui-radio` `sui-radio-container` 
`sui-radio-display` `sui-resource` `sui-result-row` 
`sui-result-row-left-section` `sui-result-row-player-info` 
`sui-result-row-portrait` `sui-result-row-portrait-icon` 
`sui-result-row-portrait-image` `sui-result-row-resources` 
`sui-result-row-right-section` `sui-result-rows` `sui-result-table` 
`sui-screen` `sui-screen-battery` `sui-screen-body` `sui-screen-btn` 
`sui-screen-btn-flex-wrapper` `sui-screen-dialogue` `sui-screen-full-width` 
`sui-screen-indicator` `sui-screen-info` `sui-screen-nav` 
`sui-screen-nav-close` `sui-screen-nav-item` `sui-screen-nav-items` 
`sui-screen-portrait` `sui-screen-portrait-image` `sui-screen-properties` 
`sui-screen-shrink` `sui-status-bar` `sui-status-bar-panel` 
`sui-text-destructive` `sui-text-disabled` `sui-text-display` 
`sui-text-header` `sui-text-hint` `sui-text-label` `sui-text-label-block` 
`sui-text-paragraph` `sui-text-primary` `sui-text-secondary` 
`sui-text-ticker` `sui-text-tiny` `sui-text-warning` `sui-tooltip`

## UI scaling (main.css)

The game scales its whole UI at these breakpoints. A companion app that does not
scale renders SUI at half size or less — see `develop/ui/index.md`.

| Breakpoint | Transform |
|---|---|
| `min-width: 1152px` | `scale(2)` |
| `min-width: 2304px` | `scale(4)` |

## SUI JavaScript modules

`SUI.js` `SUICheatsheet.js` `SUICheatsheetContentBuilder.js` 
`SUICheatsheetRenderer.js` `SUIFeature.js` `SUIInputStepper.js` 
`SUINotImplementedError.js` `SUIOffcanvas.js` `SUITooltip.js` `SUIUtil.js`

