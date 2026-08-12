---
description: How a client holds game state and turns JSON into models, including the numeric-precision trap where numbers arrive as strings.
---

# State and data

**Purpose**: How the reference client holds game state, gets it from the API, and turns
JSON into models — including the numeric-precision trap that will bite you.

---

## Numbers arrive as strings

The chain returns `uint64` values as JSON **strings**, because they routinely exceed
JavaScript's `Number.MAX_SAFE_INTEGER`. Energy values additionally carry three decimal
places of precision as integers.

**The reference client is inconsistent about converting them.** Know this before you copy
any of it.

`PlayerFactory` is the careful case. It divides energy fields through `BigInt` before
narrowing to `Number`:

```js
// src/js/factories/PlayerFactory.js
convertFromPreciseNumber(numberString) {
  return Number(BigInt(numberString) / BigInt(PRECISION_CONVERSION.ENERGY));  // ENERGY = 1000
}

make(obj) {
  const player = new Player();
  Object.assign(player, obj);
  player.load                = this.convertFromPreciseNumber(player.load);
  player.structs_load        = this.convertFromPreciseNumber(player.structs_load);
  player.capacity            = this.convertFromPreciseNumber(player.capacity);
  player.connection_capacity = this.convertFromPreciseNumber(player.connection_capacity);
  player.ore                 = parseInt(player.ore);
  return player;
}
```

Most other factories are `Object.assign` and nothing else, leaving values as strings:

```js
// src/js/factories/InfusionFactory.js — representative of most
make(obj) {
  const infusion = new Infusion();
  Object.assign(infusion, obj);
  return infusion;
}
```

The full picture:

| Path | Energy fields | Ore / counts |
|---|---|---|
| REST via `PlayerFactory` | `BigInt` ÷ 1000 → `Number` | `parseInt` |
| REST via most other factories | **left as strings** | left as strings |
| GRASS live updates | raw value straight to the setter — **no division** | `parseInt` in `setOre` only |
| Protobuf codegen `longToNumber` | `Number(int64.toString())` — **lossy above 2^53** | same |
| Signing queue payloads | `BigInt` is **rejected** — stringify first | same |

Two consequences worth stating plainly. First, `"1000" + 1` is `"10001"`, and a string
compares as a string — `"9" > "100"` is true. Sorting a leaderboard on an unconverted
field gives silently wrong output with no error anywhere. Second, energy read from REST
and energy read from GRASS **may not be on the same scale** in the reference client,
because the GRASS listeners bypass the factory.

**For a new client: normalise once, at the boundary.** Convert every field in one place,
on both the REST and GRASS paths, and keep values above 2^53 as `BigInt` or as strings
all the way to the formatter. Do not adopt the reference client's field-by-field
approach.

---

## GameState

A single mutable object, constructed once at boot and passed to everything. It holds the
wallet and signing client, the key players (yourself plus raid participants), struct
types, the current block height, map components, and assorted UI state.

**Mutation is uncontrolled.** Managers, GRASS listeners and view models all write to it
directly. There is no reducer and no immutability.

**Observation is via `window` CustomEvents.** There is no central event bus; setters
dispatch events and interested components listen on `window`:

```js
// src/js/models/KeyPlayer.js
setAlpha(alpha) {
  if (this.player && this.player.hasOwnProperty('alpha')) {
    this.player.alpha = parseInt(alpha);
    window.dispatchEvent(new SaveGameStateEvent());
    window.dispatchEvent(new AlphaCountChangedEvent(this.playerType));
  }
}
```

Event names live in `src/js/constants/Events.js` (50+ of them), each with a small
`CustomEvent` subclass in `src/js/events/`. Components subscribe in `initPageCode()` and
remove their listener when their DOM node is gone.

This is simple and it works, but it means **any code can change any state and the only
record of what changed is the event that happened to be dispatched**. If you are building
something you intend to maintain, a narrower state layer is worth the effort.

### What persists

`localStorage`, under `gameState`, holds only a thin slice: mnemonic, pubkey, player ID,
last-action block heights, charge levels, and the active map. Player objects, structs,
planets, guild data and struct types are **not** persisted — they are re-fetched at login.

Three other things also live in `localStorage`: router position (`currentMenuPage`,
`lastMenuPage`), a TTL cache of some API responses, and one-off migration flags.

> **The mnemonic is stored in plaintext.** No encryption, no passphrase. Any script that
> runs on the page can read the key that controls the account. Do not copy this. See
> [awareness/agent-security.md](../../awareness/agent-security.md) on key hygiene, and
> [SAFETY.md](../../SAFETY.md).

---

## The REST client

`src/js/api/GuildAPI.js` wraps `fetch` against `/api`, backed by the guild's PostgreSQL
read models rather than by chain queries directly — which is why it is fast enough for
search and pagination. See [knowledge/infrastructure/guild-stack.md](../../knowledge/infrastructure/guild-stack.md).

**Auth is a same-origin session cookie**, not a bearer token. Login POSTs a signed message
to `/api/auth/login`; Symfony verifies the signature, establishes a session, and every
later `/api/*` call is authenticated by the cookie that `fetch` sends automatically.

Every response is expected in one envelope:

```json
{ "success": true, "errors": [], "data": … }
```

`GuildAPIResponseFactory` throws `GuildAPIError` if any of the three keys is missing, and
`handleResponseFailure` throws if `success` is false.

> **HTTP status is never checked.** The `fetch` wrapper calls `response.json()`
> unconditionally, so a 401 or a 500 with a non-JSON body fails as an opaque JSON parse
> error rather than as the auth or server error it is. Check `response.ok` in your own
> client.

Representative endpoints:

| Purpose | Endpoint |
|---|---|
| Bootstrap | `GET /api/guild/this`, `GET /api/setting` |
| Auth | `POST /api/auth/signup`, `POST /api/auth/login`, `GET /api/auth/logout` |
| Player | `GET /api/player/{id}`, `GET /api/player/{id}/action/last/block/height` |
| Structs | `GET /api/struct/player/{id}`, `GET /api/struct/type` (cached 24h) |
| Fleet and planets | `GET /api/fleet/player/{id}`, `GET /api/planet/{id}` |
| Raid search | `GET /api/player/raid/search?…` and `…/count` |
| Guild | `GET /api/guild/{id}/roster` |
| Ledger | `GET /api/ledger/player/{id}/page/{page}` |
| Outstanding work | `GET /api/work/player/{id}` |

That last one matters more than it looks: it is how proof-of-work tasks survive a page
reload. See [work-and-pow.md](work-and-pow.md#restoring-after-a-reload).

Many more read endpoints exist in the Symfony controllers than are wrapped in
`GuildAPI.js`. If something you need is missing from the JS client, check the PHP side
before concluding it isn't available.

---

## Factories

The convention is one factory per model in `src/js/factories/`, each with
`make(obj)` and an inherited `parseList(list)`:

```js
// src/js/framework/AbstractFactory.js
export class AbstractFactory {
  make(obj) { throw new NotImplementedError(); }
  parseList(list) { return list.map(this.make); }
}
```

Beyond numeric coercion, factories are where nested structures get parsed —
`PlayerFactory` builds `PfpClientRenderAttributes` from JSON, `StructFactory` runs
`JSON.parse` on `defending_struct_ids`, `StructTypeFactory` on its ambit arrays.

**GRASS bypasses factories entirely.** Listeners take `messageData.value` and hand it
straight to a setter. That is the root of the scale inconsistency above, and it is worth
fixing on your own event path rather than reproducing.

---

## Bootstrap order

```
gameState.load()                    // restore localStorage, rebuild wallet from mnemonic
  ↓
guildAPI.getSettings()              // chain params
guildAPI.getThisGuild()             // guild identity
  ↓
authManager.login(playerId)         // player, structs, fleet, planet, struct types
  ↓  registers GRASS listeners
  ↓  initSigningClient() → restores the persisted signing queue
  ↓  restoreTasksFromDB() → respawns proof-of-work from GET /api/work/player/{id}
  ↓
router.restore()                    // return to the last page
```

The ordering matters. GRASS listeners must be registered before the client starts acting,
and the signing queue must know the confirmed last-action height before it releases any
charged transaction — otherwise it would compute charge against a default of `0` and
conclude it had a full bar. See
[actions-and-signing.md](actions-and-signing.md#charge-gating).

---

*Verified against structs-webapp `6eec7f7` (2026-07-21): `src/js/models/GameState.js`,
`src/js/api/GuildAPI.js`, `src/js/factories/`.*
