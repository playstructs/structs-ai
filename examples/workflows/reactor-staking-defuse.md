---
description: A worked workflow for defusing a reactor — unbonding stake back to the funding vault, what happens to capacity immediately, and how to verify the unbonding entry.
---

# Reactor Staking - Defuse Workflow

**Version**: 2.0.0
**Category**: economic
**Description**: Begin unbonding Alpha from a reactor's validator back to the vault that funded it. Capacity drops now; the Alpha arrives after the unbonding period.

Mechanics: [energy.md](../../knowledge/mechanics/energy.md#creating-capacity-infusion-splits-964) · Procedure: [structs-energy skill](/skills/structs-energy/SKILL.html) · Safety tier: **Tier 2** in [SAFETY.md](../../SAFETY.md) — the matter is neither in the reactor nor in your vault during the wait.

---

## What happens

`reactor-defuse` undelegates `amount` from the reactor's validator. The infusion's `fuel` and the owner's `capacity` fall **immediately**; the owner's diversity bonus is recomputed. The `ualpha` sits in a Cosmos unbonding entry until the chain's unbonding period elapses, then lands in the vault. The entry can be reversed with [`reactor-cancel-defusion`](reactor-staking-cancel-defusion.md) while it is pending.

## Workflow

### Step 1: Preflight

**Load headroom** — `structsd query structs player {playerId}`: after the defuse, `capacity` falls by roughly `amount × (1 − commission)` plus any lost diversity bonus. If `(load + structsLoad)` would then exceed `(capacity + capacitySecondary)` you go **offline** and cannot act. Deactivate structs first, or defuse less.

**Current stake** — `structsd query structs infusion {reactorId} {vault-address}` → `fuel`; or `structsd query staking delegation {vault-address} {validator-address}` → `balance.amount`. You cannot defuse more than this.

**Validator address** — `structsd query structs reactor {reactorId}` → `validator`.

### Step 2: Submit

```
structsd tx structs reactor-defuse --from {key} --gas auto --gas-adjustment 1.5 -- {validator-address} {amount}ualpha
```

Same `--owner-id` / `--delegator-address` selection as infuse; the permission is `PermTokenDefuse` (128) on the funding owner.

Broadcast body:

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgReactorDefuse",
        "creator": "structs1...",
        "validator_address": "structsvaloper1...",
        "amount": { "denom": "ualpha", "amount": "5000000" }
      }
    ]
  }
}
```

### Step 3: Confirm inclusion

Poll `GET /cosmos/tx/v1beta1/txs/{txhash}`. On `code: 0` the events include `structs.structs.EventInfusion` (reduced fuel, pending unbonding amount), `structs.structs.EventOwnerReactorDiversity`, `structs.structs.EventGrid` (capacity) and the Cosmos `unbond` event, whose `completion_time` tells you when the Alpha returns.

### Step 4: Verify

| Check | Query | Expect |
|-------|-------|--------|
| Capacity fell | `structsd query structs player {playerId}` → `gridAttributes.capacity` | Reduced; confirm still ≥ load |
| Still online | same record | `(load + structsLoad) ≤ (capacity + capacitySecondary)` |
| Unbonding entry | `structsd query staking unbonding-delegation {vault-address} {validator-address}` | `entries[].balance` = `amount`, `creation_height`, `completion_time` |
| Vault unchanged (yet) | `playerInventory.rocks` | Same as before — the Alpha is in flight |

Record `creation_height` in `memory/` — you need it to cancel.

### Step 5: After the unbonding period

`playerInventory.rocks` rises by `amount`. Nothing to submit; the SDK matures the entry.

---

## Error Handling

| Error | Cause | Recovery |
|-------|-------|----------|
| `insufficient delegation` / amount too large | `amount` exceeds the delegation | Re-read the delegation balance |
| `too many unbonding delegation entries` | Cosmos per-pair entry limit reached | Wait for an entry to mature or cancel one |
| player offline | Load > capacity | Shed load; defuse does **not** bypass the online check |
| permission denied | Signer lacks `PermTokenDefuse` on the funding owner | Grant the bit or use the primary key |
| `vault_owner_mismatch` | `--owner-id` and `--delegator-address` disagree | Drop one flag |

---

## Examples

- **Partial exit** — 10 Alpha staked, defuse 4,000,000ualpha: capacity −3,840,000 immediately; 4 Alpha back in the vault after the unbonding period.
- **Rebalancing for diversity** — rather than defuse-and-reinfuse (which idles the Alpha for the whole unbonding period), use [`reactor-begin-migration`](reactor-staking-begin-migration.md): the stake moves without unbonding.
