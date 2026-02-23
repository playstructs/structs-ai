# Reactor Staking - Defuse Workflow

**Version**: 1.0.0
**Category**: economic
**Description**: Detailed workflow for defusing reactor to undelegate validation stake (v0.8.0-beta)

---

## v0.8.0-beta Feature

- **Feature**: reactor_staking
- **Purpose**: validation_undelegation

---

## Workflow: Reactor Defuse for Validation Undelegation

### Step 1: Check Prerequisites

Verify reactor delegation status before defusing.

**Player Online** -- `GET /structs/player/{playerId}`:

| Field | Expected Value |
|-------|----------------|
| `player.online` | `true` |

**Reactor Exists** -- `GET /structs/reactor/{reactorId}`:

| Field | Expected Value |
|-------|----------------|
| `reactor.owner` | `{playerId}` |

**Delegation Status** -- `GET /structs/reactor/{reactorId}`:

| Field | Expected Value |
|-------|----------------|
| `reactor.delegationStatus` | `active` |

> **Note**: Cannot defuse if status is `migrating` or `none`.

**Delegation Amount** -- `GET /structs/reactor/{reactorId}`:

| Field | Minimum Value |
|-------|---------------|
| `reactor.delegationAmount` | `{defuseAmount}` |

### Step 2: Calculate Defuse Amount

Determine amount to defuse (can be partial or full).

| Type | Value | Description |
|------|-------|-------------|
| Full Defuse | `reactor.delegationAmount` | Undelegate all staked amount |
| Partial Defuse | custom amount | Undelegate partial amount (must be <= delegationAmount), minimum `1000000000` |

> **Note**: Partial defuse is allowed.

### Step 3: Submit Defuse Transaction

Submit `MsgReactorDefuse` transaction for validation undelegation.

**Method**: `POST`
**Endpoint**: `/cosmos/tx/v1beta1/txs`

**Request Body**:

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgReactorDefuse",
        "creator": "structs1...",
        "reactorId": "3-1",
        "destinationType": 1,
        "destinationId": "1-11",
        "alphaMatterAmount": "10000000000"
      }
    ]
  }
}
```

**Expected Response**:

```json
{
  "txResponse": {
    "code": 0,
    "txhash": "transaction_hash"
  }
}
```

### Step 4: Wait for Transaction Confirmation

Wait for transaction to be included in a block.

**Polling**:

| Parameter | Value |
|-----------|-------|
| Endpoint | `GET /cosmos/tx/v1beta1/txs/{txhash}` |
| Interval | 2 seconds |
| Max Attempts | 30 |
| Expected Status | confirmed |

### Step 5: Verify Undelegation Status

Query reactor to confirm undelegation is in progress.

**Endpoint**: `GET /structs/reactor/{reactorId}`

**Expected Fields**:

| Field | Expected Value |
|-------|----------------|
| `reactor.delegationStatus` | `undelegating` |
| `reactor.undelegationPeriod` | blocks remaining |

> **Note**: Undelegation period must pass before Alpha Matter is returned.

### Step 6: Monitor Undelegation Period

Wait for undelegation period to complete.

**Monitoring**:

| Parameter | Value |
|-----------|-------|
| Query | `GET /structs/reactor/{reactorId}` |
| Interval | check every block |
| Transition From | `undelegating` |
| Transition To | `none` |
| Condition | `undelegationPeriod === 0` |

### Step 7: Verify Alpha Matter Returned

Confirm Alpha Matter was returned to player after undelegation period.

**Endpoint**: `GET /structs/player/{playerId}`

**Expected Fields**:

| Field | Expected Value |
|-------|----------------|
| `player.alphaMatter` | increased by defuse amount |
| `reactor.delegationStatus` | `none` |

---

## Error Handling

| Error | Code | Description | Recovery | Retry |
|-------|------|-------------|----------|-------|
| Player Halted | `PLAYER_HALTED` | Player is offline (halted) | Wait for player to come online | Yes (30s delay) |
| No Active Delegation | `INVALID_STATE` | Reactor has no active delegation to undelegate | Check reactor delegation status | No |
| Insufficient Delegation Amount | `INSUFFICIENT_FUNDS` | Requested defuse amount exceeds delegation amount | Reduce defuse amount to match delegation amount | Yes |
| Migrating State | `INVALID_STATE` | Reactor is in migrating state, cannot defuse | Wait for migration to complete | Yes (check migration status) |
| Transaction Failed | `GENERAL_ERROR` | Transaction failed to broadcast or execute | Check transaction response for error details | Yes (5s delay) |

---

## Permission Checking

### Required Permissions

| Permission | Description | Check |
|------------|-------------|-------|
| Player Ownership | Player must own the reactor | `reactor.owner === playerId` |
| Reactor Access | Player must have access to reactor | `GET /structs/permission/object/{reactorId}` |

---

## Examples

### Full Defuse

- **Scenario**: Fully undelegate all staked amount
- **Delegation Amount**: `10000000000`
- **Defuse Amount**: `10000000000`
- **Expected Result**: `delegationStatus: undelegating`, `remainingDelegation: 0`

### Partial Defuse

- **Scenario**: Partially undelegate staked amount
- **Delegation Amount**: `10000000000`
- **Defuse Amount**: `5000000000`
- **Expected Result**: `delegationStatus: active`, `remainingDelegation: 5000000000`

### Cancel Defusion

- **Scenario**: Cancel undelegation before period completes
- **Note**: Use `MsgReactorCancelDefusion` to cancel undelegation
- **Workflow**: See [reactor-staking-cancel-defusion.md](reactor-staking-cancel-defusion.md)
