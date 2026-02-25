---
name: structs-energy
description: Manages energy capacity in Structs. Covers increasing capacity (reactor infusion, generator infusion, buying agreements), selling surplus energy (creating providers), and diagnosing power problems. Use when capacity is too low, going offline, need more power for new structs, want to sell energy, or asking "how do I get more energy?"
---

# Structs Energy Management

## Decision Tree

```
Need more capacity?
├── Have Alpha Matter?
│   ├── Infuse into a reactor (safest, immediate, 1g ≈ 1kW minus commission)
│   │   → See "Reactor Infusion" below
│   └── Infuse into a generator (higher ratio, IRREVERSIBLE, vulnerable to raids)
│       → See "Generator Infusion" below
└── No Alpha Matter?
    └── Buy energy from a provider via agreement
        → See "Buy Energy" below

Have surplus energy?
└── Sell it by creating a provider
    → See "Sell Energy" below
```

---

## Reactor Infusion (most common path)

Infusing Alpha Matter (ualpha) into a reactor immediately increases the player's capacity. This is the safest and most common way to get more energy.

### How It Works

When you infuse ualpha into a reactor, the system generates power equal to the amount infused. This power is split between you and the reactor based on the reactor's **commission rate**:

- **Player receives**: `power * (1 - commission)`
- **Reactor receives**: `power * commission`

The player's capacity increases automatically — no allocation or substation setup needed.

### Example

Infusing 3,000,000 ualpha into a reactor with 4% commission:

```json
{
  "destinationType": "reactor",
  "destinationId": "3-1",
  "fuel": "3000000",
  "power": "3000000",
  "commission": "0.040000000000000000",
  "playerId": "1-33"
}
```

- `fuel`: 3,000,000 ualpha infused
- `power`: 3,000,000 mW generated (1 ualpha = 1 mW = 0.001 W)
- Reactor keeps 4%: 120,000 mW (120 W)
- Player receives 96%: 2,880,000 mW (2,880 W) added to capacity

### Procedure

1. Check current capacity: `structsd query structs player [id]`
2. Choose a reactor (usually your guild's): `structsd query structs reactor [id]` — note the `commission` field
3. Infuse:

```
structsd tx structs reactor-infuse [your-address] [reactor-address] [amount-in-ualpha] --from [key-name] --gas auto --gas-adjustment 1.5 -y
```

4. Verify: re-query player, confirm capacity increased

### Choosing a Reactor

- Your guild's reactor is the default choice — it strengthens the guild and you benefit from guild infrastructure
- Lower commission = more capacity for you
- Check commission before infusing: `structsd query structs reactor [id]`
- You can infuse into any reactor, not just your guild's

### Undoing Infusion

- `structsd tx structs reactor-defuse [reactor-id]` — starts a cooldown period before ualpha is returned
- `structsd tx structs reactor-cancel-defusion [reactor-id]` — cancel defusion and re-stake
- `structsd tx structs reactor-begin-migration [source-reactor-id] [dest-reactor-id]` — move stake to a different reactor

---

## Generator Infusion

Generators convert Alpha Matter to energy at higher ratios than reactors, but the infusion is **irreversible** and the generator is vulnerable to raids.

### Conversion Rates

| Generator | Type ID | Rate | Risk |
|-----------|---------|------|------|
| Field Generator | 20 | 1g = 2 kW | High — vulnerable to raids, irreversible |
| Continental Power Plant | 21 | 1g = 5 kW | High — vulnerable to raids, irreversible |
| World Engine | 22 | 1g = 10 kW | High — vulnerable to raids, irreversible |

### Procedure

1. Identify your generator struct: `structsd query structs struct [id]` — must be type 20, 21, or 22
2. Infuse:

```
structsd tx structs struct-generator-infuse [struct-id] [amount-in-ualpha] --from [key-name] --gas auto --gas-adjustment 1.5 -y
```

3. Verify: query player for capacity increase

### When to Use Generators

- You need maximum energy efficiency per gram of Alpha Matter
- You have defense in place (shields, PDC, defenders) to protect the generator
- You accept the risk that if the generator is destroyed, the infused Alpha is lost forever

**Do not infuse generators without adequate defense.**

---

## Buy Energy (Agreement Path)

If you have no Alpha Matter to infuse, you can buy energy from another player who is running a provider.

### Procedure

1. **Find a provider**: Query available providers:

```
structsd query structs provider-all
```

Or check your guild's providers. Look for one with acceptable `rateAmount`, `capacityMaximum`, and `durationMaximum`.

2. **Open an agreement**:

```
structsd tx structs agreement-open [provider-id] [duration-in-blocks] [capacity] --from [key-name] --gas auto --gas-adjustment 1.5 -y
```

The agreement automatically creates an allocation.

3. **Connect the allocation to a substation**:

```
structsd tx structs substation-allocation-connect [substation-id] [allocation-id] --from [key-name] --gas auto --gas-adjustment 1.5 -y
```

Connect to your guild's substation to benefit the guild, or create your own substation for independent energy management.

4. **Verify**: Query player to confirm capacity increased.

### Agreement Management

- Increase capacity: `agreement-capacity-increase [agreement-id] [additional-capacity]`
- Decrease capacity: `agreement-capacity-decrease [agreement-id] [reduce-by]`
- Extend duration: `agreement-duration-increase [agreement-id] [additional-blocks]`
- Close: `agreement-close [agreement-id]` — may incur cancellation penalty

---

## Sell Energy (Become a Provider)

If you have surplus capacity (more power than you need), you can sell it to other players.

### Procedure

1. **Ensure surplus**: Query player — `availablePower = (capacity + capacitySecondary) - (load + structsLoad)`. You need meaningful surplus.

2. **Create a provider** on your substation:

```
structsd tx structs provider-create [substation-id] [rate] [access-policy] [provider-penalty] [consumer-penalty] [cap-min] [cap-max] [dur-min] [dur-max] --from [key-name] --gas auto --gas-adjustment 1.5 -y
```

| Parameter | Purpose |
|-----------|---------|
| `substation-id` | Your substation that has the surplus capacity |
| `rate` | Price per unit capacity (ualpha) |
| `access-policy` | Who can buy (open, guild-only, etc.) |
| `provider-penalty` | Penalty you pay if you cancel |
| `consumer-penalty` | Penalty buyer pays if they cancel |
| `cap-min` / `cap-max` | Minimum and maximum capacity per agreement |
| `dur-min` / `dur-max` | Minimum and maximum duration per agreement |

3. **Others open agreements** against your provider — energy flows automatically.

4. **Withdraw earnings**: `structsd tx structs provider-withdraw-balance [provider-id]`

### Provider Management

- Grant guild access: `provider-guild-grant [provider-id] [guild-id]`
- Revoke guild access: `provider-guild-revoke [provider-id] [guild-id]`
- Update terms: `provider-update-capacity-maximum`, `provider-update-duration-minimum`, etc.
- Delete provider: `provider-delete [provider-id]` (close agreements first)

---

## Quick Reference

| Situation | Action |
|-----------|--------|
| Low capacity, have Alpha | Infuse into guild reactor |
| Need maximum kW per gram | Infuse into generator (irreversible) |
| No Alpha, need capacity | Open agreement with a provider |
| Surplus capacity | Create provider to sell energy |
| Going offline (load > capacity) | Deactivate structs immediately, then increase capacity |
| Check commission rate | `structsd query structs reactor [id]` |
| Check your capacity | `structsd query structs player [id]` |

## Commands Reference

| Action | Command |
|--------|---------|
| Reactor infuse | `structsd tx structs reactor-infuse [your-addr] [reactor-addr] [amount-ualpha]` |
| Reactor defuse | `structsd tx structs reactor-defuse [reactor-id]` |
| Reactor migrate | `structsd tx structs reactor-begin-migration [src-reactor] [dest-reactor]` |
| Generator infuse | `structsd tx structs struct-generator-infuse [struct-id] [amount-ualpha]` |
| Open agreement | `structsd tx structs agreement-open [provider-id] [duration] [capacity]` |
| Close agreement | `structsd tx structs agreement-close [agreement-id]` |
| Create provider | `structsd tx structs provider-create [substation-id] [rate] [access] [prov-pen] [cons-pen] [cap-min] [cap-max] [dur-min] [dur-max]` |
| Delete provider | `structsd tx structs provider-delete [provider-id]` |
| Withdraw earnings | `structsd tx structs provider-withdraw-balance [provider-id]` |
| Connect allocation | `structsd tx structs substation-allocation-connect [substation-id] [allocation-id]` |
| Query player power | `structsd query structs player [id]` |
| Query reactor | `structsd query structs reactor [id]` |
| Query providers | `structsd query structs provider-all` |

Common tx flags: `--from [key-name] --gas auto --gas-adjustment 1.5 -y`

## Error Handling

- **Going offline** — Load exceeds capacity. Immediately deactivate non-essential structs (`struct-deactivate`), then increase capacity via reactor infusion or agreement.
- **"insufficient balance"** — Not enough ualpha. Mine and refine ore first, or buy energy via agreement instead.
- **"generator infuse failed"** — Verify the struct is a generator type (20, 21, or 22) and is online.
- **Commission too high** — Check other reactors. You can infuse into any reactor, not just your guild's.
- **No providers available** — Ask guild members to create providers, or infuse your own reactor.

## See Also

- `.cursor/skills/structs-economy/SKILL.md` — Full economic operations (all allocation types, token transfers)
- `.cursor/skills/structs-power/SKILL.md` — Substations, player connections, power monitoring
- `knowledge/mechanics/power.md` — Capacity formulas, load calculations, online status
- `knowledge/economy/energy-market.md` — Provider/agreement mechanics, pricing
- `knowledge/mechanics/resources.md` — Alpha Matter conversion rates
