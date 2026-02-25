---
name: structs-economy
description: Manages economic operations in Structs. Covers reactor staking, energy providers, agreements, allocations, generator infusion, and token transfers. Use when staking Alpha Matter in reactors, creating or managing energy providers, negotiating agreements, allocating energy, infusing generators, transferring tokens, or managing economic infrastructure.
---

# Structs Economy

## Procedure

1. **Assess position** — Query player, reactor, provider, agreement state via `structsd query structs player/reactor/provider/agreement [id]`.
2. **Reactor staking** — Stake Alpha Matter: `structsd tx structs reactor-infuse [player-address] [reactor-address] [amount] TX_FLAGS`. This **automatically increases the player's capacity** — no allocation setup needed. The reactor's commission rate determines the split: player receives `power * (1 - commission)`, reactor keeps the rest. Unstake: `reactor-defuse [reactor-id]` (cooldown applies). Cancel cooldown: `reactor-cancel-defusion [reactor-id]`. Migrate: `reactor-begin-migration [source-reactor-id] [dest-reactor-id]`.
3. **Generator infusion** — `structsd tx structs struct-generator-infuse [struct-id] [amount] TX_FLAGS`. **IRREVERSIBLE** — Alpha cannot be recovered. Higher conversion rates than reactors (2-10x) but generator is vulnerable to raids.
4. **Provider lifecycle** — Create: `provider-create [substation-id] [rate] [access-policy] [provider-penalty] [consumer-penalty] [cap-min] [cap-max] [dur-min] [dur-max] TX_FLAGS`. Update capacity/duration/access via `provider-update-capacity-maximum`, `provider-update-duration-minimum`, etc. Delete: `provider-delete [provider-id]`. Withdraw earnings: `provider-withdraw-balance [provider-id]`. Grant/revoke guild access: `provider-guild-grant`, `provider-guild-revoke`.
5. **Agreements** — Open: `agreement-open [provider-id] [duration] [capacity] TX_FLAGS`. Close: `agreement-close [agreement-id]`. Adjust: `agreement-capacity-increase/decrease`, `agreement-duration-increase`.
6. **Allocations** — Create: `allocation-create [source-id] [power] --allocation-type static|dynamic|automated|provider-agreement --controller [id] TX_FLAGS`. Update: `allocation-update [allocation-id] [new-power]`. Delete: `allocation-delete [allocation-id]`. Transfer: `allocation-transfer [allocation-id] [new-owner]`.
7. **Token transfer** — `player-send [from-address] [to-address] [amount] TX_FLAGS`.

## Commands Reference

| Action | Command |
|--------|---------|
| Reactor infuse | `structsd tx structs reactor-infuse [player-addr] [reactor-addr] [amount]` |
| Reactor defuse | `structsd tx structs reactor-defuse [reactor-id]` |
| Reactor migrate | `structsd tx structs reactor-begin-migration [src-id] [dest-id]` |
| Reactor cancel defusion | `structsd tx structs reactor-cancel-defusion [reactor-id]` |
| Generator infuse | `structsd tx structs struct-generator-infuse [struct-id] [amount]` |
| Provider create | `structsd tx structs provider-create [substation-id] [rate] [access] [prov-penalty] [cons-penalty] [cap-min] [cap-max] [dur-min] [dur-max]` |
| Provider delete | `structsd tx structs provider-delete [provider-id]` |
| Provider withdraw | `structsd tx structs provider-withdraw-balance [provider-id]` |
| Agreement open | `structsd tx structs agreement-open [provider-id] [duration] [capacity]` |
| Agreement close | `structsd tx structs agreement-close [agreement-id]` |
| Allocation create | `structsd tx structs allocation-create [source-id] [power] --allocation-type [type]` |
| Allocation update | `structsd tx structs allocation-update [allocation-id] [power]` |
| Allocation delete | `structsd tx structs allocation-delete [allocation-id]` |
| Player send | `structsd tx structs player-send [from] [to] [amount]` |

**TX_FLAGS**: `--from [key-name] --gas auto --gas-adjustment 1.5 -y`

## Verification

- **Reactor**: `structsd query structs reactor [id]` — check `infusedAmount`, `defusionCooldown`.
- **Provider**: `structsd query structs provider [id]` — verify capacity, rate, active agreements.
- **Agreement**: `structsd query structs agreement [id]` — check status, capacity, duration.
- **Allocation**: `structsd query structs allocation [id]` — confirm power, source, destination.
- **Player balance**: `structsd query structs player [id]` — verify Alpha Matter after transfers.

## Error Handling

- **Insufficient balance**: Check player Alpha Matter before infuse/send. Refine ore first.
- **Provider capacity exceeded**: Query provider `capacityMaximum`; reduce agreement capacity or create new provider.
- **Defusion cooldown**: Use `reactor-cancel-defusion` to re-stake during cooldown, or wait.
- **Generator infuse failed**: Cannot undo. Verify struct is a generator type and amount is correct before submitting.

## See Also

- `.cursor/skills/structs-energy/SKILL.md` — "I need more energy" decision tree and workflows
- `knowledge/economy/energy-market.md` — Provider/agreement flow, pricing
- `knowledge/economy/guild-banking.md` — Central Bank tokens
- `knowledge/mechanics/resources.md` — Alpha Matter, conversion rates
- `knowledge/mechanics/power.md` — Capacity, load, online status
