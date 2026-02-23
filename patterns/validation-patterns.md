# Validation Patterns

**Version**: 1.0.0  
**Category**: Pattern  
**Status**: Stable

## Overview

This document describes validation patterns for AI agents interacting with Structs. Understanding these patterns is critical for correctly handling action results and avoiding common mistakes.

## Transaction Validation Flow

### Complete Flow

```json
{
  "transactionFlow": {
    "1": "Create transaction (pending)",
    "2": "Sign transaction",
    "3": "Submit to POST /cosmos/tx/v1beta1/txs",
    "4": "Transaction moves to 'broadcast' status",
    "5": "on-chain validation occurs",
    "6": "Action succeeds OR fails based on validation",
    "7": "Check actual game state to verify result"
  }
}
```

### Critical Understanding

**⚠️ IMPORTANT**: A transaction showing "broadcast" status does NOT mean the action succeeded!

**Validation happens on-chain AFTER broadcast**. If requirements aren't met, the transaction will broadcast but the action won't happen.

### Verification Pattern

```json
{
  "verificationPattern": {
    "1": "Submit transaction",
    "2": "Wait for transaction to reach 'broadcast' status",
    "3": "Query game state to verify action actually occurred",
    "4": "If action didn't occur, check requirements",
    "5": "Fix requirements and retry if needed"
  }
}
```

## Common Validation Failures

### 1. Planet Building Without Command Ship

**Action**: `MsgStructBuild` on a planet  
**Symptom**: Transaction broadcasts but struct not created  
**Cause**: Command Ship not built or not online

**Requirements Check**:
```json
{
  "requirements": {
    "commandShipBuilt": "Check fleet for Command Ship struct",
    "commandShipOnline": "Command Ship status must be 'online' (not just materialized)",
    "fleetOnStation": "Fleet status must be 'onStation' (not 'away')",
    "playerOnline": "Player must be online (not halted)"
  }
}
```

**Dependency Chain**:
```json
{
  "dependencyChain": {
    "1": "Build Command Ship in fleet (MsgStructBuild)",
    "2": "Complete Command Ship build (MsgStructBuildComplete with proof-of-work)",
    "3": "Activate Command Ship (bring online)",
    "4": "Then can build on planets"
  }
}
```

### 2. Exploration Without Completing Current Planet

**Action**: Exploration (create new planet)  
**Symptom**: Transaction broadcasts but planet ownership unchanged  
**Cause**: Current planet still has ore remaining

**Requirements Check**:
```json
{
  "requirements": {
    "currentPlanetEmpty": "Current planet must have 0 ore remaining",
    "playerOnline": "Player must be online"
  }
}
```

**Verification**:
```json
{
  "verification": {
    "checkPlanetOre": "Query planet attributes for ore amount",
    "mustBeZero": "Ore amount must be 0 before exploring",
    "thenExplore": "Once empty, exploration will succeed"
  }
}
```

### 3. Building Without Sufficient Power

**Action**: `MsgStructBuild`  
**Symptom**: Transaction broadcasts but struct not created  
**Cause**: Insufficient power capacity

**Requirements Check**:
```json
{
  "requirements": {
    "sufficientPower": "Must have power capacity > struct passive draw",
    "checkLoad": "Current load + struct load <= capacity",
    "checkStructDraw": "Struct passive draw must be available"
  }
}
```

## Validation Status Codes

### Transaction Status Values

```json
{
  "transactionStatus": {
    "pending": {
      "description": "Transaction created, waiting to be processed",
      "action": "wait"
    },
    "broadcast": {
      "description": "Transaction sent to blockchain",
      "action": "wait for validation",
      "warning": "Does NOT mean action succeeded!"
    },
    "confirmed": {
      "description": "Transaction included in block",
      "action": "verify game state"
    },
    "failed": {
      "description": "Transaction failed validation",
      "action": "check requirements and retry"
    }
  }
}
```

### Validation Result Pattern

```json
{
  "validationResult": {
    "transactionStatus": "broadcast",
    "actionSucceeded": false,
    "reason": "Command Ship not online",
    "gameStateCheck": {
      "expected": "Struct created",
      "actual": "No struct found",
      "match": false
    }
  }
}
```

## Best Practices

### 1. Always Verify Game State

**Pattern**:
```json
{
  "verificationPattern": {
    "afterAction": "Query game state",
    "compare": "Expected vs actual",
    "ifMismatch": "Check requirements and retry"
  }
}
```

### 2. Check Requirements Before Acting

**Pattern**:
```json
{
  "preActionCheck": {
    "1": "Query current game state",
    "2": "Verify all requirements met",
    "3": "If not met, fix requirements first",
    "4": "Then perform action"
  }
}
```

### 3. Handle Validation Failures Gracefully

**Pattern**:
```json
{
  "failureHandling": {
    "1": "Detect validation failure (action didn't occur)",
    "2": "Identify missing requirement",
    "3": "Fix requirement",
    "4": "Retry action",
    "5": "Verify success"
  }
}
```

## Example: Building on Planet

### Complete Flow with Validation

```json
{
  "example": {
    "step1": {
      "action": "Check Command Ship",
      "query": "GET /structs/fleet/{fleetId}",
      "check": "Command Ship exists and is online"
    },
    "step2": {
      "action": "Check Fleet Status",
      "query": "GET /structs/fleet/{fleetId}",
      "check": "Fleet status is 'onStation'"
    },
    "step3": {
      "action": "Check Power",
      "query": "GET /structs/player/{playerId}",
      "check": "Sufficient power capacity"
    },
    "step4": {
      "action": "Build Struct",
      "transaction": "MsgStructBuild",
      "wait": "For broadcast status"
    },
    "step5": {
      "action": "Verify Struct Created",
      "query": "GET /structs/struct",
      "filter": "By locationId",
      "check": "Struct exists"
    },
    "step6": {
      "action": "If Not Created",
      "reason": "Check which requirement failed",
      "fix": "Fix requirement",
      "retry": "Retry build"
    }
  }
}
```

## Error Detection Patterns

### Pattern 1: Broadcast But No Result

```json
{
  "pattern": {
    "symptom": "Transaction status = 'broadcast' but action didn't occur",
    "diagnosis": {
      "1": "Query game state",
      "2": "Compare expected vs actual",
      "3": "Identify missing requirement",
      "4": "Check requirements list"
    },
    "solution": {
      "1": "Fix missing requirement",
      "2": "Retry action",
      "3": "Verify success"
    }
  }
}
```

### Pattern 2: Requirements Not Documented

```json
{
  "pattern": {
    "symptom": "Action fails but requirements unclear",
    "diagnosis": {
      "1": "Check action requirements in actions.json",
      "2": "Check validation patterns",
      "3": "Query game state to understand constraints"
    },
    "solution": {
      "1": "Document missing requirement",
      "2": "Update actions.json",
      "3": "Add to validation patterns"
    }
  }
}
```

## Testing Validation

### Test Pattern

```json
{
  "testPattern": {
    "1": "Perform action with missing requirement",
    "2": "Verify transaction broadcasts",
    "3": "Verify action does NOT occur",
    "4": "Fix requirement",
    "5": "Retry action",
    "6": "Verify action succeeds"
  }
}
```

## Related Documentation

- `protocols/action-protocol.md` - How to perform actions
- `schemas/actions.md` - Action definitions and requirements
- `schemas/errors.md` - Error codes
- `patterns/state-sync.md` - State synchronization patterns

---

*Last Updated: December 7, 2025*

