# Transactions, Gas, and Fees

**Purpose**: Explain how the v0.16.0 ante handler routes Structs gameplay transactions and Cosmos staking transactions through a free-gas path while everything else continues to pay fees in `ualpha`.

---

## TL;DR

- Pure-Structs transactions (every gameplay message in the `structs` module except `MsgUpdateParams`) are **free**. No fee in `ualpha` is required, and they execute against a dedicated 20 M free-gas meter that does **not** consume the block's normal gas budget.
- Pure-staking transactions (six `x/staking` messages) are also **free**, against a 40 M free-staking meter, but capped to **one free staking tx per address per block**.
- Mixing Structs messages with non-Structs messages (or with `MsgUpdateParams`, governance, bank, distribution, etc.) in a single transaction breaks the free path and the whole tx pays normal fees.
- All transactions still need `--gas auto`. Gas is metered and rejected on overflow; "free" only means the gas is not paid for, not that it's unlimited.
- Network-wide message and tx-size caps still apply, and the address rate limit still applies on `CheckTx`.

---

## What "free" actually means

Cosmos SDK ante decorators run before the message handler executes. Structs's custom ante chain (`app/ante/ante.go`) inserts a `GasRouterDecorator` early in the chain that checks every incoming transaction:

1. If `IsFreeTransaction(msgs)` -- every message URL starts with `/structs.structs.Msg` AND none of them is `MsgUpdateParams` -- the gas meter is **replaced** with a free meter capped at `FreeGasCap` (default `20_000_000`).
2. Else if `IsFreeStakingTransaction(msgs)` -- every message URL is one of the six entries in `FreeStakingMessages` -- the gas meter is replaced with a free meter capped at `FreeStakingGasCap` (default `40_000_000`), and a per-address per-block throttle gates how many of these can land.
3. Otherwise the standard SDK gas meter is used and fees flow through `ConditionalMempoolFeeDecorator` + `ConditionalFeeDecorator`, which behave like the upstream SDK fee decorators.

Both `ConditionalMempoolFeeDecorator` and `ConditionalFeeDecorator` short-circuit when the context flag `IsFreeTx(ctx)` is set, so free transactions are never charged a fee even if the user accidentally attaches one.

`--gas auto` (or `--gas-adjustment 1.5`) is still required because the SDK simulator must produce a gas estimate; if the estimate exceeds the meter cap (free or paid) the tx is rejected with `out of gas`. Free does not mean infinite.

---

## Free Structs gameplay messages

Anything in `KnownStructsMessages` (defined in `app/ante/maps.go`) qualifies for the free-gas path, except `MsgUpdateParams` (governance). The list covers, as of v0.16.0:

- All `MsgAddress*`, `MsgAgreement*`, `MsgAllocation*`, `MsgPlayer*`, `MsgProvider*`, `MsgReactor*`, `MsgStruct*`, `MsgSubstation*`, `MsgPermission*` messages.
- `MsgFleetMove`, `MsgPlanetExplore`, `MsgPlanetRaidComplete`, `MsgPlanetUpdateName`.
- All guild messages: `MsgGuildCreate`, `MsgGuildBank*`, `MsgGuildMembership*`, `MsgGuildUpdate*` (including the seven new UGC messages: `MsgGuildUpdateName/Pfp`, `MsgPlayerUpdateName/Pfp`, `MsgPlanetUpdateName`, `MsgSubstationUpdateName/Pfp`).

Excluded from the free path:

- `MsgUpdateParams` (`/structs.structs.MsgUpdateParams`) -- this is a governance message and must pay normal fees even though it's in the Structs module.
- Any message outside the Structs module URL prefix.

If you want to see the canonical, complete list, read `KnownStructsMessages` in `.references/structsd/app/ante/maps.go`.

---

## Free staking messages

The chain treats staking as a first-class gameplay action because reactor staking is what creates and powers a player. To remove that economic friction the following six messages are free, against a separate 40 M meter:

- `cosmos.staking.v1beta1.MsgDelegate`
- `cosmos.staking.v1beta1.MsgUndelegate`
- `cosmos.staking.v1beta1.MsgBeginRedelegate`
- `cosmos.staking.v1beta1.MsgCancelUnbondingDelegation`
- `cosmos.staking.v1beta1.MsgCreateValidator`
- `cosmos.staking.v1beta1.MsgEditValidator`

Constraints:

- A transaction that mixes any staking message with any other message type (Structs, bank, etc.) is **not** treated as a free staking tx and pays normal fees.
- The `StakingThrottleDecorator` enforces **one** free staking transaction per signer address per block. A second free staking tx in the same block from the same address is rejected.
- The signer is derived from the staking-message-specific field (`DelegatorAddress` for delegations, `ValidatorAddress` for validator messages).

Use this for routine `MsgDelegate` / `MsgUndelegate` activity. If you need to send several staking ops in one block, batch them into a single tx (as long as it stays purely staking) -- the throttle is on free txs, not on the messages inside the tx.

---

## Paid transactions

Anything not classified as free runs through the standard fee path:

- Mixed transactions (Structs + non-Structs).
- Pure non-Structs, non-staking transactions: `bank`, `distribution`, `gov`, `slashing`, `evidence`, IBC, etc.
- `MsgUpdateParams` in any combination.

These pay fees in `ualpha` like any other Cosmos SDK chain. Set `--fees` or `--gas-prices` accordingly.

---

## Other ante checks that still apply

Even when a transaction is free, the rest of the ante chain still runs:

- **Tx size cap** (`TxSizeDecorator`) -- rejects oversize transactions before any state read.
- **Message count cap** (`MsgCountDecorator`) -- caps the number of messages per tx.
- **Signature verification** (standard SDK decorators) -- signatures are required even on free txs.
- **Per-address CheckTx throttle** (`CheckTxThrottleDecorator`) -- rate limits how many txs a single address can cram into the mempool per block.
- **`StructsDecorator`** -- looks up the player for the signing address, applies the static permission check from `PermissionMap` for messages that use it, enforces the per-player message cap, and short-circuits same-block `lastAction` collisions for `ChargeMessages`.
- **`ThrottleDecorator`** -- per-object throttles for proof-of-work messages, fleet move, planet explore, address register.
- **Charge messages** (`StructActivate`, `StructAttack`, `StructBuildInitiate`, `StructDefenseClear/Set`, `StructMove`, `StructStealthActivate/Deactivate`) -- still require positive charge, so you cannot use the free path to side-step the once-per-block-per-object rules.

The `DynamicPermissionMessages` set (e.g. all UGC messages, address/permission management, guild membership voting flows) skips the ante-level permission check and lets the handler enforce the right permission, since the bits depend on runtime fields. This has nothing to do with fees -- those messages are still free as long as the tx stays purely Structs.

---

## Practical guidance

- Treat `--gas auto --gas-adjustment 1.5` as mandatory on every `structsd tx structs` command. The free meter is tight enough that hand-tuning a low gas value is a footgun.
- Do not mix module operations in one tx if you want the free path. For example, `MsgPlayerSend` (Structs) and `cosmos.bank.v1beta1.MsgSend` (bank) in the same tx will pay fees. If you need to do both, send two transactions.
- Free does not relax sequence numbers. The chain still tracks `account_sequence`. One in-flight tx per address at a time still applies. Wait for the previous block (~6 s) before broadcasting the next.
- Submitting the same staking message twice in one block from one address will fail at `StakingThrottleDecorator`. Wait a block.
- The free-gas budgets (20 M / 40 M) are governance parameters in the chain (`FreeGasCap`, `FreeStakingGasCap` on `HandlerOptions`). Treat them as soft-coded numbers; check `structsd query params` if you suspect they've moved.

---

## See Also

- [permissions.md](permissions.md) -- Permission flag reference and check flow
- [ugc-moderation.md](ugc-moderation.md) -- UGC name/pfp transactions and validation rules
- `protocols/transactions.md` -- Transaction broadcast/verify flow
- `troubleshooting/transaction-issues.md` -- Common rejections and fixes
