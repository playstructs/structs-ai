---
description: A worked workflow for cancelling an in-flight reactor defusion — finding the unbonding entry's creation height, re-bonding the stake, and verifying capacity returns.
---

# Reactor Staking - Cancel Defusion Workflow

**Version**: 2.0.0
**Category**: economic
**Description**: Reverse a pending `reactor-defuse` by re-bonding some or all of an unbonding entry before it matures.

Mechanics: [energy.md](../../knowledge/mechanics/energy.md#creating-capacity-infusion-splits-964) · Procedure: [structs-energy skill](/skills/structs-energy/SKILL.html) · Field notes: [schemas/actions.md](../../schemas/actions.md#msgreactorcanceldefusion)

---

## What happens

`reactor-cancel-defusion` wraps Cosmos `CancelUnbondingDelegation`: it takes `amount` out of the unbonding entry created at `creation height` and re-delegates it to the same validator. Capacity returns immediately. It only works while the entry is still pending — once matured, the Alpha is simply in your vault and you would `reactor-infuse` again instead.

## Workflow

### Step 1: Find the entry

```
structsd query staking unbonding-delegation {vault-address} {validator-address}
```

Read `entries[]`: each has `creation_height`, `completion_time`, and `balance`. Pick the entry to reverse; `amount` must be ≤ its `balance`. (`vault-address` is `structsd query structs vault {ownerId}` → `address`; the validator is `structsd query structs reactor {reactorId}` → `validator`.)

### Step 2: Submit

```
structsd tx structs reactor-cancel-defusion --from {key} --gas auto --gas-adjustment 1.5 -- {validator-address} {amount}ualpha {creation-height}
```

Same `--owner-id` / `--delegator-address` selection as infuse; the permission is `PermTokenInfuse` on the funding owner (you are re-bonding).

Broadcast body:

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgReactorCancelDefusion",
        "creator": "structs1...",
        "validator_address": "structsvaloper1...",
        "amount": { "denom": "ualpha", "amount": "4000000" },
        "creation_height": "1284410"
      }
    ]
  }
}
```

### Step 3: Confirm and verify

Poll `GET /cosmos/tx/v1beta1/txs/{txhash}` for `code: 0`; the Cosmos `cancel_unbonding_delegation` event rides along with `structs.structs.EventInfusion` and `EventGrid`.

| Check | Query | Expect |
|-------|-------|--------|
| Capacity restored | `structsd query structs player {playerId}` → `gridAttributes.capacity` | Back up by `amount × (1 − commission)` (+ bonus delta) |
| Entry shrunk or gone | `structsd query staking unbonding-delegation …` | `balance` reduced by `amount`, or entry removed |
| Delegation restored | `structsd query staking delegation {vault-address} {validator-address}` | `balance.amount` up by `amount` |
| Vault unchanged | `playerInventory.rocks` | Unchanged — the Alpha never left bonded state |

---

## Error Handling

| Error | Cause | Recovery |
|-------|-------|----------|
| `unbonding delegation entry is not found at block height` | Wrong `creation-height` | Re-read `entries[].creation_height` |
| `amount is greater than the unbonding delegation entry balance` | `amount` > entry balance | Lower the amount |
| entry already matured | Completion time passed | Nothing to cancel; `reactor-infuse` from the vault instead |
| player offline | Load > capacity | Shed load first |
| `vault_owner_mismatch` | `--owner-id` and `--delegator-address` disagree | Drop one flag |

---

## Example

Defused 4,000,000ualpha at height 1284410 by mistake; cancel the full entry:

```
structsd tx structs reactor-cancel-defusion --from ferro --gas auto --gas-adjustment 1.5 -- structsvaloper1abc... 4000000ualpha 1284410
```

Capacity is back the same block; `unbonding-delegation` shows no entries.
