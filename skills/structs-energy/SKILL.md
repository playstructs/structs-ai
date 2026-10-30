---
title: "Energy skill: capacity, load, infusion"
meta_description: Load above capacity means offline, and offline means you cannot act. Capacity management, substations, allocations, and reactor infusion.
name: structs-energy
description: "Power and capacity in Structs — getting more energy, fixing \"I'm offline\", substations and allocations, load budgeting, and reactor/generator infusion for your own capacity. Use when capacity is too low, a player or struct won't come online, you're load > capacity (offline), planning power for new builds, or wiring substations. For selling energy on the market, see structs-commerce."
level: core
domain: energy
redirect_from:
  - /skills/structs-power/SKILL
  - /skills/structs-power/SKILL.html
  - /.cursor/skills/structs-power/SKILL
  - /.cursor/skills/structs-power/SKILL.html
---

# Energy skill: capacity, load, infusion

Every online struct draws power continuously, and **load > capacity = offline = you cannot act**. Energy is therefore the substrate of everything: no power, no mining, no building, no defense. This skill is "I need power / I'm offline / how do I budget power" — raising your own capacity (infusion), distributing it (substations/allocations), and recovering from overload. *Earning* from energy (running providers, selling, the flywheel) lives in [`structs-commerce`](/skills/structs-commerce/SKILL.html).

Conventions (TX_FLAGS, `--` rule, charge bar, one-tx-at-a-time) are in [`conventions.md`](/skills/conventions.html). **Interface:** if Structs Desktop MCP is connected, use `structs_intel` for power/economy reads. Reactor infusion lifecycle controls are currently **Team Ops → Industry → Production Tauri/web-board handlers**, not a `structs_action` action or a new MCP tool; use the human board or the `structsd` fallback below. See [interface routing](/skills/conventions.html#choosing-your-interface-capability-aware).

> **Denomination footgun**: infusion amounts must carry the `ualpha` suffix — `60000000ualpha`, not `60000000`. Missing denom = failed tx. Generator infusions accept exactly **one** coin; a comma-separated list is rejected.

> **Spend-source footgun**: reactor and generator infusions are paid from your **player vault** by default, not from your signing key. Alpha on the key does not count unless you pass `--delegator-address [your-address]` (reactors only). See [conventions — vault](/skills/conventions.html#your-alpha-lives-in-your-vault).

## When to use it

- A struct won't go online, or you went offline (load exceeded capacity).
- You're about to build and need to confirm power headroom.
- You want more capacity (you have Alpha to infuse).
- You're setting up substations/allocations to distribute power.

## Decisions

### "I need more capacity" decision tree

```
Have Alpha Matter?
├── Yes → Infuse a reactor   → safest, immediate, reversible (cooldown), 1g ≈ 1 kW − commission   [default]
│         or Infuse a generator → 2-10 kW/g but IRREVERSIBLE and raidable (only with defense in place)
└── No  → Buy capacity via an agreement from a provider → ongoing cost; see structs-commerce
```

**Beginner default**: infuse your **guild's reactor**. Capacity rises automatically — no substation wiring needed for your own use. Pick the lowest commission you can.

> **Infusing a reactor powers *you*, not the guild substation.** Infusion adds ~96% (at 4% commission) to **your own** `capacity` and the commission to the reactor — it does **not** raise any substation's capacity or other members' `capacitySecondary`. To feed the shared guild pool, someone must route capacity in with an **allocation** (below). See [energy.md — infusion](https://structs.ai/knowledge/mechanics/energy#creating-capacity-infusion-splits-964).

### Spreading stake pays: the diversity bonus

Base reactor power is a flat **1:1** on fuel before commission. On top of that the chain pays an **owner diversity bonus** on your post-commission reactor power, based on how evenly your stake is spread across *eligible* (bonded, unjailed) reactors. Effective reactor count is `(Σ power)² / Σ power²`; the bonus is `50% × min(1, (effective − 1) / 9)`:

| Eligible reactors, equal split | Bonus |
|---|---|
| 1 | 0% |
| 2 | ≈ 5.56% |
| 3 | ≈ 11.11% |
| 5 | ≈ 22.22% |
| 10+ | 50% |

Unequal holdings earn less; dust spread across reactors earns almost nothing. Generators and received allocations do not count, and a guild's portfolio is separate from its members'. Read yours with `structsd query structs owner-reactor-diversity [owner-id]` — use the returned `usableBonus`/`storedCapacity`, not your own arithmetic, because the chain floors once in integer math.

> **Adding stake to a reactor you already dominate can *lower* your total power**, because it shrinks the effective count faster than the new base power grows. Preview the portfolio before signing a large infusion into your biggest reactor. A capacity drop triggers the ordinary brownout cascade. "Infuse more into the same reactor" is not always the fix for low power.

### Stake cap: a reactor can refuse you

Once ten validators are bonded the **reactor stake cap** activates (and stays active): any inflow — `reactor-infuse`, `staking delegate`, migration in, cancelling a defusion — that would leave the validator above **30%** of bonded stake is rejected with `reactor stake cap exceeded` (code 1613). Check before you send: `structsd query structs reactor-stake-share [reactor-id]` returns `capActive`, `capBps`, `externalDepositHeadroom` (room for new Alpha) and `bondedRedelegationHeadroom` (room for a migration from another bonded reactor). Empty headroom strings mean the cap is inactive, not that the reactor is full. Existing above-cap positions are not evicted; they just cannot grow.

**Reactor vs generator**: reactor is the safe default (reversible via a defusion cooldown, not raidable). Generators give far more kW per gram but the Alpha is **annihilated** (no defusion) and a raided generator takes the infused matter with it — only infuse generators you can defend (they're armoured with higher HP, but still a target). Decisions live in [`playbooks/situations/resource-rich`](https://structs.ai/playbooks/situations/resource-rich).

### "Am I about to go offline?"

Online requires load to fit the chain's usable capacity. Player passive draw is 25,000 mW; each online struct adds its `passiveDraw`. `scripts/power-budget.sh [player-id] --type [struct-type-id]` reports an exact stored margin and the proposed passive draw at one query height. It does not prove live reactor eligibility, supply validity or that activation will succeed. Confirm the actual action with native preflight and its committed result. If you're already offline, use the recovery procedure below.

## Power math

```
storedMargin = (capacity + capacitySecondary) - (load + structsLoad)
```

- `capacity` — your own generation (infusions); the only part you can allocate out.
- `capacitySecondary` — received from a substation you're connected to.
- `load` — power you've allocated to others.
- `structsLoad` — player passive (25,000 mW) + sum of `passiveDraw` of your online structs.

Units are milliwatts (1 W = 1,000 mW; 1 ualpha = 1 mW).

The chain checks usable primary capacity and the connected substation when deciding
whether the player is online. Stored values can lag bounded repairs. A positive
`storedMargin` is a diagnostic, not authorization to add load. The helper refuses
failed or incomplete reads; a failed substation query never means zero capacity.

### Worked load budget

Command Ship (50,000 mW) + Ore Extractor (500,000) + Ore Refinery (500,000) + player passive (25,000) = **1,075,000 mW** of `structsLoad`. To keep all online you need `capacity + capacitySecondary ≥ 1,075,000`. Infusing ~1,120,000 ualpha into a 4%-commission reactor nets ~1,075,000 mW to you — just enough; leave a margin.

## Procedure — raise your own capacity (reactor infusion)

1. Check capacity and vault Alpha: `structsd query structs player [id]` (`playerInventory.rocks` is the vault's spendable ualpha). If the Alpha is on your signing key instead, either move it (`structsd tx bank send [key] [vault-address] [amount]ualpha`) or plan to pass `--delegator-address`.
2. Pick a reactor and read its commission and **validator address**: `structsd query structs reactor [id]` (the `validator` field, `structsvaloper1...` — the command takes the validator address, not the reactor ID). Then `structsd query structs reactor-stake-share [id]` for cap headroom. A jailed or unbonded validator produces **zero** usable energy from infusions until it is bonded again; `reactor-restart` queues the resync afterwards.
3. Infuse (CLI prompts — review validator, commission, amount, and spend source):
   ```
   structsd tx structs reactor-infuse TX_FLAGS -- [validator-address] [amount]ualpha
   ```
   With no flags this stakes **from your player vault**. `--delegator-address [registered-address]` stakes from that signing key instead; `--owner-id [guild-id]` stakes from a guild vault you have `PermTokenInfuse` authority over. `reactor-infuse` is Tier 1 — commission is locked permanently for that infusion. Defusion takes the same arguments and selectors (`reactor-defuse -- [validator-address] [amount]ualpha`) and starts a cooldown before Alpha returns to the same account it came from; `reactor-cancel-defusion -- [validator-address] [amount]ualpha [creation-height]` re-stakes during that cooldown (and counts as an inflow against the cap).
4. Verify: re-query player; capacity increased. For a large position also check `owner-reactor-diversity` — the applied bonus may have moved.

In current Team Ops, the Infusions surface can preview and execute reactor infuse,
defuse, migration, cancel-defusion, and restart for the primary/registered virtual
players. It re-derives the holder signer, checks the infusion address, validator health,
and projected power headroom before signing. Generator infusions are listed but remain
read-only there because they are irreversible. These `mcp_infusion_*` names are internal
Tauri/web-board commands; `tools/list` still has 13 MCP tools and no
`structs_infusions`.

## Procedure — generator infusion (Tier 2, irreversible)

Only with defense in place. **Approval Block**: struct id is your generator (type 20/21/22, online); amount is annihilated on success (no defusion); the **vault** holds the amount (generator fuel is burned from the player vault, never from the signing key); generator's defense posture is sound (shield up, defenders/PDC, no inbound fleet); `--from` owns it.

```
structsd tx structs struct-generator-infuse TX_FLAGS -- [struct-id] [amount]ualpha
```

Exactly one coin, `ualpha` only. Rates: Field Generator 2 kW/g, Continental Power Plant 5 kW/g, World Engine 10 kW/g. Generator fuel survives the generator going offline (`generatorDisabled: true` on its infusion: fuel and ratio stay, power reads 0) and is credited again when it is reactivated; destruction never refunds it. Generator funding works even while you are browned out — it is one of the few actions that does — which makes it a recovery lever if you accept the irreversibility.

## Procedure — distribute power (substations & allocations)

For pooling power across structs/players (e.g. a guild powering members). Cascading deletes can knock players offline mid-operation — these are Tier 2.

1. Create an allocation from your source: `structsd tx structs allocation-create --allocation-type static|dynamic|automated TX_FLAGS -- [source-id] [power]` (`--controller [owner-id]` optional; a player `1-N` or guild `0-N`). Automated allocations auto-grow with capacity — **one per source**. An allocation sourced from a guild or a guild-owned substation is guild-controlled by default; naming another controller needs admin authority on the source.
2. Create a substation: `structsd tx structs substation-create TX_FLAGS -- [owner-id] [allocation-id]`. The allocation must not already feed a substation — disconnect it first (`substation-allocation-disconnect`) or use a fresh one.
3. Connect/disconnect sources: `substation-allocation-connect|disconnect -- [substation-id] [allocation-id]`.
4. Connect/disconnect players: `substation-player-connect|disconnect -- [substation-id] [player-id]`.
5. Migrate players: `substation-player-migrate -- [substation-id] [player-id,player-id2,...]` (destination substation + player CSV; there is **no** source-substation argument).

> **Connecting/migrating another player needs `PermSubstationConnection` (1024) on the player too — not just the substation.** Connect and migrate run the same two checks (`1024` on the destination substation AND on each target player) and both call `MigrateSubstation`. A player object is owned by itself, so **owning the substation is not enough to move other members**: either the member **self-connects** (they own themselves; gate the substation with `permission-guild-rank-set [sub] [guild] 1024 [rank]`), or they grant you `permission-grant-on-object [player] [you] 1024` first. Repointing the guild entry substation (`guild-update-entry-substation-id`) only reroutes **new** join-proxy members — existing members are not auto-migrated. See [energy.md](https://structs.ai/knowledge/mechanics/energy).

**Three things that bite when pooling** (full detail in [energy.md](https://structs.ai/knowledge/mechanics/energy)):

- **A substation loses 10% and dilutes the rest evenly.** Only `floor(capacity × 9/10)` of a substation's incoming power is usable; each connected player gets `connectionCapacity = (usable − load) / connectionCount`, recomputed on every connect/disconnect and on every outgoing allocation change. Every new player connection shrinks everyone's share — plan the pool against `connectionCount` and the 90%, not the raw feed.
- **Anyone can contribute to any substation.** `substation-allocation-connect` checks permission only on **your own allocation**, not the destination substation's owner — no guild-owner veto, no membership needed. Contributing is open, but a contributed allocation raises *your own* connection by only `0.9/connectionCount`, so it's community behavior, not self-growth. A substation that is being deleted (`deletion_pending: true`) refuses new connections of any kind.
- **Over-committing triggers a brownout.** If an object's `load` exceeds its usable `capacity` (e.g. a substation loses a feed), the grid **destroys that object's outgoing allocations in creation order** until load fits — cascading downstream and knocking dependents offline. The cascade is bounded to 256 allocation teardowns per block and queues the remainder (FIFO), so a large collapse plays out over several blocks rather than one. Leave headroom.
- **Stored headroom is not admission.** A new allocation, a dynamic increase, or an agreement is validated against the *complete* incoming supply chain (reactor → allocations → substations → you) under a 2,048-object limit. A cycle, an overloaded ancestor, a jailed reactor at the root, or a chain too deep to prove returns `unsupported_supply` even when `capacity − load` reads positive. Simplify the topology; waiting for the cascade does not clear a complexity refusal.

## Offline recovery (emergency)

1. **Free power now** — `struct-deactivate` non-essential structs until `load + structsLoad ≤ capacity + capacitySecondary`. Keep the **Command Ship online** if at all possible (offline CMD ship makes your planet raidable).
2. **Raise capacity** — infuse a reactor (fastest) or open an agreement.
3. **Reactivate** in priority order: Command Ship → defense → production.
4. Note: a player on a substation pool can show `capacity=0` while structs run fine — `structsLoad > 0` is the real "functioning" signal, not `capacity > 0`.

## Commands reference

| Action | Command |
|--------|---------|
| Reactor infuse (from vault; `--delegator-address [addr]` for a registered key, `--owner-id [guild-id]` for a guild vault) | `structsd tx structs reactor-infuse TX_FLAGS -- [validator-addr] [amount]ualpha` |
| Reactor restart | `structsd tx structs reactor-restart TX_FLAGS -- [reactor-address]` |
| Reactor defuse (same selectors) | `structsd tx structs reactor-defuse TX_FLAGS -- [validator-addr] [amount]ualpha` |
| Reactor cancel defusion (same selectors) | `structsd tx structs reactor-cancel-defusion TX_FLAGS -- [validator-addr] [amount]ualpha [creation-height]` |
| Reactor migrate (same selectors) | `structsd tx structs reactor-begin-migration TX_FLAGS -- [src-val] [dest-val] [amount]ualpha` |
| Reactor cap headroom | `structsd query structs reactor-stake-share [reactor-id]` |
| Diversity bonus | `structsd query structs owner-reactor-diversity [owner-id]` |
| Vault address | `structsd query structs vault [owner-id]` |
| Generator infuse (Tier 2, from vault, one coin) | `structsd tx structs struct-generator-infuse TX_FLAGS -- [struct-id] [amount]ualpha` |
| Allocation create / update / delete | `structsd tx structs allocation-create --allocation-type [t] TX_FLAGS -- [source-id] [power]` (and `allocation-update`/`allocation-delete -- [allocation-id] ...`) |
| Substation create / delete | `structsd tx structs substation-create \| substation-delete TX_FLAGS -- ...` |
| Substation allocation connect/disconnect | `structsd tx structs substation-allocation-connect \| disconnect TX_FLAGS -- [sub-id] [alloc-id]` |
| Substation player connect/disconnect/migrate | `structsd tx structs substation-player-connect \| disconnect \| migrate TX_FLAGS -- ...` |
| Query player power | `structsd query structs player [id]` |
| Query reactor | `structsd query structs reactor [id]` |
| Query substation / allocations | `structsd query structs substation [id]` / `allocation-all-by-source [id]` |

`TX_FLAGS` per [`conventions.md`](/skills/conventions.html); power ops cascade, so default to interactive even on routine ones. **Requires** [`structsd`](/skills/structsd-install/SKILL.html) on PATH and a signing key.

## Verification

- `structsd query structs player [id]` — `capacity`/`capacitySecondary`/`load`/`structsLoad`, online status.
- `structsd query structs substation [id]` — connected allocations/players.

## Errors

- **Going offline** — load > capacity; deactivate structs, then infuse/buy capacity.
- **"insufficient balance" / affordability on infuse** — the **vault** lacks ualpha (the key's balance is irrelevant). Fund the vault, pass `--delegator-address` (reactors only), refine ore, or buy via agreement.
- **`reactor stake cap exceeded` (1613)** — validator at/over 30% of bonded stake with the cap active; pick another reactor (`reactor-stake-share`).
- **`vault_owner_mismatch`** — an explicit `--delegator-address` does not match the vault selected by `--owner-id`; drop one of the two.
- **Capacity fell after infusing** — diversity bonus shrank because the position concentrated; check `owner-reactor-diversity` and spread across reactors.
- **"generator infuse failed" / invalid amount** — struct isn't a generator (20/21/22), is destroyed, or the amount names more than one coin.
- **`unsupported_supply`** — the allocation's supply chain cannot be proven (cycle, overloaded or jailed ancestor, >2,048 objects). Not a headroom problem; simplify the graph.
- **Allocation exceeds source** — source capacity too small; allocate less or add capacity.
- **Automated allocation limit** — one automated per source; use static/dynamic for more.
- **`substation-create` rejects the allocation** — it already feeds a substation; disconnect it first.
- **`deletion_pending`** — the destination substation is closing; connect elsewhere.

## See also

- [knowledge/mechanics/energy](https://structs.ai/knowledge/mechanics/energy) — full energy system: units, infusion split, substation dilution, allocations, brownout
- [knowledge/mechanics/power](https://structs.ai/knowledge/mechanics/power) — capacity/load/online quick formula card
- [knowledge/mechanics/resources](https://structs.ai/knowledge/mechanics/resources) — Alpha → energy conversion rates
- [playbooks/situations/resource-rich](https://structs.ai/playbooks/situations/resource-rich) — infusion strategy
- [structs-commerce](/skills/structs-commerce/SKILL.html) — selling energy, buying via agreement, the flywheel; [structs-building](/skills/structs-building/SKILL.html) — power pre-check
