---
description: "Read server time for wallet login and indexed block/readiness metadata without confusing it with native chain confirmation."
---

# Webapp System API Endpoints

| Method | Path | Authentication |
|---|---|---|
| GET | `/api/timestamp` | Public |
| GET | `/api/block` | Session or bearer |

## Server timestamp

`/api/timestamp` returns server Unix seconds, not chain time:

```json
{"success":true,"errors":[],"data":{"unix_timestamp":1704067200}}
```

Use server time for the [login proof](auth.md). Its timestamp must be a canonical
decimal string less than 600 seconds from the server in either direction. The full
public-route allowlist is in the auth reference; public guild reads are not limited
to `/api/guild/this`.

## Indexed block and readiness

`/api/block` returns a current-block object or null with `chain_id`, `height`,
`tip_height`, `lag_blocks`, `status` and `updated_at`. The response also carries
`meta` from `api_readiness([])` in the same SQL snapshot. A response can be HTTP 200
with `success: true` and still have `data_ready: false` or `transaction_ready: false`.

Read [snapshot metadata](../../protocols/webapp-api-protocol.md#snapshot-metadata)
for the exact contract. This route requests no specific projection model, so it
cannot certify a different response's inventory/work data. `tip_height` is observed
indexer evidence, not a replacement for current native status, simulation or a
committed transaction receipt.

*Verified against webapp `43bc1086` TimestampController/ResponseMetaUtil and
structs-pg `400e1c1` api_readiness.*
