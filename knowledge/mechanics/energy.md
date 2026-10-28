---
title: "Energy mechanics: infusion and brownout"
description: "The canonical energy system: units, the online equation, vaults, the 96/4 infusion split and diversity bonus, the reactor stake cap, substation 90% passthrough and dilution, allocations, and the bounded GridCascade brownout."
---

# Energy mechanics: infusion and brownout

**Purpose**: Canonical reference for the Structs energy/power system — units, the online equation, where the Alpha that fuels it lives (vaults), how capacity is created (infusion, with the diversity bonus and the stake cap) and shared (substations, allocations), and the brownout cascade. This is the deep reference; [power.md](power.md) is a quick formula card and the [structs-energy skill](/skills/structs-energy/SKILL.html) is the action playbook.

---

## Units

The chain stores power as integers in **milliwatts (mW)**. Convert to the units people speak in:

| Spoken unit | Milliwatts (chain integer) |
|-------------|----------------------------|
| 1 watt (W) | 1,000 |
| 1 kilowatt (kW) | 1,000,000 |

Two anchors fix the scale:

- **Player base draw** is `PlayerPassiveDraw = 25000` (chain) = **25 W**.
- **Infusion conversion** is `ReactorFuelToEnergyConversion = 1`, so **1 ualpha infused = 1 mW** of capacity, and **1 gram of Alpha (1,000,000 ualpha) = 1,000,000 mW = 1 kW**.

When a doc shows a struct drawing "50 W", the chain value is `50000`. All power values below are stated in W/kW; multiply by 1,000 for the raw chain integer.

> **Energy is per-block and ephemeral.** Power is generated each block and consumed in that same block — there is no stored "energy balance," only instantaneous capacity vs. load. Idle capacity is waste, not savings.

---

## The online equation

A player (and each of their structs) is online only while load fits within capacity:

```
online  ⇔  (load + structsLoad) ≤ (capacity + capacitySecondary)
```

Four quantities drive everything:

| Quantity | Meaning |
|----------|---------|
| `capacity` | Your **own** generation, from your infusions. The **only** capacity you can allocate **out** to others. |
| `capacitySecondary` | Power received **from a substation you're connected to** — exactly that substation's `connectionCapacity`. **Cannot** be re-allocated out. |
| `load` | Power you've allocated **out** (as an allocation source). |
| `structsLoad` | `PlayerPassiveDraw` (25 W) + the sum of `passiveDraw` of your **online** structs. |

Available power is `(capacity + capacitySecondary) − (load + structsLoad)`; allocatable power (what you can route out) is only `capacity − load`.

> **Going offline is not a transaction freeze.** Online status is checked **per message** — an offline player's build/attack/mine messages reject — but **recovery actions are not gated**. You can always `struct-deactivate` a struct or infuse more capacity to climb back out. (Verified: `IsOnline()` in `x/structs/keeper/player_cache.go`.)

---

## Vaults: where game Alpha lives

Every asset owner — each player (`1-N`) and each guild (`0-N`) — has a **vault**: a protocol-controlled bank account whose address is derived deterministically from the owner id. It is not a keyring key and can never sign. The rule: **game income lands in the vault, game spends are paid from the vault, and your signing key pays only native fees.**

| Flow | Account |
|------|---------|
| Refined Alpha (`struct-ore-refine-complete`) | deposited to the **player vault**; `EventAlphaRefine` carries `vaultAddress` |
| `playerInventory.rocks` on `query structs player` | the vault's **spendable** ualpha |
| `reactor-infuse` / `-defuse` / `-cancel-defusion` / `-begin-migration` | act on the **player vault** unless `--delegator-address` names one of your registered keys, or `--owner-id` names a guild vault you hold `PermTokenInfuse` on |
| `struct-generator-infuse` | burned from the **player vault**; no fallback to the key |
| `agreement-open` collateral, `guild-bank-redeem`/`-convert`, rank purchases | **player vault** (or the guild vault with `--owner-id` where supported) |
| `guild-create` (2,000,000 ualpha), `guild-bank-mint` collateral | **founder's / guild's vault** |
| Mint output, founding tokens, rank-sale revenue | **guild vault** |

Look it up with `structsd query structs vault [owner-id]` (returns `address`), then `structsd query bank balances [address]`. Move funds with `vault-send -- [owner-id] [recipient-owner-id] [amount]` (vault→vault), `player-send -- [vault-address] [to-address] [amount]` (vault→key; the sender must hold `PermTokenTransfer`), or a plain `bank send` into the vault address (key→vault). Vault spends ride on the **signing key's** token bits (`PermTokenTransfer`/`PermTokenInfuse`/…), so a delegate scoped without them cannot drain it. A `vault_owner_mismatch` error means `--delegator-address` and `--owner-id` disagreed about whose funds to use. (Verified: `x/structs/keeper/vault_context.go`, `msg_server_struct_ore_refinery_complete.go`, `msg_server_reactor_infuse.go`, `msg_server_struct_generator_infuse.go`, `msg_server_player_send.go`.)

---

## Creating capacity: infusion splits 96/4

Infusing Alpha into a reactor converts fuel to capacity **1:1** (one ualpha of stake is one mW of power before commission), then splits it by the reactor's **commission** (default **4%**):

```
infusionPower    = ratio(1) × fuel          # fuel = the ualpha you stake
commissionPower  = commission × infusionPower   → the REACTOR's capacity
playerPower       = infusionPower − commissionPower  → YOUR personal capacity
```

So at the default 4% commission, **you keep 96%** of what you infuse (added directly to your own `capacity`), and the reactor keeps 4%. Example: infuse 3,000,000 ualpha at 4% → 3,000,000 mW (3 kW) total; the reactor gains 120,000 mW (0.12 kW), you gain **2,880,000 mW (2.88 kW)** plus any diversity bonus (below). Your capacity rises automatically — no substation or allocation setup needed for your own use, which makes reactor infusion the simplest path to more power. The stake comes from your **vault** by default (see above). (Reversible: `reactor-defuse` returns the Alpha to the same account after a cooldown.) A native `structsd tx staking delegate` from a registered key produces the same infusion — and from a *fresh, funded, unregistered* key it is what creates a player in the first place, since `reactor-infuse` itself is rejected before registration.

### The owner diversity bonus

On top of the post-commission power, the chain pays an **owner diversity bonus** that rewards spreading stake across *eligible* (bonded, unjailed) reactors. With `p_i` your post-commission power in reactor `i`:

```
effective = (Σ p_i)² / Σ p_i²                   # 1 for one reactor, N for N equal reactors
bonus     = (Σ p_i) × 50% × min(1, (effective − 1) / 9)
```

| Equal split across | Bonus |
|---|---|
| 1 reactor | 0% |
| 2 | ≈ 5.56% |
| 3 | ≈ 11.11% |
| 5 | ≈ 22.22% |
| 10 or more | 50% (cap) |

Unequal holdings earn less than the table; dust spread across many reactors earns almost nothing. Generator power and received allocations are excluded; a guild's portfolio is separate from its members'. The bonus is recomputed whenever a reactor position changes and the delta is applied to your `capacity`, so **adding stake to a reactor you already dominate can lower your total power** — the effective count shrinks faster than base power grows — and a capacity drop triggers the ordinary brownout cascade. Read your portfolio with `structsd query structs owner-reactor-diversity [owner-id]` (`usableBonus`, `storedCapacity`, `liveBonus`) rather than computing it yourself; the chain floors once in integer arithmetic. Params: `diversityMaxBonusBps` 5000, `diversityTargetExtraReactors` 9. (Verified: `x/structs/types/reactor_diversity.go`, `keeper/reactor_diversity_*.go`.)

### The reactor stake cap

Once **10 validators are bonded** the stake cap activates and stays active (`reactorStakeCapMinValidators`, sticky). Any inflow that would leave a validator above **30%** (`reactorStakeCapBps` 3000) of bonded stake — `reactor-infuse`, native `staking delegate`, a migration in, cancelling a defusion — is rejected with `reactor stake cap exceeded` (code 1613). Existing positions above the cap are not evicted; they simply cannot grow. `structsd query structs reactor-stake-share [reactor-id]` reports `capActive`, `capBps`, `externalDepositHeadroom` (room for new Alpha) and `bondedRedelegationHeadroom` (room for a migration from another bonded validator); empty headroom strings mean the cap is inactive or unlimited, not that the reactor is full. Pick a reactor with headroom *before* refining for a big infusion.

> **Infusing a reactor does NOT power a substation.** Infusion changes only the **reactor** (commission) and the **infuser** (the 96%). It does **not** raise any substation's capacity, and therefore does **not** raise `connectionCapacity` for other connected players. "Everyone infuse the guild reactor to power the guild" is **false** on its own — someone must also route capacity into the guild substation via an **allocation** (below).

> **Jailed or missing validators produce zero energy.** Infusion **ratio** goes to 0; fuel and stake stay put. Unjail / rebond restores from **live staking**. If hooks cannot restore it, `reactor-restart [reactor address]` resyncs the reactor from the validator. A jailed guild reactor means everyone drawing from it goes dark until the operator unjails.

> **Infusion ownership follows the address.** The infusion record is keyed `(destination, address)`. Its `playerId` is the current owner of that address. Strict address moves (`address-register`, `player-update-primary-address`) refuse while a redelegation is in flight. `address-revoke` leaves the Cosmos stake in place and drops the game capacity credited to that address.

---

## Substations: `connectionCapacity` dilutes

A substation is a shared pool. The capacity each connected player receives is the pool divided **evenly** across all connections:

```
usable             = floor(substation.capacity × 9 / 10)      # a substation passes on 90% of what it receives
connectionCapacity = (usable − substation.load) / connectionCount
                     (connectionCount defaults to 1; result is 0 if usable ≤ load)
```

The 10% loss is applied **once to the aggregate** incoming power, so splitting a feed across several allocations does not change it. It is **recomputed on every connect, disconnect, and any capacity/load change**, so **each new connection dilutes everyone's share**. Example: a substation receiving `1,512,960,000` mW (chain) has `1,361,664,000` usable; with `220` connections each connected player gets `6,189,381` (≈ 6,189 W) of `capacitySecondary`. Chaining substations compounds the loss (81% after two hops). (Verified: `SubstationUsableCapacity` in `x/structs/types/substation_capacity.go`, `UpdateSubstationConnectionCapacity` in `x/structs/keeper/grid_context.go`.)

> **The stored `connectionCapacity` is already the per-player share — do not divide by `connectionCount` again.** The division above happens *inside* the chain when the value is written; what you read back (LCD `gridAttributes.connectionCapacity`, or the `connectionCapacity` grid row / `stat_connection_capacity`) is the amount a single connected player receives. Dividing it by `connectionCount` a second time double-dilutes and badly understates a player's real capacity.

This is the real capacity-planning rule for guilds: the per-member figure is **derived, not configured**, and it shrinks as the guild onboards more members. Plan the pool against `connectionCount`, not a fixed per-player number.

---

## Allocations

An **allocation** moves capacity from a source to a destination.

- **Source** can be a player, reactor, struct, or substation. Substation-to-substation **chaining is legal** (one substation can feed another).
- **`SetPower`** adds the allocation's power to the **destination's** `capacity` and to the **source's** `load`.

| Type | Value | Behavior |
|------|-------|----------|
| `static` | 0 | Fixed power. |
| `dynamic` | 1 | Updatable power. |
| `automated` | 2 | **One per source.** Auto-resizes to the source's **full** capacity. |
| `provider-agreement` | — | System-managed (created by energy agreements). |

(Verified: `AllocationCache` type predicates and `SetPower` in `x/structs/keeper/allocation_cache.go`.)

### Connecting an allocation needs no permission from the substation owner

`substation-allocation-connect` checks **only** `PermAllocationConnection` on the **caller's own allocation** — there is **no** check on the destination substation, **no** guild-owner veto, and **no** guild-membership requirement. (Verified: `SubstationAllocationConnect` → `allocation.CanBeConnectedBy(callingPlayer)` in `x/structs/keeper/msg_server_substation_allocation_connect.go`; the substation is passed as `destinationId`.)

Two consequences:

1. **Anyone can contribute capacity to any substation** — an open shared pool by design.
2. **Contributions are diluted by `0.9/connectionCount`.** Donating X to a 220-connection substation raises *your own* connection by only `0.9X/220`. Feeding a busy guild substation is community behavior, not self-growth — for personal capacity, **infuse** (96% to you, undiluted).
3. **A substation that is being deleted refuses connections.** `substation-delete` does bounded work: the substation is flagged `deletionPending` (with `deletionMigrationSubstationId` if players are being moved) and the grid unwinds it over following blocks. Until it is gone, player and allocation connects and guild joins routed to it are rejected (`deletion_pending`). Agreements that fed it are **detached, not closed** — the consumer keeps paying until they `agreement-close`.
4. **An allocation must prove its supply.** Creating an allocation, raising a dynamic one, or opening an agreement validates the *complete* incoming chain (reactor → allocations → substations → source) under a 2,048-object allowance. A cycle, an overloaded ancestor, a jailed reactor at the root, or a chain too deep to prove is refused with `unsupported_supply` even when the source's `capacity − load` reads positive. Simplify the topology; the cascade will not clear it. `substation-create` likewise rejects an allocation that already feeds a substation.

### Connecting/migrating a PLAYER needs permission on BOTH the substation and the player

Unlike allocation-connect, moving a **player** onto a substation is gated on both objects. `substation-player-connect` and `substation-player-migrate` run the **same two checks** and both ultimately call `MigrateSubstation` (connect first disconnects the player from any prior substation):

1. `PermSubstationConnection` (1024) on the **destination substation** (`substation.CanManageConnectionsBy`), and
2. `PermSubstationConnection` (1024) on **each target player object** (`targetPlayer.CanManageSubstationConnectionBy`).

The catch: **a player object is owned by itself** (`GetOwnerId()` returns the player's own id), so ownership of the substation does **not** confer authority over other players. A guild owner/leader who owns the tier substations still **cannot** connect or migrate other members — the player-side check fails with a (misleadingly worded) "no administrate permission on object" error. To move another player you need 1024 on **that player's object**, via one of:

- **(a) The player self-connects.** They own their own player object (ownership passes check 2), and if the destination substation's connect permission is rank-gated to them via a guild-rank register (`permission-guild-rank-set [sub] [guild] 1024 [rank]`), check 1 passes too. This is the scalable path — each member signs their own `substation-player-connect`.
- **(b) An explicit grant.** The target player signs `permission-grant-on-object [player-id] [mover-id] 1024`, after which the mover can connect/migrate them.
- **(c) A guild-rank register on the player object** granting 1024 — but setting it requires 1024 on that player object already, so it is not a leader-side shortcut.

**Operational corollary:** `guild-update-entry-substation-id` only reroutes **new** members joining via join-proxy (they are auto-connected to the guild entry substation). **Existing** members are never auto-migrated when you repoint the entry substation — they must be moved by one of the paths above. (Verified: `msg_server_substation_player_connect.go`, `msg_server_substation_player_migrate.go`, `CanManageSubstationConnectionBy` in `player_cache.go`, `CanManageConnectionsBy` in `substation_cache.go`, `PermissionCheck` in `permissions_context.go`, and `msg_server_guild_membership_join_proxy.go`.)

---

## Brownout: `GridCascade` destroys allocations

When an object's `load` exceeds its (usable) `capacity`, the keeper runs a brownout: it **destroys that object's outgoing allocations in creation order** until `load ≤ capacity`. Because destroying an allocation removes capacity from its destination, the effect **cascades downstream** — a substation that loses a feed can knock its own outgoing allocations (and the players behind them) offline. Over-committing capacity is therefore a real, anticipatable hazard.

The cascade is **bounded**: at most `GridCascadeBlockBudget` (256) allocation teardowns run per block, and whatever remains is queued FIFO and continues in the next blocks. A large collapse therefore plays out over several blocks rather than one; an object can sit with `load > capacity` for a short while before its allocations are gone. Slash reconciliation (128 reactors/block) and permission cleanup (256/block) are bounded the same way. (Verified: `GridCascade` in `x/structs/keeper/grid_context.go`; budgets in `x/structs/types/keys.go` — `GridCascadeBlockBudget`, `ReactorSlashReconcileBudget`, `PermissionCleanupBudget`; `OwnerSupplyReadBudget` in `keeper/player_primary_supply.go`.)

---

## Increasing your own capacity

| Method | How | Rate | Reversible | Risk |
|--------|-----|------|------------|------|
| Reactor infusion (from vault) | `reactor-infuse [validator-addr] [amount]ualpha` (`--delegator-address` / `--owner-id` to pick another funding account) | 1 gram ≈ 1 kW minus commission (you keep ~96%) + diversity bonus up to 50% | Yes — `reactor-defuse` (cooldown) | Low — jailed validator zeros the ratio until unjail / `reactor-restart`; a capped reactor refuses new stake |
| Generator infusion (from vault, one coin) | `struct-generator-infuse [struct-id] [amount]ualpha` | Field Generator 2 kW/g, Continental Power Plant 5 kW/g, World Engine 10 kW/g | **No** (Alpha annihilated) | High (raidable; fuel stays with an offline generator — `generatorDisabled` — and is credited again on reactivation, but destruction never refunds it) |
| Buy via agreement | `agreement-open [provider-id] [duration] [capacity]` | Varies by provider | Yes (close agreement) | Medium (ongoing cost) |

Reactor infusion is the safe default. Generators give far more kW per gram but the Alpha is permanent and a raided generator takes the infused matter with it — only infuse generators you can defend. See the [structs-energy skill](/skills/structs-energy/SKILL.html) for the full workflows and offline-recovery procedure.

Per-struct `passiveDraw` and `buildDraw` (in watts) and the per-player build `Limit` are in [struct-types.md](../entities/struct-types.md#complete-struct-type-table).

---

## See Also

- [power.md](power.md) — Quick formula card (online equation, the four quantities)
- [struct-types.md](../entities/struct-types.md) — Per-struct draws and build limits
- [building.md](building.md) — Build power requirements, charge, slots
- [resources.md](resources.md) — Alpha → energy conversion
- [energy-market.md](../economy/energy-market.md) — Agreements, providers, pricing
- [structs-energy skill](/skills/structs-energy/SKILL.html) — Infusion, substations, offline recovery
