---
title: Action protocol for submitting transactions
description: "Prepare exact authorized actions, persist signed identity, broadcast once, and verify committed outcomes without duplicate transactions."
---

# Action protocol for submitting transactions

## Overview

Prepare an action from current authoritative state, sign once, retain its identity,
and observe the outcome. Webapp login authorizes API access; it is not a native
transaction signature. A SQL enqueue or successful broadcast response is not proof
that the action committed.

### Fees

A pure Structs transaction is free only when it excludes `MsgUpdateParams`,
`MsgGuildCreate` and `MsgReactorRestart`. The last two use ordinary priced gas;
guild creation also pays its separate vault-funded founding cost. A pure transaction
of the six allowlisted Cosmos staking messages uses the separate free-staking meter.
Mixed module transactions pay ordinary fees. The default free meters are 20 million
and 40 million gas respectively; “free” does not mean unmetered.

Simulate with the intended messages and current account state. CLI examples use
`--gas auto --gas-adjustment 1.5`; priced operations also need an explicit fee/price
matching the node's admission policy. A browser/TSA integration should select its
fee policy by protocol and message set, not attach one hardcoded fee to everything.
See [transactions](../knowledge/mechanics/transactions.md).

## Base Configuration

Keep chain ID, RPC/LCD origins, protocol, signer and action intent explicit. Use
separate bounded timeouts for reads, simulation, transport and outcome observation.
Do not configure automatic retries for transaction broadcasts. Persist public
signed evidence outside short-lived UI state and keep private keys separately.

## Transaction Flow

### Step 1: Get Account Information

Read the signing account's supported native account type, account number and
sequence as exact uint64 decimal strings. Resolve its ordinary player identity and
current address permissions. Its own grant is a hard ceiling; player/guild authority
does not broaden a restricted key.

For data-derived actions, validate chain/protocol and API readiness first, then the
required current native evidence. `data_ready` permits a coherent read;
`transaction_ready` adds index freshness. Neither replaces current bank spendability,
staking eligibility, permissions, charge, ownership or target checks.

### Step 2: Build Transaction

Use the release protobuf definitions/generated codecs and the current message
fields. [Message catalog](../api/transactions/messages.md) and
[reference-client signing](../develop/client/actions-and-signing.md) identify the
implemented payloads. A readable JSON description is not itself a signed wire body.

Keep original intent alongside the payload: acting player, source owner, destination,
amount/denom, target, original work anchor and applicable proof context. Player-selected
transfers use the recipient vault; explicit non-player addresses remain literal.
Vault funds, retained balances and total wealth are different inputs. A vault never
becomes the signing address.

Use exact arithmetic, retaining full denominations and their known scales. Do not
round account numbers, ranks, clocks, native balances or proof difficulty through a
JavaScript Number. Read `meta` and native completeness before treating an absent
position as zero.

### Step 3: Sign Transaction

Validate/simulate the exact intended message and fee set. Sign the protobuf bytes
with the ordinary signing address and exact account state. Compute the hash from
the final signed `TxRaw` bytes. Persist chain, account, sequence, bytes, hash and
request identity before transport; later refreshed state cannot mutate those bytes.

Address registration uses the target key's consent proof plus an authorized ordinary
signer. The current Structs proxy nonce, asset owner and permission context are not
the native account sequence. Device approval also carries the issued activation UUID.

### Step 4: Submit Transaction

The LCD endpoint is `POST /cosmos/tx/v1beta1/txs`. Its JSON body contains:

```json
{
  "tx_bytes": "BASE64_OF_SIGNED_TXRAW",
  "mode": "BROADCAST_MODE_SYNC"
}
```

The reference client/TSA may use CometBFT RPC for equivalent transport. These are
alternative transport choices for one signed submission, not parallel attempts.
SYNC reports CheckTx admission; ASYNC cannot report inclusion. The application
makes one broadcast attempt and durably records its send marker/result.

### Step 5: Wait for Confirmation

Observe the saved hash and verify matching transaction bytes/results at a committed
block. Retain block height/hash/time, tx index, code, codespace and stage. A successful
CheckTx does not guarantee successful DeliverTx. An HTTP timeout, transaction-search
miss, larger account sequence or reconnect does not prove failure and does not
permit a replacement transaction.

Serialize work per signing account and coordinate same-origin browser tabs. Keep
unknown submissions reserved across reload/logout, connection loss and schema or
codec updates. A cancelled UI wait does not cancel an already submitted action.

### Step 6: Handle Result

| Evidence | Next step |
|---|---|
| Refused before signing/sending | Retain or cancel the unsigned intent as appropriate; prepare again only from current eligibility |
| Definitive CheckTx rejection | Record the exact rejection and allow a later revalidated action |
| Committed DeliverTx failure | Record failure and refresh state; do not label it successful because it entered a block |
| Committed success | Wait for the relevant indexed source/projections, then update the existing screen |
| Unknown/accepted without a committed result | Observe the same identity; no new signature or broadcast |

A sequence mismatch is not permission to edit a possibly submitted transaction's
sequence and resend. First establish the original outcome. See
[retry strategies](../patterns/retry-strategies.md).

## Action Patterns

### Pattern 1: Simple Action

Prepare → persist signed identity → one send → definitive outcome → indexed refresh.

### Pattern 2: Action with Follow-Up

Start a dependent action only after the first's outcome and relevant state are
confirmed. A later API failure does not require repeating the earlier native action.

### Pattern 3: Conditional Action

Recheck conditions immediately before signing. If they changed, reject the unsigned
preparation and retain the user's intent where appropriate. Never rewrite an already
signed request to match a new snapshot.

### Pattern 4: Batch Actions

Batch only where the protocol permits atomic operations. The reference withdrawal
uses a bounded vault-first then eligible retained-address batch. Raw Cosmos staking
rejects repeated operations for the same address in a transaction and across a block;
paying gas or adding keys cannot bypass shared player/object/charge limits.

## Action Requirements

### Common Requirements

Resolve explicit signer/owner/target identities and current permissions. Reject
destroyed or missing targets, insufficient spendable funds, incomplete evidence,
and unsupported protocol/fee policy. An operator grant cannot supply a permission
missing from the signing key.

### Proof-of-Work Requirements

Preserve category, object, target, original block-start anchor and exact difficulty.
Use the current worker protocol and validate the returned candidate. On notification
loss/reconnect read authoritative work; do not invent a new start block or repeat an
uncertain completion. See [work and proof](../develop/client/work-and-pow.md).

## Error Handling

Interpret native `(codespace,code)` with its submission stage, and API errors with
HTTP/body/readiness context. [Error handling](error-handling.md) explains the formats.
Do not use cached/default financial values to make an unavailable action appear ready.

## Best Practices

Preserve the existing screen's intent through definitive failure, retain uncertain
signed evidence through reload, and reject callbacks from an old route/session.
Keep native inclusion and indexed display readiness separate in diagnostics.

## Performance Optimization

Coalesce reads, use bounded polling and notification-driven invalidation, and reuse
complete compatible catalogs. Run proof work outside the UI thread. Parallelize
independent reads; serialize signing for the same account and respect shared quotas.
These optimizations do not authorize duplicate sends or broader signing permissions.

**Verified against:** webapp `43bc1086`, TSA `3258529`, and official structsd release
`96cea3a` fee/throttle maps and generated transaction definitions.
