---
meta_description: Subscribe to GRASS over NATS instead of polling. Endpoint discovery, subject patterns, event types, and building custom listeners.
name: structs-streaming
description: Connects to the GRASS real-time event system via NATS WebSocket. Use when you need real-time game updates, want to react to events as they happen, need to monitor raids or attacks, watch for player creation, track fleet movements, or build event-driven tools. GRASS is the fastest way to know what's happening in the galaxy.
level: advanced
domain: infra
---

# Structs Streaming (GRASS)

GRASS (Game Real-time Application Streaming Service) delivers real-time game events over NATS. Instead of polling queries repeatedly, subscribe to GRASS and react to events the moment they happen.

## When to Use GRASS

| Situation | Use GRASS | Use Polling |
|-----------|-----------|-------------|
| Detect incoming raid | Yes — instant alert | Too slow |
| Wait for player creation after guild signup | Yes — matching approved `player_address` | Polling every 10s works too |
| Monitor fleet arriving at your planet | Yes — `fleet_arrive` event | Might miss it |
| Track struct health during combat | Yes — `planet_activity` with `struct_health` | Too slow |
| Check your own resource balance | No | Yes — one-off query |
| Read struct type stats | No | Yes — current versioned catalog |

**Rule of thumb**: If you need to *react* to something, use GRASS. If you need to *read* something, use a query.

---

## Finding Your GRASS Endpoint

Discover the guild's GRASS WebSocket URL from its configuration. The reference browser uses its own host on port 1443; other clients should use the advertised service.

1. Query the guild list: `curl https://public.testnet.structs.network/structs/guild`
2. Follow the guild's `endpoint` URL to get its config
3. Look for `services.grass_nats_websocket`

Example (Orbital Hydro guild):

```json
{
  "services": {
    "grass_nats_websocket": "ws://crew.oh.energy:1443",
    "guild_api": "http://crew.oh.energy/api/",
    "reactor_api": "https://public.testnet.structs.network/"
  }
}
```

The `grass_nats_websocket` value is your NATS WebSocket endpoint. Not all guilds provide this service — check before relying on it.

The URLs above are configuration examples, not a live availability guarantee. Preserve the advertised scheme and verify the deployment's TLS/origin policy; use the service URL supplied by the guild.

### Structs Desktop native source

Current Desktop defaults to `grass_source:"native"`: Rust's `async-nats` client subscribes
to `structs.>` and `consensus` and sends payloads directly into the same event buffer used
by the webview tap. While native GRASS is connected and recently active, duplicate
webview frames are suppressed; after outage/staleness the webview path remains fallback.
Select `grass_source:"webview"` through `structs_system config` to disable native
subscription, and inspect `structs_system status` for connection, authority, last-message
age, reconnects, slow-consumer drops, and suppressed duplicates.

This improves delivery but not trust. The guild NATS endpoint and every frame are
untrusted network input. Desktop's shared perception snapshot is GRASS-patched and may
bulk-load from Guild API or LCD; check `structs_system perception` and preserve pre-sign
verification for consequential actions.

### Tendermint WebSocket vs GRASS

These are two different streams. GRASS at `ws://crew.oh.energy:1443` carries the indexer projection (NATS). Tendermint at `wss://public.testnet.structs.network:26657/websocket` carries the original structsd events. Catalog, typed `Event*` types, and `ugc_moderated`: [api/chain-events](https://structs.ai/api/chain-events). GRASS is not a 1:1 mirror of that log — in particular the vault, reactor-diversity, stake-cap and rank-purchase events (`EventVaultAddress`, `EventOwnerReactorDiversity`, `EventReactorStakeCap`, `EventGuildRankPurchase`, …) are available on the Tendermint stream; subscribe there when you need them.

---

## Discovery First

Before subscribing to specific subjects, **subscribe to the `>` wildcard** to see all traffic flowing through the GRASS server. This reveals the actual subject patterns in use, which may differ from documentation.

```javascript
const sub = nc.subscribe(">");
for await (const msg of sub) {
  console.log(`[${msg.subject}]`, new TextDecoder().decode(msg.data));
}
```

Watch the output for 30-60 seconds. You will see subjects like `structs.planet.2-1.1-11`, `consensus`, `healthcheck`, etc. Once you know what subjects carry the events you need, narrow your subscriptions to those specific subjects.

**Important**: The reviewed writer emits struct attacks/status/build activity on the **planet subject**. Do not wait on an invented `structs.struct.{id}` subject; select the struct's planet and filter its event detail.

---

## Subject Patterns

Subscribe to subjects matching the entities you care about:

| Entity | Wildcard | Specific | Example |
|--------|----------|----------|---------|
| Player | `structs.player.>` | `structs.player.{guild_id}.{player_id}` | `structs.player.0-1.1-11` |
| Planet | `structs.planet.>` | `structs.planet.{planet_id}.{player_id}` | `structs.planet.2-1.1-11` |
| Guild | `structs.guild.*` | `structs.guild.{guild_id}` | `structs.guild.0-1` |
| Address | `structs.address.register.*` | `structs.address.register.{code}` | -- |
| Inventory | `structs.inventory.>` | `structs.inventory.{denom}.{guild_id}.{player_id}.{address}` | Token movements |
| Grid | `structs.grid.>` | `structs.grid.{object_type}.{object_id}.{player_id}` | Attribute changes (ore, power, load, etc.) |
| Consensus | `consensus` | `consensus` | Chain consensus events |
| Healthcheck | `healthcheck` | `healthcheck` | Node health status |

**Grid and planet subjects end with the owning `player_id`** (added 2026-07-07): grid is `structs.grid.{object_type}.{object_id}.{player_id}` and planet is `structs.planet.{planet_id}.{player_id}`. When the owner can't be resolved the segment is the literal `noPlayer`. This lets you filter by owner from the subject alone — but mind the NATS wildcard rule: **`*` matches exactly one token, `>` matches one or more trailing tokens.** So `structs.planet.*` no longer matches (that's only two tokens); use `structs.planet.{planet_id}.*` for one planet (any owner) or `structs.planet.>` for all. The player subject (`structs.player.{guild_id}.{player_id}`) is likewise three tokens — use `structs.player.>`, not `structs.player.*`.

Use wildcards to discover what events exist. Narrow to specific subjects once you know what you need. Use `>` to see everything (see "Discovery First" above).

---

## Event Types

### Planet Events

| Event | Description | React By |
|-------|-------------|----------|
| `raid_status` | Raid lifecycle on planet — status values include `shieldsVulnerable` (defender's shields down, raid can now complete), `ongoing`, and completed | Restore shields (Command Ship online, fleet on station); activate defenses, alert |
| `shield_change` | Planetary shield value changed (`planetary_shield` / `planetary_shield_old` in `detail`) | Recompute raid feasibility against the target |
| `block_raid_start` | The planet's raid vulnerability clock (`blockStartRaid`) armed | Note the raid window opened (yours: defend; theirs: a raid may be incoming) |
| `struct_health` | A struct's HP changed (`health` / `health_old`) | Track combat damage live |
| `struct_status` | A struct went online / offline / destroyed | Rebuild, reallocate power |
| `fleet_arrive` | Fleet arrived at planet | Prepare defense or welcome |
| `fleet_depart` | Fleet left planet | Update threat assessment |

All of the above (and the struct categories below) are `planet_activity` rows that arrive on the **planet subject** `structs.planet.{planet_id}.{player_id}` (subscribe with `structs.planet.{planet_id}.*`). `struct_health`, `struct_status`, `shield_change`, `raid_status`, and `fleet_arrive`/`fleet_depart` are the *effect* events that fire during combat — see the stub note under [Combat Event Payloads](#combat-event-payloads) for how to retrieve full `struct_attack` detail when a notification is stubbed.

For raid settlement, `raid_status` with `status: raidSuccessful` is the authoritative GRASS outcome signal; corroborate with player ore/state deltas. Desktop's `tx_settled` is not a GRASS category and is not guaranteed when a PoW worker auto-submits the completion outside the MCP action bridge. If you need the missing hash, query the transactions at the success block and match `EventHashSuccess(category=raid)` with `EventRaid(status=raidSuccessful)` as described in [chain events](https://structs.ai/api/chain-events#recovering-a-pow-completion-transaction-hash).

### Struct Events

**Note**: Subscribe to the **planet subject** `structs.planet.{planet_id}.*` for struct activity. Refetch current structs after reconnect or a missing detail row.

| Event | Description | React By |
|-------|-------------|----------|
| `struct_attack` | Struct was attacked | Counter-attack, repair |
| `struct_status` | Struct status changed (online/offline/destroyed) | Rebuild, reallocate power |
| `struct_defense_add` / `struct_defense_remove` | Defense assignments changed | Update defense map |
| `struct_defender_clear` | All defense relationships cleared | Re-assign defenders |
| `struct_block_build_start` | Build operation initiated | Track in job list |
| `struct_block_ore_mine_start` | Mine operation initiated | Track in job list |
| `struct_block_ore_refine_start` | Refine operation initiated | Track in job list |

### Player Events

| Event | Description | React By |
|-------|-------------|----------|
| `player_consensus` | Player state updated (including `username`/`pfp` on `structs.player` after chain UGC) | Update intel |
| `player_address` | An address was added to / changed on a player | Track multi-address / delegate setup |
| `player_address_pending` | A pending address registration appeared (awaiting confirmation) | Watch for registration completion |

### Guild Events

| Event | Description | React By |
|-------|-------------|----------|
| `guild_consensus` | Guild chain data updated | Update guild status |
| `guild_meta` | Off-chain guild metadata changed (`description`, `tag`, `logo`, `services` on `structs.guild_meta`) | Update intel |
| `guild_membership` | Member joined/left guild | Update relationship map |

### UGC Moderation Events

UGC name/pfp updates emit two distinct streams:

1. **GRASS DB-trigger events** (the table above): `player_consensus` fires when sync-state commits player UGC (`username`/`pfp` on `structs.player`). `guild_meta` fires for off-chain guild config updates. Chain UGC `name`/`pfp` on guilds live on `structs.guild`. Planet and substation UGC reach observers via chain events and `planet_activity` entries.
2. **Cosmos chain event `ugc_moderated`** — emitted by the keeper directly (untyped `sdk.Event`, not GRASS). Fires only when the actor of the update is **not** the target object's owner (i.e. only on guild-moderation overrides, never on self-service updates). Subscribe and attributes: [api/chain-events](https://structs.ai/api/chain-events). Validation rules: `knowledge/mechanics/ugc-moderation.md`.

### Inventory Events

Notifications invalidate a committed read; they are not balance deltas or payment
receipts. Read exact spendable vault funds and complete positions through the event
or inclusion height, preserving API readiness metadata. Coalesce duplicates and
refresh after reconnect/resume; Core NATS does not replay missed messages.

The ledger trigger resolves canonical `owner_type`, `owner_id`, `is_vault` and
counterparty ownership. Exact helpers include `amount_p_exact`, `id_exact` and
`block_height_exact`. A guild vault keeps a guild owner and uses `noPlayer` in the
subject; do not assign it to the guild leader. Dotted synthetic denominations add
subject tokens, so match the complete denomination rather than fixed offsets.

Infusion changes separately invalidate `structs.grid.player.{owner_id}` or
`structs.grid.guild.{owner_id}` with `invalidates: "infusion"` and
`notification_owner_type`/`notification_owner_id`. Reassignment invalidates both old
and new owners. Exact values do not authorize arithmetic over incomplete state.


Subject: `structs.inventory.{denom}.{guild_id}.{player_id}.{address}`

Track token movements — Alpha Matter, guild tokens, ore, etc.

| Category | Description | React By |
|----------|-------------|----------|
| `sent` | Tokens sent from this player | Update balance tracking |
| `received` | Tokens received by this player | Update balance tracking |
| `seized` | Tokens seized via raid | Trigger counter-raid or refine alert |
| `mined` | Ore mined | Start refining immediately |
| `refined` | Ore refined into Alpha | Update wealth tracking |
| `minted` | Guild tokens minted | Track guild economy |
| `infused` | Alpha infused into reactor/generator | Update capacity tracking |
| `forfeited` | Tokens lost (penalties, etc.) | Investigate cause |

### Grid Events

Subject: `structs.grid.{object_type}.{object_id}.{player_id}`

Track attribute changes on any game object (players, structs, planets). Every grid payload also carries a top-level `player_id` field (the resolved owner, or `noPlayer`).

| Category | Description | React By |
|----------|-------------|----------|
| `capacity` | Power capacity changed | Check if approaching offline |
| `connectionCapacity` | Connection capacity changed | Update power routing |
| `connectionCount` | Connection count changed | Update power routing |
| `fuel` | Fuel level changed | Monitor generator/reactor |
| `lastAction` | Last action timestamp updated | Track activity |
| `load` | Power load changed | Check if approaching offline |
| `nonce` | Player nonce incremented | Detect activity (useful for scouting) |
| `ore` | Ore balance changed | **Refine immediately** if yours; raid target if theirs |
| `player_consensus` | Player consensus data updated | Update intel |
| `power` | Power level changed | Monitor energy infrastructure |
| `proxyNonce` | Proxy nonce changed | Detect proxy activity |
| `structsLoad` | Structs load changed | Assess fleet strength changes |
| `allocationPointerStart` / `allocationPointerEnd` | Energy allocation range pointers changed | Track allocation/substation routing |
| `ready` | Object readiness flag changed | Track object availability |
| `checkpointBlock` | Checkpoint block updated | Track grid bookkeeping |

Grid categories are the attribute name itself (e.g. `ore`, `load`), carried on `structs.grid.{object_type}.{object_id}.{player_id}` — not `grass_category` values. For an `object_type` of `player` the owner is the object itself, so the subject reads `structs.grid.player.{id}.{id}`.

### Combat Event Payloads

The PostgreSQL notification trigger emits a keyed stub when a planet activity payload
is too large for `NOTIFY`. A stub contains `subject`, `category`, `planet_id`,
`player_id`, `seq`, `time`, and `stub: "true"`; it has no `detail`. Accept both the
string and boolean forms of `true`. Small attacks contain their full detail inline.

Fetch a stub with the authenticated Guild API:

```text
GET /api/planet-activity/planet/{planet_id}/event/{seq}?time={URL-encoded-original-time}
```

Keep the original timestamp string, including microseconds and timezone. Do not
round-trip it through JavaScript `Date`, which loses precision. The exact lookup
returns one object in `data`, with object-valued `detail`, or `data: null` when the
row is absent. Validate its planet, sequence, time and category against the stub.
Never substitute the first row of the latest activity page. See the
[exact event contract](https://structs.ai/api/webapp/planet-activity#exact-event-lookup).

Await hydration before processing the next event on that planet's stream. Drop a
late reply after the player/session or observed planet changes. A missing row or
failed read means detail is unavailable; it is not successful combat. Re-fetch
current state after gaps. NATS notifications do not provide durable replay.

`detail.attackerStructId` identifies the attacker;
`detail.eventAttackShotDetail[]` contains one row per projectile. Unit type names
and enum labels are strings in the notification JSON; separate `*StructTypeId`
fields identify types. Numeric quantities normally arrive as decimal strings.
See the [captured event shape](https://structs.ai/api/integration-notes#struct_attack-event-detail-schema).

Health and damage have different meanings:

- `damageDealt` records the projectile's rolled damage. `damage` is the net volley
  damage, carried by the final projectile row; it is not another per-shot amount.
- `attackerHealthBefore/After/Max`, `targetHealthBefore/After/Max` and
  `blockerHealthBefore/After/Max` are observed health. Overkill and rebound mean
  subtracting `damageDealt` is not a replacement for the observed values.
- A target can counter and then die to the attacker's explosion. Play the counter
  before the later destruction even when `targetDestroyed` is true. For that
  counter, the target's interim health is `targetHealthBefore - damage`, clamped
  at zero, or unchanged when blocked/evaded. Then apply `targetHealthAfter`.
- `blockedByStructId` identifies a blocker. `targetCountered` and
  `targetCounteredDamage` describe a target counter; defender counters are in
  `eventAttackDefenderCounterDetail[]`.

`struct_health` activity detail uses `struct_id`, `health`, and `health_old`.
The writer omits a zero-health activity row, so also consume `struct_status` and
refresh the struct; do not wait for a final `struct_health: 0` notification.
Effects and hydrated attack detail complement each other. They are not proof that
an unrelated pending transaction committed.

### Noise Filtering

The `consensus` and `healthcheck` subjects fire constantly (every few seconds). When using the `>` wildcard for discovery, filter these out to see actual game events:

```javascript
const sub = nc.subscribe(">");
for await (const msg of sub) {
  if (msg.subject === "consensus" || msg.subject === "healthcheck") continue;
  console.log(`[${msg.subject}]`, new TextDecoder().decode(msg.data));
}
```

### Consensus Events

| Event | Description | React By |
|-------|-------------|----------|
| `block` | New block produced | Tick game loop, update charge calculations |

---

## Building Event Listener Tools

Agents should build custom tools that connect to GRASS when they need event-driven behavior. Here are patterns to follow.

### Minimal Node.js Listener

Install the NATS WebSocket client:

```bash
npm install nats.ws
```

```javascript
import { connect } from "nats.ws";

const nc = await connect({ servers: "ws://crew.oh.energy:1443" });

// Subjects end with the owner player_id, so match any owner with a trailing *
const sub = nc.subscribe("structs.planet.2-1.*");
for await (const msg of sub) {
  const event = JSON.parse(new TextDecoder().decode(msg.data));
  console.log(JSON.stringify(event));
}
```

### Minimal Python Listener

Install the NATS client:

```bash
pip install nats-py
```

```python
import asyncio, json, nats

async def main():
    nc = await nats.connect("ws://crew.oh.energy:1443")
    sub = await nc.subscribe("structs.planet.2-1.*")  # trailing * = any owner player_id
    async for msg in sub.messages:
        event = json.loads(msg.data.decode())
        print(json.dumps(event))

asyncio.run(main())
```

### Raid Alert Tool (example pattern)

A tool that watches for raids on your planet and outputs an alert:

```javascript
import { connect } from "nats.ws";

const PLANET_ID = process.argv[2]; // e.g. "2-1"
const nc = await connect({ servers: "ws://crew.oh.energy:1443" });
const sub = nc.subscribe(`structs.planet.${PLANET_ID}.*`); // trailing * = any owner player_id

for await (const msg of sub) {
  const event = JSON.parse(new TextDecoder().decode(msg.data));
  if (event.category === "raid_status") {
    console.log(JSON.stringify({ alert: "RAID", planet: PLANET_ID, data: event }));
  }
  if (event.category === "fleet_arrive") {
    console.log(JSON.stringify({ alert: "FLEET_ARRIVAL", planet: PLANET_ID, data: event }));
  }
}
```

### Player Creation Watcher (example pattern)

Listen for the new address's indexed approval, then query native/indexed state to
confirm it. The short-code subject carries pending device consent, not new-player
completion.

```javascript
import { connect } from "nats.ws";

const [endpoint, guildId, address] = process.argv.slice(2);
const nc = await connect({ servers: endpoint });
const sub = nc.subscribe(`structs.player.${guildId}.*`);
for await (const msg of sub) {
  const event = JSON.parse(new TextDecoder().decode(msg.data));
  if (event.category !== "player_address" || event.address !== address
      || event.guild_id !== guildId || event.status !== "approved") continue;
  console.log(JSON.stringify({ address, player_id: event.player_id }));
  break;
}
await nc.close();
```

Add a bounded deadline and query fallback for a production workflow: a missed
notification must not strand signup. Existing-player device activation uses the
[activation UUID and native nonce proof](https://structs.ai/api/webapp/player-address).
Refetch pending consent through its owner-scoped API; an incoming notification must
not silently grant a device authority.

---

## When to Build a Custom Tool

Build a GRASS listener tool when:

- **You need to wait for an event** — guild signup completion, fleet arrival, raid detection
- **You need continuous monitoring** — threat detection during vulnerable ore window, combat tracking
- **You want an event-driven game loop** — react to block events instead of polling on a timer
- **You're managing multiple players** — one GRASS connection can monitor all your entities simultaneously

Store custom tools in your workspace (e.g., `scripts/` or alongside the relevant skill).

---

## Connection Best Practices

- **Use specific subjects** once you know what you need. Wildcards are for discovery.
- **Limit to 10-20 subscriptions** per connection to avoid overwhelming the client.
- **Implement reconnection** with exponential backoff — NATS connections can drop.
- **Parse JSON defensively** — not all messages may match expected schema.
- **Close connections** when done. Don't leave idle GRASS connections open.

---

## Procedure

### Quick Setup

1. Get the GRASS endpoint from your guild config (or use `ws://crew.oh.energy:1443`). For chain queries you can use the SSL endpoint `https://public.testnet.structs.network/structs/guild`.
2. Record the endpoint in [TOOLS.md](https://structs.ai/TOOLS) under Servers
3. Choose your language (Node.js or Python)
4. Install the NATS client library (`nats.ws` for Node, `nats-py` for Python)
5. Write a listener script for your specific use case
6. Run it in a background terminal

### For Ongoing Monitoring

1. Subscribe to your planet(s): `structs.planet.{id}.*` — raid alerts, fleet arrivals (trailing `*` matches any owner `player_id`)
2. Filter planet activity for your struct IDs — attack/status alerts
3. Subscribe to `consensus` — observed block ticks for game loop timing
4. Log events to [continuity memory](https://structs.ai/awareness/continuity) for cross-session awareness

---

## Automation Patterns (Defence Contractor)

The Structs permission system and GRASS event stream were designed for AI agents to automate game responses. The design docs call this the "Defence Contractor" pattern — an agent that monitors events and acts on behalf of players within scoped permissions.

### Common Automation Triggers

| Event | Action | Permission Needed |
|-------|--------|-------------------|
| `ore` grid change or current mine clock/work | Reconcile current refinery work and start approved computation | Required signing-key hash bit |
| `refined` inventory invalidation or current work | Refresh vault/work and continue the approved production plan | Required signing-key hash bit |
| `block_raid_start` / `raid_status` on your planet | Alert, activate stealth, reposition defenders | Signer key or delegated permission |
| `struct_attack` targeting your struct | Log attacker, assess threat, counter-attack if able | Signer key or delegated permission |
| `struct_health` showing HP drop | Prioritize defense, consider fleet retreat | Signer key for fleet-move |
| `fleet_arrive` at your planet from unknown fleet | Identify incoming player, assess threat level | Read-only (query) |

### Permission Scoping for Automated Agents

When delegating actions to an automation agent (separate key or service):

1. **Grant minimal permissions**: Use `permission-grant-on-object` to allow specific actions on specific structs, not blanket access.
2. **Separate keys**: The automation agent should use its own signing key, registered as a secondary address on the player via `address-register`.
3. **Verify effective authority**: The signing key's bits are a hard ceiling; an object grant cannot add a bit the key lacks. Use the canonical permission recipes and current native simulation.
4. **Revoke when not needed**: Use `permission-revoke-on-object` to remove automation access during sensitive operations.

### Example: Reconcile production after an event

```text
Subscribe to the player's ore grid and inventory subjects
On ore/clock/refined invalidation:
  → Fetch current, complete work and vault state through the event height
  → Keep original work anchors and current difficulty rules
  → Adopt any existing uncertain completion transaction
  → Start only missing, approved computation
On reconnect or a bounded periodic check:
  → Repeat the same reconciliation
```

Run mining and refining according to the [production skill](/skills/structs-production/SKILL.html).
Events do not eliminate exposed ore or establish transaction success. Preserve the
commander's signing/automation approval policy when building an unattended tool.

### Example: Defend-on-Raid-Detected

```
Subscribe to: structs.planet.{planet-id}.*
On event: block_raid_start or raid_status
  → Activate stealth on vulnerable structs
  → Set defenders on high-value structs
  → Log raid to memory/intel/threats.md
  → Alert commander if available
```

### Safe Boundaries

- **Never auto-spend Alpha** without commander approval (infusion, guild-bank operations)
- **Never auto-move fleets** away from defended planets without threat assessment
- **Always log actions** to `memory/` for cross-session audit trail
- **Rate-limit reactions** — one transaction per ~6 seconds per key (sequence number constraint)

---

## See Also

- [protocols/streaming](https://structs.ai/protocols/streaming) — Full GRASS/NATS protocol specification
- [api/streaming/event-types](https://structs.ai/api/streaming/event-types) — Complete event type catalog
- [api/streaming/event-schemas](https://structs.ai/api/streaming/event-schemas) — JSON schema definitions for event payloads
- [api/streaming/subscription-patterns](https://structs.ai/api/streaming/subscription-patterns) — Subscription patterns and examples
- [awareness/async-operations](https://structs.ai/awareness/async-operations) — Background operations and pipeline strategy
- [awareness/threat-detection](https://structs.ai/awareness/threat-detection) — Using GRASS for early warning
