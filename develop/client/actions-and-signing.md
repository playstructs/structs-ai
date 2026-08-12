---
description: "How a client turns a click into a broadcast transaction: wallet, protobuf registry, the dual-lane queue, and charge gating."
---

# Actions and signing

**Purpose**: How the reference client turns a click into a broadcast transaction —
wallet, protobuf registry, the dual-lane queue, and charge gating.

Everything that changes game state goes through here. It is also where the two failure
modes that plague new clients live: `account sequence mismatch`, and acting before you
have charge.

---

## Wallet

CosmJS, bech32 prefix `structs`, 12-word mnemonic from 16 bytes of entropy:

```js
// src/js/managers/WalletManager.js
createMnemonic() {
  const getNewRandom = Random.getBytes(16);
  return Bip39.encode(getNewRandom).toString();
}

async createWallet(mnemonic) {
  return await DirectSecp256k1HdWallet.fromMnemonic(mnemonic, { prefix: "structs" });
}
```

No `hdPaths` is passed, so derivation falls back to the CosmJS default. If you need the
exact path, read it off your installed version rather than assuming — this codebase does
not state it.

> **The mnemonic is stored unencrypted in `localStorage`.** Do not copy that. See
> [SAFETY.md](../../SAFETY.md).

### Off-chain proof signatures

Guild signup, login and address registration authenticate with a signature over a
**plain concatenated string** — not an ADR-036 `SignDoc`. SHA-256 the UTF-8 bytes, sign
the digest with secp256k1, return lowercase hex of the 64-byte fixed-length signature:

```js
async createSignatureForProxyMessage(message, privateKey) {
  const encodedMessage = this.textEncoder.encode(message);
  const digest = sha256(encodedMessage);
  const rawSignature = await Secp256k1.createSignature(digest, privateKey);
  return this.bytesToHex(rawSignature.toFixedLength());
}
```

The message formats are exact — get a character wrong and the server rejects it:

| Use | Format |
|---|---|
| Guild signup | `GUILD{guildId}ADDRESS{address}NONCE{nonce}` |
| Login | `LOGIN_GUILD{guildId}ADDRESS{address}DATETIME{unixTimestamp}` |
| Address register | `PLAYER{playerId}ADDRESS{address}` |

---

## Signing client and registry

```js
// src/js/managers/SigningClientManager.js
this.registry = new Registry([...defaultRegistryTypes, ...msgTypes]);

this.wsUrl = this.publicEndpoint
    ? `wss://public.testnet.structs.network:26657`
    : `ws://${window.location.hostname}:26657`;

this.gameState.signingClient = await SigningStargateClient.connectWithSigner(
  this.wsUrl, wallet, { registry: this.registry },
);
```

`msgTypes` comes from `src/js/ts/structs.structs/registry.ts` — roughly 330
`[typeUrl, GeneratedType]` pairs covering messages, queries, events and domain objects.
Type URLs are all of the form `/structs.structs.Msg…`:

```ts
["/structs.structs.MsgStructBuildInitiate", MsgStructBuildInitiate],
```

**Fees are a single flat constant.** No simulation, no gas price, no adjustment:

```js
// src/js/constants/Fee.js
export const FEE = {
  amount: [{ denom: "ualpha", amount: "0" }],
  gas: "500000",
};
```

This differs from the CLI guidance in [AGENTS.md](../../AGENTS.md), which uses
`--gas auto --gas-adjustment 1.5`. Both work; the webapp just picks a limit generous
enough for every message it sends and stops thinking about it.

`creator` is never stored in a queued payload — it is injected from the signing account
at broadcast time, so a persisted queue cannot be replayed against the wrong account:

```js
// src/js/models/SigningTransaction.js
toCosmosMsg(registry) {
  const type = registry.lookupType(this.message.typeUrl);
  if (!type) throw new Error(`Unknown typeUrl in registry: ${this.message.typeUrl}`);
  return {
    typeUrl: this.message.typeUrl,
    value: type.fromPartial({ ...this.message.payload, creator: this.accountAddress }),
  };
}
```

---

## The dual-lane queue

`SigningQueueManager` is the most transferable idea in the client. Two lanes and one
in-flight slot:

```js
/** @type {SigningTransaction[]} Unordered lane; fired ASAP. */
this.immediateQueue = [];
/** @type {SigningTransaction[]} Ordered action lane; head gated lazily on charge. */
this.actionQueue = [];
/** @type {SigningTransaction|null} Tx currently being broadcast. */
this.inFlight = null;
```

| Lane | Enqueue | For |
|---|---|---|
| Immediate | `enqueueImmediate(typeUrl, payload)` | Anything not charge-costed — notably proof-of-work completions |
| Action | `enqueueAction(typeUrl, payload, chargeCost)` | Charged game actions, strictly FIFO |

On every block, `transactOnBlock` picks at most one transaction:

1. Return immediately if something is in flight, the signing client is missing, or a
   transaction already went out at this height.
2. If the action head exists, the confirmed last-action height is loaded, and projected
   charge covers its cost → broadcast the action head.
3. Otherwise, if the immediate queue is non-empty → broadcast its head.

**A blocked action head does not block the immediate lane.** That is the whole point of
the split: your mine completions keep flowing while a charged action waits for the bar to
refill.

### Sequence numbers: don't track them, just serialise

The client never touches sequence numbers. It avoids `account sequence mismatch` with
three mechanical guarantees:

- an `inFlight` mutex, so at most one broadcast is outstanding;
- a `lastBroadcastHeight` governor, so at most one transaction per block per address;
- strict FIFO within each lane.

CosmJS fetches and increments the sequence internally. Serialising submissions is enough.
This is the same reasoning behind the CLI rule in [AGENTS.md](../../AGENTS.md) — one
transaction at a time per account, roughly six seconds apart.

### Charge gating

Charge is elapsed blocks since your last charged action, with a `+1` offset:

```js
// src/js/util/ChargeCalculator.js
calcCharge(currentBlockHeight, lastActionBlockHeight) {
  return currentBlockHeight - (lastActionBlockHeight + 1);
}
```

The queue projects the same value against a walking base:

```js
projectedChargeAt(blockHeight) {
  return blockHeight - (this.getWalkingBase() + 1);
}
```

Three distinct heights are in play, and conflating them is a real bug:

| Value | Source | Used for |
|---|---|---|
| `confirmedLastActionBlockHeight` | GRASS `lastAction`, or REST at login | **The scheduler.** The only trustworthy base |
| `scheduleAnchorHeight` | Inclusion height of the last charged tx this client sent | Advancing the base between confirmations |
| `lastActionBlockHeight` (optimistic) | Set locally the moment you enqueue | **Display only** — the charge bar |

The walking base is `max(confirmed, anchor)`. The optimistic value drains the bar in the
UI immediately so the interface feels responsive, and deliberately never reaches the
scheduler — otherwise a dropped transaction would leave the client believing it had spent
charge it still has.

> **Hold the action lane until the confirmed height has loaded.** The base defaults to
> `0`, which projects as effectively infinite charge, and the client would empty its
> entire queue into one block. The reference client checks `isConfirmedActionLoaded()`
> before releasing anything.

When charge is short, the head simply stays put and is re-evaluated next block. Nothing
is dropped and nothing is retried.

### Persistence

The queue survives a reload. Key is `signingQueue:{wsUrl}:{address}`, so switching
account or network cannot cross-contaminate. Snapshots older than 30 minutes, or corrupt
JSON, are moved aside to `{key}.corrupt` rather than being parsed. An in-flight
transaction found at startup has its attempt count incremented and is re-queued or
dropped, because the client cannot know whether it landed.

Payloads are validated as JSON-safe at enqueue (`assertSerializable`), which is why
`BigInt` throws — stringify before enqueueing.

### Retries

```js
// src/js/constants/SigningQueueConstants.js
DEFAULT_RETRY_LIMIT: 0,           // 0 retries => 1 attempt (no retries for now)
MAX_QUEUE_AGE_MS: 30 * 60 * 1000,
TIMEOUT_POLL_BLOCKS: 5,
```

One attempt by default, with no backoff — a retry, if enabled, goes to the **tail** of
its lane and waits for the next eligible block. The one special case is a CosmJS
`TimeoutError` carrying a `txId`, where the client polls `getTx` for five blocks before
concluding failure, since a timeout is not the same as a rejection.

---

## End to end: building a struct

```
DeployOffcanvas                 user releases on a deployable struct
  → SigningClientManager.queueMsgStructBuildInitiate(playerId, typeId, ambit, slot, cost)
      maps the ambit name to its enum index
      → SigningQueueManager.enqueueAction('/structs.structs.MsgStructBuildInitiate', …)
          → SigningTransaction.create → append to action lane → persist
  ← UI updates optimistically right away (offcanvas closes, pending build appears)

BlockListener (GRASS)           every block
  → gameState.setCurrentBlockHeight → BLOCK_HEIGHT_CHANGED
      → SigningQueueManager.transactOnBlock
          charge gate passes → toCosmosMsg → signAndBroadcast(address, [msg], FEE)
          on code 0 → advance scheduleAnchorHeight → settle → persist

StructListener (GRASS)          chain emits struct_block_build_start
  → refreshStruct, and spawn the BUILD proof-of-work task
StructListener                  chain emits struct_status = BUILT
  → clear the pending build, render the struct
```

Note where the UI updates: **immediately on enqueue, not on confirmation**. That is a
deliberate responsiveness choice, and it is only safe because GRASS will correct the
display when the real event arrives.

---

## Error handling, and its gap

`whenSettled(id)` resolves — it never rejects — with the transaction object. **Callers
must check `status` themselves.**

| Failure | Handling | Reaches the user? |
|---|---|---|
| Unknown type URL | failure handler | no, `console.warn` |
| `signAndBroadcast` throws | failure handler (timeout polled first) | no |
| Broadcast `code !== 0` | treated as failure | no |
| Signer address mismatch | held, restored to lane head | no, `console.warn` |
| Retries exhausted | status `DROPPED`, settled | no |

```js
#handleBroadcastFailure(tx, err) {
  console.warn('Sign and Broadcast Error:', err);
  tx.attempts++;
  tx.error = String(err);
  if (this.canRetry(tx)) {
    this.appendToLane(tx);
  } else {
    tx.status = TX_STATUS.DROPPED;
    this.settle(tx);
    this.persist();
  }
}
```

A `SIGNING_TRANSACTION_SETTLED` event is dispatched on every terminal state — and
**nothing in the codebase listens to it**. Most call sites are fire-and-forget: the
deploy flow calls `.then()` with no handler and never inspects the status. So a dropped
build transaction leaves an optimistic pending-build in the UI with no error shown.

The auth flow is the one place it is done properly:

```js
if (registerTx.status === TX_STATUS.SUCCEEDED) { … }
```

**Do it the auth flow's way.** The queue already gives you the event and the status; the
only missing piece is a listener that turns a `DROPPED` transaction into something the
operator can see. That is a handful of lines, and it is the difference between an agent
that knows its action failed and one that reports success it never achieved — see
[AGENTS.md](../../AGENTS.md) rule 3, verify after acting.

---

*Verified against structs-webapp `6eec7f7` (2026-07-21): `src/js/managers/WalletManager.js`,
`SigningClientManager.js`, `SigningQueueManager.js`, `src/js/models/SigningTransaction.js`.*
