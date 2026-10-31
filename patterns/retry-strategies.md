---
description: "Retry bounded reads, preserve idempotent request identities, and reconcile uncertain signed transactions without duplicate broadcasts."
---

# Retry Strategies Pattern

## Overview

Decide whether the operation is a read, a known-unsent action, an idempotent request,
or a signed submission before retrying it. An HTTP status alone cannot tell you
whether a transaction reached the chain. A retry wrapper around signing/broadcast
can repeat a payment or replace the identity needed to establish its outcome.

## Retryable vs Non-Retryable Errors

### Retryable Errors

| Operation | Permitted recovery |
|---|---|
| Read times out, loses its connection, or receives HTTP 429/5xx | Retry the read with a deadline, bounded backoff and cancellation; respect a valid Retry-After policy |
| Cached session expires | Reauthenticate once, then retry the protected read within the same session generation |
| Explicit idempotent TSA operator/key request loses its SQL acknowledgement | Repeat identical arguments with the saved request UUID; do not allocate a new request |
| Unsigned action lacks current data/charge | Wait for fresh authoritative eligibility, then prepare the still-current intent |
| Broadcast or result persistence loses its acknowledgement | Observe the already saved transaction identity; do not sign or broadcast again |

### Non-Retryable Errors

Malformed payloads, invalid signatures, unsupported protocol/authority, permission
denials and failed native simulation need diagnosis or changed inputs. Sleeping does
not fix them. Do not use invented global mappings such as “code 3 = retryable
signature error”: native codes must be interpreted with their codespace and stage.

Insufficient charge, an offline player or insufficient funds may change later. They
still do not justify blindly repeating a signed request. Distinguish a preparation
refusal, definitive CheckTx rejection and committed DeliverTx failure from an unknown
transport outcome.

## Basic Retry Strategies

### Strategy 1: Exponential Backoff

Use a small bounded attempt count, a per-attempt deadline and a total deadline for
reads. Add jitter to avoid synchronized clients. Cancel when the user leaves the
route, logs out, switches player/account or replaces the connection. Coalesce
identical in-flight reads instead of multiplying requests from several listeners.

The reference webapp uses a 15-second default HTTP deadline. Its helpers reject
HTTP 5xx even if the body contains parseable JSON. Do not turn a failed read into an
empty success response.

### Strategy 2: Fixed Delay Retry

A periodic health/readiness probe can wait for its next bounded interval. A 429
response can provide Retry-After; validate the value and apply the client's overall
deadline. A transaction POST that timed out remains uncertain regardless of how
long that interval has elapsed.

### Strategy 3: Linear Backoff

A delay schedule is a transport choice for repeatable reads, not evidence that an
action is safe to repeat. Prefer the simplest schedule that respects the service's
limits; additional retry mechanisms do not change the submission rules below.

## Advanced Retry Patterns

### Pattern 1: Circuit Breaker

Stop initiating dependent actions while required reads repeatedly fail. Keep the
last coherent snapshot for display only when its stale/unavailable state is known.
Resume preparations after fresh protocol, authority and readiness checks, not merely
a successful TCP connection.

### Pattern 2: Retry with Validation

Before preparing an unsent action, verify the original intent still applies:
current player, target, protocol, permissions, exact amount, funds, charge and work
anchor. A refreshed amount/recipient must not mutate an already signed identity.
A confirmed failed transfer returns to confirmation with its amount/recipient
preserved; a new user action can then use a new validated snapshot.

### Pattern 3: Retry with Context

Persist request identity before the side effect. For signed transactions preserve
chain, signer, account number, sequence, signed bytes/hash and outcome evidence.
The webapp journal survives reload and retains public unknown-send evidence across
logout. TSA stores signed identity in SQL and on its persistent volume before its
one-use send permit. A lost acknowledgement must refer back to that identity.

### Pattern 4: Adaptive Retry

Adapt read polling frequency to visibility, connection state and useful new data.
Do not adapt permissions or generate a new signing key to escape a shared throttle.
TSA pool growth has a separate exact-grant policy; it is not transaction retry.

## Error-Specific Retry Strategies

### Rate Limit Errors (429)

Retry eligible reads after bounded delay. For an attempted broadcast, establish
whether the native node definitively rejected that exact identity. A proxy response
or missing acknowledgement does not establish non-inclusion.

### Timeout Errors

A read may be repeated. A signed submission becomes unknown and remains reserved.
Observe its hash and matching block bytes/results. Neither an empty `tx_search`
response nor a larger account sequence proves failure.

### Network Errors

Reconnect and refresh authoritative state. Recreate subscriptions and invalidate
stale projections, but do not replay signed transactions as part of reconnection.
A GRASS reconnect does not provide durable event replay.

### Server Errors (500)

Reject the failed read even if its response is valid JSON. Bound read retries and
keep actions unavailable until their evidence is complete. Preserve an uncertain
submission for reconciliation if the error followed a send attempt.

## Retry Configuration

Configure deadlines, attempt budgets and cancellation per operation. Keep transport
retry separate from submission state. A system-wide “retry all failed POSTs” policy
is incompatible with one-attempt signing. UUID-bound server requests are repeatable
only where the server explicitly implements that idempotency contract.

## Best Practices

- Preserve exact integers and the original work anchor; recalculating from rounded
  values can change the intended transaction or proof.
- Revalidate cache epoch, chain, owner and source height after reconnect or login.
- Invalidate financial data on notifications, then read a complete snapshot; do not
  apply unverified event deltas or substitute unknown balances with zero.
- Stop stale callbacks from overwriting a newer route/session. Aborting a UI wait
  does not cancel a transaction already sent to the chain.
- Keep diagnostics to operation IDs/stages and redacted error details. Never log
  credentials, private keys, recovery phrases or full authentication requests.

## Integration with Other Patterns

[Signing](../develop/client/actions-and-signing.md) defines durable submission
states. [State and data](../develop/client/state-and-data.md) defines coherent reads
and cache invalidation. [GRASS](../develop/client/realtime-grass.md) defines reconnect
recovery. [TSA operations](../knowledge/infrastructure/guild-stack.md#transaction-signing-agent)
cover persistent key/SQL recovery.

## Monitoring and Metrics

Measure read timeout/attempt counts, projection lag, unresolved-submission age and
reconciliation results separately. “Retry succeeded” cannot stand in for a matching
committed result. Alert on unresolved evidence without deleting it or unreserving keys.

## Quick Reference

Read failure → bounded read retry. Known-unsent refusal → fresh eligibility.
Idempotent request → same UUID and arguments. Uncertain broadcast → same signed
identity, observation only. Definitive outcome → record it and refresh authoritative
state before any later action.

**Verified against:** webapp integration `43bc1086` signing/journal/HTTP lifecycle
and TSA `3258529` worker/journal/operator contracts. Read-backoff recommendations
are implementation guidance, not new chain error codes or permission to rebroadcast.
