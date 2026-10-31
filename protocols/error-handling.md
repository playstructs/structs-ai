---
description: "Interpret HTTP, API and native transaction failures by their source and stage, preserving uncertain outcomes during recovery."
---

# Error Handling Protocol

## Overview

Keep the source and stage of an error: HTTP transport, webapp validation/readiness,
native simulation, CheckTx admission or committed DeliverTx. A single invented
numeric error list cannot represent all of them. The same transport failure calls
for a read retry or signed-identity reconciliation depending on the operation.

## Error Response Formats

### Consensus Network API Error Response

An LCD/gRPC-gateway error may have `code`, `message` and `details`. That `code` is
not automatically a Structs ABCI code. CometBFT admission/block results carry
`codespace`, `code` and log/result fields. Preserve those fields together and the
transaction hash, request stage and committed coordinates when available.

Do not assume HTTP 200 means a transaction succeeded, or that an entity lookup
always uses one HTTP status. Validate the endpoint's result shape and identity.

### Web Application API Error Response

The application DTO uses `success`, `errors`, `data`, and where applicable `meta`.
Success commonly has `errors: []`; failure can contain keyed error messages. Server,
proxy or framework errors may return another body entirely. Reject a non-success
HTTP response before trusting parseable JSON as current data.

```json
{
  "success": false,
  "errors": {"signature_validation_failed": "Invalid signature"},
  "data": null
}
```

Incomplete financial/catalog/work evidence may carry readiness/reason metadata and
HTTP 503. Unknown raw values remain null. An unavailable read is not an empty valid
result or permission to use zero. See [read-model protocol](webapp-api-protocol.md).

### HTTP Status Codes

| Status | Typical handling |
|---|---|
| 400 | Validate the request; diagnose native result fields separately |
| 401 | Reauthenticate a private read once; a failed login must not recurse |
| 403 | Check actual route/authority; do not broaden keys automatically |
| 404 | Verify resource/context and whether the result is authoritative |
| 409 | Resolve the reported state/identity conflict; retain the original request |
| 429 | Apply bounded backoff for repeatable reads |
| 5xx | Treat as unavailable; repeat reads within budget, observe attempted sends |

A proxy status is not definitive evidence that a native broadcast never reached a node.

## Error Categories

### Error Code Schema

Use [native code reference](../api/error-codes.md) and
[error data structures](../schemas/errors.md). `structs` and `structs-ante` are
different codespaces; Cosmos modules and transport layers also define their own.
A zero CheckTx code proves admission, while a zero committed DeliverTx code proves
execution success for that exact transaction.

### Retryable vs Non-Retryable Errors

Read timeouts/rate limits/transient failures may be retried within bounds. Invalid
proofs, payloads or permissions require diagnosis. Temporary game conditions may
permit a later revalidated action; they do not authorize blind retransmission.
A signed unknown outcome must retain its bytes/hash and reserve its signing context.

## Retry Strategies

### Exponential Backoff

Use deadlines, jitter, an attempt budget and route/session cancellation for reads.
Coalesce identical requests and cancel stale consumers. Do not wrap signing or
broadcast in a generic HTTP retry helper.

### Fixed Delay Retry

A readiness probe may wait for the next observation interval. It must still reject
wrong-chain, old-session or older snapshots. A cached timestamp is not native authority.

### Rate Limit Handling

Respect a valid Retry-After within the overall read budget. For attempted sends,
reconcile the saved identity unless a definitive native rejection is established.
See [retry strategies](../patterns/retry-strategies.md).

## Error Recovery Patterns

### Pattern 1: Resource Not Found

Verify the ID and current source. Distinguish a complete empty result from unavailable
or truncated evidence. A missing transaction-search result alone proves neither
non-inclusion nor permission to create another payment.

### Pattern 2: Insufficient Resources

Read exact spendable vault funds and current action requirements. Total inventory,
retained funds and unbonding receipts are not automatically spendable. A later action
may be prepared after funding/charge changes and the prior outcome is established.

### Pattern 3: Player Offline

Refresh authoritative capacity/load and target state. Do not infer online status
from a failed request or a fallback zero. Shared player/charge limits remain shared
across keys and paid transactions.

### Pattern 4: Network Errors

Reconnect, reauthenticate if appropriate, restore subscriptions and refresh state.
Retain signed evidence and observe its original identity. GRASS reconnect supplies
invalidation opportunities, not durable event replay or transaction cancellation.

## Error Handling Best Practices

- Check HTTP, body shape, `success`, identity and applicable readiness metadata.
- Log redacted operation IDs/stages and bounded errors, never keys or credentials.
- Keep unavailable financial/action evidence unavailable; stale data can inform a
  labelled display but cannot manufacture signing eligibility.
- Reject late callbacks from a prior route/account/session.
- Keep SQL and TSA-volume evidence through recovery; never clear an unknown send
  to make a queue look healthy.

## Error Code Reference

The [API code reference](../api/error-codes.md) lists selected release-native codes
and links their source. There is no universal “1–9” game-error mapping.

## Examples

An API timeout while reading funds permits a bounded read retry. A timeout after
sending signed transfer bytes requires observing that hash. A committed failure
returns the transfer to its existing confirmation with the same recipient/amount;
a later confirmed action can be prepared from fresh state.

## Integration with Other Protocols

[Action protocol](action-protocol.md) defines one-send identity and outcomes.
[Authentication](authentication.md) defines session/token recovery.
[State and data](../develop/client/state-and-data.md) defines coherent cache updates.

## Testing Error Handling

Exercise actual transport boundaries: HTTP failure with valid JSON, lost send
acknowledgement, admission without inclusion, committed failure, reload while
unknown, notification loss, wrong-session late replies and incomplete native data.
Assert the original hash/bytes and send count survive; checking only an error string
cannot establish duplicate prevention.

## References

- [Retry strategies](../patterns/retry-strategies.md)
- [Native errors](../api/error-codes.md)
- [API contracts](webapp-api-protocol.md)

**Verified against:** webapp `43bc1086`, TSA `3258529`, official structsd `96cea3a`.
