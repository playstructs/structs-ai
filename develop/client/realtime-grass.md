---
description: "GRASS connection recovery, committed-state invalidation, exact combat hydration, listener scope, and notification limits."
---

# Real-time events with GRASS

GRASS transports committed database notifications through NATS. Use them to request
current state and drive captured activity; they are not a durable transaction receipt
or a complete balance history. The reference browser keeps its existing UI while
refresh managers reconcile funds, work and signing authority.

## Connection

`GrassManager` uses `@nats-io/nats-core` `wsconnect`. The stock browser constructs two
managers at `ws://{hostname}:1443`, without NATS credentials:

| Manager | Subscription | Purpose |
|---|---|---|
| `grassManager` | `structs.>` | Game and device notifications |
| `blockGrassManager` | `consensus` | Observed block clock |

Other clients discover the advertised guild service and its auth/TLS requirements;
do not infer a public host's current availability or rewrite its URL scheme.

NATS retries transient disconnections indefinitely with a two-second reconnect wait.
The outer supervisor handles closed/failed streams with backoff from one to thirty
seconds. Listener registrations survive reconnect. Resume/watchdog checks use the
shared consensus clock to detect a stale connection and avoid duplicate reconnects.
A quiet game subject alone does not mean the connection is dead.

Initial connection and NATS reconnect status dispatch `GRASS_CONNECTED`. Funds,
work and authority refresh managers use that signal for fresh reads. No new status
screen is implied. Core NATS does not backfill the gap merely because a socket
reconnected.

## One subscription, client-side filtering

Each manager has one NATS subscription. `GrassManager` decodes JSON, requires envelope
`subject` and `category`, then fans out to registered listeners. Listeners filter
scope/category themselves. Use narrower subjects for a custom client that does not
need the reference browser's broad subscription.

Representative reviewed paths:

| Subject | Meaning |
|---|---|
| `consensus` | Block notifications, independent of activity hydration |
| `structs.player.{guild_id}.{player_id}` | Player and indexed address updates |
| `structs.planet.{planet_id}.{player_id}` | Struct/combat/fleet/raid activity |
| `structs.grid.{object_type}.{object_id}.{player_id}` | Grid attribute notification |
| `structs.inventory.{denom}.{guild_id}.{player_id}.{address}` | Ledger invalidation with canonical owner metadata |
| `structs.grid.player.{owner_id}` | Player infusion invalidation |
| `structs.grid.guild.{owner_id}` | Guild infusion invalidation |
| `structs.address.register.{code}` | Pending consent for an existing player's new device |
| `structs.guild.{guild_id}` | Guild consensus/meta/membership-application notification |

Unresolved ownership can use `noPlayer`/`noGuild`. A guild vault's owner remains the
guild, not its leader. Dotted synthetic denominations create extra NATS tokens, so
do not parse inventory ownership by a fixed token offset. `*` matches one token;
`>` matches trailing tokens. Planet observers use `structs.planet.{planet_id}.*`.

Struct activity lives on the planet path; the reviewed triggers do not provide
separate `structs.struct.{id}` or `structs.fleet.{id}` activity subscriptions.
`consensus` is the block subscription, not `structs.global`.

## The listener contract

A listener supplies a unique `name`, synchronous `handler(messageData)` and optional
`shouldUnregister()`. Names are Map keys; re-registering a name replaces that listener.
Unregistration is checked immediately after the handler returns. Async work inside
a listener still needs its own stale-context/cancellation checks; a flag set later
is noticed on a later dispatch.

Current listener groups include:

| Group | Behavior |
|---|---|
| Block and last action | Update observed height and confirmed charge base |
| Player load/capacity/ore/shields | Update established display/state paths |
| `PlayerAlphaListener`, `AlphaChangeListener` | Request authoritative funds refresh; never apply balance deltas |
| `StructListener` | Refresh structs, reconcile build work, and render ordered combat effects |
| Mine/refine status listeners | Request current scoped work reconciliation |
| Raid/planet raid listeners | Maintain offensive/defensive raid state and relevant local work |
| Player created/new planet | Continue scoped onboarding/entity loading |
| Address revoked | Request a native ownership check for the active key, or refresh another device's list |

Economic/device completion is owned by its transaction observer and current evidence,
not the first similar-looking notification. Removed one-shot transfer/infusion/device
listeners are not an integration API to copy.

`RegistrationRefreshListener` gives pending-consent and registration-status observers a prompt read wakeup. It matches the current activation/device context, coalesces bursts and in-flight reads, and spaces notification-driven reads by at least one second. Polling still backs off from two to thirty seconds if notifications are lost. A wakeup never establishes successful approval or substitutes for the exact native nonce/owner and indexed association checks. Aborted observers unregister and cancel their timers.

## Refresh committed funds and work

`AlphaChangeListener` matches the current owner on inventory subjects and on explicit
infusion invalidations. It requests `AlphaRefreshManager` through
`block_height_exact` (or a supported legacy height). `PlayerAlphaListener` also
invalidates rather than assigning an unqualified grid balance.

The ledger trigger carries `amount_p_exact`, `id_exact`, `block_height_exact`,
canonical `owner_type`/`owner_id`/`is_vault` and counterparty ownership. Those fields
preserve precision; they do not establish that a client has every preceding event.
Infusion changes notify old/new/live owners with `invalidates: "infusion"`, including
reassignment and deletion. Refetch exact available-funds evidence and complete positions; a retained native refund is an invalidation, not permission to run a background sweep.

`AlphaRefreshManager` coalesces notifications, checks monotonic source heights, and
refreshes on resume/reconnect and visible polling. Work/catalog refresh similarly
uses coherent snapshots rather than notification anchors. `SessionAuthorityManager`
checks native ownership before treating a key as revoked. See
[state-and-data.md](state-and-data.md) for each manager's scope and cadence.

## Hydrate large planet activity before dispatch

PostgreSQL NOTIFY payloads are limited to 8 KB. A large attack can be a keyed stub
with `stub: true` or `stub: "true"`, carrying `planet_id`, `seq`, `time`, category
and subject without `detail`. The release's multi-target/projectile fixture exercises
this path through the actual writer, database, bridge and browser.

Fetch the exact row using the authenticated endpoint:

```text
GET /api/planet-activity/planet/{planet_id}/event/{seq}?time={URL-encoded-original-time}
```

Preserve the original timestamp string, microseconds and timezone. JavaScript Date
round-trips lose needed precision. The endpoint returns an object-valued `detail`
or null for a missing exact row. Match the full key and category; never substitute
the latest activity row.

`resolvePlanetActivityNotification` fetches only for a currently observed player and
planet, and discards late replies after session/account/planet changes.
`GrassManager` awaits hydration before dispatching the next message on that stream,
then also checks the connection identity. The independent consensus subscription
continues. Missing/malformed detail is skipped as unavailable, not converted into
an empty successful attack. General async listener work still is not globally ordered.

## Combat playback

Typed attack detail supplies rolled projectile damage, final net volley damage and
observed health; they are not interchangeable. A target can counter and then die from
the attacker's explosion. Render the counter at its intermediate health before the
later destruction, including blocked/evaded cases. Do not apply effect damage again
to indexed models; refresh involved structs.

A zero-health activity row is not guaranteed, so combine status/current-state reads
with attack detail. The [captured event reference](../../api/streaming/event-schemas.md)
and [exact event endpoint](../../api/webapp/planet-activity.md#exact-event-lookup)
define those payloads. The renderer fixture verifies actual animation completion,
queue drainage and final health for counter/rebound and large-event cases.

## What the stream will not do for you

- It has no durable replay or global client deduplication/gap recovery.
- Notification order is not a replacement for coherent SQL/native source heights.
- A balance, attack or address event does not prove an unrelated signed transaction
  committed. Match its durable hash/bytes and native execution result first.
- A connection event does not certify all displayed data as current. Reconcile the
  required scoped models, honoring incomplete/unavailable responses.
- Stale notifications or failed reads do not authorize a new send, reset a proof's
  original anchor, or erase a local key.

*Verified against webapp `581fcd0f`: GrassManager, PlanetActivityNotification,
AlphaChangeListener, PlayerAddressRevokedListener, current listener registration and
scoped refresh managers. Subject/ownership paths were checked against structs-pg
`400e1c1` and the bridge forwarding logic. Captured release-event transport and real
rendered hydration are separate from live deployment acceptance.*
