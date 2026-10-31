---
title: Error codes quick reference
description: "Identify native codespace and submission stage, distinguish read failures from uncertain transactions, and use the release error catalog."
---

# Error codes quick reference

## Overview

Preserve the source and stage before interpreting a code. HTTP status, gRPC-gateway
codes and native ABCI `(codespace, code)` pairs use different namespaces. The
[native error catalog](../api/error-codes.md) lists verified release definitions.

## Common Error Codes

| Evidence | Meaning / response |
|---|---|
| CheckTx code 0 | Admitted; observe committed execution |
| Committed DeliverTx code 0 | That exact transaction succeeded; wait for indexed refresh |
| `structs`, 1050 | Object not found; verify ID and authoritative source |
| `structs`, 1100 | Permission failure; inspect current signer and object authority |
| `structs`, 1152 | Player offline; refresh power state |
| `structs`, 1200 | Insufficient charge; wait for current eligibility |
| `structs`, 1613 | Reactor stake cap; choose an eligible target after current reads |
| `structs-ante`, 2011 | Signing key lacks required permission |
| `structs-ante`, 2021 | Player charge action already used this block |
| `structs-ante`, 2042 / 2043 | Duplicate staking operation in transaction/block |

## Error Handling

Read timeouts, 429 and temporary 5xx failures permit bounded read retries. Malformed
proofs, unsupported payloads and permission failures need diagnosis, not automatic
re-signing. An unavailable financial read stays unknown rather than becoming zero.

Once a native send may have happened, retain its bytes/hash and observe that identity.
Timeout, search miss, reconnect or a larger account sequence is not proof of failure.
Definitive CheckTx rejection or committed failure must be recorded before a later
revalidated action. Never convert an uncertain payment back to an available queue item.

## Related Documentation

- [Full selected error catalog and source definitions](../api/error-codes.md)
- [Error data structures](../schemas/errors.md)
- [Error handling protocol](../protocols/error-handling.md)
- [Retry strategies](../patterns/retry-strategies.md)
- [Practical symptom index](../play/errors.md)

**Reviewed against:** official structsd `96cea3a`, webapp `43bc1086` and TSA `3258529`.
