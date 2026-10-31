---
title: API request schemas
description: "Current wallet authentication, device consent, native broadcast and query request contracts, with links to endpoint-specific field definitions."
---

# API Request Schemas

## Request Type Index

The webapp API, native LCD and native transaction messages are different contracts.
Use the matching deployed API revision and release codecs. This index points to
verified field definitions rather than treating one generic body as valid everywhere.

| Request family | Canonical contract |
|---|---|
| Wallet login, bearer and guild signup | [Authentication API](../api/webapp/auth.md) |
| Device activation, consent and metadata | [Player address API](../api/webapp/player-address.md) |
| Player/search queries | [Player API](../api/webapp/player.md) |
| Public guild directory/filter | [Guild API](../api/webapp/guild.md) |
| Native signed broadcast | [Submit transaction](../api/transactions/submit-transaction.md) |
| Native message fields | [Release message catalog](../api/transactions/messages.md) |

## Authentication Requests

### AuthSignupRequest

`POST /api/auth/signup` requires `primary_address`, `signature`, `pubkey` and
`guild_id`. Optional profile fields are `username`, `pfp` and
`pfp_client_render_attributes`. The proof is over
`GUILD{guildId}ADDRESS{address}NONCE0`. HTTP 202 accepts asynchronous onboarding;
it does not establish native registration or a login session.

### AuthLoginRequest

`POST /api/auth/login` or `/api/auth/token` requires `address`, `signature`,
`pubkey`, `guild_id` and canonical decimal `unix_timestamp`. Sign SHA-256 of the
exact UTF-8 bytes `LOGIN_GUILD{guildId}ADDRESS{address}DATETIME{unix_timestamp}`.
The timestamp must be less than 600 seconds from server time in either direction.

These proofs use a compressed secp256k1 public key as 66 hex characters and a raw
R+S signature as 128 hex characters. There is no caller-selected `message` field.
See [authentication schemas](authentication.md) for response and session handling.

## Player Requests

### Player Name and PFP Updates

Names and PFPs use native `MsgPlayerUpdateName`, `MsgPlayerUpdatePfp` and
`MsgPlayerUpdatePfpClientRenderAttributes`. Validate with the release rules and
encode the native message; a webapp profile request does not replace a transaction.

### PlayerRaidSearchQuery

Use the deployed [player search parameters](../api/webapp/player.md). Do not add
invented `status` filters or assume entity-detail fields are accepted query inputs.

### PlayerTransferSearchQuery

Use the [player transfer search](../api/webapp/player.md) contract. Player selection
resolves the recipient's vault for payment; a literal non-player address remains
literal. Search results do not authorize the sender's spend.

## Player Address Requests

### PlayerAddressAddPendingRequest

`POST /api/auth/player-address` requires `player_id`, `guild_id`, `code`,
`activation_id`, `address`, `signature` and `pubkey`; `user_agent` is optional.
The proof is bound to the current native registration context and issued activation
UUID. Persist the new key once and retain its consent; acceptance is not registration.

### PlayerAddressMetaRequest

`POST /api/player-address/meta` requires an authenticated owner, `address`,
`guild_id` and optional `user_agent`. The server derives IP from the request.
It is private device metadata, not an arbitrary metadata-object write.

### PlayerAddressActivationCodeRequest

`POST /api/player-address/activation-code` accepts `logged_in_address` and
`guild_id` from the authenticated owner. Retain the returned code and UUID together.
A reused short code is a different activation instance.

### PlayerAddressPendingPermissionsRequest

`PUT /api/player-address/pending/permissions` accepts `code`, `activation_id`,
`address` and a numeric `permissions` mask, not a list of names. This records an
owner's proposal; the native registration transaction establishes authority.
See the [device API](../api/webapp/player-address.md) for accepted mask bounds.

### PlayerAddressPermissionsRequest

`PUT /api/player-address/permissions` returns 410 `chain_transaction_required`.
Prepare `MsgPermissionSetOnAddress`, preserving unexposed bits and checking the
signer's ceiling over both removed and granted permissions. Observe inclusion
before adopting the indexed result.

## Transaction Requests

### TransactionRequest

`POST /cosmos/tx/v1beta1/txs` accepts this **broadcast envelope**:

```json
{"tx_bytes":"BASE64_OF_SIGNED_TXRAW","mode":"BROADCAST_MODE_SYNC"}
```

The signed protobuf `TxRaw` contains encoded body/auth-info and signatures. A JSON
object containing `body`, `auth_info` and `signatures` is not the LCD request above.
Keep account number, sequence, amounts, ranks and heights exact; select fees for
the actual message set. Ordinary fees use the chain's configured denomination
(`ualpha` here), not an invented `ustructs` asset.

#### body

Prepare native messages, memo and applicable timeout height, then encode them with
the matching release codecs. Never change an already signed body to retry a timeout.

#### auth_info

Encode the ordinary signer's public key/mode/sequence and chosen fee/gas policy.
A player or guild vault is an asset owner and never a substitute signing key.

### TransactionMessage

Native JSON descriptions use registered `@type` URLs, but actual broadcast carries
signed protobuf bytes. Refer to the [message catalog](../api/transactions/messages.md)
and release `tx.proto` for fields. For example, `MsgAllocationTransfer` takes
`creator`, `allocationId` and `ownerId` (player or guild), not an old `controller`
field. Native uint64 values must not pass through lossy JavaScript Numbers.

A CheckTx code zero means admitted, not committed. Persist the one signed identity
and reconcile its outcome; do not repeat the send after an uncertain response.

## Query Parameters

### QueryParameters

Pagination is endpoint-specific. Native key pagination and webapp page/limit
parameters are not interchangeable. Respect advertised limits and continuation
fields; an incomplete page is not a complete empty balance or permission result.

### GuildNameFilterQuery

Use the public `/api/guild/name` filter fields in the [guild contract](../api/webapp/guild.md).

### GuildDirectoryQuery

Use the public `/api/guild/directory` paging fields in the [guild contract](../api/webapp/guild.md).
Preserve its response shape and exact values; do not invent a universal 20-row limit.

**Reviewed against:** webapp `43bc1086` authentication/device/query contracts and
structsd release `96cea3a` transaction definitions.
