---
description: "Device activation, native registration proofs, permission transactions, and private player-address metadata."
---

# Webapp Player Address API Endpoints

**Category**: webapp
**Reviewed implementation**: structs-webapp `5991ca95` and structs-pg `400e1c1`.

These routes add signing devices to an existing player. New-player guild signup is
separate. API authentication uses a [session or bearer](auth.md); native permission
comes from the signing key and chain state. The matching schema/API must deploy
together before using activation identities or private metadata grants.

## Endpoint Summary

| Method | Path | Meaning | Access |
|---|---|---|---|
| GET | `/api/auth/player-address/{address}/guild/{guild_id}/player-id` | Approved player lookup | Public |
| GET | `/api/auth/activation-code/{code}` | Active code/player/activation identity | Public |
| GET | `/api/auth/player-address/{address}/player/{player_id}/proof` | Native consent context | Public |
| GET | `/api/auth/player-address/{address}/player/{player_id}/registration` | Indexed/native registration evidence | Public |
| POST | `/api/auth/player-address` | Submit target-device consent | Public, signature validated |
| POST | `/api/player-address/activation-code` | Issue a code and activation UUID | Authenticated owner |
| GET | `/api/player-address/code/{code}?activation_id={uuid}` | Read pending consent | Authenticated owner |
| DELETE | `/api/player-address/activation-code/{code}?activation_id={uuid}` | Delete that activation instance | Authenticated owner |
| PUT | `/api/player-address/pending/permissions` | Select a pending grant | Authenticated owner |
| PUT | `/api/player-address/permissions` | Returns 410; a native transaction is required | Authenticated |
| GET | `/api/player-address/{address}/state` | Native/indexed authority with exact masks | Authenticated |
| GET | `/api/player-address/count/player/{player_id}` | Approved device count | Authenticated owner |
| GET | `/api/player-address/player/{player_id}` | Approved devices and private metadata | Authenticated owner |
| GET | `/api/player-address/{address}` | One owned approved device | Authenticated owner |
| POST | `/api/player-address/meta` | Refresh owned device IP/browser metadata | Authenticated owner |

Private device and proof/status responses use `Cache-Control: no-store`. Successful envelopes contain
`success:true`, `errors:[]` and `data` (possibly null); failures use keyed errors.

## Activation identity and consent

1. The existing device POSTs `logged_in_address` and `guild_id` to
   `/api/player-address/activation-code`. HTTP 201 returns `code`, `created_at` and
   `activation_id` (UUID). Ownership and approved current guild membership are
   checked; issuing another code for that player/device replaces its old one.
2. The new device resolves `/api/auth/activation-code/{code}` and retains its player
   and UUID alongside the selected guild. The response includes the guild tag, not
   a new guild-ID field. Codes expire after one hour. A short code reused later identifies
   a different activation; never recover consent by short code alone.
3. Generate and persist the new key once, scoped to chain, guild, player and issued
   UUID. Fetch its native proof context and sign the exact message below.
4. POST `/api/auth/player-address` with `player_id`, `guild_id`, `code`,
   `activation_id`, `address`, `signature`, `pubkey`, and optional `user_agent`.
   Signature and public key use the [hex format](auth.md#signed-login-request).
   The server independently reads the current native context and validates consent.
5. The approver reads the pending record with both code and UUID. Select permissions
   using PUT `/api/player-address/pending/permissions`, body `code`, `activation_id`,
   `address`, `permissions`. This stores a proposal, not chain authority. The pending
   column accepts a nonnegative mask up to `2147483647` (the existing controls cover
   the current 25-bit permissions).
6. Submit `MsgAddressRegister` through the authorized signing key, using the target's
   consent. Confirm committed success, then native and indexed ownership at or beyond
   inclusion. Delete the completed activation using both code and UUID.

HTTP 202 from the consent POST means stored, not registered. An identical accepted
retry reuses one consent. A second device or different proof for that instance is
409 `resource_already_exists`; an unavailable/expired identity is 409
`activation_code_unavailable`. Invalid signature is 400; unavailable current proof is
409 `proof_unavailable`. Code deletion/expiry removes its bound pending row.

Do not replace a persisted key or an uncertain signed registration to recover a lost
HTTP response. A changed nonce requires fresh target-device consent before a new
transaction, and only after any prior send is definitively resolved.

## Native registration proof

GET `/api/auth/player-address/{address}/player/{player_id}/proof` returns:

```json
{
  "chain_id": "structstestnet-111",
  "protocol": "v0.22.0",
  "source_height": "3353000",
  "player_id": "1-11",
  "address": "structs1...",
  "proof_nonce": "0",
  "registered_player_id": "",
  "timeout_height": "0"
}
```

This is the `data` payload; the example address is a placeholder. A real address is
validated. Source height and nonce are exact decimal strings. The target must be
unassociated (`registered_player_id` empty). Sign SHA-256 of these UTF-8 bytes:

```text
CHAIN{chain_id}|REGISTERADDRESSPLAYER{player_id}ADDRESS{address}NONCE{proof_nonce}
```

The nonce comes from the single-address native query, not a SQL sequence or a GRASS
JSON number. It is proof input, not a new field on `MsgAddressRegister`. Successful
registration consumes it; revocation preserves it. Before sending, recheck protocol,
owner, nonce and the signing key's ceiling over the requested grant, and simulate
the exact signed transaction.

The stock implementation selects the protocol from testnet `structstestnet-111`,
height `3353000`. Its pre-activation path uses `PLAYER{player_id}ADDRESS{address}`,
null nonce and transaction timeout `3352999`. Configure and verify another network
explicitly; do not infer its boundary from these constants.

## Registration and authority reads

The public `/registration` endpoint returns `data.indexed` (address, player, guild,
status, or null), `data.chain` (native context), and SQL snapshot `meta`. It excludes
IP/browser metadata. An unavailable native source returns 503
`registration_unavailable`, not a fabricated unregistered address.

Authenticated `/api/player-address/{address}/state` uses the session player's ID
and adds exact string `permissions` to the native and indexed sides. Native height
and SQL height are independent. Do not stamp the older SQL row with the newer native
height or accept an unrelated indexed player as a successful registration.

## Permission changes and revocation

PUT `/api/player-address/permissions` returns HTTP 410 with
`chain_transaction_required`. Use `MsgPermissionSetOnAddress` and wait for confirmed
indexing. The signing key must be allowed to destroy the old bits as well as grant
the new ones; preserve bits not exposed by the existing controls. The primary key
retains full access.

Use `MsgAddressRevoke` for native eviction, requiring the signing key's Delete bit.
Do not make revocation depend on the compromised target's grant remaining unchanged.
Log Out without Delete clears this browser's key/session only. A successful revoke
can clear that local session from committed evidence, since the revoked key may no
longer authenticate a subsequent indexed read. The user-facing sweep destination is
“Player Account.”

## Private metadata and device lists

List/count reject another player's ID with 403. Detail returns null outside the
caller's approved set. List/detail permissions are decimal strings; missing grant
rows mean `"0"`. Detail `alpha` is an address-level display value, not the player's
spendable vault balance.

POST `/api/player-address/meta` requires `address`, `guild_id` and optional
`user_agent`. It validates current approved ownership in the write and returns 201;
foreign/unapproved ownership returns 403 `address_does_not_exist`. IP comes from
Symfony's trusted-proxy-aware request. This endpoint updates IP/browser metadata,
not chain permissions or public profile render attributes.

The schema dependencies include `table-player-address-20261030-activation-instance`,
`role-structs-webapp-20261030-address-permission` and
`role-structs-webapp-20261030-device-metadata`. Keep private-table grants coordinated
with these API ownership checks; an older API cannot safely consume them.

*Reviewed against the controllers, proof manager and device manager at webapp
`5991ca95`; activation, recovery, permissions, revocation and metadata were exercised
with restricted database roles and an isolated native chain. See
[permissions](../../knowledge/mechanics/permissions.md) for chain authority.*
