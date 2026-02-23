---
name: structs-diplomacy
description: Handles permissions, address management, and inter-player coordination in Structs. Use when delegating authority, managing multi-address accounts, or coordinating with other players.
---

# Structs Diplomacy

## Procedure

1. **Query permissions** — `structsd query structs permission [id]`, `permission-by-object [object-id]`, `permission-by-player [player-id]`.
2. **Grant on object** — `structsd tx structs permission-grant-on-object [object-id] [player-id] [permissions] TX_FLAGS`. Permissions are additive.
3. **Revoke on object** — `permission-revoke-on-object [object-id] [player-id] [permissions]`.
4. **Set on object** — `permission-set-on-object [object-id] [player-id] [permissions]` — clears existing and applies new set.
5. **Address-level permissions** — `permission-grant-on-address [address] [permissions]`, `permission-revoke-on-address`, `permission-set-on-address`.
6. **Address management** — Register: `address-register [player-id] [address] [proof-pubkey] [proof-signature] [permissions] TX_FLAGS`. Revoke: `address-revoke [address]`. Update primary: `player-update-primary-address [player-id] [new-address]`.

## Commands Reference

| Action | Command |
|--------|---------|
| Grant on object | `structsd tx structs permission-grant-on-object [object-id] [player-id] [permissions]` |
| Revoke on object | `structsd tx structs permission-revoke-on-object [object-id] [player-id] [permissions]` |
| Set on object | `structsd tx structs permission-set-on-object [object-id] [player-id] [permissions]` |
| Grant on address | `structsd tx structs permission-grant-on-address [address] [permissions]` |
| Revoke on address | `structsd tx structs permission-revoke-on-address [address] [permissions]` |
| Set on address | `structsd tx structs permission-set-on-address [address] [permissions]` |
| Address register | `structsd tx structs address-register [player-id] [address] [proof-pubkey] [proof-sig] [permissions]` |
| Address revoke | `structsd tx structs address-revoke [address]` |
| Update primary address | `structsd tx structs player-update-primary-address [player-id] [new-address]` |

**TX_FLAGS**: `--from [key-name] --gas auto --gas-adjustment 1.5 -y`

| Query | Command |
|-------|---------|
| Permission by ID | `structsd query structs permission [id]` |
| Permission by object | `structsd query structs permission-by-object [object-id]` |
| Permission by player | `structsd query structs permission-by-player [player-id]` |
| Address | `structsd query structs address [address]` |
| Addresses by player | `structsd query structs address-all-by-player [player-id]` |

## Verification

- **Permission**: `structsd query structs permission-by-object [object-id]` — list players with access.
- **Address**: `structsd query structs address [address]` — verify registration, player link.
- **Player addresses**: `structsd query structs address-all-by-player [player-id]` — all linked addresses.

## Error Handling

- **Permission denied**: Signer lacks permission on object. Check `permission-by-object` for current grants.
- **Address already registered**: Use `address-revoke` first, or link to different player.
- **Invalid proof**: Address registration requires valid proof pubkey and signature. Verify auth flow.
- **Object not found**: Object ID may be stale. Re-query to confirm entity exists.

## See Also

- `knowledge/entities/entity-relationships.md` — Object types and IDs
- `protocols/authentication.md` — Auth for address registration
