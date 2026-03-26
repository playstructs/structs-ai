# Energy Market

**Purpose**: AI-readable reference for Structs energy agreements, pricing dynamics, supply/demand, and entity relationships. How energy flows between players.

---

## Overview

Energy is **ephemeral and per-block** — produced from Alpha Matter via conversion structs, consumed by structs and operations. Energy generated in a block but not consumed in that block is permanently lost. There is no "energy balance" to accumulate. Idle capacity is waste, not safety margin. Guild substations should run at full utilization.

Transaction fees also come from energy, not Alpha tokens. Any player connected to a power source can transact without holding a separate fee balance.

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

This automatic capacity increase makes reactor infusion the fastest and simplest way for a player to gain capacity. Check a reactor's commission rate before infusing: `structsd query structs reactor [id]`.

For step-by-step energy management workflows, see the [structs-energy skill](https://structs.ai/skills/structs-energy/SKILL).

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
| **Allocation** | Routing of energy capacity from source to Substations |

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

When a buyer opens an agreement (`agreement-open [provider-id] [capacity] [duration]`):

1. Buyer pays `capacity * rate * duration` upfront in the rate denomination (e.g., uguild.0-1)
2. Payment goes to the provider's **collateral address** (on-chain escrow)
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
- `agreement-close` -- either party can close early (cancellation penalties may apply)
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
