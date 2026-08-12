---
description: "How a client consumes the live event stream: the NATS connection, the listener contract, all 26 listeners, and what the stream won't do."
---

# Real-time events with GRASS

**Purpose**: How the reference client consumes the live event stream — connection,
the listener contract, the full listener catalogue, and what the stream will not do
for you.

For the event schema and subject taxonomy from the server side, see the
[structs-streaming skill](../../.cursor/skills/structs-streaming/SKILL.md) and
[api/streaming/event-types.md](../../api/streaming/event-types.md). This page is how a
client wires it up.

---

## Connection

NATS over WebSocket via `@nats-io/nats-core` 3.0.0, using `wsconnect`:

```js
this.nc = await natsCore.wsconnect({
  servers: this.grassServerUrl,
  maxReconnectAttempts: -1, // never give up on transient drops
  reconnectTimeWait: 2000,
  waitOnFirstConnect: true,
});
```

The client runs **two managers**, both against `ws://{hostname}:1443`:

| Manager | NATS subject | Listeners |
|---|---|---|
| `grassManager` | `structs.>` | all 25 game listeners |
| `blockGrassManager` | `consensus` | `BlockListener` only |

**No authentication is sent.** No token, no credentials. The scheme is `ws://`, not
`wss://` — production TLS, if any, is handled by a reverse proxy outside this code.

### Reconnection is doubly defended

The NATS client retries forever on its own, and an outer supervisor loop catches anything
that escapes it, with exponential backoff from 1s to a 30s ceiling:

```js
while (this.running) {
  try {
    this.nc = await natsCore.wsconnect({ … });
    this.backoffMs = 1000;                       // reset on a good connect
    this.subscription = this.nc.subscribe(this.subject);
    for await (const message of this.subscription) { /* decode, fan out */ }
  } catch (e) {
    console.warn('[GrassManager] connection error:', this.subject, e);
  }
  await this.nc?.close();
  if (!this.running) break;
  await new Promise((resolve) => setTimeout(resolve, this.backoffMs));
  this.backoffMs = Math.min(this.backoffMs * 2, this.backoffMax);
}
```

Registered listeners live in a `Map` that persists across reconnects, so nothing needs
re-registering. Malformed JSON is skipped; a listener that throws is caught and logged
without killing the loop.

> **Connection state never reaches the UI.** Drops are `console.warn` and nothing else.
> A user can sit in front of a silently disconnected client watching stale numbers. If
> you build anything operational on GRASS, surface the connection state — it is the
> single highest-value addition to this subsystem.

Note also that despite comments referring to them, there is no public `close()` or
`reconnect()` on `GrassManager`. Only `init()`.

---

## One subscription, client-side filtering

This is the architectural decision to understand: **there is one NATS subscription per
manager, and every listener sees every message.** Listeners do not subscribe to subjects.
They filter, in JavaScript, on fields in the decoded payload.

```js
getMessageData(message) {
  return message.json();
}

shouldIgnoreMessage(messageData) {
  return !messageData.hasOwnProperty('subject')
    || !messageData.hasOwnProperty('category');
}
```

Messages are JSON with `subject` and `category` as required envelope fields; anything
missing either is dropped before listeners run.

Subject strings inside the payload follow these shapes:

| Pattern | Carries |
|---|---|
| `consensus` | block height |
| `structs.player.{guildId}.{playerId}` | player consensus, address approve/revoke |
| `structs.grid.player.{playerId}.{playerId}` | alpha, load, capacity, ore, lastAction |
| `structs.grid.substation.{substationId}` | connection capacity |
| `structs.grid.struct.{structId}.{playerId}` | struct fuel |
| `structs.planet.{planetId}.{playerId}` | structs, combat, raids, shields, fleet, mining |
| `structs.inventory.ualpha.{guildId}.{playerId}` | alpha sent / received / refined |
| `structs.inventory.ualpha.infused.{guildId}.{playerId}` | infusion |
| `structs.inventory.ualpha.defusing.{guildId}.{playerId}` | defusion |
| `structs.address.register.{activationCode}` | pending device registration |

Fan-out cost grows with listener count, since every listener runs its filter on every
message. At 26 listeners this is fine. If you are building something that registers
hundreds, subscribe to narrower NATS subjects instead.

---

## The listener contract

```js
export class AbstractGrassListener {
  constructor(name) { this.name = name; }
  handler(messageData) { throw new NotImplementedError(); }
  shouldUnregister() { return false; }
}
```

Three obligations: a unique `name`, a `handler`, and optionally `shouldUnregister`.

```js
registerListener(listener) { this.listeners.set(listener.name, listener); }
unregisterListener(name)   { this.listeners.delete(name); }
```

> **`name` is a `Map` key, so duplicates silently overwrite.** `AlphaInfusedChangeListener`
> always names itself `ALPHA_INFUSED_CHANGE`, so registering it for both infuse and defuse
> replaces the first with the second. Namespace your listener names per instance —
> several in the codebase already do, e.g. `CONSUME_ALPHA_CHANGE_{structId}`.

### Self-unregistering listeners

Many listeners exist to await exactly one event: a signup confirming, a device being
approved, a transfer landing. The manager checks after each dispatch:

```js
this.listeners.forEach((listener) => {
  try {
    listener.handler(messageData);
    if (listener.shouldUnregister()) {
      this.unregisterListener(listener.name);
    }
  } catch (e) {
    console.warn('[GrassManager] listener error:', listener.name, e);
  }
});
```

Two idioms are in use. Most one-shot listeners overwrite the method on the instance:

```js
this.shouldUnregister = () => true;
```

`StructListener` overrides it as a real method, tying its lifetime to a raid:

```js
shouldUnregister() {
  if (this.gameState.keyPlayers[this.targetPlayerType].isRaidDependent()) {
    return !this.gameState.getPlanetRaidInfoForKeyPlayer(this.targetPlayerType)?.isRaidActive();
  }
  return false;
}
```

The check is synchronous, immediately after `handler()` returns. A listener that sets the
flag inside a `.then()` will not be removed until the *next* message arrives — harmless
here, but worth knowing if you build on it.

---

## The listener catalogue

All on `structs.>` except `BlockListener`, which is on `consensus`.

| Listener | Fires on | Does |
|---|---|---|
| `BlockListener` | `block` | Sets block height; dispatches `BLOCK_HEIGHT_CHANGED`. **This is the client's clock** — the signing queue and charge bar both hang off it |
| `PlayerCreatedListener` | `player_consensus`, matching primary address | Logs in, finds a first planet. One-shot |
| `NewPlanetListener` | `player_consensus` with `planet_id` | Fetches planet/fleet/structs, configures the map, navigates. One-shot |
| `PlayerAlphaListener` | `alpha` | `setAlpha` |
| `AlphaChangeListener` | `sent` / `received` / `refined` | Adjusts alpha by delta |
| `AlphaInfusedChangeListener` | `infused` / `defusion_started` | Refreshes player, navigates to reactor. One-shot |
| `ConsumeAlphaChangeListener` | `infused` for one struct | Refreshes alpha. One-shot |
| `TransferSentListener` | `sent`, matching counterparty and amount | Navigates to the transaction page. One-shot |
| `PlayerLoadListener` | `load` | `setLoad` |
| `PlayerCapacityListener` | `capacity` | `setPlayerCapacity` |
| `PlayerStructsLoadListener` | `structsLoad` | `setStructsLoad` |
| `ConnectionCapacityListener` | `connectionCapacity` | `setConnectionCapacity` |
| `KeyPlayerLastActionListener` | `lastAction` | **Updates the confirmed charge base.** The signing queue depends on this |
| `KeyPlayerOreListener` | `ore` | `setOre`, optional planet refresh |
| `KeyPlayerShieldChangeStatusListener` | `shield_change`, `block_raid_start` | Updates shield info |
| `StructListener` | `struct_block_build_start`, `struct_status`, `struct_move`, `struct_defense_add`/`remove`, `struct_attack` | The big one: refreshes structs, enqueues combat animations, spawns and kills build tasks |
| `StructMineStatusListener` | `struct_block_ore_mine_start` | Spawns or kills the MINE proof-of-work task |
| `StructRefineStatusListener` | `struct_block_ore_refine_start` | Spawns or kills the REFINE task |
| `GridStructListener` | `fuel` for one struct | Updates fuel, releases the action-bar lock. One-shot |
| `RaidStatusListener` | `raid_status`, `fleet_depart`/`arrive` on the target | Full offensive raid lifecycle |
| `PlanetRaidStatusListener` | `raid_status` on your own planet | Defensive raid lifecycle |
| `PlayerAddressApprovedListener` | `player_address` approved | Refreshes devices, navigates. One-shot |
| `PlayerAddressApprovedLoginListener` | `player_address` approved for the signing address | Navigates to device activation. One-shot |
| `PlayerAddressPendingCreatedListener` | `player_address_pending` | Prompts to approve a new device. One-shot |
| `PlayerAddressRevokedListener` | `player_address` revoked | Logs out or refreshes devices. One-shot |
| `RecoverAccountAddressApprovedListener` | `player_address` approved for recovery | Completes mnemonic login. One-shot |

Registration is spread across `index.js` (block), `AuthManager` (auth and device flows),
`RaidManager`, and several view models that register a one-shot listener for the event
they are waiting on and then navigate.

---

## Reaching the UI

Three patterns, in increasing order of side effects.

**GRASS → GameState setter → CustomEvent → component.** The common case:

```js
// PlayerAlphaListener
this.gameState.keyPlayers[PLAYER_TYPES.PLAYER].setAlpha(parseInt(messageData.value));
// → KeyPlayer.setAlpha dispatches SaveGameStateEvent + AlphaCountChangedEvent
// → AlphaOwnedComponent updates its text node
```

**GRASS → direct CustomEvent**, for things with no natural model home — block height.

**GRASS → side effects**, where a listener calls the REST API, navigates the router, or
pushes onto the [animation queue](rendering-entities.md#the-animation-event-queue).
`StructListener` does all three.

---

## What the stream will not do for you

| | |
|---|---|
| **No replay** | Messages sent while you were disconnected are gone. There is no backfill and no sequence gap detection |
| **No deduplication** | Nothing keyed on a message ID |
| **No ordering guarantee** | Handled sequentially in one loop, but async work inside handlers is fire-and-forget and can interleave |
| **Lag behind chain** | GRASS trails the chain by one to two blocks. The signing queue accounts for this; your code should too |
| **Silence on disconnect** | No indicator, no event |

Which is why the architecture in [index.md](index.md) matters: **REST is authoritative,
GRASS keeps you current.** Re-fetch on login and after anything significant. A client that
treats the stream as its source of truth will drift, and it will drift silently — the
worst failure mode there is, because everything keeps looking fine.

---

*Verified against structs-webapp `6eec7f7` (2026-07-21): `src/js/framework/GrassManager.js`,
`src/js/framework/AbstractGrassListener.js`, `src/js/grass_listeners/`.*
