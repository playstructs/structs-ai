---
title: Transaction Endpoints
description: Transaction endpoints, split out from the full API reference to keep context windows small.
permalink: /api/transactions/
redirect_from:
  - /api/transactions/README
  - /api/transactions/README.html
---

# Transaction Endpoints

**Version**: 1.0.0  
**Purpose**: Transaction endpoints split from `endpoints.md` for context window efficiency

---

## Overview

This directory contains transaction endpoints. All game actions are submitted through the transaction endpoint.

**Use Case**: Load transaction endpoint documentation when submitting actions, instead of loading the entire `endpoints.md` (1153 lines).

Writes go here. Every `structsd tx structs` call needs `--gas auto`, `--` before entity IDs that look like flags, and a pause for the account sequence. Broadcast is not success — query state after. Compute completions (`*-compute`) are a different path: initiate now, finish hours later, never block the session on proof-of-work.

If the transaction “worked” and the board did not change, see [troubleshooting](../../troubleshooting/common-issues.md#transaction-issues) before you send a second one.

There is only one submit path. Everything else in this folder is how to call it without wasting the sequence number. Do not parallelize two transactions from the same key. Different keys can run in parallel. That is the whole concurrency model.

If you are looking for the list of *which* messages exist (mine, build, raid, infuse), that is the [action index](../../reference/action-index.md) and the transaction half of [endpoints](../endpoints.md). This folder is the envelope those messages travel in.

---

## Available Files

- **`submit-transaction.md`** - Submit transaction endpoint (~60 lines)

---

## Context Window Savings

### Before (Loading endpoints.md)

**To get transaction endpoint**:
- Load: `api/endpoints.md` (1153 lines)
- Contains: All query, transaction, and webapp endpoints
- **Waste**: ~1090 lines of unused endpoints

### After (Loading transaction file)

**To get transaction endpoint**:
- Load: `api/transactions/submit-transaction.md` (~60 lines)
- Contains: Only transaction endpoint
- **Savings**: 95% reduction (1090 lines saved)

---

## Usage

### Loading Transaction Endpoint

```json
{
  "load": "api/transactions/submit-transaction.md"
}
```

---

## Related Documentation

- **Main Endpoints**: `../endpoints.md` - Complete endpoint catalog (index)
- **Queries**: `../queries/` - Query endpoints
- **Actions**: `../../schemas/actions.md` - Action message types
- **Protocols**: `../../protocols/action-protocol.md` - How to perform actions

---

*Last Updated: January 2025*
