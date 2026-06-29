# Integration Notes: Live Data Shapes & Gotchas

**Purpose**: Hard-won, verified notes for anyone building against the live Structs chain and Guild API (bots, MCP servers, dashboards). These are the data-shape and endpoint details that cause silent integration bugs. Each note is tagged with where it was verified.

> Scope: this page is about the **game API / proto / data shapes**. For the proof-of-work mechanism see [hashing.md](../knowledge/mechanics/hashing.md); for combat math see [combat.md](../knowledge/mechanics/combat.md).

---

## Live Endpoints (public testnet)

The public testnet exposes the standard Cosmos surfaces over TLS. There is **no port `1317`** on the public host — that port is local-devnet only.

| Surface | URL | Notes |
|---------|-----|-------|
| REST (LCD) | `https://public.testnet.structs.network` | Standard HTTPS, **no port**. `http://...:1317` is dead (connection refused). |
| Tendermint RPC | `https://public.testnet.structs.network:26657` | Block, tx, status |
| gRPC | `public.testnet.structs.network:9090` | If exposed for your tooling |
| Local devnet LCD | `http://localhost:1317` | Only when you run your own node (see [local-devnet.md](../reference/local-devnet.md)) |

**Caveat — not every LCD query is implemented.** Some module queries return gRPC `code 12` ("Not Implemented") on the deployed testnet build (observed for `GET /structs/structs/struct_type/...`). When an LCD route 501s, fall back to the CLI (`structsd query structs ...`) or the Guild Stack PostgreSQL mirror. Do not assume a 501 means a bad URL.

The query docs under [api/queries/](queries/) use `http://localhost:1317` as a generic base — substitute the live HTTPS base above for testnet.

---

## Guild API: numeric fields are JSON strings

The Guild API serializes **numeric fields as JSON strings**, not numbers. Naive numeric use (`a + b`, comparisons) silently misbehaves.

```json
{ "health": "6", "last_action_block_height": "1337217", "ore": "5", "load": "25000", "capacity": "1000000" }
```

Always coerce: `parseInt(x, 10)` for counts/heights, and **BigInt** for precise energy/capacity values (the client divides load/capacity/structs_load by an energy precision factor). Verified in webapp `src/js/factories/PlayerFactory.js` (`Number(BigInt(numberString) / BigInt(PRECISION))`) and `src/js/api/GuildAPI.js` (`parseInt(...)` on block heights and counts).

**Blanket rule:** treat every Guild API numeric as a string at the wire and convert explicitly.

Note this also applies to chain LCD responses: protobuf JSON serializes `uint64` fields as strings (e.g. address `permissions` below comes back as `"1"`).

---

## Event `detail` has two representations

The same activity event reaches you in two different encodings depending on the transport:

| Source | `detail` encoding | How to read |
|--------|-------------------|-------------|
| Guild API `planet-activity` feed (REST) | **JSON-encoded string** | `JSON.parse(row.detail)` before use |
| NATS / GRASS realtime stream | **already-parsed object** | use `message.detail.*` directly |

Verified: GRASS frames are parsed once via `message.json()` in webapp `src/js/framework/GrassManager.js`, and listeners access `messageData.detail.*` as an object. The REST `planet-activity` rows come straight from a PostgreSQL `detail` column and arrive as a JSON string. An integrator consuming **both** must branch on the source.

There is also a **field-casing split** inside `detail`: most struct events use snake_case keys (`struct_id`, `defender_struct_id`), but `struct_attack` uses camelCase (see next section).

---

## `struct_attack` event detail schema

Attacker context is **flat at the top** of `detail`; the per-shot outcomes are in a **nested array** `eventAttackShotDetail[]`. (Verified against webapp `src/js/ts/structs.structs/types/structs/structs/events.ts` `EventAttackDetail` / `EventAttackShotDetail`.)

```jsonc
// detail (flat attacker block)
{
  "attackerStructId": "5-1",
  "attackerStructType": 2,
  "attackerStructOperatingAmbit": 4,        // ambit ENUM (space=4) — see Ambit note below
  "weaponSystem": 0,
  "weaponControl": 1,
  "recoilDamage": 0,
  "recoilDamageToAttacker": false,
  "planetaryDefenseCannonDamage": 0,
  "attackerPlayerId": "1-11",
  "targetPlayerId": "1-22",
  "eventAttackShotDetail": [                 // nested: one entry PER PROJECTILE
    {
      "targetStructId": "5-3",
      "targetStructType": 3,
      "evaded": false,
      "evadedCause": 0,
      "blocked": false,
      "blockedByStructId": "",
      "damageDealt": 2,
      "damage": 2,
      "damageReduction": 0,
      "targetDestroyed": false,
      "targetCountered": false,
      "targetCounteredDamage": 0
    }
  ]
}
```

Notes:
- `attackerHealthBefore` / `targetHealthBefore` / `targetHealthAfter` appear as **runtime-enriched** fields on the live activity feed (used for animation); they are not in the canonical protobuf type. Health values may arrive as strings (coerce).
- Evasion is per-target (the whole volley); hit/miss is per-projectile (per `eventAttackShotDetail` entry).
- A struct counters at most once per `struct-attack` invocation; defender counters nest under `eventAttackDefenderCounterDetail[]` inside each shot.

See [combat.md](../knowledge/mechanics/combat.md#attack-resolution-sequence) for the resolution order and [api/streaming/event-schemas.md](streaming/event-schemas.md) for the event catalog.

---

## Where struct HP and status live

Struct **health** and the numeric **status bitmask** are NOT on the base struct row. They live in `struct_attribute` rows and are only joined by some endpoints.

| Source | Returns `health`? | Returns numeric `status`? |
|--------|-------------------|---------------------------|
| Guild API catalog `GET /api/struct/list/{all\|owner\|location}/...` | No | No |
| Guild API bespoke `GET /api/struct/player/{id}`, `GET /api/struct/{id}` | **Yes** (joined, default 0) | **Yes** (joined, default 0) |
| Chain LCD struct entity (`GET /structs/struct/{id}`) | Yes (`structAttributes.health`) | Yes (`status`) |

The catalog list endpoints return only base columns: `id, index, type, creator, owner, location_type, location_id, operating_ambit, slot, is_destroyed, destroyed_block, created_at, updated_at` (verified in webapp `TableReadManager::structListAll/ByOwner/ByLocation`). To get HP, built-state, or the build clock you must use a bespoke endpoint or the chain entity, where `structAttributes` exposes `health`, `isBuilt`, `blockStartBuild`, and `status`.

The numeric `status` is a `StructState` bit-flag, not an enum. Decode it with the canonical table in [building.md — Status field (numeric)](../knowledge/mechanics/building.md#status-field-numeric) (Online = `status & 4`, Destroyed = `status & 32`; e.g. `35` is a destroyed struct). The catalog list's `is_destroyed` boolean is the only destruction signal on the base row.

See [api/webapp/struct.md](webapp/struct.md) for full response shapes.

---

## `/structs/address/{addr}` response shape

The chain LCD address query returns a flat object with **`playerId` top-level (camelCase)** — not nested under an `Address` wrapper:

```json
{ "address": "structs1...", "playerId": "1-11", "permissions": "1" }
```

Verified in `proto/structs/structs/query.proto` (`QueryAddressResponse { string address; string playerId; uint64 permissions; }`, route `/structs/address/{address}`). `permissions` is a `uint64` → serialized as a string. A common polling bug is looking for the player id under a nested key; it is top-level.

---

## Field-name traps

- **The `rate` infix.** Weapon shot-success fields are `primaryWeaponShotSuccessRate{Numerator,Denominator}` / `secondaryWeaponShotSuccessRate{Numerator,Denominator}` — note **`Rate`** in the middle. Mis-keying as `primaryWeaponShotSuccess{Numerator,Denominator}` reads `undefined`/null and **silently zeroes your combat math**. Verified in `proto/structs/structs/struct.proto` (fields 22/23, 34/35).
- **Casing varies by source.** The chain LCD/CLI proto JSON uses **camelCase** (`primaryWeaponShotSuccessRateNumerator`). The Guild Stack PostgreSQL / Guild API uses **snake_case** column names (`primary_weapon_shot_success_rate_numerator`). Key your parser to the source you are reading.
- **Guaranteed shots is `omitempty`.** `primaryWeaponGuaranteedShots` / `secondaryWeaponGuaranteedShots` exist on `StructType` (fields 67/68) but are `0` for every type except the Starfighter secondary (`= 1`), and zero values are omitted from JSON. A `struct_type` payload with no guaranteed-shots key does not mean the field was removed — it means the value is 0. See [combat.md](../knowledge/mechanics/combat.md#multi-shot-damage).

---

## Ambit: enum vs reach bitmask

There are **two different ambit numbering schemes**; conflating them produces an `invalid int32` error on build.

| Scheme | Values | Used by |
|--------|--------|---------|
| **Enum** | none=0, water=1, land=2, air=3, space=4, local=5 | Transaction messages: `MsgStructBuildInitiate.operatingAmbit`, `MsgStructMove.ambit`; a struct's stored `operatingAmbit` |
| **Reach bitmask** | none=1, water=2, land=4, air=8, space=16, local=32 | `StructType.possibleAmbit`, `primaryWeaponAmbits`, `secondaryWeaponAmbits` (weapon reach masks) |

When you build or move, pass the **enum** (the CLI accepts the lowercase name `space|air|land|water`, which maps to enum 4/3/2/1). The bitmask values (2/4/8/16) are only for interpreting `possibleAmbit` and weapon-reach fields. Verified in `proto/structs/structs/keys.proto` (enum) and `x/structs/types/keys.go` (`Ambit_flag` bitmask). See [building.md](../knowledge/mechanics/building.md#ambit-encoding).

---

## Charge is not a pool

`charge = currentBlock - lastActionBlock`, per-player, and **any** charge-consuming action resets it to **0**. The per-action "cost" is a *minimum threshold*, not a balance you draw down or bank. You cannot stockpile charge to burst several expensive actions; idling past your next action's cost gains nothing. Plan combat as single actions spaced ~1 block per charge apart. A dashboard "Charge: N" is the current `currentBlock - lastActionBlock`, not a wallet. See [building.md](../knowledge/mechanics/building.md#charge-accumulation).

---

## `capacity_exceeded` covers two different build checks

`struct-build-initiate` raises one error string — `cannot handle new load requirements (required: X, available: Y)` (structured error key `capacity_exceeded`) — for **two** unrelated gates. The numbers tell them apart:

| `required` / `available` look like | Gate | Meaning |
|------------------------------------|------|---------|
| Tiny integers, often equal (e.g. `1 / 1`) | **Per-player build limit** | `required` is the struct type's build limit, `available` is how many you already own. Most planet structs and the Command Ship cap at 1; only Orbital Shield Generator, Ore Bunker, and fleet combat structs stack. |
| Large values (hundreds of thousands to millions) | **Power capacity** (milliwatts) | `required` is the struct's `BuildDraw`, `available` is remaining capacity `(capacity + capacitySecondary) - (load + structsLoad)`. |

Do not assume the error is always about power — a `1/1` is the build-count limit, not a power shortage. Verified in `x/structs/keeper/msg_server_struct_build_initiate.go` (build-count and `CanSupportLoadAddition` checks) and `x/structs/types/errors_structured.go` (`capacity_exceeded`). See [building.md](../knowledge/mechanics/building.md#build-validation-order).

---

## Proxy signup is idempotent

The guild proxy signup flow (sign `GUILD{id}ADDRESS{addr}NONCE0` → `POST /api/auth/signup` → guild fronts `MsgGuildMembershipJoinProxy` → poll `/structs/address/{addr}` for the player id) is safe to re-run. Re-running for an address that already joined returns `{resource_already_exists}`. **Treat this as success** (adopt the existing player) rather than a hard failure. See [structs-onboarding](../.cursor/skills/structs-onboarding/SKILL.md).

---

## Guild API auth scope (public vs authenticated)

Almost everything under `/api/` requires an authenticated session (the `PlayerAuthenticator` checks `player_id` in the PHP session; missing → `401 {"authentication_error":"Login required"}`). Only these prefixes are **public** (firewall `security: false`), verified in webapp `config/packages/security.yaml`:

| Public prefix | Purpose |
|---------------|---------|
| `/api/auth/` | `signup`, `login`, `logout`, `activation-code/{code}` |
| `/api/guild/this` | This guild's metadata |
| `/api/timestamp` | Server time |
| `/api/setting` | Live tunables |
| `/api/pfp` | Profile images |

**Correction to a common assumption:** struct reads and the `planet-activity` feed are **not** public — `/api/struct/list/...`, `/api/struct/{id}`, `/api/planet-activity/...`, etc. all require a session. Authenticate first (see [api/webapp/auth.md](webapp/auth.md)) before any catalog or bespoke read.

---

## See Also

- [hashing.md](../knowledge/mechanics/hashing.md) — Proof-of-work input format and which block to anchor on
- [combat.md](../knowledge/mechanics/combat.md) — Combat math, ambit reach, guaranteed shots
- [api/webapp/struct.md](webapp/struct.md) — Struct endpoint response shapes
- [api/streaming/event-schemas.md](streaming/event-schemas.md) — Event catalog
- [reference/api-quick-reference.md](../reference/api-quick-reference.md) — Endpoint quick lookup
- [protocols/webapp-api-protocol.md](../protocols/webapp-api-protocol.md) — Envelope and pagination conventions
