---
title: API error code catalog
description: "Selected release-native errors with codespaces and submission stages, plus HTTP/API handling and links to authoritative definitions."
---

# API error code catalog

## Error Code Reference

Interpret native `(codespace,code)` together with the stage. An HTTP/gRPC gateway
code is a separate namespace. The table selects errors useful to clients; the full
release definitions are linked below.

### HTTP Status Code Errors

400/401/403/404/409 describe request/authentication/resource/conflict handling;
429 and 5xx can justify bounded **read** retries. None alone authorizes repeating an
attempted native broadcast. The webapp body commonly has `success`, `errors`, `data`
and optional `meta`; empty errors can be an array and keyed failures an object.

### Consensus Network Error Codes

| Codespace | Code | Release sentinel | Client response |
|---|---|---|---|
| `structs` | 1050 | `ErrObjectNotFound` | Verify object and source; resource absence is distinct from query unavailability |
| `structs` | 1100 | `ErrPermission` | Check current object and signing-key authority |
| `structs` | 1152 | `ErrPlayerOffline` | Refresh power state and action eligibility |
| `structs` | 1200 | `ErrInsufficientCharge` | Wait for eligible current charge before a later action |
| `structs` | 1613 | `ErrReactorStakeCapExceeded` | Read current reactor stake share/cap and choose an eligible target |
| `structs` | 1900 | `ErrInvalidPacketTimeout` | Diagnose IBC timeout input; this is not object-not-found |
| `structs-ante` | 2000 / 2001 | `ErrTxTooLarge` / `ErrMsgCountExceeded` | Reduce transaction shape within the release limits |
| `structs-ante` | 2002 / 2004 | `ErrUnknownStructsMessage` / `ErrNestedStructsMessage` | Use current direct message types |
| `structs-ante` | 2005 | `ErrInvalidProofIdentity` | Diagnose proof identity before signing |
| `structs-ante` | 2010 / 2011 | `ErrUnregisteredAddress` / `ErrMissingPermission` | Verify ordinary address registration and its own grant |
| `structs-ante` | 2020 / 2021 | `ErrDuplicateChargeInTx` / `ErrChargeAlreadyUsedThisBlock` | Respect the shared player charge action limit |
| `structs-ante` | 2022 | `ErrPlayerDischargedThisBlock` | Wait for a later eligible action |
| `structs-ante` | 2030 / 2031 | `ErrDuplicateProofInTx` / `ErrProofAlreadyAttemptedThisBlock` | Preserve original work intent; respect proof throttles |
| `structs-ante` | 2032 / 2033 | `ErrDuplicateThrottleKeyInTx` / `ErrObjectThrottledThisBlock` | Respect shared object throttle keys |
| `structs-ante` | 2040 / 2041 | `ErrPlayerMsgCapExceeded` / `ErrCheckTxAddrCapExceeded` | Reduce submissions across the relevant player/address budget |
| `structs-ante` | 2042 / 2043 | `ErrDuplicateStakingInTx` / `ErrStakingAlreadySubmittedThisBlock` | One listed staking operation per address per transaction/block; mixed paid transactions do not bypass it |

Some failures are SDK/module errors or structured wrappers with added context.
Do not infer their code from a human label or numeric value in another namespace.

## Error Response Format

Preserve native code/codespace/log, hash and stage. For inclusion also preserve
height, tx index and matching block hash/time. API failures additionally retain
HTTP status and applicable readiness/reason fields. Do not treat parseable JSON,
HTTP 200 or CheckTx code zero as committed execution success.

## Error Handling

A preparation refusal can be reconsidered after current eligibility changes.
Definitive rejection or committed failure is recorded before any later action.
An uncertain send retains its original signed bytes/hash and is observed; a timeout,
empty search result or sequence change cannot authorize re-signing/rebroadcast.

See [error-handling protocol](../protocols/error-handling.md) and
[retry strategies](../patterns/retry-strategies.md).

## Source and Related Documentation

- [Structs release error definitions](https://github.com/playstructs/structsd/blob/96cea3a322c406b46ca1feb880dc4497ebd9353f/x/structs/types/errors.go)
- [Custom ante error definitions](https://github.com/playstructs/structsd/blob/96cea3a322c406b46ca1feb880dc4497ebd9353f/app/ante/errors.go)
- [Structured error context](https://github.com/playstructs/structsd/blob/96cea3a322c406b46ca1feb880dc4497ebd9353f/x/structs/types/errors_structured.go)
- [Error data structures](../schemas/errors.md)
- [Practical error index](../play/errors.md)

**Verified against:** official structsd v0.22.0 `96cea3a`, webapp `43bc1086` and
TSA `3258529`. Source registration names/codes are verified; recovery guidance
still depends on the actual operation and stage.
