---
title: "Permissions skill: bits, keys, delegates"
meta_description: "Permissions are identity and authority: the 25-bit bitmask per grantee, address registration, and delegation recipes for multi-agent play."
name: structs-permissions
description: Permissions, address management, and delegation in Structs. Use when granting/revoking permissions on objects or addresses, registering additional signing keys, managing multi-address accounts, or setting up minimum-permission delegate agents (mining bot, defense watcher, co-pilot). Covers the full 25-bit permission model and delegation recipes for multi-agent play.
level: advanced
domain: social
---

# Structs Permissions

Permissions *are* identity and authority in Structs. Every object (player, guild, reactor, provider, substation, struct) has a 25-bit permission bitmask per grantee, and addresses can be attached to a player so multiple keys act on its behalf. This is the foundation of **delegation** — running a focused worker agent that can mine but not spend, or a watcher that can read but not act. Granted breadth is the risk: a wide grant to an adversarial key is unrecoverable.

Conventions (TX_FLAGS, `--` rule, one-tx-at-a-time) are in [`conventions.md`](/skills/conventions.html). Every transaction here is Tier 1 or Tier 2 — default to interactive, and **prefer minimum-necessary bits**.

## When to use it

- Delegating a task to another key/agent (multi-agent play).
- Granting a guild-mate or service access to a reactor/provider/substation.
- Registering or rotating signing keys for one player.
- Locking down or auditing who can do what.

## Decisions

**Grant the minimum, not PermAll.** Compose exactly the bits a task needs (they OR together). `PermAll` (33554431) yields total control and there is no undo if the holder turns. Reserve it for keys you fully control.

**Object grant vs address grant vs guild-rank grant**:
- **On object** — give a specific player rights on one object (e.g. let an ally infuse your reactor).
- **On address** — attach rights to a signing key directly.
- **Guild rank** — give everyone at/above a rank a permission on an object (scales delegation across a guild; see [`structs-guild`](/skills/structs-guild/SKILL.html)).

**Address registration is an attack surface.** `address-register` attaches a new signing key using attacker-suppliable proof material — if you register a key you don't control, you've hired your attacker. Verify proof provenance; see [`awareness/agent-security`](https://structs.ai/awareness/agent-security).

**Your primary address cannot be narrowed.** Any `permission-set-on-address` / `permission-revoke-on-address` that would leave the player's primary address below `PermAll` is rejected (`primary_full_access_required`). Scope delegates on *secondary* addresses; the primary stays the full-authority recovery key.

**Vault spends ride on the signing key's token bits.** `PermTokenTransfer` / `PermTokenInfuse` / `PermTokenMigrate` / `PermTokenDefuse` on the key are what let it spend the player vault (and, with an object grant, a guild vault). A delegate without `PermTokenTransfer` cannot `vault-send`, buy ranks, open agreements, or mint.

## The 25-bit permission model

| Permission | Value | Description |
|------------|-------|-------------|
| PermPlay | 1 | Basic play access |
| PermAdmin | 2 | Manage permissions on the object (and set member ranks, on the signing key) |
| PermUpdate | 4 | Update object settings (also self-service UGC name/pfp) |
| PermDelete | 8 | Delete object |
| PermTokenTransfer | 16 | Transfer tokens; spend the vault (`vault-send`, agreements, rank purchase, mint collateral) |
| PermTokenInfuse | 32 | Infuse tokens into reactors/generators |
| PermTokenMigrate | 64 | Migrate stake between reactors (also needed for a guild join that migrates stake) |
| PermTokenDefuse | 128 | Defuse (withdraw) tokens |
| PermSourceAllocation | 256 | Create/update/delete allocations and providers from the object |
| PermGuildMembership | 512 | Manage guild membership (also required on the key for invite/request bypass joins and proxy-joining a registered address) |
| PermSubstationConnection | 1024 | Connect to substations |
| PermAllocationConnection | 2048 | Connect allocations to substations |
| PermGuildTokenBurn | 4096 | Burn & confiscate guild tokens |
| PermGuildTokenMint | 8192 | Mint guild tokens |
| PermGuildEndpointUpdate | 16384 | Update guild endpoint |
| PermGuildJoinConstraintsUpdate | 32768 | Update join infusion minimum / bypass settings |
| PermGuildSubstationUpdate | 65536 | Update guild entry substation |
| PermProviderWithdraw | 131072 | Withdraw provider balance |
| PermProviderOpen | 262144 | Open agreements on a provider |
| PermReactorGuildCreate | 524288 | Reserved reactor bit; `guild-create` no longer checks it |
| PermHashBuild | 1048576 | Submit build proof-of-work |
| PermHashMine | 2097152 | Submit mine proof-of-work |
| PermHashRefine | 4194304 | Submit refine proof-of-work |
| PermHashRaid | 8388608 | Submit raid proof-of-work |
| PermGuildUGCUpdate | 16777216 | Moderate name/pfp on guild-owned objects |
| PermAll | 33554431 | All permissions |

Composites: `PermAssetsAll` = 16+32+64+128 = **240**; `PermHashAll` = **15728640**; `PermGuildAll` = admin/update/delete + membership + the three guild-settings bits + mint/burn + ProviderOpen + UGC + **PermAssetsAll + PermSourceAllocation + PermAllocationConnection** (a guild-admin grant therefore also conveys spending of the guild vault and allocation control — grant it knowingly). Canonical page: [`knowledge/mechanics/permissions`](https://structs.ai/knowledge/mechanics/permissions).

## Delegation recipes (multi-agent play)

Compose the bits for a worker key, then grant them on the relevant object/address. Different keys transact in parallel (one-tx-at-a-time is per account), so delegates multiply your throughput.

- **Mining bot** — can run the production PoW but cannot move tokens. Bits: `PermPlay | PermHashMine | PermHashRefine` = `1 + 2097152 + 4194304` = **6291457**. Grant on the player whose extractor/refinery it operates. (Add `PermHashBuild` 1048576 if it also builds.)
- **Defense watcher** — read-only alerting; grant **nothing** on chain. It only needs query access (and GRASS, see [`structs-streaming`](/skills/structs-streaming/SKILL.html)). Keep it keyless so a compromise can't act.
- **Co-pilot agent** — broad but bounded operator: play + build/mine/refine + infuse for power, no token transfer/defuse. Bits: `PermPlay | PermHashBuild | PermHashMine | PermHashRefine | PermTokenInfuse` = `1 + 1048576 + 2097152 + 4194304 + 32` = **7340065**. Grant on the player; withhold `PermTokenTransfer`/`PermTokenDefuse`/`PermAll`. Note `PermTokenInfuse` alone lets the key spend **vault Alpha into reactors and generators** (generator fuel is irreversible) — cap the vault balance you leave reachable, or keep the bulk on a key the delegate cannot see.
- **Guild treasurer** — spend the guild vault without administering the guild: `permission-grant-on-object -- [guild-id] [player-id] 16` (`PermTokenTransfer`) enables `vault-send`/`player-send` from the guild vault and opening agreements on the guild's behalf (`--owner-id`); add `32` for guild-vault reactor infusions. Do **not** reach for `PermGuildAll` for this.
- **Energy seller** — let a guild-mate open agreements on your provider: grant `PermProviderOpen` (262144) on the provider (or by guild rank).

Verify every grant after applying it (`permission-by-object`), and revoke promptly when a delegate's job ends.

## Procedure

1. **Inspect** — `permission-by-object [object-id]`, `permission-by-player [player-id]`, `address-all-by-player [player-id]`. These are paginated (default 100, max 1000, `total` always 0) — walk `next_key` on busy objects.
2. **Grant / revoke / set on object** — `permission-grant-on-object -- [object-id] [player-id] [bits]` (additive; the target player must exist, and you need `PermAdmin` on the object plus the bits you are granting); `permission-revoke-on-object -- ...`; `permission-set-on-object -- ...` (replaces the set — confirm you aren't dropping a bit you need).
3. **Address-level** — `permission-grant-on-address|revoke-on-address|set-on-address -- [address] [bits]`. The primary address cannot be set below `PermAll`.
4. **Guild rank** — `permission-guild-rank-set -- [object-id] [guild-id] [permission] [rank]` / `permission-guild-rank-revoke -- [object-id] [guild-id] [permission]`. Rank-register `PermAdmin` grants **no** authority of its own — rank-setting still needs `PermAdmin` on the signing key. Kicked members keep their *direct* object grants; revoke those separately.
5. **Address management** — register a key: `address-register -- [player-id] [address] [proof-pubkey] [proof-signature] [permissions]` (Tier 2, verify proof). The new key signs the exact string `CHAIN<chain-id>|REGISTERADDRESSPLAYER<player-id>ADDRESS<address>NONCE<n>`, where `n` is the per-address nonce served as `proofNonce` by `structsd query structs address [address]` (0 for a never-registered address). A successful registration burns that nonce, so a captured proof cannot be replayed — including after an `address-revoke`, which does not reset it. Revoke: `address-revoke -- [address]` (don't orphan your own `--from`; revoke leaves Cosmos stake and drops game capacity on that address); change primary: `player-update-primary-address -- [new-address]` (**requires `PermAll` on the signing address** — a limited delegate cannot rotate primary). Strict address moves refuse while a redelegation is in flight. **Distinguish two patterns:** `address-register` (or a webapp activation code) adds another signing key to **one existing player** (shared identity, planet, inventory); deriving fresh addresses from one mnemonic at `m/44'/118'/0'/0/N` and running a separate guild signup for each creates **fully independent players** (separate identities) recoverable from a single seed — see [team-operations — Keys and accounts](https://structs.ai/playbooks/meta/team-operations).

## Commands reference

| Action | Command |
|--------|---------|
| Grant / revoke / set on object | `structsd tx structs permission-grant-on-object \| permission-revoke-on-object \| permission-set-on-object TX_FLAGS -- [object-id] [player-id] [bits]` |
| Grant / revoke / set on address | `structsd tx structs permission-grant-on-address \| ...-revoke-on-address \| ...-set-on-address TX_FLAGS -- [address] [bits]` |
| Guild rank set / revoke | `structsd tx structs permission-guild-rank-set \| permission-guild-rank-revoke TX_FLAGS -- [object-id] [guild-id] [permission] [rank]` |
| Address register / revoke | `structsd tx structs address-register \| address-revoke TX_FLAGS -- ...` |
| Update primary address | `structsd tx structs player-update-primary-address TX_FLAGS -- [new-address]` (signer must hold `PermAll`) |
| Query permission / address (incl. `proofNonce`) | `structsd query structs permission-by-object \| permission-by-player \| address \| address-all-by-player [id]` |

`TX_FLAGS` per [`conventions.md`](/skills/conventions.html). **Requires** [`structsd`](/skills/structsd-install/SKILL.html) on PATH and a signing key.

## Verification

- `permission-by-object [object-id]` — who holds what.
- `guild-rank-permission-by-object [object-id]` — rank-based grants.
- `address [address]` / `address-all-by-player [player-id]` — registered keys and their player link.

## Errors

- **Permission denied** — signer lacks the needed bit on the object; check `permission-by-object`. Primary rotation specifically needs `PermAll`, not merely `PermAdmin`. Rank changes need `PermAdmin` on the **key**, not via rank-register.
- **`primary_full_access_required`** — you tried to narrow the primary address; scope a secondary key instead.
- **Object not found on grant** — the target player ID does not exist; grants to nonexistent players are refused.
- **Address already registered** — revoke first or link to a different player.
- **Redelegation in flight** — strict address moves (`address-register`, primary rotation) refuse until the redelegation completes.
- **Invalid proof** — wrong chain-id, player, address, or **stale nonce** (re-read `proofNonce`; a used or revoked address keeps counting); see [`protocols/authentication`](https://structs.ai/protocols/authentication).
- **Locked yourself out** — revoking the address your `--from` resolves to breaks your next command; verify before revoking.

## See also

- [knowledge/mechanics/permissions](https://structs.ai/knowledge/mechanics/permissions) — full 25-bit reference + UGC hook
- [awareness/agent-security](https://structs.ai/awareness/agent-security) — address-register attack pattern, delegate hygiene
- [awareness/async-operations](https://structs.ai/awareness/async-operations) — multi-player orchestration
- [protocols/authentication](https://structs.ai/protocols/authentication) — auth for address registration
- [structs-guild](/skills/structs-guild/SKILL.html) — guild rank permissions; [structs-streaming](/skills/structs-streaming/SKILL.html) — keyless watcher agents
