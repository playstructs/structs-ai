# Reactor Staking - Cancel Defusion Workflow

**Version**: 1.0.0
**Category**: economic
**Description**: Detailed workflow for canceling an ongoing undelegation process

---

## Workflow: Reactor Cancel Defusion to Restore Delegation

### Step 1: Check Prerequisites

Verify reactor is in undelegating state.

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
| `reactor.delegationStatus` | `undelegating` |

> **Note**: Can only cancel if status is `undelegating`.

**Undelegation Period** -- `GET /structs/reactor/{reactorId}`:

| Field | Note |
|-------|------|
| `reactor.undelegationPeriod` | Can cancel at any point during undelegation period |

### Step 2: Submit Cancel Defusion Transaction

Submit `MsgReactorCancelDefusion` transaction to cancel undelegation.

**Method**: `POST`
**Endpoint**: `/cosmos/tx/v1beta1/txs`

**Request Body**:

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgReactorCancelDefusion",
        "creator": "structs1...",
        "reactorId": "3-1"
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

### Step 3: Wait for Transaction Confirmation

Wait for transaction to be included in a block.

**Polling**:

| Parameter | Value |
|-----------|-------|
| Endpoint | `GET /cosmos/tx/v1beta1/txs/{txhash}` |
| Interval | 2 seconds |
| Max Attempts | 30 |
| Expected Status | confirmed |

### Step 4: Verify Delegation Restored

Query reactor to confirm delegation is active again.

**Endpoint**: `GET /structs/reactor/{reactorId}`

**Expected Fields**:

| Field | Expected Value |
|-------|----------------|
| `reactor.delegationStatus` | `active` |
| `reactor.delegationAmount` | original amount (pre-undelegation value) |
| `reactor.undelegationCancelled` | `true` |

> **Note**: Delegation amount should be restored to pre-undelegation value.

### Step 5: Verify No Alpha Matter Returned

Confirm Alpha Matter was not returned (undelegation cancelled).

**Endpoint**: `GET /structs/player/{playerId}`

**Expected Fields**:

| Field | Expected Value |
|-------|----------------|
| `player.alphaMatter` | unchanged |

> **Note**: Alpha Matter remains staked since undelegation was cancelled.

---

## Error Handling

| Error | Code | Description | Recovery | Retry |
|-------|------|-------------|----------|-------|
| Player Halted | `PLAYER_HALTED` | Player is offline (halted) | Wait for player to come online | Yes (30s delay) |
| Not Undelegating | `INVALID_STATE` | Reactor is not in undelegating state | Check reactor delegation status -- must be `undelegating` | No |
| Already Active | `INVALID_STATE` | Reactor already has active delegation | No action needed -- delegation is already active | No |
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

### Cancel Early Undelegation

- **Scenario**: Cancel undelegation shortly after starting
- **Undelegation Period**: 100 blocks remaining
- **Expected Result**: `delegationStatus: active`, `undelegationCancelled: true`

### Cancel Late Undelegation

- **Scenario**: Cancel undelegation near end of period
- **Undelegation Period**: 1 block remaining
- **Expected Result**: `delegationStatus: active`, `undelegationCancelled: true`

### Change of Mind

- **Scenario**: Player changes mind about undelegating
- **Description**: Cancel undelegation to restore active delegation
- **Expected Result**: `delegationStatus: active`, `delegationAmount: restored_to_original`
