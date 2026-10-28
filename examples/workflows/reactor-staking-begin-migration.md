---
description: A worked workflow for migrating reactor stake between validators without unbonding — the diversity motive, the destination stake cap, and verification.
---

# Reactor Staking - Begin Migration Workflow

**Version**: 2.0.0
**Category**: economic
**Description**: Redelegate Alpha from one reactor's validator to another's. The stake stays bonded the whole time, so capacity is preserved; this is the tool for spreading stake to earn the diversity bonus.

Mechanics: [energy.md — diversity bonus](../../knowledge/mechanics/energy.md#the-owner-diversity-bonus), [stake cap](../../knowledge/mechanics/energy.md#the-reactor-stake-cap) · Procedure: [structs-energy skill](/skills/structs-energy/SKILL.html)

---

## What happens

`reactor-begin-migration` wraps Cosmos `BeginRedelegate`: `amount` moves from the source validator to the destination validator. The source infusion shrinks, a destination infusion grows (or is created), and the owner's capacity is recomputed with the new commission and diversity figures. Because the stake never unbonds, the vault is untouched and capacity does not dip — but Cosmos imposes the usual redelegation constraints (no re-redelegating the same tokens until the redelegation matures; entry limits per pair).

## Workflow

### Step 1: Preflight

**Source stake** — `structsd query structs infusion {src-reactorId} {vault-address}` → `fuel`, or `structsd query staking delegation {vault-address} {src-validator}`.

**Destination headroom** — `structsd query structs reactor-stake-share {dst-reactorId}`: migrations from bonded stake are measured against `bondedRedelegationHeadroom` (not `externalDepositHeadroom`). Zero headroom → code 1613.

**Destination health** — `structsd query structs reactor {dst-reactorId}`: `validator`, `commission`; the validator must be bonded and not jailed.

**Diversity payoff** — `structsd query structs owner-reactor-diversity {playerId}` before and after. Moving stake from a reactor you dominate to one you hold little of raises `usableBonus`.

### Step 2: Submit

```
structsd tx structs reactor-begin-migration --from {key} --gas auto --gas-adjustment 1.5 -- {src-validator-address} {dst-validator-address} {amount}ualpha
```

Same `--owner-id` / `--delegator-address` selection as infuse; the permission is `PermTokenMigrate` (64) on the funding owner.

Broadcast body:

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgReactorBeginMigration",
        "creator": "structs1...",
        "validator_src_address": "structsvaloper1aaa...",
        "validator_dst_address": "structsvaloper1bbb...",
        "amount": { "denom": "ualpha", "amount": "2500000" }
      }
    ]
  }
}
```

### Step 3: Confirm and verify

Poll `GET /cosmos/tx/v1beta1/txs/{txhash}` for `code: 0`; events include two `structs.structs.EventInfusion` rows (source and destination), `EventOwnerReactorDiversity`, `EventGrid`, and the Cosmos `redelegate` event.

| Check | Query | Expect |
|-------|-------|--------|
| Source reduced | `structsd query structs infusion {src-reactorId} {vault-address}` | `fuel` − `amount` |
| Destination grew | `structsd query structs infusion {dst-reactorId} {vault-address}` | `fuel` + `amount` |
| Capacity | `structsd query structs player {playerId}` → `gridAttributes.capacity` | Changed only by the commission difference and the diversity delta |
| Redelegation record | `structsd query staking redelegation {vault-address} {src-validator} {dst-validator}` | Entry with `completion_time` |
| Vault | `playerInventory.rocks` | Unchanged |

---

## Error Handling

| Error | Code / key | Cause | Recovery |
|-------|------------|-------|----------|
| `reactor stake cap exceeded` | 1613 | Destination lacks `bondedRedelegationHeadroom` | Choose another destination |
| `redelegation to this validator already in progress; first redelegation to this validator must complete before next redelegation` | staking | Cosmos redelegation chaining rule | Wait for the earlier redelegation to mature |
| `too many redelegation entries` | staking | Per-pair entry limit | Wait or consolidate |
| destination jailed / not bonded | staking | Reactor offline | Pick a bonded reactor |
| player offline | 1152 | Load > capacity | Shed load first |
| permission denied | structured | Signer lacks `PermTokenMigrate` on the funding owner | Grant the bit or use the primary key |

---

## Example

10 Alpha all in reactor `3-1` (no diversity bonus). Move 5 Alpha to `3-2`:

```
structsd tx structs reactor-begin-migration --from ferro --gas auto --gas-adjustment 1.5 -- structsvaloper1aaa... structsvaloper1bbb... 5000000ualpha
```

Result: two even positions → ≈5.6% diversity bonus on the whole 10 Alpha, with no capacity dip and nothing idle in the vault. Moving on to a third, fourth and fifth reactor steps the bonus to ≈11%, ≈16.7% and ≈22%.
