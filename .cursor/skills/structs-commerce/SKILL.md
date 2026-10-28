---
title: "Commerce skill: energy, banks, transfers"
meta_description: "How Alpha Matter compounds into economic power: providers, energy agreements, reactor staking, the guild Central Bank, and token transfers."
name: structs-commerce
description: Earning and trading in Structs — selling energy via providers, buying capacity via agreements, allocations, reactor staking economics, the guild Central Bank (mint/redeem/convert), and token transfers. Use when you want to monetize surplus energy, shop for an energy agreement, set provider pricing, stake Alpha into a reactor for capacity, mint/redeem/convert guild tokens, or send tokens. For just keeping your own structs powered, see structs-energy.
level: advanced
domain: economy
redirect_from:
  - /skills/structs-economy/SKILL
  - /skills/structs-economy/SKILL.html
  - /.cursor/skills/structs-economy/SKILL
  - /.cursor/skills/structs-economy/SKILL.html
---

# Commerce skill: energy, banks, transfers

Commerce is how Alpha Matter compounds into economic power. The core loop: refine Alpha → infuse a reactor (capacity) → route it through an **allocation** to a **substation** → sell it through a **provider** → buyers pay in tokens via **agreements** → reinvest. Layered on top are guild Central Bank tokens (mint/redeem) and direct transfers. Where [`structs-energy`](/skills/structs-energy/SKILL.html) is "power my own structs", this skill is "make Alpha and energy *earn*."

Conventions (TX_FLAGS, `--` rule, charge bar, one-tx-at-a-time, `ualpha` denom suffix, the vault) are in [`conventions.md`](/skills/conventions.html). Every command here is Tier 1 or Tier 2 — default to interactive.

> **Every spend in this skill is paid from a vault, not from your signing key.** Agreement collateral, reactor stake, Central Bank mint/redeem/convert and rank purchases all debit the player vault (or a guild vault you control). Fund the vault first (`structsd tx bank send [key] [vault-address] [amount]ualpha`; address from `structsd query structs vault [owner-id]`). Earnings likewise land in vaults: refined Alpha, redeemed Alpha, minted guild tokens. The one exception is `provider-withdraw-balance`, which pays to the bank address you name.

## When to use it

- You have surplus capacity and want revenue (run a provider).
- You need capacity but have no Alpha (buy via agreement).
- You're setting provider pricing / access policy.
- You want to stake Alpha into a reactor for capacity, mint/redeem guild tokens, or transfer tokens.

## Decisions

**Sell or hold?** Surplus capacity earns nothing idle. If you have headroom beyond your own structs, sell it. Price in **guild tokens** (`1uguild.0-N`) to create demand for your guild's currency, or in `ualpha` for direct value.

**Buyer-side: shop before you commit.** Opening an agreement **debits the entire cost in full, immediately, at open** — `rate × capacity × duration`, moved from the paying vault into the collateral pool (`x/structs/keeper/msg_server_agreement_open.go`). It is not metered per block. Closing early can incur a penalty. Compare providers on `rateAmount`, `capacityMaximum`, `durationMaximum`, and penalties before opening. Pick a duration whose expiry height is not already full: at most 256 agreements may expire at one height, and a full bucket rejects the open with `expiration_height_full` — nudge the duration by a block or two and retry.

**The `rate_denom` trap.** The cost is charged in the **provider's** `rate_denom`, not in alpha. A provider that prices in a guild token (`uguild.0-N`) requires your vault to hold that token — a buyer holding only `ualpha` is **rejected at broadcast** (insufficient-funds error keyed `agreement_open`; read `rawLog` for the exact denom). Check the provider's `rateDenom` and acquire that denom (mint guild tokens / trade) *before* opening.

**Reactor staking economics — you are buying *capacity*, not a yield.** Infusing a reactor stakes your Alpha behind a validator at a locked commission and, in return, credits **energy capacity** to you (`1 − commission` of the infused amount; the commission share becomes the reactor's own capacity), plus a **diversity bonus** of up to 50% for stake spread evenly across ten or more reactors. There is **no delegator reward stream, no APR, no passive income** — the payoff is the capacity itself. Income is *indirect*: you turn that capacity into revenue only by selling it as energy through a provider. Lower commission = more capacity to you; spreading across reactors = more bonus; staking also strengthens the guild's reactor. It's reversible only via a defusion cooldown — don't stake Alpha you'll need short-term. A jailed validator zeros the infusion ratio until unjail / `reactor-restart`, and a reactor already holding 30% of bonded stake refuses new stake once the cap is active (`reactor-stake-share`). See [`structs-energy`](/skills/structs-energy/SKILL.html) for the diversity table and cap, and [energy — reactor infusion](https://structs.ai/knowledge/mechanics/energy) for the 96/4 split.

**The energy flywheel (advanced default):** mine → refine → infuse guild reactor → automated allocation grows substation capacity → sell via provider for guild tokens → redeem/reinvest. Each turn compounds. Decisions live in [`knowledge/economy/valuation`](https://structs.ai/knowledge/economy/valuation), [`trading`](https://structs.ai/knowledge/economy/trading), and [`playbooks/phases/late-game`](https://structs.ai/playbooks/phases/late-game).

## Allocation types (the routing primitive)

| Type | Updatable | Deletable | Auto-grows | Limit | Use |
|------|-----------|-----------|------------|-------|-----|
| static | no | no (while connected) | no | unlimited | fixed routing |
| dynamic | yes | yes | no | unlimited | flexible/managed routing |
| automated | yes | no | yes (with source capacity) | **one per source** | energy sales (recommended) |
| provider-agreement | system | system | system | system-created | auto-made when agreements open — never create manually |

Only the **controller** can delete/transfer an allocation (`--controller [owner-id]` on create, defaults to the creating player; `allocation-transfer -- [allocation-id] [new-controller-owner-id]` to hand it to another player `1-N` or a guild `0-N`). Allocations sourced from a guild or a guild-owned substation default to guild control.

## Procedure — sell energy (provider pipeline)

1. **Have capacity** — infuse a reactor first ([`structs-energy`](/skills/structs-energy/SKILL.html)).
2. **Automated allocation** (auto-grows as you infuse more):
   ```
   structsd tx structs allocation-create --allocation-type automated TX_FLAGS -- [your-player-id] [power]
   ```
3. **Substation** (distribution node):
   ```
   structsd tx structs substation-create TX_FLAGS -- [your-player-id] [allocation-id]
   ```
4. **Provider** (your storefront):
   ```
   structsd tx structs provider-create TX_FLAGS -- [substation-id] [rate] [access-policy] [provider-penalty] [consumer-penalty] [cap-min] [cap-max] [dur-min] [dur-max]
   ```
   Pricing/policy heuristics: `rate` `1uguild.0-N` (drives guild-token demand) or a `ualpha` rate; `access-policy` `open-market` (max reach), `guild-market` (members at/above a rank — grant via `permission-guild-rank-set [provider-id] [guild-id] 262144 [rank]`), or `closed-market` (explicit PermProviderOpen only); penalties `0` initially to lower friction; cap/dur ranges wide (e.g. `1000`–`1000000000` / `100`–`1000000`). Add `--owner-id [guild-id]` to create the provider **as the guild** (needs `PermSourceAllocation` on the guild); otherwise you own it.
5. **Monitor & withdraw**: `structsd query structs provider [id]`; `provider-withdraw-balance TX_FLAGS -- [provider-id] [destination-address]`. Earnings drip from the provider's collateral (escrow) to its earnings address as blocks pass.

> **Deleting the substation under a provider**: `substation-delete` is bounded work — the substation flips to `deletion_pending`, refuses new connections, and the grid unwinds it over several blocks. Inbound agreements are **detached, not closed**: the consumer keeps paying until they `agreement-close`. Warn consumers before you delete.

## Procedure — buy energy (agreement)

1. Find a provider: `structsd query structs provider-all` (or your guild's). Compare rate/capacity/duration/penalties.
2. Open (paid upfront from your vault; auto-creates a provider-agreement allocation):
   ```
   structsd tx structs agreement-open TX_FLAGS -- [provider-id] [duration-in-blocks] [capacity]
   ```
   `--owner-id [guild-id]` opens it on the guild's behalf, paying from the guild vault (needs `PermTokenTransfer` on the guild).
3. Connect the allocation to your substation:
   ```
   structsd tx structs substation-allocation-connect TX_FLAGS -- [substation-id] [allocation-id]
   ```
4. Adjust as needed: `agreement-capacity-increase|decrease`, `agreement-duration-increase`; `agreement-close [agreement-id]` (may penalize).

## Procedure — reactor staking

```
structsd tx structs reactor-infuse TX_FLAGS -- [validator-address] [amount]ualpha
```
Validator address is `structsvaloper1...` (from `structsd query structs reactor [id]`, `validator` field) — not the reactor ID. The stake comes from your **player vault**; `--delegator-address [registered-address]` stakes from a signing key instead, `--owner-id [guild-id]` stakes from a guild vault (needs `PermTokenInfuse` on the guild). Commission locks at infusion. Check `reactor-stake-share [reactor-id]` for cap headroom first. Unstake: `reactor-defuse -- [validator-address] [amount]ualpha` (cooldown; Alpha returns to the account it came from); `reactor-cancel-defusion -- [validator-address] [amount]ualpha [creation-height]` to re-stake during cooldown; `reactor-begin-migration -- [src-val] [dest-val] [amount]ualpha` to move stake (verify the destination — no undo; the destination's cap applies). After an unjail, `reactor-restart [reactor-address]` resyncs energy output from live staking if hooks did not.

## Procedure — guild Central Bank & transfers

- **Mint** (guild-privileged; `guild-bank-mint -- [alpha-amount] [token-amount]`, `--guild-id` to name a guild other than your own): Alpha collateral moves **from the guild vault** to the bank pool and the new tokens land **in the guild vault**. Distribute them with `vault-send` or `player-send` from the guild vault.
- **Redeem** (`guild-bank-redeem -- [amount]uguild.[id] [min-amount-alpha]`, `floor` payout): tokens are burned from your player vault, Alpha arrives in your player vault.
- **Convert** ualpha→token or token→token (`guild-bank-convert`/`guild-bank-convert-token`, `min-amount-token` slippage): debits and credits your player vault. See [`structs-guild`](/skills/structs-guild/SKILL.html) and [`knowledge/economy/guild-banking`](https://structs.ai/knowledge/economy/guild-banking). `uguild.*` cannot go to IBC.
- **Transfer tokens, vault to vault**: `vault-send TX_FLAGS -- [owner-id] [recipient-owner-id] [amount]` — the game-native payment rail (player `1-N` or guild `0-N` on either side; needs `PermTokenTransfer` on the sending owner).
- **Transfer tokens to or from an address**: `player-send TX_FLAGS -- [from-address] [to-address] [amount]`. `from-address` may be your own registered key *or* a vault address you control — that is how you fund a key with refined Alpha. A typo in the destination is permanent — to a brand-new address this is Tier 2. Guild denoms additionally require an eligible recipient.
- **Buy a guild rank**: when a guild has enabled rank purchase, `guild-rank-purchase TX_FLAGS -- [guild-id] [target-rank] [max-price] [expected-rank]` pays **in that guild's token** (`uguild.<id>`, base units) from your player vault to the guild vault (`quoted_price_exceeded` if the live price has moved above `max-price`). Hold the token first — redeem/convert into it. Non-members use `guild-membership-join-by-rank-purchase`. Pricing lives in [`structs-guild`](/skills/structs-guild/SKILL.html).

## Commands reference

| Action | Command |
|--------|---------|
| Allocation create / update / delete / transfer | `structsd tx structs allocation-create --allocation-type [t] TX_FLAGS -- [source-id] [power]` (+ `allocation-update`/`allocation-delete -- [allocation-id] ...`; `allocation-transfer -- [allocation-id] [new-controller-owner-id]`) |
| Substation create | `structsd tx structs substation-create TX_FLAGS -- [owner-id] [allocation-id]` |
| Provider create / delete / withdraw | `structsd tx structs provider-create [--owner-id guild] \| provider-delete \| provider-withdraw-balance TX_FLAGS -- ...` |
| Agreement open / close / adjust | `structsd tx structs agreement-open [--owner-id guild] \| agreement-close \| agreement-capacity-increase \| ... TX_FLAGS -- ...` |
| Reactor infuse / defuse / migrate / restart | `structsd tx structs reactor-infuse \| reactor-defuse TX_FLAGS -- [validator-addr] [amount]ualpha`; `reactor-begin-migration -- [src-val] [dest-val] [amount]ualpha`; `reactor-restart -- [reactor-addr]` (`--delegator-address` / `--owner-id` select the funding account) |
| Bank mint / redeem | `structsd tx structs guild-bank-mint TX_FLAGS -- [alpha-amount] [token-amount]` (add `--guild-id` to name another guild) / `guild-bank-redeem TX_FLAGS -- [amount]uguild.[id] [min-amount-alpha]` |
| Bank convert / convert-token | `structsd tx structs guild-bank-convert TX_FLAGS -- [guild-id] [alpha-amount] [min-amount-token]` / `guild-bank-convert-token TX_FLAGS -- [amount]uguild.[src] [target-guild-id] [min-amount-token]` |
| Vault → vault transfer | `structsd tx structs vault-send TX_FLAGS -- [owner-id] [recipient-owner-id] [amount]` |
| Address transfer (key or vault as `from`) | `structsd tx structs player-send TX_FLAGS -- [from-address] [to-address] [amount]` |
| Rank purchase | `structsd tx structs guild-rank-purchase TX_FLAGS -- [guild-id] [target-rank] [max-price] [expected-rank]` |
| Query provider / agreement / reactor / vault | `structsd query structs provider \| agreement \| reactor \| vault [id]` |
| Query reactor cap / diversity | `structsd query structs reactor-stake-share [reactor-id]` / `owner-reactor-diversity [owner-id]` |

`TX_FLAGS` per [`conventions.md`](/skills/conventions.html). **Requires** [`structsd`](/skills/structsd-install/SKILL.html) on PATH and a signing key.

## Verification

- Provider: `structsd query structs provider [id]` — capacity, rate, active agreements, balance.
- Agreement: `structsd query structs agreement [id]` — status (OPEN→ACTIVE→EXPIRED), capacity, duration.
- Reactor: `structsd query structs reactor [id]` — infused amount, defusion cooldown.
- Player: `structsd query structs player [id]` — `playerInventory.rocks` is vault-spendable Alpha; `structsd query bank balances [vault-address]` for every denom.

## Errors

- **Insufficient balance / affordability** — the **vault** is short in the required denom; the signing key's balance is irrelevant. Refine ore, fund the vault, or acquire the token.
- **`expiration_height_full`** — 256 agreements already expire at that height; change the duration by a block.
- **`reactor stake cap exceeded` (1613)** — reactor at the 30% cap; pick another (`reactor-stake-share`).
- **`quoted_price_exceeded`** — the rank price moved above your `max-price`; re-quote and retry.
- **Provider capacity exceeded** — reduce agreement capacity or add provider capacity.
- **Defusion cooldown** — `reactor-cancel-defusion` to re-stake, or wait it out.
- **recipient_not_eligible** — `uguild.*` cannot go to IBC escrow or an unregistered address.
- **`vault_owner_mismatch`** — `--delegator-address` and `--owner-id` point at different owners; use one.
- **Automated allocation limit** — one per source; use dynamic for additional routing.
- **Generator infuse / staking irreversibility** — staking has a cooldown; generator infusion has none (see [`structs-energy`](/skills/structs-energy/SKILL.html)).

## See also

- [knowledge/economy/energy-market](https://structs.ai/knowledge/economy/energy-market) — provider/agreement flow, pricing
- [knowledge/economy/guild-banking](https://structs.ai/knowledge/economy/guild-banking) — Central Bank tokens, collateral
- [api/webapp/analytics](https://structs.ai/api/webapp/analytics) — live `GET /api/guild-bank`, inventory, leaderboards
- [knowledge/economy/valuation](https://structs.ai/knowledge/economy/valuation) / [trading](https://structs.ai/knowledge/economy/trading) — what things are worth
- [playbooks/phases/late-game](https://structs.ai/playbooks/phases/late-game) — market control
- [structs-energy](/skills/structs-energy/SKILL.html) — capacity for your own use; [structs-permissions](/skills/structs-permissions/SKILL.html) — provider access grants
