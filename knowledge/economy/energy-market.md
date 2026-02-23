# Energy Market

**Purpose**: AI-readable reference for Structs energy agreements, pricing dynamics, supply/demand, and entity relationships. How energy flows between players.

---

## Overview

Energy is **ephemeral**—produced from Alpha Matter via conversion structs, consumed by structs and operations. It cannot be stored. Energy agreements create **self-enforcing subscriptions** between providers (sellers) and consumers (buyers). Energy is shared across a player's structs via substation connections.

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
- **Allocation**: On-chain record of energy flow. Source = Provider or Reactor; destination = Player or Struct.

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
- **Static**: Fixed amount of capacity allocated
- **Automated**: Uses all available capacity (limit: one automated allocation per source)

---

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
- **Allocatable capacity**: Only primary substation capacity is allocatable to reactors/generators; see [power.md](../mechanics/power.md).

---

## See Also

- [guild-banking.md](guild-banking.md) — Guild economic context
- [trading.md](trading.md) — Alpha Matter exchange
- [entity-relationships.md](../entities/entity-relationships.md) — Provider/Agreement/Allocation graph
- [power.md](../mechanics/power.md) — Capacity, load, online status
- [resources.md](../mechanics/resources.md) — Alpha Matter → energy conversion
- `schemas/entities.md` — Provider, Agreement, Allocation definitions
- `api/queries/provider.md`, `api/queries/agreement.md`, `api/queries/allocation.md`
