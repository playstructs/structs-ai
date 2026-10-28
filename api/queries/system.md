---
description: "Query system-level state on the consensus network: chain parameters, vault addresses, and signature validation."
---

# System Query Endpoints

**Version**: 1.0.0
**Category**: Query
**Entity**: System
**Base URL**: `http://localhost:1317`
**Base Path**: `/structs`

---

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/blockheight` | Get current block height | No | No |
| GET | `/structs/structs/params` | Get module parameters | No | No |
| GET | `/structs/vault/{ownerId}` | Vault address for a player or guild | No | No |
| GET | `/structs/structs/guild_charter` | Legacy; nothing consumes it | No | No |
| GET | `/structs/validate_signature/{address}/{proofPubKey}/{proofSignature}/{message}` | Validate a signature | No | No |

---

## Endpoint Details

### Get Current Block Height

`GET /blockheight`

Returns the current block height of the blockchain.

#### Response

- **Content-Type**: `application/json`
- **Schema**: [BlockHeight](../../schemas/entities.md)

#### Example

**Request**: `GET /blockheight`

**Response**:

```json
{
  "height": 12345
}
```

---

### Get Module Parameters

`GET /structs/structs/params`

Returns the current module parameters for the Structs module. Staking-related params worth reading before you infuse: `diversityMaxBonusBps` (5000), `diversityTargetExtraReactors` (9), `reactorStakeCapBps` (3000), `reactorStakeCapMinValidators` (10). The `guildCharterDifficultyRange` / `guildCharterReactorAge` params still exist but are consumed by nothing.

#### Response

- **Content-Type**: `application/json`
- **Schema**: [Params](../../schemas/entities.md)

---

### Vault

`GET /structs/vault/{ownerId}`

Resolves the deterministic vault account for a player (`1-N`) or guild (`0-N`). **CLI**: `structsd query structs vault [owner-id]`. Response: `ownerId`, `address` (bech32), `provisioned` (whether the account exists on chain yet — it is created lazily on the first write). Refined Alpha, stake and Central Bank balances live at this address; read them with the standard `bank` module (`/cosmos/bank/v1beta1/balances/{address}`). See [energy.md — Vaults](../../knowledge/mechanics/energy.md#vaults-where-game-alpha-lives).

### Guild Charter (legacy)

`GET /structs/structs/guild_charter`

Still served (**CLI**: `guild-charter`) but no handler reads it: guild founding is a paid `guild-create`, not a proof-of-work. Do not build on this endpoint.

### Validate Signature

`GET /structs/validate_signature/{address}/{proofPubKey}/{proofSignature}/{message}`

**CLI**: `validate-signature`. Used by guild proxy signup verification, not gameplay.
