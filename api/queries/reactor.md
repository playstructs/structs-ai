---
description: "Query reactors on the consensus network: infused Alpha Matter, capacity produced, and the validator each one backs."
---

# Reactor Query Endpoints

**Version**: 1.0.0
**Category**: Query
**Entity**: Reactor
**Base URL**: `http://localhost:1317`
**Base Path**: `/structs`

---

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/reactor/{id}` | Get reactor by ID | No | No |
| GET | `/structs/reactor` | List all reactors | No | Yes |
| GET | `/structs/reactor/{reactorId}/stake-share` | Stake cap headroom and slash revisions | No | No |
| GET | `/structs/owner/{ownerId}/reactor-diversity` | Owner's diversity bonus accounting | No | No |

---

## Endpoint Details

### Get Reactor by ID

`GET /structs/reactor/{id}`

Returns a single reactor by its entity ID.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `id` | string | Yes | entity-id (`^3-[0-9]+$`) | Reactor identifier in format 'type-index' (e.g., '3-1' for reactor type 3, index 1). Type 3 = Reactor. |

#### Response

- **Content-Type**: `application/json`
- **Schema**: [reactor](../../schemas/entities/reactor.md)

#### Example

**Request**: `GET /structs/reactor/3-1`

**Response**:

```json
{
  "Reactor": {
    "id": "3-1",
    "validator": "structsvaloper1...",
    "guildId": "0-1",
    "defaultCommission": "0",
    "owner": "1-11"
  }
}
```

The `owner` field (string, PlayerId) identifies the player who owns this reactor.

---

### List All Reactors

`GET /structs/reactor`

Returns a paginated list of all reactors.

#### Response

- **Content-Type**: `application/json`
- **Schema**: [reactor](../../schemas/entities/reactor.md) (array)

---

### Reactor Stake Share

`GET /structs/reactor/{reactorId}/stake-share`

**CLI**: `structsd query structs reactor-stake-share [reactor-id]`. Check this **before** `reactor-infuse`: once ten or more validators are bonded, a reactor holding ≥ `capBps` (default 3000 = 30%) of bonded stake refuses further inflows (`reactor stake cap exceeded`, code 1613).

| Field | Meaning |
|-------|---------|
| `reactorId`, `validatorAddress` | Identity |
| `validatorTokens` | Tokens bonded to this validator (string) |
| `stakeDenominator` | Total bonded stake the cap is measured against (string) |
| `capBps`, `capActive` | Cap setting and whether it is in force (sticky once activated) |
| `externalDepositHeadroom` | How much a fresh `reactor-infuse` may add before hitting the cap. Empty when the cap is inactive or 100% |
| `bondedRedelegationHeadroom` | How much may arrive by `reactor-begin-migration` from bonded stake (the denominator does not grow) |
| `slashRevision`, `reconciledSlashRevision` | Unequal values mean the reactor has an unreconciled slash and will not take commission until it is reconciled; stake admission is unaffected |

### Owner Reactor Diversity

`GET /structs/owner/{ownerId}/reactor-diversity`

**CLI**: `structsd query structs owner-reactor-diversity [owner-id]`. Shows the [diversity bonus](../../knowledge/mechanics/energy.md#the-owner-diversity-bonus) an owner earns for spreading stake across reactors.

| Field | Meaning |
|-------|---------|
| `stored.power`, `stored.squaredPower`, `stored.appliedBonus` | The accounting currently applied to capacity (Σp, Σp² as strings) |
| `liveBonus` | Exact formula result from current native stake; empty if the portfolio read was incomplete |
| `usableBonus` | Applied bonus bounded by live entitlement — what you actually get |
| `livePortfolioComplete`, `infusionInventoryComplete` | Whether the live read covered everything |
| `maxBonusBps`, `targetExtraReactors` | Params (5000, 9): 50% maximum at ten evenly-funded reactors |
| `initialized`, `storedCapacity`, `usablePrimaryCapacity` | Whether the row exists and the capacity figures it feeds |
