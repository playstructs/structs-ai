# Error Codes

**Version**: 1.0.0  
**Category**: Troubleshooting  
**Status**: Stable

## Overview

This document provides quick reference for error codes and their meanings. For complete error definitions, see `schemas/errors.md`.

---

## Common Error Codes

### Success
- **Code**: 0
- **Name**: SUCCESS
- **Description**: Operation successful
- **Action**: Continue

---

### General Errors
- **Code**: 1
- **Name**: GENERAL_ERROR
- **Description**: General error occurred
- **Action**: Log and retry
- **Retryable**: Yes

---

### Resource Errors
- **Code**: 2
- **Name**: INSUFFICIENT_FUNDS
- **Description**: Insufficient funds for transaction
- **Action**: Wait for resources
- **Retryable**: No
- **Requires**: Check player inventory, wait for resources

---

### Authentication Errors
- **Code**: 3
- **Name**: INVALID_SIGNATURE
- **Description**: Transaction signature is invalid
- **Action**: Re-sign transaction
- **Retryable**: Yes

---

### Gas Errors
- **Code**: 4
- **Name**: INSUFFICIENT_GAS
- **Description**: Insufficient gas for transaction
- **Action**: Increase gas limit
- **Retryable**: Yes

---

### Message Errors
- **Code**: 5
- **Name**: INVALID_MESSAGE
- **Description**: Message format is invalid
- **Action**: Validate message format
- **Retryable**: No

---

### Player Status Errors
- **Code**: 6
- **Name**: PLAYER_HALTED
- **Description**: Player is halted (offline)
- **Action**: Wait for player online
- **Retryable**: No
- **Requires**: Check player status, wait for player online

---

### Charge Errors
- **Code**: 7
- **Name**: INSUFFICIENT_CHARGE
- **Description**: Struct has insufficient charge
- **Action**: Wait for charge to build
- **Retryable**: No
- **Requires**: Check struct charge, wait for charge

---

## Error Handling Patterns

### Pattern 1: Retryable Errors

```json
{
  "pattern": {
    "errors": [1, 3, 4],
    "action": "Retry with same parameters",
    "maxRetries": 3,
    "retryDelay": 2000
  }
}
```

### Pattern 2: Non-Retryable Errors

```json
{
  "pattern": {
    "errors": [2, 5, 6, 7],
    "action": "Fix requirement, then retry",
    "steps": [
      "Identify missing requirement",
      "Fix requirement",
      "Verify fix",
      "Retry action"
    ]
  }
}
```

---

## Error Code Lookup

### By Category

**Success**: 0

**General**: 1

**Resources**: 2

**Authentication**: 3

**Gas**: 4

**Message**: 5

**Player Status**: 6

**Charge**: 7

---

## Related Documentation

- **Error Schemas**: `../schemas/errors.md` - Complete error definitions
- **Common Issues**: `common-issues.md` - Common issues and solutions
- **Validation**: `../validation/` - Validation patterns

---

*Last Updated: January 2025*

