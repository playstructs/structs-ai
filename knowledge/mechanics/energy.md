# Energy Mechanics

**Purpose**: Canonical reference for the Structs energy/power system — units, the online equation, how capacity is created (infusion) and shared (substations, allocations), and the brownout cascade. This is the deep reference; [power.md](power.md) is a quick formula card and the [structs-energy skill](https://structs.ai/skills/structs-energy/SKILL) is the action playbook.

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

## Creating capacity: infusion splits 96/4

Infusing Alpha into a reactor converts fuel to capacity at ratio 1, then splits it by the reactor's **commission** (default **4%**):

```
infusionPower    = ratio(1) × fuel          # fuel = the ualpha you stake
commissionPower  = commission × infusionPower   → the REACTOR's capacity
playerPower       = infusionPower − commissionPower  → YOUR personal capacity
```

So at the default 4% commission, **you keep 96%** of what you infuse (added directly to your own `capacity`), and the reactor keeps 4%. Example: infuse 3,000,000 ualpha at 4% → 3,000,000 mW (3 kW) total; the reactor gains 120,000 mW (0.12 kW), you gain **2,880,000 mW (2.88 kW)**. Your capacity rises automatically — no substation or allocation setup needed for your own use, which makes reactor infusion the simplest path to more power. (Reversible: `reactor-defuse` returns the Alpha after a cooldown.)

> **Infusing a reactor does NOT power a substation.** Infusion changes only the **reactor** (commission) and the **infuser** (the 96%). It does **not** raise any substation's capacity, and therefore does **not** raise `connectionCapacity` for other connected players. "Everyone infuse the guild reactor to power the guild" is **false** on its own — someone must also route capacity into the guild substation via an **allocation** (below).

---

## Substations: `connectionCapacity` dilutes

A substation is a shared pool. The capacity each connected player receives is the pool divided **evenly** across all connections:

```
connectionCapacity = (substation.capacity − substation.load) / connectionCount
                     (connectionCount defaults to 1; result is 0 if capacity ≤ load)
```

It is **recomputed on every connect, disconnect, and any capacity/load change**, so **each new connection dilutes everyone's share**. Example: a substation with `1,512,960,000` capacity (chain) and `220` connections gives each connected player `6,877,090` (≈ 6,877 W) of `capacitySecondary`. (Verified: `UpdateSubstationConnectionCapacity` in `x/structs/keeper/grid_context.go`.)

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
2. **Contributions are diluted by `1/connectionCount`.** Donating X to a 220-connection substation raises *your own* connection by only `X/220`. Feeding a busy guild substation is community behavior, not self-growth — for personal capacity, **infuse** (96% to you, undiluted).

---

## Brownout: `GridCascade` destroys allocations

When an object's `load` exceeds its `capacity`, the keeper runs a brownout: it **destroys that object's outgoing allocations in creation order** until `load ≤ capacity`. Because destroying an allocation removes capacity from its destination, the effect **cascades downstream** — a substation that loses a feed can knock its own outgoing allocations (and the players behind them) offline. Over-committing capacity is therefore a real, anticipatable hazard. (Verified: `GridCascade` in `x/structs/keeper/grid_context.go`.)

---

## Increasing your own capacity

| Method | How | Rate | Reversible | Risk |
|--------|-----|------|------------|------|
| Reactor infusion | `reactor-infuse [your-addr] [validator-addr] [amount]ualpha` | 1 gram ≈ 1 kW minus commission (you keep ~96%) | Yes — `reactor-defuse` (cooldown) | Low |
| Generator infusion | `struct-generator-infuse [struct-id] [amount]ualpha` | Field Generator 2 kW/g, Continental Power Plant 5 kW/g, World Engine 10 kW/g | **No** (Alpha annihilated) | High (raidable) |
| Buy via agreement | `agreement-open [provider-id] [duration] [capacity]` | Varies by provider | Yes (close agreement) | Medium (ongoing cost) |

Reactor infusion is the safe default. Generators give far more kW per gram but the Alpha is permanent and a raided generator takes the infused matter with it — only infuse generators you can defend. See the [structs-energy skill](https://structs.ai/skills/structs-energy/SKILL) for the full workflows and offline-recovery procedure.

Per-struct `passiveDraw` and `buildDraw` (in watts) and the per-player build `Limit` are in [struct-types.md](../entities/struct-types.md#complete-struct-type-table).

---

## See Also

- [power.md](power.md) — Quick formula card (online equation, the four quantities)
- [struct-types.md](../entities/struct-types.md) — Per-struct draws and build limits
- [building.md](building.md) — Build power requirements, charge, slots
- [resources.md](resources.md) — Alpha → energy conversion
- [energy-market.md](../economy/energy-market.md) — Agreements, providers, pricing
- [structs-energy skill](https://structs.ai/skills/structs-energy/SKILL) — Infusion, substations, offline recovery
