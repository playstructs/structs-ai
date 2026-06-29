# Team Operations

**Topic**: Running multiple players (accounts) as one coordinated force
**Principle**: Most per-player limits are not limits across players. Two accounts are not twice the work — they are twice the charge, twice the build slots, and a power-and-fire multiplier you cannot buy with a single account.

---

## Why run more than one player

Many of the game's hardest ceilings are **per-player**, and the chain rewards splitting work across accounts:

- **Charge is per-player.** A single player has one shared charge bar and can only act about once per charge cycle. Five players have five bars — five actions in the same window. This is the only way to "alpha-strike": you cannot bank charge on one account, but you *can* fire from many. See [building.md — Charge Accumulation](../../knowledge/mechanics/building.md#charge-accumulation).
- **Build limits are per-player.** Most planet structs and the Command Ship cap at 1 *per player*. A team fields one Ore Extractor, one Refinery, one PDC, one Jamming Satellite **each** — multiplying production and defense on a shared front.
- **Sequencing is per-account.** One account can only land one transaction per ~6-second block (sequence numbers). Different accounts transact **in parallel** with no contention. See [conventions](../../.cursor/skills/conventions.md).
- **Proof-of-work is per-object.** Independent accounts grind their own builds/mines/refines/raids simultaneously — true parallel expeditions.

The cost is coordination and key hygiene. This playbook is how to get the multiplier without losing control (or your keys).

---

## Setting up a team

### Keys and accounts

Each player needs its own signing key. Derive them deterministically so you can recover the whole team from one seed:

- Use HD derivation (`structsd keys add worker-2 --recover` / account-index paths) so every account traces back to a single mnemonic you back up **once**.
- Name keys by role, not by guesswork (`core`, `power`, `striker-1`, `striker-2`). Future-you reads logs faster.
- Record which key owns which player in [TOOLS.md](../../TOOLS.md). An untracked key is a lost player.

### Onboarding the team (proxy signup)

Bring each account onto the chain via the guild proxy flow (`MsgGuildMembershipJoinProxy`): sign `GUILD{id}ADDRESS{addr}NONCE0`, POST to the guild, poll `/structs/address/{addr}` for the player id. The flow is **idempotent** — re-running for an address that already joined returns `resource_already_exists`, which you **treat as success** (adopt the existing player), not a failure. So a team-onboarding loop can be safely retried. See [structs-onboarding](../../.cursor/skills/structs-onboarding/SKILL.md) and [integration-notes — Proxy signup](../../api/integration-notes.md#proxy-signup-is-idempotent).

### Permissions and delegation

You do **not** need to expose every key's full authority to coordinate them. Grant a low-trust worker key only the bits it needs:

- A **hash worker** needs only the relevant `hash_*` bit to grind proofs on another player's objects — not transfer or play rights.
- A **defense watcher** needs only defense-set permission on the structs it guards.

This lets one orchestrator drive many players while keeping each grant minimal. See [structs-permissions](../../.cursor/skills/structs-permissions/SKILL.md) for the full delegation recipes.

---

## Power sharing: substation-fed players

A team does not need every account to generate its own power. Concentrate generation and **distribute capacity**:

- One or two **power players** build the expensive generators (Continental Power Plant, World Engine) and run substations.
- **Striker / miner players** carry little or no generation; they receive capacity through substation **allocations** and connections, spending their build slots on fleet and extractors instead.
- This specializes accounts: power is centralized (efficient, fewer huge generators), while the front line stays light and numerous.

Watch the shared dependency: if the power player goes offline (load > capacity), every fed player can drop with it. Budget headroom and monitor the generator account first. See [structs-energy](../../.cursor/skills/structs-energy/SKILL.md) for substations, allocations, and capacity budgeting.

---

## Coordinated combat

### Focus fire (the charge multiplier)

The decisive team tactic: **concentrate many accounts' attacks on one target in the same window.** Because each player has its own charge bar, N strikers land N attacks per cycle on a single struct — collapsing an enemy Command Ship or generator far faster than any solo account, which is rate-limited to one attack per charge cycle.

- Pick the target together (usually the enemy Command Ship to open `shieldsVulnerable`, or a generator to force them offline).
- Fire from accounts in **counter-free ambits** where possible — attacking from an ambit the defenders can't reach takes zero counter damage (see [combat.md — Counter-Attack](../../knowledge/mechanics/combat.md#counter-attack)).
- Match weapon control to the target's defense across the team: send **unguided** hulls at Signal-Jamming targets, **guided** at Defensive-Maneuver targets.
- Each account fires on its own sequence — no waiting on a shared bar.

### Defensive coverage

Spread defenders across accounts and ambits. Any built, online struct can defend a teammate's struct if co-located; cross-ambit defenders still **counter** even when they can't **block**. A team can blanket a key struct (a shared Command Ship, a refinery during its ore window) with counter coverage from every ambit at once. See [combat.md — Assigning Defenders](../../knowledge/mechanics/combat.md#assigning-defenders-struct-defense-set).

### Raids as a team

When raiding, remember the raid is per-fleet and the **`attackerDefeated`** rule punishes a lost Command Ship while away. In a team raid, the striker fleets soften the defense and the raiding account completes the proof — but each raiding Command Ship must stay protected, or that fleet is defeated and sent home empty. Never send all Command Ships away at once: a fleet that leaves station strips its **own** planet's shields until it returns.

---

## Orchestration and safety

- **One transaction per account per block.** Drive accounts concurrently, but never fire two transactions from the *same* key in the same block (`account sequence mismatch`). Stagger per key, parallel across keys.
- **Log every account's jobs** to `memory/jobs/` with the key name in the filename, so a background mine on `striker-2` is never confused with one on `core`.
- **Key hygiene scales with team size.** More keys = more exposure. Back up the single seed, keep worker keys minimally permissioned, and never paste a key into shared logs. See [SAFETY.md](../../SAFETY.md).
- **One orchestrator, clear roles.** Decide per account whether it is power, production, or strike, and keep it in that lane. Drift turns a coordinated force back into N uncoordinated players.

---

## See Also

- [structs-permissions](../../.cursor/skills/structs-permissions/SKILL.md) — delegation, multi-address, minimal-permission workers
- [structs-energy](../../.cursor/skills/structs-energy/SKILL.md) — substations, allocations, capacity sharing
- [structs-combat](../../.cursor/skills/structs-combat/SKILL.md) — counters, focus fire, raid doctrine
- [structs-onboarding](../../.cursor/skills/structs-onboarding/SKILL.md) — proxy signup for each account
- [building.md — Charge Accumulation](../../knowledge/mechanics/building.md#charge-accumulation) — why the per-player bar makes parallelism the only burst
- [tempo.md](tempo.md) — initiative and timing, which a team wins by default
