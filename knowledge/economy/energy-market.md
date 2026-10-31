---
title: "Energy market: providers and pricing"
description: "How energy flows between players: providers, agreements, pricing dynamics, supply and demand, and provider configuration."
---

# Energy market: providers and pricing

**Purpose**: AI-readable reference for Structs energy agreements, pricing dynamics, supply/demand, and entity relationships. How energy flows between players.

---

## Overview

Energy is **ephemeral and per-block** — produced from Alpha Matter via conversion structs, consumed by structs and operations. Energy generated in a block but not consumed in that block is permanently lost. There is no "energy balance" to accumulate. Idle capacity is waste, not safety margin. Guild substations should run at full utilization.

Ordinary pure Structs gameplay transactions are **free**; `MsgGuildCreate`, `MsgReactorRestart` and `MsgUpdateParams` use ordinary paid gas. The free path uses a dedicated meter with no `ualpha` fee (see [transactions](../mechanics/transactions.md)). So a player does not need to hold a fee balance to play. Note this is distinct from *energy*: you must be online (powered) and hold charge to *act*, but no energy is spent as a per-transaction gas fee.

Energy agreements create **self-enforcing subscriptions** between providers (sellers) and consumers (buyers). Energy is shared across a player's structs via substation connections.

---

## Entity Relationships

| Entity | ID Format | Role |
|--------|-----------|------|
| **Provider** | `10-{index}` | Offers energy capacity; owned by player; linked to substation |
| **Agreement** | `11-{index}` | Binds provider to consumer; defines capacity, duration, rate |
| **Allocation** | `6-{index}` | Distributes energy from source to destination |

### Flow

```
Provider → Agreement → Consumer (Player)
     ↓
Allocation: sourceId (Provider/Reactor) → destinationId (Player/Struct)
```

- **Provider**: Player creates via `provider-create`. Provider exposes capacity from substation.
- **Agreement**: Consumer opens via `agreement-open`. Links provider to consumer; specifies capacity, blocks, rate.
- **Allocation**: On-chain record of energy flow. Source = Provider or Reactor; destination = Player or Struct. The `controller` is a PlayerId (not an address).

---

## Supply and Demand

| Factor | Effect |
|--------|--------|
| Alpha Matter scarcity | Higher energy cost; producers charge more |
| Raid activity | Supply shocks when reactors/providers go offline |
| Guild coordination | Members may subsidize each other via agreements |
| Struct count | More structs = higher demand; power grid strain |

**Pricing dynamics**: Energy agreements use `rateAmount`/`rateDenom` (Alpha Matter per unit). Market-clearing depends on provider availability, consumer willingness to pay, and cancellation penalties.

---

## Energy Production (Supply Side)

| Facility | Rate | Risk | When to Use |
|----------|------|------|-------------|
| Reactor | 1g = 1 kW | Low | Baseline; redundancy |
| Field Generator | 1g = 2 kW | High | Efficiency when risk acceptable |
| Continental Power Plant | 1g = 5 kW | High | High output, high risk |
| World Engine | 1g = 10 kW | High | Maximum efficiency; single point of failure |

See [struct-types.md](../entities/struct-types.md) for build costs and power requirements.

### Reactor Commission and Auto-Capacity

Reactors charge a **commission** on infusions. When a player infuses ualpha into a reactor, the generated power is split:

- **Player receives**: `power * (1 - commission)` — added directly to the player's capacity (no manual allocation needed)
- **Reactor receives**: `power * commission` — increases the reactor's capacity

On top of the post-commission share, an **owner diversity bonus** of up to **50%** rewards spreading stake evenly across ten or more bonded reactors (≈5.6% at two, ≈11% at three, ≈22% at five); concentrating everything in one reactor earns none, and piling more onto a reactor you already dominate can *lower* your total. Once ten validators are bonded a **stake cap** also applies: a reactor at 30% of bonded stake refuses further inflows (`reactor stake cap exceeded`). The stake itself is paid from the infuser's **vault**. This automatic capacity increase makes reactor infusion the fastest and simplest way for a player to gain capacity. Check a reactor's commission and headroom before infusing: `structsd query structs reactor [id]` and `reactor-stake-share [id]`; check your own spread with `owner-reactor-diversity [owner-id]`. Full mechanics: [energy.md](../mechanics/energy.md#creating-capacity-infusion-splits-964).

> **Staking pays capacity, not a yield.** The return on infusing a reactor is the **energy capacity** credited above — there is no delegator reward stream, APR, or passive token income. Income is realized only *indirectly*, by selling that capacity as energy through a provider.

For step-by-step energy management workflows, see the [structs-energy skill](/skills/structs-energy/SKILL.html).

---

## Provider Configuration

Providers define (per database schema):

| Field | Purpose |
|-------|---------|
| rateAmount / rateDenom | Price per unit capacity |
| capacityMinimum / capacityMaximum | Offer range |
| durationMinimum / durationMaximum | Agreement length |
| accessPolicy | Who can subscribe |
| providerCancellationPenalty / consumerCancellationPenalty | Early exit cost |

---

## Query Patterns

| Need | Endpoint |
|------|----------|
| Provider by ID | `GET /structs/provider/{id}` |
| Agreements by provider | `GET /structs/agreement_by_provider/{providerId}` |
| Allocations by source | `GET /structs/allocation_by_source/{sourceId}` |
| Allocations by destination | `GET /structs/allocation_by_destination/{destinationId}` |

---

## Infusions vs Allocations

| Concept | Purpose |
|---------|---------|
| **Infusion** | Record of energy production -- who put Alpha Matter into which conversion struct |
| **Allocation** | Routing of energy capacity from source to Substations. A substation passes on only **90%** of what it receives, so price the loss into chained routes |

An allocation's controller may be a player or a **guild** (`--controller`, `allocation-transfer -- [allocation-id] [new-controller-owner-id]`); allocations sourced from a guild or a guild-owned substation are guild-controlled by default. Admission validates the whole upstream supply chain (`unsupported_supply` on cycles, overloaded or jailed ancestors, or more than 2,048 objects).

**Allocation types**:

| Type | Behavior | Updatable | Deletable | Limit |
|------|----------|-----------|-----------|-------|
| `static` | Fixed capacity amount | No | No (while connected) | Unlimited |
| `dynamic` | Can be manually updated | Yes | Yes | Unlimited |
| `automated` | Auto-grows with source capacity | Yes | No | One per source |
| `provider-agreement` | System-created when agreements open | System | System | System |

For energy commerce, use `automated` -- it scales with your capacity as you infuse more alpha.

---

## Agreement Payment Flow

When a buyer opens an agreement (`agreement-open [provider-id] [duration] [capacity]`):

1. Buyer pays `capacity * rate * duration` upfront in the rate denomination (e.g., uguild.0-1) — the **entire** amount is debited **from the buyer's vault** (or from a guild vault with `--owner-id`) in full at open, not metered per block
2. Payment goes to the provider's **collateral address** (on-chain escrow). At most **256** agreements may expire at any one height; if the chosen duration lands on a full bucket the open is refused (`expiration_height_full`) — shift the duration by a block. A duration that would overflow the end height is likewise refused

> **`rate_denom` trap:** the debit is in the *provider's* denom, not alpha. If the provider prices in a guild token, a buyer holding only `ualpha` is **rejected at broadcast** (insufficient-funds error keyed `agreement_open`). Check the provider's `rateDenom` and acquire that denom before opening.
3. System auto-creates a `provider-agreement` allocation -- energy flows to the buyer immediately
4. Revenue **drips** from collateral to the provider's **earnings address** proportionally as blocks pass
5. Provider can withdraw accumulated earnings at any time via `provider-withdraw-balance`
6. On expiry (endBlock reached), the allocation is released and remaining collateral converts to earnings

### Agreement Lifecycle

```
OPEN -> ACTIVE (blocks pass, revenue accrues) -> EXPIRED (capacity released)
                                              -> or CLOSED early (penalties apply)
```

- `agreement-open` -- buyer initiates
- `agreement-close` -- either party can close early (cancellation penalties may apply). This is also the **consumer's** job after the provider's substation is deleted: deletion **detaches** inbound agreements instead of ending them, so billing continues until the consumer closes
- `agreement-capacity-increase/decrease` -- modify mid-agreement
- `agreement-duration-increase` -- extend the agreement

### Revenue Denomination Strategy

Using guild tokens (uguild.X-Y) as the rate denomination is strategically significant:
- Buyers must acquire the guild's token to purchase energy, creating demand
- Revenue earned strengthens the guild's treasury
- Guild tokens can be minted against Alpha collateral (`guild-bank-mint`) or traded

## Agreement Properties

| Property | Meaning |
|----------|---------|
| **automatic** | Executes on-chain without manual intervention |
| **penaltyProtection** | On-chain penalty enforcement for violations |
| **persistent** | Long-term, survives across sessions |
| **selfEnforcing** | Terms enforced by blockchain, no trust required |

**Provider selection criteria**: rate, price, available capacity, penaltyProtection, reputation.

---

## Strategic Notes

- **Self-enforcing**: Agreements execute on-chain; no trust required for fulfillment.
- **Lock-out**: Energy agreements can exclude raiders (no capacity = no operations).
- **Diversification**: Relying on single provider = vulnerability; agreements can expire or be cancelled.
- **Allocatable capacity**: Only the player's personal `capacity` (from infusions) is allocatable — `capacitySecondary` (substation-provided) cannot be allocated out. See [power.md](../mechanics/power.md).

---

## See Also

- [guild-banking.md](guild-banking.md) — Guild economic context
- [trading.md](trading.md) — Alpha Matter exchange
- [entity-relationships.md](../entities/entity-relationships.md) — Provider/Agreement/Allocation graph
- [power.md](../mechanics/power.md) — Capacity, load, online status
- [resources.md](../mechanics/resources.md) — Alpha Matter → energy conversion
- `schemas/entities.md` — Provider, Agreement, Allocation definitions
- `api/queries/provider.md`, `api/queries/agreement.md`, `api/queries/allocation.md`
