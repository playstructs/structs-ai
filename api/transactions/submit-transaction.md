---
description: "Submit signed protobuf transaction bytes, distinguish admission from inclusion, and preserve identity when the outcome is uncertain."
---

# Submit Transaction

## Endpoint

| Method | Path | Input |
|---|---|---|
| POST | `/cosmos/tx/v1beta1/txs` | Signed protobuf `TxRaw` bytes in the LCD broadcast envelope |

Native signing authority is required. Webapp session/bearer authentication does
not sign a chain transaction. CometBFT RPC is an alternative transport; use one
transport for the one attempted broadcast.

## Parameters

| Field | Encoding | Meaning |
|---|---|---|
| `tx_bytes` | base64 string | Complete signed `TxRaw` bytes |
| `mode` | enum string | `BROADCAST_MODE_SYNC` asks for CheckTx admission |

A JSON message body is input to transaction construction, not a signed broadcast
request. Use current generated protobuf types and exact account/sequence/amounts.

## Example

### Request

```json
{
  "tx_bytes": "BASE64_OF_SIGNED_TXRAW",
  "mode": "BROADCAST_MODE_SYNC"
}
```

### Response

Inspect `tx_response` including hash, code, codespace and log. A code of zero in a
SYNC response establishes admission only. Observe matching bytes/results at a
committed height and check DeliverTx success before treating the action as complete.

Persist the exact bytes/hash and request identity before transport. On timeout or
lost acknowledgement observe that identity; never automatically create or resend
another transaction. Indexer/read-model confirmation is separate from native inclusion.

## Related Documentation

- [Action protocol](../../protocols/action-protocol.md)
- [Message catalog](messages.md)
- [Reference-client signing](../../develop/client/actions-and-signing.md)
- [Native errors](../error-codes.md)
- [Retry strategies](../../patterns/retry-strategies.md)

**Verified scope:** native submission contract used by webapp `43bc1086` and TSA
`3258529`, with official structsd release `96cea3a` messages and SDK transport.
