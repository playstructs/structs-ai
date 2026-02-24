# Structs Error Codes

**Version**: 1.1.0
**Category**: errors
**Description**: Complete catalog of error codes for AI agents

---

## Resolved Bugs

| Bug | Status | Description |
|-----|--------|-------------|
| GetInfusionByID array split bug | resolved | Bug in GetInfusionByID array split logic has been resolved |
| EventGuildBankAddress format bug | resolved | Bug in EventGuildBankAddress format has been resolved |
| BankAddress format logging bug | resolved | Bug in BankAddress format logging has been resolved |
| Fleet movement logic | resolved | Fleet movement bug fixes and improvements applied |

---

## Error Codes

### Success

| Code | Name | Category | Description | Action | Retryable |
|------|------|----------|-------------|--------|-----------|
| 0 | SUCCESS | success | Operation successful | continue | -- |

### Game Errors

| Code | Name | Category | Description | Action | Retryable | Requires |
|------|------|----------|-------------|--------|-----------|----------|
| 1 | GENERAL_ERROR | error | General error occurred | log and retry | yes | -- |
| 2 | INSUFFICIENT_FUNDS | error | Insufficient funds for transaction | wait for resources | no | check player inventory, wait for resources |
| 3 | INVALID_SIGNATURE | error | Transaction signature is invalid | re-sign transaction | yes | -- |
| 4 | INSUFFICIENT_GAS | error | Insufficient gas for transaction | increase gas limit | yes | -- |
| 5 | INVALID_MESSAGE | error | Message format is invalid | validate message format | no | -- |
| 6 | PLAYER_HALTED | error | Player is halted (offline) | wait for player online | no | check player status, wait for player online |
| 7 | INSUFFICIENT_CHARGE | error | Struct has insufficient charge | wait for charge | no | check struct charge, wait for charge |
| 8 | INVALID_LOCATION | error | Location is invalid or inaccessible | validate location | no | -- |
| 9 | INVALID_TARGET | error | Target is invalid or not attackable | validate target | no | -- |

### HTTP Errors

| Code | Name | Category | Description | Action | Retryable |
|------|------|----------|-------------|--------|-----------|
| 400 | BAD_REQUEST | http | Invalid request | validate request format | no |
| 404 | ENTITY_NOT_FOUND | http | Entity not found | verify entity ID | no |
| 500 | INTERNAL_SERVER_ERROR | http | Server error | retry with backoff | yes |

### Network Errors

| Code | Name | Category | Description | Action | Retryable |
|------|------|----------|-------------|--------|-----------|
| timeout | REQUEST_TIMEOUT | network | Request timed out | retry with backoff | yes |
| network | NETWORK_ERROR | network | Network error occurred | retry with backoff | yes |

---

## Error Categories

| Category | Error Codes |
|----------|-------------|
| success | 0 |
| error | 1, 2, 3, 4, 5, 6, 7, 8, 9 |
| http | 400, 404, 500 |
| network | timeout, network |

---

## Retry Classification

**Retryable**: 1 (GENERAL_ERROR), 3 (INVALID_SIGNATURE), 4 (INSUFFICIENT_GAS), 500 (INTERNAL_SERVER_ERROR), timeout (REQUEST_TIMEOUT), network (NETWORK_ERROR)

**Not retryable**: 0 (SUCCESS), 2 (INSUFFICIENT_FUNDS), 5 (INVALID_MESSAGE), 6 (PLAYER_HALTED), 7 (INSUFFICIENT_CHARGE), 8 (INVALID_LOCATION), 9 (INVALID_TARGET), 400 (BAD_REQUEST), 404 (ENTITY_NOT_FOUND)

---

## Error Handling Strategy

### Retryable Errors

| Setting | Value |
|---------|-------|
| Action | retry |
| Max retries | 3 |
| Backoff | exponential |
| Initial delay | 1000 ms |

### Non-Retryable Errors

| Setting | Value |
|---------|-------|
| Action | log |
| Fallback | abort or wait |
