# Reactor Staking - Infuse Workflow

**Version**: 1.0.0
**Category**: economic
**Description**: Detailed workflow for infusing reactor with Alpha Matter for validation delegation (v0.8.0-beta)

---

## v0.8.0-beta Feature

- **Feature**: reactor_staking
- **Purpose**: validation_delegation

---

## Workflow: Reactor Infuse for Validation Delegation

### Step 1: Check Prerequisites

Verify player and reactor status before infusing.

**Player Online** -- `GET /structs/player/{playerId}`:

| Field | Expected Value |
|-------|----------------|
| `player.online` | `true` |

**Reactor Exists** -- `GET /structs/reactor/{reactorId}`:

| Field | Expected Value |
|-------|----------------|
| `reactor.owner` | `{playerId}` |

**Sufficient Alpha Matter** -- `GET /structs/player/{playerId}`:

| Field | Minimum Value |
|-------|---------------|
| `player.alphaMatter` | `{infuseAmount}` |

**Delegation Status** -- `GET /structs/reactor/{reactorId}`:

| Field | Allowed Values |
|-------|----------------|
| `reactor.delegationStatus` | `none`, `active`, `undelegating` |

> **Note**: Cannot infuse if status is `migrating`.

### Step 2: Calculate Infusion Amount

Determine amount to infuse based on staking strategy.

| Amount | Value | Unit | Description |
|--------|-------|------|-------------|
| Minimum | `1000000000` | nanograms | Minimum amount for validation delegation |
| Recommended | `10000000000` | nanograms | Recommended amount for meaningful delegation |
| Maximum | `player.alphaMatter` | -- | Player's available Alpha Matter |

### Step 3: Submit Infuse Transaction

Submit `MsgReactorInfuse` transaction for validation delegation.

**Method**: `POST`
**Endpoint**: `/cosmos/tx/v1beta1/txs`

**Request Body**:

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgReactorInfuse",
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

### Step 5: Verify Delegation Status

Query reactor to confirm delegation is active.

**Endpoint**: `GET /structs/reactor/{reactorId}`

**Expected Fields**:

| Field | Expected Value |
|-------|----------------|
| `reactor.delegationStatus` | `active` |
| `reactor.delegationAmount` | `10000000000` |
| `reactor.validator` | `validator_address` |

### Step 6: Verify Player Resources

Confirm Alpha Matter was deducted from player.

**Endpoint**: `GET /structs/player/{playerId}`

**Expected Fields**:

| Field | Expected Value |
|-------|----------------|
| `player.alphaMatter` | decreased by infuse amount |

---

## Error Handling

| Error | Code | Description | Recovery | Retry |
|-------|------|-------------|----------|-------|
| Player Halted | `PLAYER_HALTED` | Player is offline (halted) | Wait for player to come online | Yes (30s delay) |
| Insufficient Alpha Matter | `INSUFFICIENT_FUNDS` | Player does not have enough Alpha Matter | Mine and refine more Alpha Matter | No |
| Reactor Not Found | `ENTITY_NOT_FOUND` | Reactor does not exist | Verify reactor ID is correct | No |
| Invalid Delegation Status | `INVALID_STATE` | Reactor is in migrating state | Wait for migration to complete or cancel defusion | Yes (check migration status) |
| Transaction Failed | `GENERAL_ERROR` | Transaction failed to broadcast or execute | Check transaction response for error details | Yes (5s delay) |

---

## Permission Checking

### Required Permissions

| Permission | Description | Check |
|------------|-------------|-------|
| Player Ownership | Player must own the reactor | `reactor.owner === playerId` |
| Reactor Access | Player must have access to reactor | `GET /structs/permission/object/{reactorId}` |

### Permission Validation

- **When**: Before Step 3
- **Query**: `GET /structs/permission/object/{reactorId}`
- **Filter**: `permission.playerId === {playerId}`
- **Required**: `permission.value` includes appropriate bits

---

## Examples

### Basic Infusion

- **Scenario**: Basic validation delegation with minimum amount
- **Amount**: `1000000000`
- **Expected Result**: `delegationStatus: active`, `delegationAmount: 1000000000`

### Large Infusion

- **Scenario**: Large validation delegation for significant stake
- **Amount**: `100000000000`
- **Expected Result**: `delegationStatus: active`, `delegationAmount: 100000000000`

### Partial Infusion (Add to Existing)

- **Scenario**: Add to existing delegation
- **Existing Amount**: `5000000000`
- **Additional Amount**: `5000000000`
- **Expected Result**: `delegationStatus: active`, `delegationAmount: 10000000000`
