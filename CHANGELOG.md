# Changelog

All notable changes to the Structs Compendium documentation will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.21.0] - 2026-07-20

Raid shield-vulnerability doctrine, from a field report by **beezhan** (player `1-471`, guild SN Corp `0-5`) where an agent correctly read that a target's shields were up (defending Command Ship online) but treated it as a dead end — hunting for an already-vulnerable target instead of *creating* the vulnerable window by destroying the Command Ship, and conflating a 5-day-idle owner with a raidable one. Thanks to beezhan for the detailed report and the exact rejection message that let us reconcile the two error paths. Every claim source-verified against `structsd` v0.20.0 (`x/structs/keeper/{planet_cache,struct_cache,msg_server_planet_raid_complete}.go`, `x/structs/client/cli/tx_planet_raid_compute.go`). Docs describe current reality; only this changelog records history.

### Added

- **Two raid modes: opportunistic vs siege** — shield-vulnerability is now framed as a **state you can create**, not just wait for. New "Vulnerability is a state you can create" section (with a raid state diagram) and a promoted, step-by-step "Raid attack doctrine" (siege) in [`combat.md`](knowledge/mechanics/combat.md); a "Two ways to raid" section and a full **siege procedure** (move in → strip same-ambit blockers → destroy the Command Ship → compute) alongside the opportunistic one in the [`structs-combat`](.cursor/skills/structs-combat/SKILL.md) skill; a create-vulnerability branch in the Raid Flow of [`decision-tree-combat.md`](patterns/decision-tree-combat.md); and a `siege raid` term in [`glossary.md`](reference/glossary.md). Siege executability confirmed via `isReachable` (an away, first-in-queue fleet can attack the on-station defender's Command Ship) and the `CommandStructRaidStatusHook` → `RefreshRaidVulnerability` clock start.
- **"Idle is not vulnerable"** — a dormant owner (online is pure power math, not activity) keeps a powered Command Ship defending indefinitely, so inactivity/badges must never be read as raidability. New callout in [`combat.md`](knowledge/mechanics/combat.md), an `idle vs vulnerable` glossary term, and the strictly-negative **fleet-move trap** (moving onto a not-yet-vulnerable target drops your own shields for a raid that can't complete). Reinforced in the [`structs-intel`](.cursor/skills/structs-intel/SKILL.md) skill and [`opportunity-identification.md`](awareness/opportunity-identification.md).
- **`scout.sh` siege verdict** — [`scout.sh`](scripts/scout.sh) now returns `SIEGE CANDIDATE` (not a flat `NO-GO`) when shields are up but ore is present, surfaces the owner's `lastAction`/idle age, and prints an "idle != vulnerable" caution.

### Changed

- **The two raid rejection messages, reconciled** — documented that the CLI `planet-raid-compute` pre-check emits `"...shields are not vulnerable: no active raid window (defending Command Ship may still be online)"` when `blockStartRaid == 0` (the message a raider usually hits first), distinct from the chain-side `planet-raid-complete` codes `shields_active` / `raid_clock_unset`. Added as a side-by-side table in [`combat.md`](knowledge/mechanics/combat.md) and corrected in the [`structs-combat`](.cursor/skills/structs-combat/SKILL.md) skill's error list and [`decision-tree-combat.md`](patterns/decision-tree-combat.md).
- **Raid go/no-go reframed** — an online defending Command Ship is now a **siege decision** (can I reach and destroy it? is the ore worth my exposed home?), not a hard stop; the [`structs-intel`](.cursor/skills/structs-intel/SKILL.md) skill's "Stop here" was corrected, and the [`shieldsVulnerable`](reference/glossary.md) glossary entry cross-links siege/idle. [Transcript 02 — Raid Go/No-Go](examples/transcripts/02-raid-go-no-go.md) gains a dormant-target siege-evaluation variant so the reasoning is modeled, not omitted.

## [1.20.0] - 2026-07-17

Field-report documentation fixes across harvest lifecycle, on-chain portraits, onboarding/ante, economy, indexer, and combat visibility. Every item source-verified against `structsd` v0.20.0 (`x/structs/...`), the webapp, and `structs-pg`. Docs describe current reality; only this changelog records history.

### Added

- **Mine/refine cycle lifecycle** — new "Mine/Refine Cycle Lifecycle" section in [`hashing.md`](knowledge/mechanics/hashing.md): anchors set on activation (activation *is* the cycle start; no separate "begin mining" message), cleared on deactivate/offline, **never expire** (aged = cheaper, not wedged), completion auto-restarts the cycle, and ore is checked only at completion (a refinery can run with 0 ore and count ore that arrives mid-cycle). Reflected in the [`structs-production`](.cursor/skills/structs-production/SKILL.md) skill (parallel-pipeline tip + "don't clean up aged anchors" warning), the activate/deactivate/complete effects in [`schemas/actions.md`](schemas/actions.md), and the clock entry in [`glossary.md`](reference/glossary.md).
- **On-chain portrait convention** — documented the official webapp 5-layer avatar in [`ugc-moderation.md`](knowledge/mechanics/ugc-moderation.md): JSON **string** (`JSON.parse`) of `{head, neck, body, arms, background}`, paint order background→arms→body→neck→head, index ranges (head 1–87, neck 1–10, body 1–57, arms 1–34, background 1–6) as a client convention renderers must clamp, and asset path `/img/pfp/{part}/pfp_{part}_{index}.png`. Cross-linked from [`entities.md`](schemas/entities.md), [`validation.md`](schemas/validation.md), and the stale [`entities/player.md`](schemas/entities/player.md) (added `username`/`pfp`/`pfpClientRenderAttributes`). Catalog gaps closed: `MsgPlayerUpdatePfpClientRenderAttributes` in [`requests.md`](schemas/requests.md) and a new Player Identity section (3 actions) in [`action-index.md`](reference/action-index.md).
- **Onboarding vs activation-code contrast** — [`auth.md`](api/webapp/auth.md) and the [`structs-onboarding`](.cursor/skills/structs-onboarding/SKILL.md) skill now state that fresh signup needs no activation code and no funds (guild fronts the fee), while activation codes only add an address/device to an existing player.
- **One-mnemonic fleet pattern** — HD path `m/44'/118'/0'/0/N` (one signup per index → fully independent players, poll `GET /structs/address/{address}` for `playerId`, no chain-imposed link/cap) added to [`team-operations.md`](playbooks/meta/team-operations.md), cross-linked from the onboarding and [`structs-permissions`](.cursor/skills/structs-permissions/SKILL.md) skills.
- **Two-jammings clarity** — a side-by-side table in [`combat.md`](knowledge/mechanics/combat.md) distinguishing unit `signalJamming` from the planetary low-orbit ballistic interceptor network.

### Changed

- **Ante player-registration gate** — [`transactions.md`](knowledge/mechanics/transactions.md) `StructsDecorator` note now states every `/structs.structs.*` message requires the signing address to resolve to a player, else rejected with `"address is not registered as a player"` (ante code 2010); bank sends are exempt. Added to the onboarding skill's error list.
- **Staking framing** — reframed reactor staking as buying *capacity* (not a yield/APR/income stream; income is indirect via selling energy) in the [`structs-commerce`](.cursor/skills/structs-commerce/SKILL.md) skill, [`energy-market.md`](knowledge/economy/energy-market.md), [`valuation.md`](knowledge/economy/valuation.md), and the [`speculator`](identity/souls/speculator.md) soul.
- **Agreement escrow + `rate_denom` trap** — documented the full `rate × capacity × duration` debit at open and the guild-denom affordability rejection (keyed `agreement_open`) in the commerce skill, [`energy-market.md`](knowledge/economy/energy-market.md), and `MsgAgreementOpen` in [`schemas/actions.md`](schemas/actions.md).
- **Indexer caveats** — [`database-schema.md`](knowledge/infrastructure/database-schema.md) now lists `stat_connection_capacity`/`stat_connection_count` and warns that five stat hypertables (`stat_structs_load`, `stat_connection_capacity`, `stat_connection_count`, `stat_struct_health`, `stat_struct_status`) have **no `object_type`** column (type implied by table); recommends deriving seized ore from `ledger action='seized'` rows (0-gram rows meaningful) over `planet_raid.seized_ore` (also softened in [`entities/planet.md`](schemas/entities/planet.md), the combat skill, and [`combat.md`](knowledge/mechanics/combat.md)); and notes `connectionCapacity` is **already** the per-player share (don't divide by `connectionCount` again — also in [`energy.md`](knowledge/mechanics/energy.md)).
- **Combat myth-buster visibility** — promoted "a raid cannot eliminate a player — the only prize is stored ore" to a headline callout in [`combat.md`](knowledge/mechanics/combat.md). Added `knowledge/mechanics/combat.md` and `knowledge/mechanics/energy.md` to `CORE_FILES` in [`generate-llms-full.sh`](scripts/generate-llms-full.sh) so the core bundle carries the combat ruleset and energy-units anchor.

## [1.19.0] - 2026-07-17

Update for **structsd `v0.20.0`** (commit `a976768`), the latest **structs-webapp** (`0ece596`), and the **structs-desktop** embedded MCP (README at `ec79ab3`). Docs describe current reality; only this changelog records history.

### Added — structsd v0.20.0 gameplay

- **`struct-trash` action** — destroys a *built* struct; irreversible; consumes build charge (`8`) via its handler (distinct from `struct-build-cancel`, which only cancels an unfinished build). Added to [`action-index.md`](reference/action-index.md), [`action-quick-reference.md`](reference/action-quick-reference.md), [`schemas/actions.md`](schemas/actions.md), [`schemas/requests.md`](schemas/requests.md), the [`permissions.md`](knowledge/mechanics/permissions.md) handler table + `PermPlay` list, [`transactions.md`](knowledge/mechanics/transactions.md), [`building.md`](knowledge/mechanics/building.md), [`conventions.md`](.cursor/skills/conventions.md), the [`structs-building`](.cursor/skills/structs-building/SKILL.md) skill, and classified as a Tier-2 irreversible action in [`SAFETY.md`](SAFETY.md).
- **Batch deactivate (`MsgStructDeactivateBatch`)** — deactivate up to 65 structs in one message, costs no charge. Added across the same action catalogs and permissions/charge tables.
- **Allocation actions** — `allocation-create`/`allocation-update`/`allocation-delete`/`allocation-transfer` added to the action catalogs and request schema; `MsgAllocationUpdate` (no false `capacity_exceeded` on increase) noted in [`integration-notes.md`](api/integration-notes.md).

### Changed — structsd v0.20.0 corrections

- **`struct-deactivate` no longer requires the player online** (it is a recovery action, like reactor infuse); only `activate` requires online + charge + power. Reconciled in [`schemas/actions.md`](schemas/actions.md), [`action-quick-reference.md`](reference/action-quick-reference.md), and [`state-assessment.md`](awareness/state-assessment.md).
- **Jamming Satellite interceptor logic** — the low-orbit ballistic interceptor network evades only *guided* ordnance regardless of ambit (unguided passes through); the "space-only ambit" framing was removed everywhere ([`combat.md`](knowledge/mechanics/combat.md), [`struct-types.md`](knowledge/entities/struct-types.md), [`planet.md`](knowledge/mechanics/planet.md), [`glossary.md`](reference/glossary.md), the [`structs-combat`](.cursor/skills/structs-combat/SKILL.md) skill). Attack resolution reworded so all defender counters resolve *before* any block and a destroyed attacker deals no damage.

### Added — structs-desktop MCP

- **New [`structs-desktop.md`](knowledge/infrastructure/structs-desktop.md)** documents the embedded desktop MCP (`http://127.0.0.1:8420/mcp` + bearer token): 13 tools, 6 prompts, `structs://` compendium resources, and subsystems (GPU/CPU hashing, perception/simulator, policy engine, combat mode, virtual players, tx-signing bridge, agent-driven UI, notifications, guild config). [`TOOLS.md`](TOOLS.md) slimmed to a connect + tool-list pointer; the deprecated `structs_query`/`structs_ui` names replaced with `structs_intel`/`structs_board` across awareness docs; the stale port-3000 note in [`SAFETY.md`](SAFETY.md) corrected.

### Removed — phantom cosmetic-mod subsystem

- **Deleted the fabricated cosmetic/L-mod API** — it had no basis in the webapp source. Removed `api/cosmetic-mods.md`, the `schemas/cosmetic-*.md`, `protocols/cosmetic-mod-*.md`, `examples/cosmetic-mods/`, and the cosmetic error examples, plus every reference in `schemas/requests.md`/`responses.md`, `reference/endpoint-index.md`, `api/endpoints-by-entity.md`, `api/error-codes.md`, `patterns/caching.md`, `reference/api-quick-reference.md`, `SITEMAP.md`, and `sitemap.xml`. The real chain fields (`defaultCosmeticName`, `defaultCosmeticModelNumber`, `class`) are retained.

### Changed — webapp API drift (all)

- **Removed the phantom `/api/struct/planet/{planet_id}`** — the real surface is `/api/struct/list/location/{location_id}/page/{page}` and `/api/struct/player/{player_id}`. Repointed in [`struct.md`](api/webapp/struct.md), [`endpoints.md`](api/endpoints.md), [`endpoints-by-entity.md`](api/endpoints-by-entity.md), [`webapp-api-protocol.md`](protocols/webapp-api-protocol.md), and the planet-monitor workflow.
- **`struct_type` columns** — documented `generating_rate`/`generating_rate_p` and `primary/secondary_weapon_armour_piercing` in [`struct.md`](api/webapp/struct.md).
- **PFP fields** — added `pfp` / `pfp_client_render_attributes` to the player response ([`player.md`](api/webapp/player.md), [`responses.md`](schemas/responses.md)); flattened the stale nested `{player, guild, stats}` player shape to the real flat SQL-column object in `player.md`, `responses.md`, and `webapp-api-protocol.md`.
- **New planet-activity categories** — `block_raid_start` and `shield_change` added to [`planet-activity.md`](api/webapp/planet-activity.md).
- **`banned-word` is not paginated** — `/api/banned-word/all` (no `/page/{page}`) corrected in [`banned-word.md`](api/webapp/banned-word.md), [`webapp-api-protocol.md`](protocols/webapp-api-protocol.md), [`api-quick-reference.md`](reference/api-quick-reference.md), and [`endpoint-quick-lookup.md`](reference/endpoint-quick-lookup.md).
- **Player last-action key** — the response key is `last_action_block_height` (LCD numeric string), corrected in [`endpoints.md`](api/endpoints.md), [`player.md`](api/webapp/player.md), and `BlockHeightResponse` in [`responses.md`](schemas/responses.md).
- **Removed the phantom `/api/pfp` public route** and fixed the public-prefix list in [`integration-notes.md`](api/integration-notes.md) (public = `/api/auth/`, `/api/guild/this`, `/api/timestamp`, `/api/setting`).
- **New endpoint docs** — [`work.md`](api/webapp/work.md) (`/api/work/*`), [`player-address.md`](api/webapp/player-address.md) (the 9 `/api/player-address/*` + 2 `/api/auth/player-address*` routes), and `/api/fleet/player/{player_id}` in [`fleet.md`](api/webapp/fleet.md). Registered in [`api/webapp/README.md`](api/webapp/README.md).

## [1.18.0] - 2026-07-07

GRASS streaming update, **verified against structs-pg `f90cfce` and structs-webapp `7c692a0`** (both dated 2026-07-07) plus the surrounding structs-pg migrations. The grid and planet event subjects now carry the owning player id, which changes subscription patterns; also folds in a few secondary Guild-Stack data-shape changes.

### Changed — GRASS grid/planet subjects carry the owner `player_id`

- **Subjects gained a trailing owner segment.** `structs.GRID_NOTIFY()` now publishes on `structs.grid.{object_type}.{object_id}.{player_id}` and `structs.PLANET_ACTIVITY_NOTIFY()` on `structs.planet.{planet_id}.{player_id}` (owner resolved via `player_object`, falling back to `planet.owner`; the literal `noPlayer` when unresolved; for a `player` grid object the owner is the object itself). Both payloads now include a top-level `player_id`. Verified in structs-pg `deploy/trigger-grass-grid-20260707-add-owner-player-id.sql` / `deploy/trigger-grass-planet-activity-20260707-add-owner-player-id.sql`; the webapp listener matches the suffixed subjects in `src/js/framework/GrassManager.js`.
- **Wildcard-token correction.** Because NATS `*` matches exactly one token and `>` matches the rest, the documented `structs.planet.*` / `structs.grid.*` single-token wildcards no longer match. Updated [`structs-streaming`](.cursor/skills/structs-streaming/SKILL.md), [`event-types.md`](api/streaming/event-types.md), [`subscription-patterns.md`](api/streaming/subscription-patterns.md), [`event-schemas.md`](api/streaming/event-schemas.md), [`api-quick-reference.md`](reference/api-quick-reference.md), and [`glossary.md`](reference/glossary.md) to use `structs.planet.{id}.*` (one planet) / `structs.planet.>` (all) and `structs.player.>` (the player subject is likewise three tokens). Added a NATS wildcard-rule callout to each.
- **Stub shape corrected.** The oversized-`planet_activity` stub is `{subject, planet_id, player_id, seq, category, time, stub:'true'}` (with `player_id`, and `stub` as the string `'true'`), not a bare `{stub:true}`. Updated the streaming skill, event-types, and the glossary [Stub](reference/glossary.md) entry.
- **DB trigger docs.** [`knowledge/infrastructure/database-schema.md`](knowledge/infrastructure/database-schema.md) now documents the `GRID_NOTIFY` / `PLANET_ACTIVITY_NOTIFY` GRASS publishing (owner-suffixed subject + `player_id`). A GRASS subject/player_id integration note was added to [`api/integration-notes.md`](api/integration-notes.md).

### Added — secondary Guild-Stack data shapes

- **`struct_type.generating_rate` is a formatted column** — the raw chain rate is now `generating_rate_p`, with `generating_rate = generating_rate_p * 1000` (same `_p`/formatted split as grid `value_p`/`value`). Read `generating_rate_p` for the per-gram rate quoted in docs. Noted in [`struct-types.md`](knowledge/entities/struct-types.md) and [`integration-notes.md`](api/integration-notes.md). Verified in structs-pg `deploy/table-struct-type-20260602-add-generating-rate-precision.sql`.
- **Armour-piercing is explicit booleans** — `struct_type.primary_weapon_armour_piercing` / `secondary_weapon_armour_piercing` (chain `StructType.primary/secondaryWeaponArmourPiercing`, v0.18.0). Read the flag rather than inferring from class. Noted in [`struct-types.md`](knowledge/entities/struct-types.md) / [`integration-notes.md`](api/integration-notes.md). Verified in structs-pg `deploy/table-struct-type-20260612-add-armour-piercing.sql`.
- **PFP signup threading** — `PLAYER_PENDING_JOIN_PROXY` threads `player-name`, `player-pfp`, and `player-pfp-client-render-attributes` into the signed `guild-membership-join-proxy` `ugc` argument (the column `pfp_cr_attributes` was renamed to `pfp_client_render_attributes`, and the ugc key lengthened from the short `-cr-attributes` form). Documented in [`integration-notes.md`](api/integration-notes.md); [`ugc-moderation.md`](knowledge/mechanics/ugc-moderation.md) already covered the `pfp` / `pfpClientRenderAttributes` fields.

## [1.17.0] - 2026-06-30

Energy/power overhaul driven by an agent field report, **verified against the `structsd` v0.19.1 keeper source** (`x/structs/...`) and live `structstestnet` reads. Adds a canonical Energy page, fixes a 1000× unit-label error, and documents grid mechanics, build slots/limits, and energy data shapes that had no home in the docs.

### Added — canonical Energy page

- **New [`energy.md`](knowledge/mechanics/energy.md)** consolidates the whole energy system: the milliwatt unit convention, the online equation and its four quantities (`capacity`/`capacitySecondary`/`load`/`structsLoad`), the per-message offline behavior, infusion mechanics, substation dilution, allocations, and the brownout cascade. [`power.md`](knowledge/mechanics/power.md) is slimmed to a quick formula card that defers to it. Registered in [`AGENTS.md`](AGENTS.md), [`llms.txt`](llms.txt), [`SITEMAP.md`](SITEMAP.md), [`sitemap.xml`](sitemap.xml), and the bundles.
- **Infusion splits 96/4** — `Infusion.GetPowerDistribution()` + `ReactorFuelToEnergyConversion = 1` (`x/structs/types/infusion.go`, `types/keys.go`): 1 ualpha → 1 mW, split so the infuser keeps `1 − commission` (default 4%, `reactor_hooks.go`) on their **own** capacity and the reactor keeps the commission. **Infusing a reactor does not power a substation** — an allocation must route capacity in. Documented in [`energy.md`](knowledge/mechanics/energy.md#creating-capacity-infusion-splits-964) and the [`structs-energy`](.cursor/skills/structs-energy/SKILL.md) skill.
- **`connectionCapacity` dilutes** — `UpdateSubstationConnectionCapacity` (`x/structs/keeper/grid_context.go`): each connected player receives `(capacity − load) / connectionCount`, recomputed on every connect/disconnect, so each new connection shrinks everyone's share. The real guild capacity-planning rule. Added to [`energy.md`](knowledge/mechanics/energy.md#substations-connectioncapacity-dilutes) and the skill.
- **Open allocation-permission model** — `substation-allocation-connect` checks `PermAllocationConnection` only on the caller's **own allocation** (`msg_server_substation_allocation_connect.go` → `CanBeConnectedBy`); no destination-substation veto, no guild membership. Anyone can contribute capacity to any substation (diluted by `1/connectionCount`). Documented with the dilution caveat.
- **`GridCascade` brownout** — when `load` exceeds `capacity`, the keeper destroys that object's outgoing allocations in creation order until load fits, cascading downstream (`grid_context.go`). Added to [`energy.md`](knowledge/mechanics/energy.md#brownout-gridcascade-destroys-allocations) and the skill.

### Changed — unit labels and build mechanics

- **Fixed a 1000× unit-label error** — the chain stores power in **milliwatts**; the [`struct-types.md`](knowledge/entities/struct-types.md) draw table and [`power.md`](knowledge/mechanics/power.md) example/onboarding tables mislabeled watt values as `kW`. Relabeled to **W** (e.g. Command Ship `50 W`, not `50 kW`) and the unit anchored once in [`energy.md`](knowledge/mechanics/energy.md#units).
- **Per-player build `Limit` column** — added to the [`struct-types.md`](knowledge/entities/struct-types.md#complete-struct-type-table) main table from genesis `BuildLimit` (`x/structs/types/genesis_struct_type.go`): Command Ship, Ore Extractor, Ore Refinery, Jamming Satellite, PDC, Field Generator, Continental Power Plant, World Engine = 1; all fleet combat structs, Orbital Shield Generator, and Ore Bunker = unlimited. (`buildLimit: 0` = unlimited.)
- **Build slots and charge cadence** — [`building.md`](knowledge/mechanics/building.md#slots) gains a Slots section (**4 per ambit** on both planet and fleet, `PlanetStartingSlots = 4`; slot reserved at initiate; counts fixed) and a build-cadence note (build costs 8 charge and resets the bar, so ~one build per ~8 blocks).

### Added — integration data shapes

- **Energy/grid data shapes** in [`integration-notes.md`](api/integration-notes.md) — power fields live under a `gridAttributes` sub-object (LCD numerics are JSON strings/milliwatts), `guild` carries `primaryReactorId`/`entrySubstationId`, and verified message shapes for `MsgReactorInfuse` (single `Coin` amount), `MsgAllocationCreate` (no `destinationId`), and `MsgSubstationAllocationConnect` (substation goes in `destinationId`) from `proto/structs/structs/tx.proto`.
- **Glossary** — [`reference/glossary.md`](reference/glossary.md) adds Allocation, `connectionCapacity`, `GridCascade`, Reactor, `structsLoad`, and Slots, and repoints the energy entries (capacity, load, infusion, substation, BuildDraw) to [`energy.md`](knowledge/mechanics/energy.md).

## [1.16.0] - 2026-06-29

Documentation improvements driven by agent field notes, **verified against the `structsd`, `structs-grass`, and `structs-pg` sources**. This pass closes content gaps the field notes surfaced, reconciles the streaming catalog to the actual Postgres triggers, and adds discoverability and learning aids (a concept glossary, a worked combat/raid transcript, and a multi-account playbook).

### Added (verified against source)

- **`capacity_exceeded` covers two build checks** — `struct-build-initiate` raises the same `cannot handle new load requirements (required: X, available: Y)` string for both the **per-player build-count limit** and the **power-capacity** check (`x/structs/keeper/msg_server_struct_build_initiate.go`, `x/structs/types/errors_structured.go`). Tiny equal integers = build limit; large values = milliwatt capacity. Documented in [`building.md`](knowledge/mechanics/building.md#build-validation-order), [`troubleshooting/common-issues.md`](troubleshooting/common-issues.md), [`api/integration-notes.md`](api/integration-notes.md).
- **Fresh-vs-aged PoW worked example** — difficulty runs 64 (fresh, impossible) → 1 once a clock reaches `range` blocks old, so an old anchor is a cheaper proof than a fresh one. Added to [`hashing.md`](knowledge/mechanics/hashing.md#worked-example-fresh-vs-aged-anchor); cross-linked from [`structs-production`](.cursor/skills/structs-production/SKILL.md) and [`structs-building`](.cursor/skills/structs-building/SKILL.md), with the mine/refine clock reset reaffirmed.
- **Defender assignment vs block vs counter** — any built, online, co-located struct can be assigned to defend regardless of ambit; same-ambit is required only to **block**, while a cross-ambit defender still **counters** (`struct_cache.go` `ResolveDefenders`). Added [Assigning Defenders](knowledge/mechanics/combat.md#assigning-defenders-struct-defense-set) to [`combat.md`](knowledge/mechanics/combat.md) and clarified the [`structs-combat`](.cursor/skills/structs-combat/SKILL.md) defense procedure.
- **Counter damage is two per-type fields, not a flat value** — same-ambit uses `counterAttackSameAmbit`, cross-ambit uses `counterAttack` (`genesis_struct_type.go`; e.g. CMD 2/2, Destroyer 1/2). Replaced the "÷2" framing in [`combat.md`](knowledge/mechanics/combat.md#counter-attack) and added the "counters are a backstop" note to combat docs.
- **Parallel-charge focus fire** — because charge is per-player, the only way to land many hits in one window is many accounts. Added to [`structs-combat`](.cursor/skills/structs-combat/SKILL.md) and the new team playbook.
- **Six-value ambit tables** — reach bitmask now shows `none=1 … local=32` (`bit = 1 << enum`) alongside the enum (0–5) consistently in [`building.md`](knowledge/mechanics/building.md#ambit-encoding), [`combat.md`](knowledge/mechanics/combat.md#ambit-targeting), and [`struct-types.md`](knowledge/entities/struct-types.md), each cross-linked to [`integration-notes`](api/integration-notes.md#ambit-enum-vs-reach-bitmask).
- **Canonical numeric-status pointer** — HP/status references in [`struct-types.md`](knowledge/entities/struct-types.md), [`combat.md`](knowledge/mechanics/combat.md), and [`integration-notes.md`](api/integration-notes.md) now point to the single decoder table in [`building.md`](knowledge/mechanics/building.md#status-field-numeric) (`status & 4` online, `status & 32` destroyed; `35` = destroyed).

### Changed — streaming catalog reconciled to the `grass` triggers

- **`struct_attack` is streamed but stubbed** — the Postgres NOTIFY payload is capped (~7995 bytes); large combat `detail` is replaced by a `{ "stub": true }` envelope with no shot log (`structs-pg/deploy/trigger-grass-planet-activity.sql`). Detect combat from effect events (`struct_health`, `struct_status`, `shield_change`, `raid_status`) and pull `planet_activity` for shot detail. Documented in [`structs-streaming`](.cursor/skills/structs-streaming/SKILL.md), [`api/streaming/event-types.md`](api/streaming/event-types.md), [`api/streaming/event-schemas.md`](api/streaming/event-schemas.md), [`schemas/database-schema.md`](schemas/database-schema.md).
- **Added emitted categories** — `shield_change` and `block_raid_start` (`structs-pg` migration `type-grass-category-20260612-add-raid-shield-categories.sql`), plus `struct_health`, `player_address`, `player_address_pending`, and the grid/inventory category lists. Flagged `fleet_advance` and `player_meta` as **defined but not emitted**.

### Added — discoverability & learning aids

- **Concept glossary** — [`reference/glossary.md`](reference/glossary.md): ~70 terms with one-line definitions, disambiguation of the common traps (ambit enum vs bitmask, block vs counter, multi-shot vs multi-target, `capacity_exceeded`, stub, `attackerDefeated`), and a canonical-page link each. Linked from [`AGENTS.md`](AGENTS.md), [`SITEMAP.md`](SITEMAP.md), [`llms.txt`](llms.txt) and added to the bundles.
- **Drift guard for the glossary** — [`scripts/check-drift.sh`](scripts/check-drift.sh) now validates (filesystem-only) that every glossary link target file exists and every `#anchor` resolves to a heading, so the glossary cannot silently rot.
- **Worked combat/raid transcript** — [`examples/transcripts/03-combat-and-raid.md`](examples/transcripts/03-combat-and-raid.md): counter-free attacking ambits, weapon-control vs defense, charge pacing, numeric status, the stubbed stream, and completing a raid without losing the attacker's Command Ship.
- **Team-operations playbook** — [`playbooks/meta/team-operations.md`](playbooks/meta/team-operations.md): multi-account play, per-player charge/build-limit multipliers, focus fire, substation-fed power, idempotent proxy onboarding, minimal-permission workers.
- **Bundle coverage** — added `event-types.md`, `event-schemas.md`, `common-issues.md`, `glossary.md`, the new transcript, and the team playbook to [`scripts/generate-llms-full.sh`](scripts/generate-llms-full.sh); linked the streaming catalogs and troubleshooting from [`llms.txt`](llms.txt). Regenerated `llms-full.txt` / `llms-core.txt`.

## [1.15.0] - 2026-06-22

Documentation rolled forward to **structsd v0.19.1** (tag `v0.19.1`), with the toolchain refocused on [`structs-desktop`](https://github.com/playstructs/structs-desktop) and its embedded MCP server.

### Changed (structsd v0.19.1 gameplay, verified against source)

- **Battle actions no longer require the Command Ship** — `struct-attack`, `struct-defense-set`, and stealth changes evaluate readiness on the operating struct and its owner only (`msg_server_struct_attack.go`, `struct_cache.go` `ReadinessCheck`). The attacker's Command Ship need not be online or on-station. Updated [`combat.md`](knowledge/mechanics/combat.md), [`structs-combat`](.cursor/skills/structs-combat/SKILL.md), [`fleet.md`](knowledge/mechanics/fleet.md), [`schemas/actions.md`](schemas/actions.md), [`reference/action-quick-reference.md`](reference/action-quick-reference.md), [`patterns/validation-patterns.md`](patterns/validation-patterns.md).
- **Unbuilt structs cannot be attacked** — `CanAttack` rejects a target that is not yet built (`struct_cache.go`, error `unbuilt`); a destroyed target is rejected (`destroyed`). Documented across combat docs and the validation patterns.
- **Fleet-away exposes home shields** — a defender's command struct is vulnerable whenever their fleet is off-station **or** their Command Ship is offline/destroyed (`planet_cache.go` `IsDefenderCommandStructVulnerable`). Sending your fleet away to raid leaves your own planet raidable until it returns. Updated [`combat.md`](knowledge/mechanics/combat.md), [`planet.md`](knowledge/mechanics/planet.md), [`fleet.md`](knowledge/mechanics/fleet.md), [`patterns/decision-tree-combat.md`](patterns/decision-tree-combat.md), [`structs-combat`](.cursor/skills/structs-combat/SKILL.md), [`structs-planets-fleet`](.cursor/skills/structs-planets-fleet/SKILL.md), [`scripts/scout.sh`](scripts/scout.sh).
- **Battleship secondary damage 1 → 2** — the Battleship's guided space secondary now deals 2 damage per shot (`genesis_struct_type.go`). Updated [`struct-types.md`](knowledge/entities/struct-types.md).

### Changed (toolchain)

- **MCP via `structs-desktop`** — all MCP guidance now points to the MCP server embedded in the `structs-desktop` app: a 9-tool catalog (`structs_dashboard`, `structs_query`, `structs_hash`, `structs_action`, `structs_intel`, `structs_policy`, `structs_ui`, `structs_events`, `structs_sequence`) and 6 guided prompts, with charge-paced action queueing and agent-driven UI for human+agent co-op. Connection details live in the app's Debug menu. Rewrote the MCP section of [`TOOLS.md`](TOOLS.md); updated [`AGENTS.md`](AGENTS.md), [`SITEMAP.md`](SITEMAP.md), and the awareness docs.
- **TypeScript bindings** — generated from `structsd`'s make system (`make proto-gen-ts`) and used directly with CosmJS; no separate client package.

### Removed

- References to `structs-client-ts`, `structs-compendium`, and `structs-mcp` — these are no longer part of the toolchain. Build TypeScript bindings via `structsd`; connect agents through the `structs-desktop` MCP server.

## [1.14.0] - 2026-06-17

Combat-and-raid documentation hardening from live-play findings, **verified against the structsd v0.18.0 source** (tag `v0.18.0`, commit `173e7a2`). An initial pass documented several player-reported mechanics that source verification then corrected — the net result below is what the code actually does, with file:line citations.

### Added (verified against source)

- **Raid does ore theft only — no player elimination** — `planet-raid-complete` seizes **all** of the defender's `storedOre` and nothing else; there is no player-destruction outcome. Killing the defender's Command Ship only opens the `shieldsVulnerable` window (`IsDefenderCommandStructVulnerable`); if it's restored before completion the raid is rejected (`shields_active`). `trigger_raid_defeat_by_destruction` is on the **Command Ship** and defeats the **attacking** fleet when its away-from-home CMD is destroyed (`attackerDefeated`), per `struct_cache.go` `CanTriggerRaidDefeatByDestruction` and `fleet_cache.go` `Defeat()`. Updated [`combat.md`](knowledge/mechanics/combat.md#what-a-raid-does), [`planet.md`](knowledge/mechanics/planet.md#raid-vulnerability), [`structs-combat`](.cursor/skills/structs-combat/SKILL.md). Added `attackerDefeated` to the raid-status table.
- **Planetary defenses (only two are wired in v0.18.0)** — the PDC and the **low-orbit ballistic interceptor network** (provided by the **Jamming Satellite**, type 17, which has `noUnitDefenses`). The interceptor network evades attacks only when the **attacker is in air/space and the target is in land/water** (`attack_context.go:155-171`, `evadedByPlanetaryDefenses` / `lowOrbitBallisticInterceptorNetwork`). The `orbitalJammingStation`, `coordinatedGlobalShieldNetwork`, and `repairNetwork` attributes exist but are not incremented by any struct nor read in combat. Updated [`combat.md`](knowledge/mechanics/combat.md#other-planetary-defense-structs), [`struct-types.md`](knowledge/entities/struct-types.md).
- **Single-target weapons** — all 13 fleet types have `primaryWeaponTargets = 1` (and `secondaryWeaponTargets = 1` where a secondary exists) in `genesis_struct_type.go`; no multi-target weapon exists, though the field supports >1. Distinguished from multi-*shot* (`primaryWeaponShots`). Updated [`combat.md`](knowledge/mechanics/combat.md#targets-per-attack), [`struct-types.md`](knowledge/entities/struct-types.md), [`structs-combat`](.cursor/skills/structs-combat/SKILL.md), [`AGENTS.md`](AGENTS.md), [`llms.txt`](llms.txt).
- **Charge cannot be banked or burst** — `charge = CurrentBlockHeight - LastActionBlock`, so every action resets the bar to 0; no alpha-strike. Added to [`building.md`](knowledge/mechanics/building.md#charge-accumulation), cross-referenced from [`combat.md`](knowledge/mechanics/combat.md).
- **Numeric struct `status` field** — documented as the `StructState` bit-flag (`struct.go`): Materialized 1, Built 2, Online 4, Stored 8, Hidden 16, Destroyed 32, Locked 64. Common composites: 0 stateless, 1 materialized, 3 built/offline, 7 online, **35 = destroyed (1+2+32)**. Added to [`building.md`](knowledge/mechanics/building.md#status-field-numeric).

### Corrected (initial draft → source-verified)

- **Removed the "player elimination" raid outcome** — it does not exist; `trigger_raid_defeat_by_destruction` defeats the *attacker's* fleet, not the defender.
- **Jamming Satellite** does **not** zero guided weapons; its real effect is the low-orbit ballistic interceptor network (air/space-vs-land/water evasion). Guided weapons missing is the **unit-level** `signalJamming` defense on the *target* (66% vs guided).
- **No generator HP boost** — Field/Orbital Shield Generators do not raise neighbours' HP; the observed "6–8 HP" are normal max-HP values.
- **No defender cap** — `defense-set`/`ResolveDefenders` impose no per-ambit cap; the "4 per ambit" is just the planet's 4 slots/ambit.
- **`status` 35** is a destroyed struct (not an unknown/ambit value).
- **Attack charge** is the source-verified **3/5** (CMD/Starfighter/Pursuit/Tank = 3; other armed hulls = 5); the report's "≈ 8" was a misread of build charge (8).

## [1.13.0] - 2026-06-12

A decision-first rebuild of the skills layer, plus a read-only script toolkit, machine-readable memory, and learning/measurement scaffolding. Every skill now states **when to use it**, the **decisions** it helps you make, and the exact commands — with shared boilerplate factored out once.

### Added

- **[`conventions.md`](.cursor/skills/conventions.md)** — single source for shared skill boilerplate: transaction flags (`TX_FLAGS` / `TX_FLAGS_APPROVED`), the `--` entity-ID rule, the per-player charge bar, proof-of-work `-D` policy, one-transaction-at-a-time, and the skill-authoring template (`level` / `domain` front matter).
- **New consolidated skills** — [`structs-production`](.cursor/skills/structs-production/SKILL.md) (absorbs mining), [`structs-planets-fleet`](.cursor/skills/structs-planets-fleet/SKILL.md) (absorbs exploration), [`structs-energy`](.cursor/skills/structs-energy/SKILL.md) (absorbs power; capacity-side), [`structs-commerce`](.cursor/skills/structs-commerce/SKILL.md) (absorbs economy; market-side), [`structs-permissions`](.cursor/skills/structs-permissions/SKILL.md) (replaces diplomacy; adds delegate-agent recipes), [`structs-intel`](.cursor/skills/structs-intel/SKILL.md) (replaces reconnaissance).
- **Script toolkit** in [`scripts/`](scripts/README.md) — read-only helpers that turn multi-step queries into one-line decisions: [`assess.sh`](scripts/assess.sh), [`power-budget.sh`](scripts/power-budget.sh), [`scout.sh`](scripts/scout.sh) (raid go/no-go with the shield-vulnerability gate), [`job-status.sh`](scripts/job-status.sh), [`watch-defense.mjs`](scripts/watch-defense.mjs) (GRASS defense alerts), [`check-drift.sh`](scripts/check-drift.sh) (flag doc constants that drift from the live chain), and a shared [`lib.sh`](scripts/lib.sh).
- **Machine-readable memory** — [`memory/README.md`](memory/README.md) defines JSON schemas for operational state (`player.json`, `game-state.json`, `jobs/<job>.json`); new [`memory/jobs/`](memory/jobs/README.md) directory convention (`.json` / `.log` / `.pid` per expedition).
- **Learning & measurement** — [golden transcripts](examples/transcripts/README.md) ([zero-to-mining](examples/transcripts/01-zero-to-mining.md), [raid go/no-go](examples/transcripts/02-raid-go-no-go.md)), the [agent scorecard](awareness/scorecard.md), and a [local devnet guide](reference/local-devnet.md) for safe practice.
- **`llms-core.txt`** — a tight starter bundle (identity + conventions + core-loop skills + key knowledge) alongside the full `llms-full.txt`; both emitted by [`scripts/generate-llms-full.sh`](scripts/generate-llms-full.sh).
- **`--pfp-client-render-attributes`** support in [`create-player.mjs`](.cursor/skills/structs-onboarding/scripts/create-player.mjs), with local v0.18.0 validation (≤512-byte JSON object).

### Changed

- **All skills are now decision-first** with `level` / `domain` front matter and a "When to use it" + "Decisions" section. Rewrote [`structs-building`](.cursor/skills/structs-building/SKILL.md), [`structs-combat`](.cursor/skills/structs-combat/SKILL.md) (v0.18.0 raid doctrine), and [`structs-guild`](.cursor/skills/structs-guild/SKILL.md) (guild-choice criteria); refocused [`play-structs`](.cursor/skills/play-structs/SKILL.md) and [`structs-onboarding`](.cursor/skills/structs-onboarding/SKILL.md) on the new skill map and per-player charge.
- **Skill index & cross-links** updated across [`.cursor/skills/index.md`](.cursor/skills/index.md), [`AGENTS.md`](AGENTS.md), [`SAFETY.md`](SAFETY.md), [`SITEMAP.md`](SITEMAP.md), [`llms.txt`](llms.txt), and `sitemap.xml`.

### Removed

- **Merged/renamed skills deleted** — `structs-mining`, `structs-exploration`, `structs-power`, `structs-economy`, `structs-diplomacy`, `structs-reconnaissance` (their content lives in the consolidated skills above). Root `skills/` symlinks updated to match.

## [1.12.0] - 2026-06-12

### Fixed

- **Charge is per-player, not per-struct** — corrected the fundamental framing everywhere it was wrong. Charge is a single shared bar per player (`charge = CurrentBlockHeight - player.lastActionBlock`); every charge-consuming action by any of the player's structs draws from and resets the same bar. Rewrote [`knowledge/mechanics/building.md`](knowledge/mechanics/building.md#charge-accumulation) as the canonical explainer and fixed per-struct phrasing in [`schemas/actions.md`](schemas/actions.md), [`schemas/errors.md`](schemas/errors.md), [`schemas/entities.md`](schemas/entities.md), [`protocols/action-protocol.md`](protocols/action-protocol.md), [`protocols/error-handling.md`](protocols/error-handling.md), [`reference/action-quick-reference.md`](reference/action-quick-reference.md), [`troubleshooting/error-codes.md`](troubleshooting/error-codes.md), [`awareness/state-assessment.md`](awareness/state-assessment.md), [`awareness/async-operations.md`](awareness/async-operations.md), [`awareness/context-handoff.md`](awareness/context-handoff.md), [`awareness/continuity.md`](awareness/continuity.md), [`knowledge/infrastructure/guild-stack.md`](knowledge/infrastructure/guild-stack.md), and [`knowledge/lore/structs-origin.md`](knowledge/lore/structs-origin.md).

### Changed (structsd v0.18.0 gameplay rebalance)

- **Charge rebalance** — `activateCharge` 1→2 and `stealthActivateCharge` 1→2 (all types); Command Ship `moveCharge` 8→3; primary weapon charges rebased to 3 (Command Ship, Starfighter, Pursuit Fighter, Tank) or 5 (all other armed hulls); secondary charges 5 (Battleship, Starfighter) / 3 (Cruiser). Updated [`building.md`](knowledge/mechanics/building.md), [`struct-types.md`](knowledge/entities/struct-types.md), [`combat.md`](knowledge/mechanics/combat.md).
- **Planetary struct health & armour** — baseline planetary structs to 6 HP; power generators hardened (Field Generator 8, Continental Power Plant 10, World Engine 10) and given `armour` (damage reduction 1). Fleet HP unchanged.
- **Armour-piercing + Battleship rework** — added `primaryWeaponArmourPiercing` / `secondaryWeaponArmourPiercing` (negate the target's damage reduction). Battleship primary is now armour-piercing, restricted to Land/Water, and gains a guided secondary that reaches Space — the dedicated counter to Tanks and armoured generators.
- **Build limits** — Orbital Shield Generator and Ore Bunker (shield-only structs) are now unlimited per player; corrected the per-player limits table.
- **Raid `SHIELDS_VULNERABLE`** — documented that `planet-raid-complete` only succeeds while the defender's Command Ship is offline/destroyed/non-existent, the `blockStartRaid` vulnerability clock, and the new `shieldsVulnerable` / `ongoing` raid statuses. Planetary shield values rebased onto a base shield of 25.
- **Movement** — clarified that only the Command Ship is `movable`; the chain rejects `struct-move` on any other struct.

### Added

- **`pfpClientRenderAttributes`** — new player field carrying render hints (a compacted JSON object, ≤512 bytes) for a locally-rendered profile picture, set via `MsgPlayerUpdatePfpClientRenderAttributes` (or at guild signup). Owner-only; not guild-moderatable. Documented in [`ugc-moderation.md`](knowledge/mechanics/ugc-moderation.md), [`schemas/validation.md`](schemas/validation.md), [`schemas/actions.md`](schemas/actions.md), [`schemas/entities.md`](schemas/entities.md), [`reference/action-quick-reference.md`](reference/action-quick-reference.md), [`transactions.md`](knowledge/mechanics/transactions.md).

## [1.11.0] - 2026-05-29

### Added

- **Sync-state indexer architecture** documented across [`knowledge/infrastructure/guild-stack.md`](knowledge/infrastructure/guild-stack.md), [`.cursor/skills/structs-guild-stack/SKILL.md`](.cursor/skills/structs-guild-stack/SKILL.md), [`knowledge/infrastructure/database-schema.md`](knowledge/infrastructure/database-schema.md), and [`schemas/database-schema.md`](schemas/database-schema.md) — `structs-sync-state` service, `sync_state.*` schema, `cache.*` compatibility views, retired `player_meta`/`planet_meta` tables.
- **`guild-update-primary-reactor`** CLI command and `MsgGuildUpdatePrimaryReactor` in [`schemas/actions.md`](schemas/actions.md) and [`reference/action-quick-reference.md`](reference/action-quick-reference.md).
- **Optional planet name on explore** — `planet-explore [player-id] [name]` documented in exploration skill, [`schemas/actions.md`](schemas/actions.md), [`knowledge/mechanics/planet.md`](knowledge/mechanics/planet.md).

### Changed

- **Network identifiers** standardized to `structstestnet-111` / `NETWORK_VERSION=113b` in [`TOOLS.md`](TOOLS.md), guild-stack skill, and [`structsd-install`](.cursor/skills/structsd-install/SKILL.md) (v0.17.0).
- **UGC column locations** — `username`/`pfp` on `structs.player`, `name` on `structs.planet`, `name`/`pfp` on `structs.guild`; `guild_meta` documents off-chain config only.
- **GRASS event paths** — `player_consensus` replaces `player_meta` for UGC; block height no longer via `current_block` NOTIFY; streaming protocol, event schemas, and streaming skill updated.
- **Guild stack compose** — `compose.yaml` canonical filename; default profile is `structsd structs-pg structs-sync-state structs-grass`; MCP/proxy removed from compose (separate [`structs-mcp`](https://github.com/playstructs/structs-mcp) repo).
- **`schemas/database-schema.md`** rewritten as current-state structural catalog (changelog sections removed).
- **Combat mechanics** — defender counter-damage exclusion, distant-fleet defense restriction in [`knowledge/mechanics/combat.md`](knowledge/mechanics/combat.md).
- **Webapp player API** — documents UGC on `structs.player` instead of `player_meta` in [`api/webapp/player.md`](api/webapp/player.md).

## [1.10.1] - 2026-05-13

### Added

- **["Reconnecting to a Long Job" four-state flow](awareness/async-operations.md#reconnecting-to-a-long-job)** in [`awareness/async-operations.md`](awareness/async-operations.md) — when a new session inherits a "running" job in `memory/jobs/`, the agent now has a procedure (alive PID? landed on chain? state matches expectation? silent-failure diagnosis?) instead of a one-line aspiration. Includes a `nohup ... > memory/jobs/<job>.log 2>&1 & echo $! > memory/jobs/<job>.pid` template so each expedition leaves a paper trail, and a re-verify-consent checklist for refines specifically (the 34h window is the worst-case staleness gap).
- **Top-of-skill safety surface** in [`play-structs`](.cursor/skills/play-structs/SKILL.md) — a new "Before You Sign Anything" callout above Step 1 introduces the tier framework and links [SAFETY.md](SAFETY.md) and [COMMANDER.md](COMMANDER.md) **before** the first transaction example. Also adds reconnect and SAFETY reminders to the skill's "What You Need to Know" section.

### Changed

- [`awareness/context-handoff.md`](awareness/context-handoff.md) — resume protocol now includes `SAFETY.md` in the startup-read list and inserts a dedicated "verify long-running compute jobs first" step (pointing at the new four-state flow) before strategic state assessment.
- [`structs-mining`](.cursor/skills/structs-mining/SKILL.md), [`structs-building`](.cursor/skills/structs-building/SKILL.md), [`structs-combat`](.cursor/skills/structs-combat/SKILL.md) — Safety callouts now point at the reconnect flow at the point of need, so an agent reading the skill in the middle of a problem finds the verification procedure without bouncing back to async-operations.

### Context

Skilled-player feedback on the 1.10.0 ship: two real gaps. (1) The 34-hour refinery window leaves agents stranded when they reconnect — `memory/jobs/` was the persistence pattern, but no procedure told them how to *verify* what happened in the gap. (2) [`play-structs`](.cursor/skills/play-structs/SKILL.md) was supposed to be the entry-point skill but only mentioned safety in "See Also" at the bottom — new agents could run 180 lines of commands before encountering the tier framework. Both addressed.

## [1.10.0] - 2026-05-13

### Added

- **["The `-y` Rule"](SAFETY.md) in [`SAFETY.md`](SAFETY.md)** — codifies that `-y` is OFF by default in every transaction example, ON only after commander approval. Two named flag bundles (`TX_FLAGS`, `TX_FLAGS_APPROVED`) make the distinction explicit. Compute commands (`struct-build-compute`, `struct-ore-mine-compute`, `struct-ore-refine-compute`, `planet-raid-compute`) are the documented exception — they must auto-submit unattended, so they ship with `-y` paired with an **Approval Block** that surfaces consent up-front.
- **The Approval Block pattern** — a template the agent prints before signing high-impact transactions, making the consent surface explicit (action, tier, signer, target, amount, reversibility, blast radius, pre-flight checks). Documented in [`SAFETY.md`](SAFETY.md) and applied at every Tier 1+ command site in the skills.
- **"Requires" callout** on all 10 transaction-using skills — declares `structsd` as a required tool inline, closing the ASI04 dependency Notes ClawScan raised on `structs-energy`, `structs-economy`, `structs-diplomacy`, and similar.
- **Read-only profile** as the **default** in [`structs-guild-stack`](.cursor/skills/structs-guild-stack/SKILL.md) setup — Step 4 starts only `structsd structs-pg structs-grass` instead of the full stack. The MCP server, webapp, NATS, and signing agent must be enabled explicitly. A new "Enabling Additional Services" section documents how.
- **Pinned release tag** as Step 1 of the guild-stack setup — `git checkout <latest-tag>` makes the Compose file a reviewable artifact instead of a moving target.

### Changed

- **Removed `-y` from every Tier 1+ transaction example** in 11 skills (~50 instances across `structs-onboarding`, `structs-mining`, `structs-building`, `structs-combat`, `structs-economy`, `structs-energy`, `structs-power`, `structs-guild`, `structs-diplomacy`, `structs-exploration`, `play-structs`) plus the `create-player.mjs` script's `next_step` example. The CLI's confirmation prompt becomes the last gate before signing.
- **Compute commands keep `-y`** because they auto-submit completion when no shell is attached. Each compute example is now preceded by an Approval Block that surfaces the deferred-consent risk.
- **TX_FLAGS rewritten** in every skill from a single line ending in `-y` to two named bundles: `TX_FLAGS` (interactive, the default) and `TX_FLAGS_APPROVED` (interactive plus `-y`, only after commander approval). Each skill's bundle docs explain which commands actually warrant the approved form.
- **[`AGENTS.md`](AGENTS.md) Critical Rule 6** rewritten to teach the new flag policy. The "Common transaction flags" line now shows the interactive default and references the auto-approved form separately.
- **`planet-explore` split** in [`structs-exploration`](.cursor/skills/structs-exploration/SKILL.md) into two distinct procedural steps: Tier 0 first-explore (routine) and Tier 2 subsequent-explore (preceded by an Approval Block surfacing `currentOre == 0`, fleet status, and the destruction warning).
- **[`structs-guild-stack`](.cursor/skills/structs-guild-stack/SKILL.md) "Lifecycle & Trust"** condensed — pin-a-tag and disable-services moved into the main Setup Procedure where they belong; the section now hosts the longer-form rationale, MCP localhost binding, signing-agent caveat, and teardown commands.

### Context

Responds to the **re-audit pass** of ClawScan on the 11 affected skills after the 1.9.0 changes. The 1.9.0 work moved six skills to zero ClawScan Concerns and downgraded most remaining findings to Notes; the remaining Concerns in `structs-onboarding`, `structs-combat`, `structs-energy`, `structs-power`, `structs-exploration`, and `structs-guild-stack` all traced to one issue — `-y` was still present in command examples even when the Safety callout sat directly above. 1.10.0 retires `-y` from default examples entirely and reframes its use as a documented, narrow exception with an explicit approval surface at each call site. `structsd-install` remains unchanged and continues to Pass.

### Verdict shift (1.8 → 1.9 → 1.10 target)

| Skill | 1.8 | 1.9 | 1.10 target |
|---|---|---|---|
| structs-onboarding | Review · 5 findings | 2 Concerns + 2 Notes | 0 Concerns |
| structs-mining | Review · 2 Concerns | 0 Concerns | 0 Concerns |
| structs-building | Review · 3 Concerns | 0 Concerns | 0 Concerns |
| structs-combat | Suspicious · 3 Concerns | 1 Concern | 0 Concerns |
| structs-economy | Suspicious · 2 Concerns | 0 Concerns | 0 Concerns |
| structs-energy | Suspicious · 2 Concerns | 2 Concerns | 0 Concerns |
| structs-power | Suspicious · 2 Concerns | 1 Concern | 0 Concerns |
| structs-guild | Suspicious · 1 Concern | 0 Concerns | 0 Concerns |
| structs-diplomacy | Suspicious · 1 Concern | 0 Concerns | 0 Concerns |
| structs-exploration | Review · 2 Concerns | 1 Concern | 0 Concerns |
| structs-guild-stack | Review · 2 Concerns | 3 Concerns | 0 Concerns |
| structsd-install | Pass | Pass | Pass |

## [1.9.0] - 2026-05-13

### Added

- **[`SAFETY.md`](SAFETY.md)** — the trust contract between agent and commander. Three operation tiers (Routine / Significant / Irreversible) mapped to `COMMANDER.md` autonomy levels. Battle-order approval pattern, background-expedition rules, key hygiene, verification checklist, and audit log pattern. Links the public [ClawScan audits](https://clawhub.ai/abstrct) for every skill.
- **[`awareness/agent-security.md`](awareness/agent-security.md)** — operational threat playbook. UGC prompt injection, RPC node trust, `address-register` identity hijack, guild API trust, MCP/signing-agent exposure, multi-agent key isolation. Includes a step-by-step incident response playbook (defuse → revoke → transfer → revoke permissions → rotate primary address → log).
- **[`COMMANDER.md`](COMMANDER.md)** standing-orders template — pre-filled Tier 1 auto-approval caps and Tier 2 always-escalate lists so commanders fill blanks instead of designing from scratch.
- **Per-skill Safety callouts** on all 11 affected skills ([`structs-onboarding`](.cursor/skills/structs-onboarding/SKILL.md), [`structs-mining`](.cursor/skills/structs-mining/SKILL.md), [`structs-building`](.cursor/skills/structs-building/SKILL.md), [`structs-combat`](.cursor/skills/structs-combat/SKILL.md), [`structs-economy`](.cursor/skills/structs-economy/SKILL.md), [`structs-energy`](.cursor/skills/structs-energy/SKILL.md), [`structs-power`](.cursor/skills/structs-power/SKILL.md), [`structs-guild`](.cursor/skills/structs-guild/SKILL.md), [`structs-diplomacy`](.cursor/skills/structs-diplomacy/SKILL.md), [`structs-exploration`](.cursor/skills/structs-exploration/SKILL.md), [`structs-guild-stack`](.cursor/skills/structs-guild-stack/SKILL.md)). Each callout lists the skill's highest-impact ops with their tier and in-character flavor.
- **[`.cursor/skills/structs-guild-stack/SKILL.md`](.cursor/skills/structs-guild-stack/SKILL.md)** "Lifecycle & Trust" subsection — pin a release tag rather than tracking `main`, disable services not needed (read-only PG profile), bind MCP to `127.0.0.1`, signing-agent caveat, teardown commands.

### Changed

- [`AGENTS.md`](AGENTS.md), [`README.md`](README.md), [`index.md`](index.md), [`QUICKSTART.md`](QUICKSTART.md), [`llms.txt`](llms.txt), [`SITEMAP.md`](SITEMAP.md), and [`awareness/index.md`](awareness/index.md) — surface SAFETY.md and agent-security.md as discoverable entry points; added Critical Rule 9 in AGENTS.md.
- [`scripts/generate-llms-full.sh`](scripts/generate-llms-full.sh) — includes SAFETY.md and `awareness/agent-security.md` in the aggregated build.

### Context

Responds to [ClawScan](https://clawhub.ai/abstrct) audits of 11 Structs skills (ASI02 `-y` auto-confirm; ASI03 signing-key scope; ASI04 binary trust; ASI06 personal-file context poisoning; ASI07 guild API + MCP; ASI10 long-running PoW). Keeps `-y` in `TX_FLAGS` for ergonomics and instead makes the approval gate explicit through a commander-grounded tier system. `structsd-install` was the only audited skill that already passed; it remains unchanged.

## [1.8.0] - 2026-05-13

### Added

- **Public SSL chain endpoint** documented as the canonical example for chain queries: `https://public.testnet.structs.network` (REST) and `https://public.testnet.structs.network:26657` (Tendermint RPC; `wss://...:26657/websocket` for the Tendermint WebSocket). The new endpoint avoids mixed-content and CORS issues that occurred when calling `http://reactor.oh.energy:1317` from HTTPS contexts. The Guild API (`http://crew.oh.energy/api/`) and GRASS NATS WebSocket (`ws://crew.oh.energy:1443`) remain hosted by individual guilds and are unchanged.
- **Webapp catalog read API**: 19 new per-entity files in [`api/webapp/`](api/webapp/) covering the `CatalogReadController` family (`address-tag`, `agreement`, `allocation`, `banned-word`, `defusion`, `fleet/list`, `grid`, `guild-membership-application`, `permission`, `permission-guild-rank`, `planet-activity`, `planet-attribute`, `provider`, `reactor`, `substation`, `struct-attribute`, `struct-defender`) plus `setting` (live tunables) and `stat` (time-series range queries). Existing per-entity files (`player.md`, `planet.md`, `guild.md`, `struct.md`, `ledger.md`, `infusion.md`) extended with their corresponding `/list/...` catalog endpoints.
- **Webapp protocol additions** in [`protocols/webapp-api-protocol.md`](protocols/webapp-api-protocol.md): catalog-read pattern, time-series stats pattern, live-tunables pattern, kebab-case naming, the `/list/` namespacing rule that prevents the catalog list from shadowing single-id routes, and the `?start_time=&end_time=` (unix seconds) query convention.
- **structs-pg schema additions** in [`knowledge/infrastructure/database-schema.md`](knowledge/infrastructure/database-schema.md): new tables `structs.banned_word`, `structs.address_tag` (with the `(label, entry)` reverse-lookup index), `structs.setting` (seeded keys: `REACTOR_RATIO`, `PLAYER_RESUME_CHARGE`, `PLANETARY_SHIELD_BASE`, `PLAYER_PASSIVE_DRAW`, `PLANET_STARTING_ORE`, `PLANET_STARTING_SLOTS`), `structs.defusion` (with the `CLEAN_DEFUSION()` cron), aggregated views `view.guild_bank`, `view.leaderboard_guild`, `view.leaderboard_player`, and the `planet.seized_ore` column. [`knowledge/infrastructure/guild-stack.md`](knowledge/infrastructure/guild-stack.md) gained a one-paragraph note that the PG schema is owned by `structs-pg` and applied with Sqitch (initial deploy by `structs-pg-init`, ongoing by `structs-pg-auto-migrate`).

### Changed

- **Reference node** in [`TOOLS.md`](TOOLS.md) switched to `https://public.testnet.structs.network` and the SSL Tendermint URL (`wss://...:26657/websocket`). Skills (`play-structs`, `structs-onboarding`, `structs-streaming`) and the `create-player.mjs` script header / usage strings updated to match.
- **Endpoint indexes** ([`api/endpoints.md`](api/endpoints.md), [`reference/endpoint-index.md`](reference/endpoint-index.md), [`reference/endpoint-quick-lookup.md`](reference/endpoint-quick-lookup.md), [`reference/api-quick-reference.md`](reference/api-quick-reference.md), [`api/webapp/README.md`](api/webapp/README.md)) refreshed to register the new webapp endpoints and the SSL chain hosts. Stale per-doc "Version" pins removed in favour of `Last Updated` dates only — these documents represent current truth, not versioned history.
- **structsd v0.16 wording reconciled**: documented the fact that there is no `MsgGuildModerate*` message in `tx.proto`. Moderation is the same `Msg*UpdateName` / `Msg*UpdatePfp` chain message, gated by `PermGuildUGCUpdate` (bit 24) on the target owner's guild when actor != owner, and the chain emits a `ugc_moderated` Cosmos event for audit. The 1.7.0 entry below references "Guild moderation overrides: `MsgGuildModeratePlayerName/Pfp` ..." — those names refer to `tx_guild_moderate_*` PL/pgSQL wrappers in the **signer** layer (which queue the same `Msg*Update*` chain message after a `PermGuildUGCUpdate` preflight), not to chain message types. [`knowledge/infrastructure/database-schema.md`](knowledge/infrastructure/database-schema.md) reworded the `signer.tx_*` wrapper section to make this explicit.

### Removed

- Per-file "Version: 1.x.0" pins on touched documentation files. The repo now expresses freshness only via `Last Updated` dates on the file and via this `CHANGELOG.md`.

## [1.7.0] - 2026-04-28

### Added - v0.16.0 (Quantillia) / structstestnet-112

Major documentation update for `structsd` v0.16.0 (codename "Quantillia"). Synchronizes the docs with the chain's permission expansion (24->25 bit), the new fee/ante model, the seven new UGC (User-Generated Content) transactions and their decentralized moderation hooks, the `GuildMembershipJoinProxy` UGC fields, the planet-explore precondition tightening, the Starfighter guaranteed-shot fix, the Quantillia database schema, and the related webapp / signer / build-system changes. Includes two new knowledge documents (`transactions.md`, `ugc-moderation.md`) and a Makefile-based install path.

#### Permission System (24-bit -> 25-bit)

- `PermAll` and `PermPlayerAll` bumped from `16777215` to `33554431` (25 bits).
- New permission flag `PermGuildUGCUpdate` (bit 24, value `16777216`) for guild-scoped moderation of player/planet/substation UGC.
- `PermGuildAll` updated to `17166862`.
- `knowledge/mechanics/permissions.md` now documents `UGCPermissionCheck` -- the two-tier flow that first attempts a self-service `PermUpdate` check, and falls back to `PermGuildUGCUpdate` against the target owner's guild.
- All affected docs updated: `api/queries/permission.md`, `schemas/entities.md`, `schemas/game-state.md`, `knowledge/mechanics/index.md`, `reference/entity-index.md`, `reference/action-quick-reference.md`, `troubleshooting/edge-cases.md`, `troubleshooting/permission-issues.md`, `patterns/performance-optimization.md`, `examples/database/query-examples.md`, `examples/workflows/permission-checking.md`, `examples/auth/permission-examples.md`, `.cursor/skills/structs-diplomacy/SKILL.md`, `.cursor/skills/structs-guild/SKILL.md`, `SITEMAP.md`, `llms.txt`.

#### Free Gameplay Transactions and Custom Ante Handler

- **NEW: `knowledge/mechanics/transactions.md`** -- explains the v0.16.0 fee model: pure-Structs gameplay transactions (allocations, substations, guilds, combat, UGC, ...) are free with a 20M gas cap; six Cosmos SDK staking messages are free with a 40M gas cap (one per address per block); standard Cosmos SDK operations (`MsgSend`, non-listed `x/staking` messages, mixed transactions) still pay `ualpha`. `--gas auto` is still required for accurate gas estimation.
- `protocols/action-protocol.md` updated with a new "Fees" subsection summarizing the free-gas changes.

#### UGC Transactions and Decentralized Moderation

- **NEW: `knowledge/mechanics/ugc-moderation.md`** -- philosophy and how-to for guild-scoped moderation. Covers self-service vs. moderator paths, the `PermGuildUGCUpdate` permission, the `ugc_moderated` Cosmos chain event (emitted only when `actor != owner`), per-field validation rules with Python and JavaScript snippets, and operational guidance for guild policy/auditing.
- Seven new transactions documented across `schemas/actions.md`, `reference/action-quick-reference.md`, `.cursor/skills/structs-guild/SKILL.md`, and the structsd CLI references:
  - Self-service: `MsgPlayerUpdateName`, `MsgPlayerUpdatePfp`, `MsgGuildUpdateName`, `MsgGuildUpdatePfp`, `MsgPlanetUpdateName`, `MsgSubstationUpdateName`, `MsgSubstationUpdatePfp` (all gated by `PermUpdate` on the target object)
  - Guild moderation overrides: `MsgGuildModeratePlayerName/Pfp`, `MsgGuildModeratePlanetName`, `MsgGuildModerateSubstationName/Pfp` (all gated by `PermGuildUGCUpdate` on the target owner's guild)
- `knowledge/lore/factions.md` got a new "Identity and moderation" subsection introducing the model in lore terms.

#### UGC String Validation

- Per-profile validation rules added to `schemas/validation.md` and fully spelled out in `knowledge/mechanics/ugc-moderation.md` for: player name (3-20, no spaces, no apostrophe), entity name (guild/substation, 3-20, allows space and apostrophe, no leading/trailing/double space), planet name (3-25, same as entity), and PFP (opaque `[A-Za-z0-9._/-]{1,256}` or URL with allowed schemes `https`, `http`, `ipfs`, `ipns`, `ar`).
- All names: NFC-normalized, no control characters, no bidi/zero-width/format/combining marks, no `N-N` ID-shaped strings, must be valid UTF-8.
- `.cursor/skills/structs-onboarding/scripts/create-player.mjs` -- new `--username` and `--pfp` flags, client-side validators that mirror the chain's `ValidatePlayerName` / `ValidatePfp`, and `pfp` plumbed into the signup payload and final output.

#### `GuildMembershipJoinProxy` UGC Fields

- `MsgGuildMembershipJoinProxy` now accepts optional `playerName` and `playerPfp` so the chain becomes the sole source of truth for player identity at signup. Documented in `schemas/actions.md`, `reference/action-quick-reference.md`, `.cursor/skills/structs-guild/SKILL.md`, `.cursor/skills/structs-onboarding/SKILL.md`, and threaded through `create-player.mjs`.

#### Planet Exploration Precondition

- `MsgPlanetExplore` now requires the fleet to be `onStation` at the player's current planet *only when the player already owns one*. First-time explorers (no current planet) are exempt. Documented in `schemas/actions.md`, `knowledge/mechanics/planet.md`, `knowledge/mechanics/fleet.md`, and `.cursor/skills/structs-exploration/SKILL.md`. New error string `"fleet must be onStation to explore"` added to the exploration skill's error handling.

#### Starfighter Guaranteed Shots

- New struct-type fields `primaryWeaponGuaranteedShots` and `secondaryWeaponGuaranteedShots` documented in `knowledge/entities/struct-types.md`. Starfighter's secondary weapon is set to `1` guaranteed shot.
- `knowledge/mechanics/combat.md` Multi-Shot Damage section explains how `weaponGuaranteedShots` provides a floor of successful hits per volley before probabilistic rolls.

#### Streaming and Events

- `api/streaming/event-types.md` and `api/streaming/event-schemas.md` updated:
  - `PlayerMetaEvent` now carries `username` and `pfp` (chain is sole source of truth as of v0.16.0).
  - `GuildMetaEvent` now carries `pfp` in addition to `name`.
  - New section/schema for the **Cosmos chain** `ugc_moderated` event with attribute schema and emission rules. (Not delivered through GRASS -- subscribe via Tendermint event subscriptions.)
- `.cursor/skills/structs-streaming/SKILL.md` got a "UGC Moderation Events" section explaining the two streams (GRASS DB-trigger meta events vs. the chain `ugc_moderated` event) and the "actor != owner" emission condition.

#### Database Schema (Quantillia / structs-pg)

- `knowledge/infrastructure/database-schema.md` updated:
  - New rows for `structs.guild_meta` (now with `pfp`), `structs.player_meta` (PK collapsed from `(id, guild_id)` to `(id)` -- one row per player; webapp no longer writes meta directly), `structs.substation` (with `name` and `pfp`), and `structs.planet_meta` (chain-only updates, never overwritten by empty values).
  - New `signer.signer_tx_type` enum values for the seven UGC transactions.
  - 12 new `signer.tx_*` wrappers documented (7 self-service + 5 guild moderation).
  - `signer.UPDATE_PENDING_ACCOUNT` bumped to `PermAll = 33554431`.
  - `PLAYER_PENDING_JOIN_PROXY` trigger now threads `playerName`/`playerPfp` into the `ugc` JSONB; `PLAYER_PENDING_MERGE` no longer writes `player_meta`.

#### Webapp API

- `PUT /api/player/username` removed in v0.16.0. Username and PFP are now updated via the chain `MsgPlayerUpdate*` transactions; the webapp's signing client manager queues them through `queueMsgPlayerUpdateName` / `queueMsgPlayerUpdatePfp`. Updated: `api/endpoints.md`, `api/endpoints-by-entity.md`, `api/webapp/player.md`, `api/rate-limits.md`, `schemas/requests.md`.
- New `queueMsg*` wrappers (10 new entries) added to the webapp registry alongside `MsgGuildMembershipJoinProxy`'s expanded args; `queueMsgBankSend` removed (no callers).

#### Build System

- **structsd-install skill rewritten**: switched from Ignite-based builds to two supported paths -- (A) prebuilt release binaries from <https://github.com/playstructs/structsd/releases>, or (B) build from source via the Makefile (`make install` / `make build`). Go 1.23+ now required (was 1.24.1). Ignite is only needed for local devnet (`make serve`).
- Cross-compilation targets documented (`build-linux-amd64`, `build-darwin-arm64`, ..., `build-all`).

#### Top-Level / Indices

- `AGENTS.md`, `SITEMAP.md`, `llms.txt`, and `TOOLS.md` updated to reflect the new structsd-install description.
- `scripts/generate-llms-full.sh` includes `knowledge/mechanics/transactions.md` and `knowledge/mechanics/ugc-moderation.md`. `llms-full.txt` regenerated.

---

## [1.6.0] - 2026-03-26

### Added - v0.15.0-beta (Pyrexnar) / structstestnet-111

Major update incorporating all changes from Structs v0.15.0-beta (codenamed Pyrexnar) on the structstestnet-111 network. v0.14.0-beta (Opheliora) was a botched release; v0.15.0-beta (Pyrexnar) supersedes it with proxy join and test fixes.

#### Permission System Overhaul (8-bit -> 24-bit)

- **NEW: `knowledge/mechanics/permissions.md`** -- Comprehensive permission reference combining the Permission System, Guild Rank Permission System, and Message Handler Permission Reference. Covers all 24 permission bits, composite masks, storage format, check flow, and every handler's permission requirements.
- Permissions expanded from 8 flags (PermAll=255) to 24 flags (PermAll=16777215) with HasAll semantics (all required bits must be present)
- Old struct-specific permissions removed in favor of new fine-grained flags: PermTokenTransfer, PermTokenInfuse, PermTokenMigrate, PermTokenDefuse, PermSourceAllocation, PermGuildMembership, PermSubstationConnection, PermAllocationConnection, PermGuildTokenBurn, PermGuildTokenMint, PermGuildEndpointUpdate, PermGuildJoinConstraintsUpdate, PermGuildSubstationUpdate, PermProviderWithdraw, PermProviderOpen, PermReactorGuildCreate, PermHashBuild, PermHashMine, PermHashRefine, PermHashRaid
- Guild Rank Permission System: rank-based access control where guild members receive permissions based on their numeric rank (lower = more privileged)
- New transactions: `permission-guild-rank-set`, `permission-guild-rank-revoke`, `player-update-guild-rank`
- New queries: `guild-rank-permission-by-object`, `guild-rank-permission-by-object-and-guild`
- All examples, troubleshooting, patterns, and reference files updated with 24-bit values

#### Combat Engine Rewrite

- Attack resolution centralized into AttackContext with typed result structs
- Counter-attacks now fire at most once per `struct-attack` invocation (not per shot)
- Defender counter-attack fires before block and on evaded shots
- Target counter-attack fires after all shots resolve; destroyed targets cannot counter
- Block does NOT fire on evaded shots
- Each projectile gets its own EventAttackShotDetail row (per-projectile events)
- `targetPlayerId` moved from EventAttackDetail to EventAttackShotDetail (API-breaking)
- Planetary Defense Cannon now correctly reports when cannons fire; multiple PDCs stack
- EvadedCause only set on successful evasion

#### Allocation System Rework

- `controller` field is now PlayerId (not address) -- account abstraction
- `locked` column removed from allocation table
- Source capacity underloads properly guarded
- `provider-guild-grant` and `provider-guild-revoke` transactions removed; replaced by guild rank permissions (`permission-guild-rank-set` with PermProviderOpen on the provider)

#### New Entity Fields

- Guild: `entryRank` (uint64) -- default rank for new members (chain default: 101)
- Player: `guildRank` (uint64) -- rank within guild (1 = creator, 101 = default on join)
- Reactor: `owner` (string) -- PlayerId of reactor owner

#### New/Changed Transactions

- Added: `guild-create` (from reactor), `guild-update-entry-rank`, `player-update-guild-rank`, `player-send`, `permission-guild-rank-set`, `permission-guild-rank-revoke`
- Removed: `provider-guild-grant`, `provider-guild-revoke`
- Changed args: `player-update-primary-address` (removed playerId), `address-register` (removed playerId)

#### Database Schema

- New table: `structs.permission_guild_rank` (object_id, guild_id, permission, rank)
- New columns: `guild.entry_rank`, `player.guild_rank`, `reactor.owner`
- Removed column: `allocation.locked`
- New event: `EventGuildRankPermission`
- Cache handler updates for all affected entities
- Permission views rewritten for 24-bit flags

### Updated Files

- `knowledge/mechanics/permissions.md` -- NEW
- `knowledge/mechanics/combat.md` -- Attack resolution rewrite, counter-attack overhaul, PDC fix, per-projectile events
- `knowledge/mechanics/index.md` -- Permissions entry
- `knowledge/economy/energy-market.md` -- Controller=PlayerId, provider access via guild rank
- `knowledge/infrastructure/database-schema.md` -- New tables, columns, removed locked
- `schemas/entities/allocation.md` -- Controller=PlayerId, removed locked
- `schemas/entities/guild.md` -- entryRank field
- `schemas/entities/player.md` -- guildRank field
- `schemas/entities/reactor.md` -- owner field
- `schemas/entities.md` -- 24-bit permission flags
- `schemas/game-state.md` -- 24-bit permission flags
- `schemas/actions.md` -- New transactions, updated requirements
- `reference/action-quick-reference.md` -- New actions, permission/allocation/provider sections
- `reference/entity-index.md` -- New fields, 24-bit perms
- `reference/gameplay-index.md` -- Counter-attack mechanics
- `api/queries/permission.md` -- Guild rank queries
- `api/queries/guild.md` -- entryRank
- `api/queries/player.md` -- guildRank
- `api/queries/reactor.md` -- owner
- `api/streaming/event-types.md` -- EventGuildRankPermission
- `api/streaming/event-schemas.md` -- EventGuildRankPermission, targetPlayerId move
- `api/endpoints.md` -- Guild rank permission endpoints
- `api/endpoints-by-entity.md` -- Guild rank permission queries
- `.cursor/skills/structs-combat/SKILL.md` -- Counter-attack rules, PDC notes
- `.cursor/skills/structs-economy/SKILL.md` -- Controller=PlayerId, provider access
- `.cursor/skills/structs-energy/SKILL.md` -- Guild rank provider access
- `.cursor/skills/structs-power/SKILL.md` -- Controller=PlayerId
- `.cursor/skills/structs-diplomacy/SKILL.md` -- 24-bit perms, guild rank commands, arg changes
- `.cursor/skills/structs-guild/SKILL.md` -- guild-create, rank system, provider access
- `.cursor/skills/structs-onboarding/SKILL.md` -- Guild rank note
- `troubleshooting/permission-issues.md` -- 24-bit perms, HasAll, guild rank
- `troubleshooting/edge-cases.md` -- 24-bit perms
- `examples/auth/permission-examples.md` -- 24-bit perms, guild rank examples
- `examples/workflows/permission-checking.md` -- 24-bit perms, guild rank step
- `examples/database/query-examples.md` -- 24-bit perms
- `examples/gameplay-combat-bot.md` -- Per-projectile events, counter-attack
- `protocols/gameplay-protocol.md` -- Combat mechanics, battleDetails
- `patterns/performance-optimization.md` -- 24-bit bitwise checks
- `patterns/decision-tree-combat.md` -- Combat resolution order
- `AGENTS.md` -- Permissions in Knowledge section
- `SITEMAP.md` -- permissions.md entry
- `llms.txt` -- permissions.md entry
- `sitemap.xml` -- permissions URL

---

## [1.5.0] - 2026-02-24

### Added - Async Agent Architecture

Major overhaul addressing PoW timing and async operations, based on agent field experience:

- **NEW: `awareness/async-operations.md`** -- Core document teaching agents the async pattern: pipeline strategy, background PoW management, job/charge tracker templates, difficulty planning table, multi-player orchestration, ore vulnerability analysis.
- **Timing corrections across all docs** -- Previous estimates were wrong by 1-2 orders of magnitude. Mining takes ~8 hours (D=8) not ~15-30 min. Refining takes ~15 hours (D=8) not ~30-45 min. All skills and mechanics docs updated with correct calculations.
- **Difficulty cliff documented** -- D=8 to D=9 cliff is the most important tactical fact in PoW. Hash is instant at D<=8, impossible at D>=9. Recommended `-D 8` for all operations.
- **Game loop updated** -- Added "Check Jobs" (step 0) and "Dispatch" step. Renamed "Passive" tempo to "Pipeline" mode.
- **Playbooks reframed** -- Early game changed from "First 30 minutes" to "First 1-2 days". Build order updated with pipeline strategy. Mid-game and tempo docs updated with realistic multi-day timelines.
- **Ore vulnerability window** -- New section in `resources.md`: ore is stealable for ~15-24 hours between mining and refining completion. Primary driver of PvP conflict.
- **Context handoff expanded** -- Templates now include Active PoW Jobs, Pending Initiations, and Charge Status sections.
- **Continuity updated** -- Memory file list includes `jobs.md`, `charge-tracker.md`, `game-state.md`. Session resume checks jobs first.
- **Critical rule #5** -- "Never block on PoW" added to AGENTS.md.
- **`llms.txt` and `llms-full.txt` updated** -- New async-operations entry, corrected descriptions, regenerated full text.

### Updated Files

- `awareness/async-operations.md` -- NEW
- `knowledge/mechanics/building.md` -- Difficulty decay table, cliff, charge costs, async cross-reference
- `knowledge/mechanics/resources.md` -- PoW timing table, ore vulnerability window
- `.cursor/skills/structs-onboarding/SKILL.md` -- Correct timing, async strategy, D=8 recommendation
- `.cursor/skills/structs-building/SKILL.md` -- Correct timing, async cross-reference
- `.cursor/skills/structs-mining/SKILL.md` -- Multi-hour timing, pipeline strategy
- `.cursor/skills/structs-combat/SKILL.md` -- Background raid compute, fleet lock note
- `awareness/game-loop.md` -- Async loop, pipeline tempo mode
- `awareness/context-handoff.md` -- Job state in handoff template
- `awareness/continuity.md` -- Memory file list expanded
- `playbooks/phases/early-game.md` -- Reframed to 1-2 days, pipeline build order
- `playbooks/phases/mid-game.md` -- Days/weeks timeline
- `playbooks/meta/tempo.md` -- Tempo through parallelism section
- `AGENTS.md` -- Async-operations in awareness, timeline fix, rule #5
- `llms.txt` -- Async-operations entry, corrected descriptions
- `scripts/generate-llms-full.sh` -- Added async-operations.md
- `llms-full.txt` -- Regenerated
- `awareness/index.md` -- Async-operations entry
- `playbooks/phases/index.md` -- Timeline fix
- `reference/gameplay-index.md` -- Timeline fix

---

## [1.4.0] - 2026-02-24

### Fixed - Agent Operational Documentation

Addressed 10 issues reported by an AI agent during first play session:

- **Struct type IDs corrected** -- Command Ship is type 1 (was incorrectly listed as 14), Ore Extractor is type 14. All skills now use explicit, verified type IDs.
- **Complete struct type table** -- All 22 struct types added to `knowledge/entities/struct-types.md` with DB-verified stats: ID, category, build difficulty, build/passive draw, max HP, and possible ambit.
- **Ambit bit-flag encoding documented** -- Space=16, Air=8, Land=4, Water=2. Added to struct-types, building mechanics, and onboarding skill.
- **Compute vs Complete clarified** -- `struct-build-compute` (and mine-compute, refine-compute, raid-compute) are helpers that calculate the hash AND auto-submit the complete transaction. Documented across all skills and building mechanics.
- **-D flag documented** -- Range 1-64, waits until difficulty drops to target level before hashing. Recommended `-D 5` for most operations. Added to building, mining, combat skills, and building mechanics.
- **Timing expectations added** -- Every skill now includes approximate durations. Build times range from ~2-5 min (Command Ship) to ~45-60 min (World Engine). Mine ~15-30 min, refine ~30-45 min.
- **`player-me` replaced** -- All references replaced with `structsd query structs address [address]`. Note: player ID `1-0` means nonexistent.
- **New player power budget** -- Added to `knowledge/mechanics/power.md`. Documents cumulative load through onboarding build order, minimum viable capacity (~575 kW).
- **TOOLS.md improved** -- Added deployment options, placeholder guidance, address query tip, MCP parameter reference.

### Fixed - MCP Query Tools

- **Parameter bug resolved** -- MCP query tools now accept both entity-specific parameters (`player_id`, `planet_id`, etc.) and generic `id` as an alias.
- **Root cause** -- Callers using generic `id` left entity-specific params undefined, causing crash in `validateEntityId`. Server now guards against undefined/null/non-string IDs.
- **MCP query parameter reference** added to `TOOLS.md` with correct parameter names and examples for all 10 query tools.

### Updated Files

- `.cursor/skills/structs-onboarding/SKILL.md` -- Rewrote: correct type IDs, address query, -D flag, timing, ambit encoding
- `.cursor/skills/structs-building/SKILL.md` -- Compute/complete clarification, -D flag, build time table
- `.cursor/skills/structs-mining/SKILL.md` -- Compute auto-complete, timing section
- `.cursor/skills/structs-combat/SKILL.md` -- Raid compute auto-complete, -D flag, raid timing
- `.cursor/skills/structs-reconnaissance/SKILL.md` -- Address query pattern, 1-0 note
- `knowledge/mechanics/building.md` -- Build process, -D flag, timing, ambit encoding section
- `knowledge/entities/struct-types.md` -- Complete 22-type table, ambit encoding, combat stats
- `knowledge/mechanics/power.md` -- New player power budget section
- `TOOLS.md` -- Deployment, placeholders, MCP query parameter reference

---

## [1.3.0] - 2026-02-24

### Chain Releases Covered

- **v0.10.0-beta (Junctiondale)** -- Sticky State (partial; some items in 1.2.0)
- **v0.11.0-beta (Luxoria)** -- IBC v10, SDK v0.53.5, open hashing, genesis improvements
- **v0.12.0-beta (Mystigon)** -- Context Manager refactor, combat fixes, raid improvements
- **v0.13.0-beta (Nebulon)** -- Indexer commit order fix

### Changed - Combat Mechanics

- **Minimum damage floor** (v0.12.0-beta)
  - After damage reduction, minimum damage is now 1 -- attacks always deal at least 1 damage
  - Updated `knowledge/mechanics/combat.md` with minimum damage edge case

- **Offline counter-attack fix** (v0.12.0-beta)
  - Offline/destroyed structs can no longer counter-attack
  - Counter-attack now requires full readiness check including weapon system validation
  - Updated `knowledge/mechanics/combat.md` counter-attack section

- **Attack health results** (v0.11.0-beta)
  - Attack events now include remaining health values in addition to damage amounts
  - Updated `knowledge/mechanics/combat.md` algorithm description

- **Multi-commit prevention** (v0.11.0-beta)
  - Each struct can only commit once per attack action (prevents double-commit on same target)
  - Updated `knowledge/mechanics/combat.md` edge cases

- **Target struct validation** (v0.11.0-beta)
  - Target struct existence is now validated before attack proceeds
  - Updated `knowledge/mechanics/combat.md` edge cases

### Added - Raid Improvements

- **Seized ore tracking** (v0.12.0-beta)
  - `seized_ore` (numeric) field added to `planet_raid` table
  - Tracks total ore stolen during a raid for easier victory handling
  - Updated `schemas/entities/planet.md` with `planet_raid` table schema
  - Updated `knowledge/mechanics/planet.md` raid vulnerability section
  - Updated `knowledge/mechanics/combat.md` outcomes section

### Changed - Building & Hashing

- **Open hashing by default** (v0.11.0-beta)
  - All proof-of-work operations (build, mine, refine, raid) now accept hashes openly
  - Zero-block hashing results handled correctly post-migration
  - Updated `knowledge/mechanics/building.md` proof-of-work section

### Changed - Fleet Movement

- **Fleet movement readiness fix** (v0.12.0-beta)
  - Fixed `MoveReadiness` bug that erroneously checked for fleet-away status
  - Fixed error on fleet movement to populated planet
  - Updated `knowledge/mechanics/fleet.md` fleet movement section

### Added - Struct Fields

- **`destroyed_block` field** (v0.12.0-beta)
  - `destroyed_block` (bigint) added to struct table -- records block height of destruction
  - Updated `schemas/entities/struct.md` with new field
  - Updated `knowledge/mechanics/building.md` StructSweepDelay note
  - Corrected existing `destroyed` field: DB column is actually `is_destroyed` (boolean)

### Added - Provider Guild Access

- **`ProviderGuildAccessRecord`** (v0.12.0-beta)
  - New protobuf message for provider-guild access tracking
  - Fields: `providerId`, `guildId`
  - Used for genesis import/export of provider access policies
  - Updated `schemas/entities/provider.md`

### Changed - Internal Architecture (v0.11.0-v0.12.0)

- **Cosmos SDK v0.53.5 and IBC v10 upgrade** (v0.11.0-beta)
- **General Context Manager** (v0.12.0-beta) -- major keeper refactoring introducing `*_context.go` files for all entity types
- **Structured error types** (v0.11.0-beta) -- migrated error handling to structured error types
- **Improved genesis import/export** (v0.11.0-beta) -- allocation count, reactor index, index rebuild, block attribute resets
- **Object deletion consistency** (v0.11.0-beta) -- resolved inconsistencies in object deletion
- **Indexer commit order fix** (v0.13.0-beta) -- attributes now committed after objects to prevent indexer cascading failures

### Added - Database Schema Changes

- **`struct.destroyed_block`** (bigint) -- block height of destruction (2026-02-07)
- **`planet_raid.seized_ore`** (numeric) -- ore seized during raids (2026-02-21)
- **`struct_health`** added to `grass_category` enum for planet activity events (2026-01-15)
- **`handle_event_struct_defender_clear`** cache function (2026-01-11)
- **`player_address_cascade`** trigger on player table for onboarding (2026-02-23)
- **Cache system refactor** (2026-01-21) -- 41 handler functions in cache schema
- **`view.work` zero-block fix** (2026-01-19)
- **Player insert trigger fix** for guild association (2026-01-23)
- **Defender clear caching** -- multiple iterations fixing defender removal event processing (2026-01-11 through 2026-01-18)
- **Zero-value attribute cleanup** in cache handlers (2026-02-03)
- See `schemas/database-schema.md` for complete migration log

### Added - Webapp Features (PRs #16-#40)

- **Struct actions UI** -- move (#29-#30), defend (#32), attack (#37-#38), stealth (#28)
- **Raid end dialogues** (#39) -- victory/defeat notification sequences with Lottie animations
- **Struct HUD** (#27) -- struct status display with real-time updates
- **Progress estimations** (#16) -- estimated completion times for proof-of-work tasks
- **Signing Manager** cleanup (#20) and TX response logging (#31)
- **Key player refactor** (#22-#23) -- improved player state management
- **Command Ship loading** during planet exploration (#25)
- **Map rendering fixes** (#35-#36) -- struct rendering on preview map, raid enemy map display
- **Planet depart button** fix and messaging update (#40)
- **Gameplay bug fixes** (#33-#34) -- action bar visibility, various gameplay issues

### Updated - Documentation Files

- `schemas/database-schema.md` -- v0.10.0-v0.13.0 changelog, database schemas overview, verified table/view/trigger definitions
- `schemas/entities/struct.md` -- `destroyed_block` field, corrected `is_destroyed` column name, updated verification
- `schemas/entities/planet.md` -- planet view fields, `planet_raid` table, `seized_ore`, updated verification
- `schemas/entities/provider.md` -- `ProviderGuildAccessRecord`
- `knowledge/mechanics/combat.md` -- minimum damage, counter-attack fixes, seizedOre, health results, edge cases
- `knowledge/mechanics/fleet.md` -- movement readiness fix, populated planet fix
- `knowledge/mechanics/building.md` -- open hashing, destroyed_block in sweep delay
- `knowledge/mechanics/planet.md` -- seized ore tracking in raids
- `.cursor/skills/structs-combat/SKILL.md` -- combat notes, verification updates

---

## [1.2.0] - 2026-01-16

### Added - Streaming Events

- **Struct Defender Clear Event** (v0.10.0-beta)
  - Added `struct_defender_clear` to streaming event types
  - Updated GRASS event category list to include defender-clear events

### Added - Genesis Operations

- **Genesis Import/Export Notes** (v0.10.0-beta)
  - Added operator notes for import/export completeness changes
  - Documented allocation count, reactor index, and index rebuild behavior

### Changed - Action Requirements

- **Struct Activate Charge** (v0.10.0-beta)
  - Documented `activateCharge = 1` for all struct types in genesis
  - Updated action quick reference charge guidance

- **Build Cancel Requirements** (v0.10.0-beta)
  - Documented that build cancel no longer requires charge or player online

### Changed - Onboarding & Command Ship

- **Initial Command Ship Grant** (v0.10.0-beta)
  - Documented initial Command Ship grant at player creation
  - Updated onboarding flow to verify existing Command Ship and activate if offline

## [1.1.0] - 2026-01-01

### Added - Permissions

- **Hash Permission** (v0.8.0-beta)
  - Added new Hash permission bit to permission system
  - Permission values are bit-based flags that can be combined
  - Hash permission bit value: 64
  - Updated `schemas/game-state.md` with permission bit documentation
  - See `schemas/game-state.md#/definitions/Permission` for details

### Added - Combat & Raids

- **New Raid Status: `attackerRetreated`** (v0.8.0-beta)
  - Added `attackerRetreated` status to raid outcome enum in `schemas/gameplay.md`
  - Updated `api/streaming/event-schemas.md` to include attackerRetreated in PlanetRaidStatusEvent
  - Documented new status in `protocols/gameplay-protocol.md`
  - Updated `examples/gameplay-combat-bot.md` to handle attackerRetreated status
  - Status indicates attacker retreated from raid before completion
  - No resources gained or lost when attacker retreats

### Added - Reactor Staking & Validation Delegation

- **Reactor Staking Functionality** (v0.8.0-beta)
  - Added reactor staking fields to `schemas/entities/reactor.md`
  - Documented player-level staking management
  - Added staking delegation statuses: `active`, `undelegating`, `migrating`
  - Updated `schemas/economics.md` with reactor staking section
  - Updated `reference/entity-index.md` with staking information

- **Validation Delegation Actions** (v0.8.0-beta)
  - Updated `MsgReactorInfuse` to handle validation delegation
  - Updated `MsgReactorDefuse` to handle validation undelegation
  - Added `MsgReactorBeginMigration` action for redelegation
  - Added `MsgReactorCancelDefusion` action to cancel undelegation
  - All actions documented in `schemas/actions.md`
  - Added comprehensive workflow examples in `protocols/economic-protocol.md`
  - Added reactor staking examples to `examples/economic-bot.md`

### Added - Struct Lifecycle

- **StructSweepDelay** (v0.8.0-beta)
  - Added block-based delay (5 blocks) for struct sweeping
  - Documented in `lifecycles/struct-lifecycle.md`
  - Added constant to `schemas/gameplay.md`
  - Planet/fleet slot references persist during delay period
  - Slots fully cleared after 5 blocks

### Changed - Fleet Movement

- **Fleet Movement Improvements** (v0.8.0-beta)
  - Updated `lifecycles/fleet-lifecycle.md` with bug fix documentation
  - Improved fleet movement logic and validation
  - Better error handling for invalid movements
  - More reliable fleet status transitions

### Changed - Membership Join Process

- **Streamlined Redelegation** (v0.8.0-beta)
  - Updated `protocols/economic-protocol.md` with membership join improvements
  - Staked assets automatically redelegated during migration
  - Streamlined process for joining guilds

### Fixed - Bug Resolutions

- **GetInfusionByID Array Split Bug** (v0.8.0-beta)
  - Bug in GetInfusionByID array split logic resolved
  - Documented in `schemas/errors.md` and `troubleshooting/common-issues.md`

- **EventGuildBankAddress Format Bug** (v0.8.0-beta)
  - Bug in EventGuildBankAddress format resolved
  - Documented in `schemas/errors.md` and `troubleshooting/common-issues.md`

- **BankAddress Format Logging Bug** (v0.8.0-beta)
  - Bug in BankAddress format logging resolved
  - Documented in `schemas/errors.md` and `troubleshooting/common-issues.md`

### Updated - Documentation

- **Version Updates**
  - Updated version numbers to 1.1.0 in all major schema files
  - Updated `AGENTS.md` version and last updated date
  - Updated `DOCUMENTATION_INDEX.md` version and last updated date
  - Updated `reference/action-quick-reference.md` with new actions

- **Quick References**
  - Updated `reference/action-quick-reference.md` with reactor staking actions
  - Added documentation for new validation delegation actions
  - Updated combat/raid quick reference with attackerRetreated status
  - Updated `reference/entity-index.md` with Hash permission information

- **Examples**
  - Updated `examples/gameplay-combat-bot.md` with attackerRetreated handling
  - Added reactor staking workflow to `examples/economic-bot.md`
  - Updated version to 1.1.0 in economic bot example

- **Error Handling**
  - Added resolved bugs section to `troubleshooting/common-issues.md`
  - Updated `schemas/errors.md` with v0.8.0-beta resolved bugs metadata
  - Documented all resolved bugs from v0.8.0-beta

### Added - Database Schema

- **Database Schema Documentation** (v0.8.0-beta)
  - Created `schemas/database-schema.md` documenting PostgreSQL schema changes
  - Documented all structs-pg repository changes from November-December 2025
  - See `schemas/database-schema.md` for complete database change log

- **Struct Table Changes** (v0.8.0-beta)
  - Added `destroyed` column to struct table (2025-12-29)
  - Tracks struct destruction status
  - Related to StructSweepDelay (5 blocks) - destroyed structs persist for 5 blocks
  - Updated `schemas/entities/struct.md` with destroyed field

- **Struct Type Table Changes** (v0.8.0-beta)
  - Added `cheatsheet_details` column (2025-11-29)
  - Added `cheatsheet_extended_details` column (2025-12-02)
  - Removed deprecated charge columns for mine and refine (2025-12-08)
  - Updated `schemas/entities/struct-type.md` with database change metadata

- **Permission System Database Changes** (v0.8.0-beta)
  - Added `permission_hash` level to permission view (2025-12-18)
  - Updated signer_tx table to support Hash permission (2025-12-18)
  - Added permissions column to player_address_pending table (2025-12-29)
  - Maps to Hash permission bit (value 64) in API layer

- **Transaction Signing Changes** (v0.8.0-beta)
  - Fixed Hash Complete nonces: INTEGER → CHARACTER VARYING (2025-12-15)
  - Updated transaction signing permission levels (2025-12-18)
  - Added new transaction types (2025-12-18)
  - Fixed signer account bug (2025-12-29)

- **View Improvements** (v0.8.0-beta)
  - Fixed raid logic in view.work (2025-12-13)
  - Improved exclusion logic to exclude impossible tasks (2025-12-27)
  - Removed deprecated charge columns from views (2025-12-08)

- **Cache and Trigger Updates** (v0.8.0-beta)
  - Fixed struct type cache commit (2025-12-18)
  - Fixed GRASS grid p values (2025-12-19)
  - Updated cache triggers for deprecated column removal (2025-12-08)

### Technical Details

- **Schema Changes**
  - `schemas/game-state.md`: Added Hash permission bit (64) documentation
  - `schemas/gameplay.md`: Added attackerRetreated status, StructSweepDelay constant
  - `schemas/entities/reactor.md`: Added staking fields and delegation properties
  - `schemas/entities.md`: Updated Permission entity with Hash permission info
  - `schemas/entities/struct.md`: Added destroyed field, updated version to 1.1.0
  - `schemas/entities/struct-type.md`: Added database change metadata, updated version to 1.1.0
  - `schemas/actions.md`: Updated Reactor Infuse/Defuse, added Begin Migration/Cancel Defusion
  - `schemas/economics.md`: Added reactor staking section
  - `schemas/errors.md`: Added v0.8.0-beta resolved bugs metadata
  - `schemas/database-schema.md`: New file documenting PostgreSQL schema changes

- **Protocol Updates**
  - `protocols/gameplay-protocol.md`: Added attackerRetreated status documentation
  - `protocols/economic-protocol.md`: Added reactor staking and validation delegation sections

- **Lifecycle Updates**
  - `lifecycles/struct-lifecycle.md`: Documented StructSweepDelay
  - `lifecycles/fleet-lifecycle.md`: Documented fleet movement improvements

---

## [1.0.0] - 2025-12-07

### Initial Release

- Comprehensive AI agent documentation
- Complete schema definitions
- Protocol documentation
- Example implementations
- Quick reference guides

---

## Version History

- **1.6.0** (2026-03-26): v0.15.0-beta (Pyrexnar) / structstestnet-111 -- Permission system overhaul (8-bit to 24-bit, guild rank permissions, HasAll semantics), combat engine rewrite (counter-attack limits, per-projectile events), allocation rework (controller=PlayerId, removed locked), new entity fields, new/changed/removed transactions, database schema updates. ~48 files updated, 1 new. Supersedes v0.14.0-beta (Opheliora).
- **1.4.0** (2026-02-24): Agent feedback fixes - Corrected struct type IDs, documented compute/complete workflow, -D flag, timing expectations, ambit encoding, new player power budget. MCP query tool parameter fix and documentation.
- **1.3.0** (2026-02-24): v0.10.0-v0.13.0-beta updates - Combat fixes (minimum damage, counter-attack), seized ore tracking, open hashing, destroyed_block, fleet movement fix, Context Manager refactor, SDK v0.53.5/IBC v10, database schema updates, webapp struct actions UI
- **1.2.0** (2026-01-16): v0.10.0-beta updates - Defender clear event, genesis import/export, activate charge, build cancel, initial Command Ship grant
- **1.1.0** (2026-01-01): v0.8.0-beta updates - Hash permission, reactor staking, attackerRetreated status, struct sweep delay, database schema changes, bug fixes
- **1.0.0** (2025-12-07): Initial release

---

*For detailed information about each change, see the relevant documentation files.*

