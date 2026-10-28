---
description: A worked workflow for infusing a reactor from your vault — preflight (vault balance, stake cap, diversity), the transaction, and on-chain verification.
---

# Reactor Staking - Infuse Workflow

**Version**: 2.0.0
**Category**: economic
**Description**: Stake Alpha from a vault into a reactor's validator to gain energy capacity. Covers preflight, the message, verification, and errors.

Mechanics: [energy.md — Infusion](../../knowledge/mechanics/energy.md#creating-capacity-infusion-splits-964) · Procedure: [structs-energy skill](/skills/structs-energy/SKILL.html) · Field notes: [schemas/actions.md](../../schemas/actions.md#msgreactorinfuse)

---

## What happens

`reactor-infuse` delegates `amount` of `ualpha` from a **vault** to the reactor's **validator**. The funding owner's `capacity` rises by the staked amount minus the reactor's commission (default 4%), plus the owner's [diversity bonus](../../knowledge/mechanics/energy.md#the-owner-diversity-bonus). The Alpha is not spent; it is locked until `reactor-defuse` unbonds it.

The money never comes from the signing key. By default it comes from the signer's own player vault; `--owner-id` picks another player or guild vault the signer holds `PermTokenInfuse` on; `--delegator-address` alone names a registered address that stakes from its own balance.

## Workflow

### Step 1: Preflight

**Player online** — `GET /structs/player/{playerId}` (or `structsd query structs player {playerId}`): `(load + structsLoad) ≤ (capacity + capacitySecondary)`.

**Vault balance** — the same player record: `playerInventory.rocks` is the spendable `ualpha` in the vault and must cover `amount`. To see the account itself:

```
structsd query structs vault {playerId}          # → address
structsd query bank balances {vault-address}
```

**Reactor and validator** — `structsd query structs reactor {reactorId}`: note `validator` (a `structsvaloper1…` address — this is the positional argument, not `3-N`) and `commission`.

**Stake cap headroom** — `structsd query structs reactor-stake-share {reactorId}`: if `capActive` is `true`, `externalDepositHeadroom` is the most you can add. Zero headroom means the transaction will fail with code 1613.

**Diversity** — `structsd query structs owner-reactor-diversity {playerId}`: `usableBonus` is what you earn now. Adding to a reactor you already dominate can lower it; spreading across a new reactor raises it.

### Step 2: Choose the amount

| Consideration | Guidance |
|---------------|----------|
| Unit | `ualpha` (1,000,000 ualpha = 1 Alpha) — always write the denom: `5000000ualpha` |
| Capacity gained | `amount × (1 − commission) + diversity bonus` in energy units |
| Reversibility | Recoverable via `reactor-defuse`, after the unbonding period |
| Cap | ≤ `externalDepositHeadroom` when the cap is active |

### Step 3: Submit

CLI (interactive form; see [SAFETY.md](../../SAFETY.md) for when `-y` is allowed — this is a Tier 1 action):

```
structsd tx structs reactor-infuse --from {key} --gas auto --gas-adjustment 1.5 -- {validator-address} {amount}ualpha
```

Fund from a guild vault instead (needs `PermTokenInfuse` on the guild):

```
structsd tx structs reactor-infuse --from {key} --gas auto --gas-adjustment 1.5 --owner-id={guild-id} -- {validator-address} {amount}ualpha
```

Equivalent broadcast body (`POST /cosmos/tx/v1beta1/txs`):

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgReactorInfuse",
        "creator": "structs1...",
        "validator_address": "structsvaloper1...",
        "amount": { "denom": "ualpha", "amount": "5000000" },
        "ownerId": ""
      }
    ]
  }
}
```

### Step 4: Confirm inclusion

Poll `GET /cosmos/tx/v1beta1/txs/{txhash}` every ~2 s (≤ 30 attempts). `code: 0` means the message ran; the `events` array carries `structs.structs.EventAlphaInfuse` (with `vaultAddress`), `structs.structs.EventInfusion`, `structs.structs.EventOwnerReactorDiversity` and the Cosmos `delegate` event.

### Step 5: Verify state

| Check | Query | Expect |
|-------|-------|--------|
| Capacity rose | `structsd query structs player {playerId}` → `gridAttributes.capacity` | Previous + staked × (1 − commission) + bonus delta |
| Vault debited | `playerInventory.rocks` | Previous − `amount` |
| Delegation exists | `structsd query staking delegation {vault-address} {validator-address}` | `balance.amount` ≥ `amount` |
| Infusion record | `structsd query structs infusion {reactorId} {vault-address}` | `fuel` = staked amount, `power`, `commission` |
| Diversity | `structsd query structs owner-reactor-diversity {playerId}` | `usableBonus` updated |

Broadcast is not success — read the state.

---

## Error Handling

| Error | Code / key | Cause | Recovery |
|-------|------------|-------|----------|
| `address is not registered as a player` | ante 2010 | Fresh key, no player yet | Create the player first (`structsd tx staking delegate` or guild signup) |
| `insufficient funds` naming the vault | bank | Vault short of `amount` | Refine, or `player-send` ualpha to the vault address |
| `reactor stake cap exceeded` | 1613 | Reactor at ≥ 30% of bonded stake | Pick a reactor with headroom |
| `vault_owner_mismatch` | structured | `--owner-id` and `--delegator-address` disagree | Drop one flag |
| `validator does not exist` / jailed | staking | Wrong `structsvaloper` or reactor offline | Re-read `reactor.validator`; use `reactor-restart` after unjail |
| player offline | 1152 | Load > capacity | Shed load first ([offline](../../playbooks/situations/offline.md)) |
| permission denied | structured | Signer lacks `PermTokenInfuse` on the funding owner | Grant the bit or sign from a key that has it |

---

## Permissions

| Funding source | Required on |
|----------------|-------------|
| Own vault (default) | `PermTokenInfuse` (32) on your player — the primary key has `PermAll` |
| Guild vault (`--owner-id 0-N`) | `PermTokenInfuse` on the guild (direct grant or rank register) |
| Registered address (`--delegator-address`) | `PermTokenInfuse` on that address's owner |

---

## Examples

- **First capacity** — new player, 5 Alpha in the vault: `reactor-infuse … -- {validator} 5000000ualpha` → capacity +4,800,000 (4% commission, no diversity bonus with one reactor).
- **Second reactor** — same 5 Alpha split 2.5 / 2.5 across two reactors → base +4,800,000 plus ≈5.6% diversity bonus on the total.
- **Guild treasury stake** — treasurer with `PermTokenInfuse` on guild `0-3` stakes the guild vault: `--owner-id 0-3`; capacity accrues to the guild's grid, not the signer's.
