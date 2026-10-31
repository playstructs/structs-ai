---
description: "Exact transaction intents, wallet proofs, native preparation, durable submissions, charge scheduling, and confirmed outcomes."
---

# Actions and signing

The client saves an intent, prepares it against current indexed/native evidence,
signs and verifies the exact transaction, journals it before sending, then reconciles
its committed result. A timeout or CheckTx acceptance cannot establish success.
This page describes webapp integration `bde1cec8`; a client must deploy its matching
API, schema, generated types and workers together.

## Wallet

`WalletManager` uses CosmJS `DirectSecp256k1HdWallet` with prefix `structs` and a
12-word mnemonic generated from 16 random bytes. It supplies no custom `hdPaths`.
The reference browser stores wallet material in localStorage; that storage is within
the page's trust boundary. See [SAFETY.md](../../SAFETY.md) before adopting its custody
model. Do not put private keys in API bodies, journals or diagnostics.

### Off-chain proof signatures

SHA-256 the UTF-8 bytes of the exact string, sign with secp256k1, and hex-encode the
raw 64-byte R followed by S signature. Public key is compressed 33-byte hex.
These proofs are separate from protobuf transaction signing.

| Use | Signed message |
|---|---|
| Guild proxy signup | `GUILD{guildId}ADDRESS{address}NONCE0` |
| API login/token | `LOGIN_GUILD{guildId}ADDRESS{address}DATETIME{unixTimestamp}` |
| Address registration | Exact preimage below; the separator is one literal pipe |

```text
CHAIN{chainId}|REGISTERADDRESSPLAYER{playerId}ADDRESS{address}NONCE{proofNonce}
```

Login timestamps are canonical decimal strings less than 600 seconds from server
time in either direction. Registration reads the current native address nonce and
requires the target to be unassociated. It also carries the issued activation UUID
through the [device workflow](../../api/webapp/player-address.md). A new proof cannot
replace an uncertain signed registration.

## Signing client and registry

`SigningClientManager` combines CosmJS `defaultRegistryTypes` with generated
`src/js/ts/structs.structs/registry.ts`. The generator pins structsd release
`96cea3a322c406b46ca1feb880dc4497ebd9353f`, its Buf dependency lock and a separate tool
lock. Generate/check through `npm --prefix src run proto:sync -- --source <checkout>`
and `proto:check`, rather than hand-editing generated files.

`forceLong=string` preserves 64-bit protobuf fields. `MessagePayload` validates the
actual generated request schema before persistence and again on restore; unknown
fields and already-rounded unsafe numbers are rejected. Keep integer and coin
amounts as canonical decimal strings. LegacyDec protobuf strings encode scaled
18-place integer atoms, while LCD JSON uses decimal text; the codec adapter handles
that distinction without Number arithmetic.

`creator` is injected from the transaction's fixed signing account when encoding.
A source address, target device or spending owner is a subject, not an alternate
signer. Vault addresses have no private keys. The queue checks account scope again
before preparation and sending.

### Protocol-aware intents

| Intent | Preparation |
|---|---|
| Alpha transfer | Current native ownership/TokenTransfer and vault-first funding with eligible retained collection; selected player resolves to that player's vault, explicit address stays literal |
| Reactor change | Same-height native/indexed complete positions; vault first, then eligible retained addresses deterministically |
| Generator funding | Native target/type/owner/TokenInfuse, vault-first funding with eligible retained collection and current stored output |
| Address registration | Target consent, current nonce/protocol, current signing key and requested grant |
| Device change | Current ownership, nonce lifetime and appropriate permission ceiling; native permission-set/revoke |
| Gameplay | Explicit allowlist for the 17 existing control messages, current signing owner/key bits, native simulation of target/charge/proof rules |

Generated support for a message does not make every low-level builder a reviewed
v0.22 action. A stale primary-address payload is not made vault-aware by new codecs.
Generic queued messages without current-protocol preparation remain deferred.

Reactor withdrawal creates one atomic transaction across at most 16 positions;
it rejects an incomplete request rather than making a partial withdrawal. Native
pagination and request/time budgets are bounded, every batch is simulated, and
ineligible retained stake does not become a fabricated available balance. See
[state-and-data.md](state-and-data.md) for exact read models.

### Fees and exact signed preparation

The legacy `FEE` fallback is zero `ualpha` with gas `500000`. Reviewed gameplay,
registration/device, reactor and generator preparation explicitly use zero `ualpha`
and the release free-gas ceiling `20000000`. A transfer that collects retained funds uses that ceiling too; a single-message transfer retains the fallback.
These are client limits, not proof that arbitrary state will fit or a gas-price rule
for native Cosmos staking messages.

`SigningSubmission.prepare` reads account number/sequence and authority at a pinned
native height, checks the API contract and required projection evidence, then calls
CosmJS `sign` with that explicit account/chain context. Installed CosmJS uses Number
for account number/sequence and query heights; unsupported unsafe values are refused.

The client decodes and checks the wallet's returned message bytes, order, memo,
timeout, fee, mode, signer and signature against the intended transaction. It hashes
the exact TxRaw bytes. Reviewed intents simulate those same signed bytes at the
preparation height; simulation must fit the selected gas limit. Before sending,
protocol and connection/account identity are rechecked. Simulation reserves nothing;
only committed chain execution determines success.

For the configured `structstestnet-111` transition at `3353000`, pre-activation
transactions expire at `3352999`. Post-activation transactions expire at the observed preparation height plus 60 blocks. This client validity window is separate from native permission, staking cooldown and the address-consent proof context.
Other networks require an explicit authoritative configuration.

## The dual-lane queue

`SigningQueueManager` keeps FIFO action and immediate lanes. It selects at most one
new transaction per observed block per address. An eligible charged action has
priority; a blocked action head permits immediate work, including proof completions.
An uncertain submission that can still execute reserves new sends in both lanes. Historical unknown outcomes do not reserve the signing account.

### Sequence numbers and account ownership

Same-origin tabs share a Web Lock keyed by chain and signing account. Inside that
lock the queue reloads the per-intent journal before preparing or sending. A missing
Web Locks implementation or failed durable storage prevents a new send; there is no
unlocked fallback. A secure context with Web Locks is required: localhost was tested; a non-local deployment needs HTTPS and origin-specific acceptance. Different origins/devices need their own account coordination.

Account changes suspend and drain the old queue, persist its evidence under its own
scope, cancel its observers and only then attach the new wallet. A save failure
refuses the handoff. A sequence change elsewhere never proves an old transaction
failed and never authorizes automatically signing its replacement.

### Charge gating

The browser's conservative scheduler/display convention is:

```text
projectedCharge(H) = H - (max(confirmedLastAction, scheduleAnchor) + 1)
```

This client offset is separate from the chain's elapsed-block charge calculation.
The action lane waits until its confirmed last-action source has loaded. A local
optimistic drain affects only display. The anchor advances on a verified successful
charged transaction's inclusion height and disappears when confirmed state catches
up. When charge is short the head waits for another block.

### Persistence

Queue snapshot version 3 uses `signingQueue:{wsUrl}:{address}`. Each intent also has
an independent `signingJournal:{chainId}:{address}:{id}` record. The snapshot cannot
erase signed evidence. Signed bytes/hash and the `prepared` record must be durably
written before the separate `broadcasting` marker; only then can the network send
run. Terminal history is bounded, except records still referenced by saved device-action pointers. Unresolved evidence is never pruned simply for its age.

| Journal/state | Recovery meaning |
|---|---|
| queued / current-format preparing without send evidence | Demonstrably unsent; revalidate before trying |
| prepared journal | Exact bytes saved, but no durable send marker; rebuild only this unsent intent |
| broadcasting / accepted / unknown | May have reached the chain; retain bytes/hash and reconcile only |
| historical / unknown | Legacy record without signed identity, or durable native proof its signed sequence was consumed; preserve the unknown outcome and permit new explicit actions, never replay it |
| succeeded | Matching committed code 0 |
| dropped | Definitive rejection, failure before sending, or proved non-execution after signed expiry |
| cancelled | Explicit cancellation of unsent work |

The 30-minute age limit applies only to unsent intents. Legacy in-flight records
without signed identity remain unknown history and never become fresh sends. They
do not block new explicit actions. Corrupt active queues or journals still block
signing and remain available for recovery. Logout clears private browser state
and closes the unsigned session boundary while retaining public journals.

Legacy lane entries with a nonzero attempt count or recorded broadcast block are
possible sends, even when their status says queued or an earlier import saved them
as version 3. They remain unknown history. The current endpoint/account's `.corrupt`
backup is preserved verbatim. Identifiable possible sends are imported for
observation; malformed backups are not executed and do not reserve the account.
A backup with valid current signed identity still follows native reconciliation.
Unsigned-only backups are not replayed. No notice or new screen is added.
This preserves evidence without resolving an identity-free transaction's outcome
or inspecting another origin's storage. A manually repeated action can execute
again if the earlier action already committed; no automatic repeat is permitted.

### Retries and settlement

There are no automatic signed-send retries. `broadcastTxSync` code 0 is admission,
not completion. A valid CheckTx rejection can settle failure; an ambiguous transport
failure cannot. `find` looks up the original hash and verifies exact bytes, hash,
chain, block/commit identity, transaction index and execution code. A missing hash,
RPC outage or local deadline leaves the result unknown. After exact native TxNotFound, a nonzero signed timeout can settle as dropped only when a later committed snapshot proves the same account number and an unchanged signed account sequence. A passed height alone is insufficient. A later committed snapshot of the same account
with an advanced sequence proves the old signed bytes cannot execute again. Save
that proof durably and release the signing reservation while keeping the outcome
unknown; this is not a failed or successful receipt. Conflicting/unavailable
evidence stays held. Retain the original bytes and proof; never automatically sign
a replacement. Bounded lookups prioritize possible live sends before historical
records and rotate within each group.

`whenSettled(id, signal)` resolves with the terminal transaction; check `status`.
It remains pending for uncertainty. Aborting a view observer rejects only that
observer, not the transaction. Persist the queue ID with the action/work so reload
reattaches to the same operation. `SIGNING_TRANSACTION_SETTLED` notifies observers,
including the authoritative Alpha refresh path.

### Recovering a silently dead signing socket

`OwnedRpcClient` owns the socket and bounds requests. Resume checks use fresh chain
status, share one in-flight probe, respect connection/session epochs and do not
replace the first startup connection. Visibility, focus, pageshow, online and
watchdog paths can recover transport and reconcile journals. A dead socket does
not become a failed payment.

## End to end: building a struct

```text
Existing Deploy control
  → capture gameplay intent and enqueue in the action lane
Block / confirmed charge
  → read API/native authority, sign, verify, simulate exact bytes
  → journal prepared + send marker
  → broadcast once and reconcile original hash
Matching committed success
  → observe indexed work with the original start anchor
  → compute proof using the current catalog/rule epoch
  → queue completion and retain its durable transaction ID
```

Pending visuals are not receipts. Refresh authoritative indexed state after inclusion
and on notification loss/reconnect. The [work lifecycle](work-and-pow.md) keeps local
worker completion distinct from successful native completion.

## Error handling

Keep view, session and action lifetimes separate. Closing an offcanvas cancels its
preview work, while the action observes its persisted transaction. Stale reads and
notifications must not complete a different action or affect a new wallet session.

The existing transfer flow returns a definitive failure to its confirmation screen
with recipient/amount preserved. An unknown send stays protected against duplicates.
Deploy and action controls handle enqueue refusal before adding pending visuals, and release only their own operation lock after a definitive failure. Device and gameplay actions likewise require terminal evidence before reporting
success; a successful self-revoke may clear local state without waiting for an API
read that the revoked key can no longer authenticate.

### Desktop adds a native virtual-player signer

The separately reviewed Desktop source has two additional virtual-player modes.
Its baseline below does not certify compatibility with this webapp integration:

- `sync` / `async` use the Rust ↔ webview bridge and CosmJS.
- `native` / `native_async` sign in Rust and broadcast through LCD REST.

At sign-in, `native_signer_import` can transfer the mnemonic from the webview once. Rust
normalizes it, verifies that `m/44'/118'/0'/0/0` derives the signed-in device address,
stores it in the OS keychain, and retains a zeroized BIP39 seed in memory. A child key at
`m/44'/118'/0'/0/N` is derived per sign and dropped before the first await. Until import
succeeds, native modes fall back to the webview bridge.

Native signing tracks account number/sequence per address, advances on mempool acceptance,
and resets from the chain's expected sequence on disagreement. A per-account mutex is
shared with the JS bridge so modes cannot race one account; `tx_gate_cap` bounds
cross-account concurrency. `native_async` returns after CheckTx acceptance and later emits
`tx_settled`, while `native` waits for inclusion.

This is a custody change, not an MCP key-export feature: tool callers still request
signatures and never receive the mnemonic, but the Rust process and OS keychain now belong
inside the signing trust boundary. See [agent-security.md](../../awareness/agent-security.md).

*Webapp claims verified against integration `bde1cec8`: WalletManager,
SigningClientManager, SigningQueueManager, SigningSubmission, TransactionJournal,
SigningTransaction, MessagePayload, protocol/fee constants and intent preparation.
The checked release fixtures include exact signed bytes, simulation, native atomic
rollback, reload/unknown outcomes and unchanged rendered controls.*

*Desktop integration retains its separate verification against
`3f04437d5606d6736df41301bb980893129a7912`: `mcp/native_signer.rs`,
`vplayer_bridge.rs`, `tx_gate.rs`, `tx_retry.rs`, and `tools/system.rs`. No new Desktop
compatibility or deployment claim is made here.*
