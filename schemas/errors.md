---
description: "Error identity across HTTP, webapp and native results, with stage-aware recovery and no implicit broadcast retries."
---

# Structs Error Codes

## Error Codes

### Success

Native `code=0` must be interpreted with its stage: CheckTx admission is not
committed execution. A matching committed DeliverTx result with code zero establishes
execution success. Indexed API display readiness is a later check.

### Game Errors

Use `(codespace,code)` from the native result. Structs handler sentinels use
`structs`; custom ante sentinels use `structs-ante`. See the
[selected native catalog](../api/error-codes.md) and pinned release source.
Do not assign generic numbers 1–9 to insufficient funds, signatures, gas or charge.

### HTTP Errors

HTTP status belongs to the request/transport layer. It is not a native ABCI error
code. A proxy timeout or 5xx after a send does not prove the transaction was rejected.
Read failures can be retried with bounds; uncertain sends must be observed.

### Network Errors

Retain operation stage, whether transport was attempted, signed request identity,
and error evidence. Do not turn a lost acknowledgement into a fresh request.

## Error Categories

| Evidence | Fields to retain |
|---|---|
| Webapp response | HTTP status, `success`, `errors`, relevant readiness/reason metadata |
| LCD/gRPC query failure | Transport status and gateway `code`, `message`, `details` when present |
| Native simulation/admission | Stage, `(codespace,code)`, log, exact intended/signed identity |
| Committed native result | Hash/bytes, height, tx index, block hash/time, DeliverTx code/codespace |
| Unknown submission | Original chain/signer/account/sequence/bytes/hash and send marker |

The webapp's empty `errors` value can be an array; keyed failures can be objects.
A framework/proxy failure need not use the application DTO.

## Retry Classification

Repeatable read failures use bounded retries. Changed unsigned eligibility permits
new preparation. UUID-bound server requests reuse identical arguments and the saved
UUID. An uncertain signed transaction is never automatically replaced or resent.

## Error Handling Strategy

### Retryable Errors

Classify the operation before the transport error. Preserve cancellation, total
deadlines, current session and source identity for read retries. Follow
[retry strategies](../patterns/retry-strategies.md).

### Non-Retryable Errors

Invalid payloads/proofs/permissions need diagnosis. Preserve a definitive failure
and revalidate later intent. Never “repair” uncertainty by deleting history,
changing account sequence or widening a key's permissions.

**Verified scope:** webapp `43bc1086`, TSA `3258529`, native codespaces at official
structsd `96cea3a`. This is an error-shape/recovery contract, not a complete SDK catalog.
