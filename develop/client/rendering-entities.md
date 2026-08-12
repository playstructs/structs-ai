---
description: "How players and structs are drawn: layered profile-picture compositing, struct art selection, and the Lottie animation queue."
---

# Rendering entities

**Purpose**: How players and structs are drawn — layered PFP compositing, struct art
selection, the Lottie lifecycle, and the queue that keeps combat animations coherent.

---

## Profile pictures

A player's avatar is not an image file. It is **five PNG layers composited by index**,
painted back to front: background, arms, body, neck, head.

```js
// src/js/view_models/components/PfpViewerComponent.js
const layers = [
  ['background', this.pfp.background],
  ['arms', this.pfp.arms],
  ['body', this.pfp.body],
  ['neck', this.pfp.neck],
  ['head', this.pfp.head],
];

return layers
  .filter(([, index]) => index !== null && index !== undefined)
  .map(([part, index]) =>
    `<img class="pfp-viewer-layer" src="/img/pfp/${part}/pfp_${part}_${index}.png" alt="">`
  )
  .join('');
```

Path convention is `/img/pfp/{part}/pfp_{part}_{index}.png`. All five layers are absolutely
positioned at 72×72 in the portrait container, so later DOM nodes paint on top.

Indices are **1-based** and bounded by:

```js
// src/js/constants/PfpConstants.js
head: 87, neck: 10, body: 57, arms: 34, background: 6
```

That is 87 × 10 × 57 × 34 × 6 ≈ 10.1 million combinations from 194 assets.

The indices live on the player as `pfp_client_render_attributes`, parsed from chain data
by `PlayerFactory`. Note the trap: `Player` also has a `pfp` string field that is **not
used for rendering**. Reading it and expecting an image URL is a natural mistake.

Two fallback behaviours, and one gap:

- No attributes at all, or unparseable JSON → `/img/portrait-placeholder.png`.
- An individual layer index that is `null` → that layer is skipped.
- **An out-of-range index is not validated.** The browser requests a URL that doesn't
  exist and you get a broken image. Clamp against `PFP_PART_COUNTS` yourself.

Rendering a PFP requires no network call beyond the layer PNGs, which makes it cheap to
show avatars in a long roster. Randomising one at signup is `Math.floor(Math.random() *
count) + 1` per layer.

---

## Struct art

Two rendering modes, and the choice between them is about state, not about quality.

| Mode | Used for |
|---|---|
| **Static still** — layered PNGs | Resting appearance on a map tile |
| **Lottie animation** — SVG | Combat, deployment, movement, stealth, destruction, active loops |

### Stills

`StructTypeArtSetBuilder` maps each struct type to its PNG layers under `/img/structs`:

```js
buildCruiser(structType) {
  const art = new StructTypeArtSet(structType);
  art[STRUCT_STILL_LAYERS.STRUCT_VARIANT_BASE]  = this.structImageDir + '/cruiser/cruiser-struct-base.png';
  art[STRUCT_STILL_LAYERS.STRUCT_VARIANT_DMG]   = this.structImageDir + '/cruiser/cruiser-struct-dmg.png';
  art[STRUCT_WEAPON_SYSTEM.PRIMARY_WEAPON]      = this.structImageDir + '/cruiser/cruiser-top-weapon-ballistic.png';
  art[STRUCT_WEAPON_SYSTEM.SECONDARY_WEAPON]    = this.structImageDir + '/cruiser/cruiser-top-weapon-smart.png';
  art[STRUCT_WATER_RIPPLE]                      = this.structImageDir + '/cruiser/cruiser-bottom-ripples.png';
  return art;
}
```

Variant selection is driven by health, with per-type layout differences — a Frigate puts
its primary weapon on the bottom detail layer, a Cruiser on top:

```js
renderHTML(currentHealth = -1, structVariant = '') {
  if (currentHealth === 0) {
    return `<div class="struct-still"></div>`;      // destroyed: nothing
  }
  if (structVariant === '') {
    structVariant = (0 < currentHealth && currentHealth < this.structType.max_health)
      ? STRUCT_STILL_LAYERS.STRUCT_VARIANT_DMG
      : STRUCT_STILL_LAYERS.STRUCT_VARIANT_BASE;
  }
  return `
    <div class="struct-still">
      ${this.renderTopDetailLayers(structVariant)}
      ${this.renderStructVariant(structVariant)}
      ${this.renderBottomDetailLayers(structVariant)}
    </div>
  `;
}
```

Three z-index bands order the layers: bottom detail 100, body 200, top detail 300.

Stealth is handled two ways. Most types get 50% opacity via `struct-stealth-active`; a
Submersible swaps to a dedicated `STRUCT_VARIANT_HIDDEN` sprite, because a half-transparent
submarine is not the same idea as a submerged one.

Note that `StructTypeArtSetBuilder` has no art set for Continental Power Plant or World
Engine, and will throw if asked for one. Those types presumably never reach a tactical
map, but guard for it if your surface is more general.

### Lottie

`lottie-web` 5.12.2, loaded from `/js/vendor/`, always with the SVG renderer. Animation
JSON lives at predictable paths:

```
/lottie/deployment_{space|air|land|water}/data.json      shared by ambit
/lottie/attack_primary_weapon/{snake_case_type}/data.json    per struct type
/lottie/stealth_activate/{snake_case_type}/data.json         per struct type
```

The still and the animation are mutually exclusive: playing an animation hides the still
container, and structs with an active loop (extractors and refineries while online) hide
the still permanently in favour of the loop.

**Lottie lifecycle is where the memory leaks are**, and the reference client is explicit
about it:

```js
/**
 * Tear down all lottie players owned by this viewer. Must be called before
 * the viewer is dereferenced (e.g. when its tile is cleared or the viewer
 * is replaced), otherwise lottie-web's internal animation registry keeps
 * the JSON, image bitmaps, rAF subscription, and DOM listeners alive.
 */
```

Dropping the reference is not enough — `lottie-web` holds its own registry. The teardown
chain is `MapStructViewerComponent.destroy()` → `lottieCustomPlayer.destroyAll()` →
`animation.destroy()`, and the map layer calls it **before** overwriting a tile, not
after.

Animations load lazily on first play. During playback the client swaps struct PNGs into
named SVG placeholders (`.struct_init`, `.struct_top_layer_1`), using a generation counter
so a stale async swap from a previous animation cannot land on the current one.

---

## The animation event queue

A single attack produces a burst of GRASS events: the attacker fires, the defender
evades, a point-defence cannon counters, a struct takes damage, a struct is destroyed.
Played concurrently, they trample each other's partial state — health bars and still
images end up showing a mixture of moments that never existed.

`AnimationEventQueue` serialises them globally. One animation plays at a time, and the
next starts only when the previous reports it has ended:

```js
// src/js/data_structures/AnimationEventQueue.js
enqueue(event) {
  super.enqueue(event);
  if (!this.isPlaying) {
    this.playNext();
  }
}

playNext() {
  if (this.isEmpty()) {
    const wasPlaying = this.isPlaying;
    this.isPlaying = false;
    this.currentEvent = null;
    if (wasPlaying) {
      window.dispatchEvent(new CustomEvent(EVENTS.ANIMATION_QUEUE_EMPTY));
    }
    return;
  }
  this.isPlaying = true;
  this.currentEvent = super.dequeue();
  window.dispatchEvent(this.currentEvent);
}
```

`StructListener.handleStructAttack` expands one `struct_attack` message into an ordered
list of `AnimationEvent`s and enqueues them in narrative order.

Three consequences ripple outward from this design, and each is worth copying:

**Game state and displayed state diverge on purpose.** `gameState` holds the final
post-attack values the moment the event arrives, while animation events carry
`options.healthAfter` so each step shows the health at *that* moment. The bars catch up as
the sequence plays.

**Other renderers defer to the queue.** The HUD layer holds back struct-HUD renders while
an animation is playing and flushes them on `ANIMATION_QUEUE_EMPTY`:

```js
if (this.gameState.animationEventQueue && this.gameState.animationEventQueue.isPlaying) {
  this.deferredHudRenders.set(event.struct.id, event.struct);
  return;
}
```

`StructManager` likewise skips showing a still while `isStructAnimating(struct.id)`, so a
routine refresh cannot tear down a Lottie mid-play.

**Chained side effects hang off `onAnimationEnd`.** A move sequence clears the old tile
and refreshes the struct after the departure animation and before the arrival one, which
is the only way to get that ordering right.

Deployment animations are the exception: they autoplay when a struct first renders after
being built, bypassing the queue entirely, because nothing else is competing at that
moment.

---

*Verified against structs-webapp `6eec7f7` (2026-07-21):
`src/js/view_models/components/PfpViewerComponent.js`, `StructStillRenderer.js`,
`MapStructViewerComponent.js`, `MapStructLottieAnimationSVG.js`,
`src/js/data_structures/AnimationEventQueue.js`.*
