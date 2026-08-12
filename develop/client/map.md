---
title: The tactical map in a Structs client
description: "How the tactical map is built: the ambit stack, the tile grid, fog of war, and the picture-in-picture trick that keeps combat visible."
---

# The tactical map in a Structs client

**Purpose**: How the tactical map is built — the ambit stack, the tile grid, fog of war,
and the picture-in-picture trick that keeps combat visible while you scroll.

---

## It's DOM, not canvas

The whole map is nested `<div>` elements with CSS background sprites. No canvas, no WebGL.
That sounds naive for a game map and turns out to be the right call: tiles are 128×128
pixel art on a fixed grid, the whole thing scales with a CSS `transform`, and every tile
is inspectable and event-targetable for free.

Seven stacked layers:

```js
// src/js/view_models/components/map/MapComponent.js
return `
  <div id="${this.mapId}" class="map">
    <div id="${this.terrainId}" class="map-terrain"></div>
    <div id="${this.ornamentsId}" class="map-ornaments"></div>
    <div id="${this.markersId}" class="map-markers"></div>
    <div id="${this.structLayerId}" class="map-struct-layer"></div>
    <div id="${this.structHUDLayerId}" class="map-struct-hud-layer"></div>
    <div id="${this.fogOfWarId}" class="map-fog-of-war-anchor"></div>
    <div id="${this.tileSelectionId}" class="map-tile-selection"></div>
  </div>
`;
```

Terrain, structs and struct HUD all share identical row and column geometry, so a tile at
grid position (row, col) means the same place in all three. Tile size is 128×128,
matching `--tile-width` and `--tile-height` in `sui.css`.

---

## The ambit stack

Only ambits the planet actually has are rendered — the planet's slot counts decide — and
they always stack in the same order, top to bottom: **space, air, land, water**.

```js
// src/js/models/Planet.js
getAmbits() {
  const ambits = [];
  if (this.space_slots && this.space_slots > 0) { ambits.push(AMBITS.SPACE); }
  if (this.air_slots   && this.air_slots   > 0) { ambits.push(AMBITS.AIR); }
  // … land, water
}
```

`.map-terrain` is a column flexbox, so DOM order is visual order. Each ambit is two rows
of tiles (`MAP_TILE_ROWS_PER_AMBIT = 2`).

### Transitions between ambits

Between every pair of ambits — and after the last one — sits a 128px transition band, so
the map reads as a continuous vertical slice of a world rather than as stacked strips:

```js
for (let i = 0; i < ambits.length; i++) {
  let transition = this.transitionBuilder.make(this.mapColCount, lastAmbit, ambits[i]);
  html += transition.renderHTML();
  html += (new MapTerrainAmbitComponent(…)).renderHTML();
  if (i === ambits.length - 1) {
    transition = this.transitionBuilder.make(this.mapColCount, ambits[i]);
    html += transition.renderHTML();
  }
}
```

Some transitions are named rather than generic — entering land gets a `HORIZON` band.

The struct and HUD layers insert their own transition rows at the same offsets, tagged
`data-tile-type="TRANSITION"`, purely to keep the three grids aligned.

---

## Tiles

Terrain tile classes encode ambit plus position within the ambit block:

```js
// src/js/util/TileClassNameUtil.js
getTileClassName(ambit, verticalPos, horizontalPos) {
  return `tile-${ambit.toLowerCase()}-${verticalPos}-${horizontalPos}`;
}
```

Vertical is `top`/`middle`/`bottom`, horizontal is `left`/`middle`/`right`, giving classes
like `.tile-space-top-left` backed by `/img/tiles/space/space-1-1-top-left.png`. Edge
variants (`tile-{ambit}-edge-…`, `tile-horizon-…`) handle the transition bands.

Struct-layer tiles carry their identity in data attributes rather than in classes, which
is what makes hit-testing a click trivial:

```html
<div class="map-struct-layer-tile mod-side-left"
     data-tile-type="PLANETARY_SLOT"
     data-side="left"
     data-player-id="4-118"
     data-ambit="land"
     data-slot="2"
     data-struct-id=""></div>
```

Columns run: defender command ship, planetary slots, defender fleet, a divider, attacker
fleet, attacker command ship. Attacker-side tiles are mirrored with a single CSS rule:

```css
.map-struct-layer-tile.mod-side-right { transform: scaleX(-1); }
```

---

## Fog of war

Two mechanisms for the same idea, applied at different layers.

**An overlay** covers everything from the divider rightwards, but only when you are
looking at your own planet with no attacker present:

```js
shouldDisplayFogOfWar() {
  return !this.attacker && (this.perspective === MAP_PERSPECTIVES.DEFENDER);
}
```

It is a left edge sprite plus a repeating body, sized in pixels from the divider position.

**Fog tiles** replace attacker-side struct tiles with `data-tile-type="FOG_OF_WAR"`
carrying `icon-unknown-territory`. These hold the grid positions so geometry stays
consistent, while making the tiles non-interactive and visibly unknown.

The distinction matters when you are building a scouting or intel view: the overlay is
cosmetic, the tile type is what your click handling should key off.

---

## The struct layer

`MapStructLayerComponent.renderStruct()` resolves a tile's `data-*` attributes to a struct
and then takes one of three paths: no struct → destroy any old viewer and clear the tile;
unbuilt struct → show the deployment indicator; built struct → create a
`MapStructViewerComponent` and mount it.

**The old viewer is always destroyed before the tile is overwritten**, for the Lottie
reasons in [rendering-entities.md](rendering-entities.md#lottie).

Updates arrive as `window` CustomEvents, so the map never polls:

| Event | Effect |
|---|---|
| `RENDER_ALL_STRUCTS` | Full resync |
| `RENDER_STRUCT` | Re-render one struct |
| `ANIMATION` | Play a queued animation on the matching viewer |
| `RENDER_DEPLOYMENT_INDICATOR` | Show the building indicator |
| `CLEAR_STRUCT_TILE` | Clear |
| `SHOW`/`CLEAR_DEFEND_TARGETS`, `SHOW`/`CLEAR_ATTACK_TARGETS` | Targeting highlights |

The chain of custody for a live update is worth tracing once:
GRASS → `StructListener` → `StructManager.refreshStruct()` → `RenderStructEvent` or an
enqueued animation → the map layer.

---

## Picture-in-picture

A neat solution to a real problem. The map is larger than the viewport and scaled with a
CSS `transform`, so during a combat sequence the struct that is currently animating may be
entirely off-screen — you hear about a battle you cannot see.

`MapPictureInPictureComponent` is a fixed 128×128 viewport appended to `document.body`
(outside the scaled container, so it can position against the viewport) that mirrors the
animating struct whenever its real tile is fully off-screen. It slides in from whichever
side the struct is on, tracks visibility on scroll and resize, and slides out when the
[animation queue](rendering-entities.md#the-animation-event-queue) drains.

The critical detail is one flag:

```
 * The PIP's struct viewer runs in "muted" mode (no `AnimationEndEvent`
 * dispatch) so its lottie completions can't drive the global
 * `AnimationEventQueue`.
```

Two viewers play the same animation, so without muting, the queue would advance twice per
event and the sequence would run at double speed and then desynchronise. Any time you
mirror an animation, mute the copy.

---

*Verified against structs-webapp `6eec7f7` (2026-07-21):
`src/js/view_models/components/map/`, `src/js/util/TileClassNameUtil.js`,
`src/js/models/Planet.js`.*
