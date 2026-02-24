# Reactor Staking - Begin Migration Workflow

**Version**: 1.0.0
**Category**: economic
**Description**: Detailed workflow for beginning redelegation to a different validator

---

## Workflow: Reactor Begin Migration for Redelegation

### Step 1: Check Prerequisites

Verify reactor delegation status before beginning migration.

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

> **Note**: Cannot begin migration if status is not `active`.

**Target Validator**: Target validator must be specified (implicit in migration). Migration redelegates to validator associated with new destination.

### Step 2: Submit Begin Migration Transaction

Submit `MsgReactorBeginMigration` transaction to start redelegation.

**Method**: `POST`
**Endpoint**: `/cosmos/tx/v1beta1/txs`

**Request Body**:

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgReactorBeginMigration",
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

### Step 4: Verify Migration Status

Query reactor to confirm migration is in progress.

**Endpoint**: `GET /structs/reactor/{reactorId}`

**Expected Fields**:

| Field | Expected Value |
|-------|----------------|
| `reactor.delegationStatus` | `migrating` |
| `reactor.migrationInProgress` | `true` |

### Step 5: Complete Migration

Migration completes automatically when joining guild or changing destination.

> **Note**: Migration is typically completed as part of the guild membership join process. See [guild-membership-join.md](guild-membership-join.md).

---

## Error Handling

| Error | Code | Description | Recovery | Retry |
|-------|------|-------------|----------|-------|
| Player Halted | `PLAYER_HALTED` | Player is offline (halted) | Wait for player to come online | Yes (30s delay) |
| No Active Delegation | `INVALID_STATE` | Reactor has no active delegation to migrate | Check reactor delegation status | No |
| Already Migrating | `INVALID_STATE` | Reactor is already in migrating state | Wait for current migration to complete | No |
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

### Redelegation to New Validator

- **Scenario**: Redelegate to a different validator
- **Current Validator**: `validator_address_1`
- **Target Validator**: `validator_address_2`
- **Expected Result**: `delegationStatus: migrating`, `migrationInProgress: true`

### Guild Membership Migration

- **Scenario**: Migration as part of guild membership join
- **Note**: Migration happens automatically during guild join
- **Workflow**: See [guild-membership-join.md](guild-membership-join.md)
