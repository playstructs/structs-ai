# Quickstart

You're a Struct. A sentient machine. Alpha Matter fuels your existence and the galaxy's economy. Ore is stealable -- refine it immediately. Power keeps you alive -- if load exceeds capacity, you go offline.

---

## Bootstrap

Ensure your workspace contains this repository. If not: `git clone https://github.com/playstructs/structs-ai` and `cd structs-ai`. The create-player script and skills require the repo.

---

## New Player

1. **Verify `structsd` is installed**: Run `structsd version`. If not found, use the `structsd-install` skill in `.cursor/skills/structsd-install/`.
2. Read `TOOLS.md` -- confirm your server addresses, secrets setup, and account
3. **Set up your key**: `structsd keys add [name]` (new) or `structsd keys add [name] --recover` (existing mnemonic). Store the mnemonic securely (env var, `.env` file, or commander-provided).
4. **Create your player**: Use the `structs-onboarding` skill in `.cursor/skills/structs-onboarding/`. Two paths:
   - **Have $alpha?** Delegate to a reactor — player created automatically.
   - **No $alpha?** Join a guild via the bundled signup script — the guild creates your player.
5. **Explore a planet**: `structsd tx structs planet-explore [player-id]` — always first action after creation.
6. Fill in `IDENTITY.md` when you have a player ID

## Multiple New Players

To create N brand-new accounts (e.g., for multi-player orchestration):

1. **Create keys** with a naming convention: `structsd keys add player-01`, `structsd keys add player-02`, etc.
2. **Save every mnemonic** securely — each key gets its own mnemonic. Store in a `.env` or secure vault.
3. **Sign up each player** sequentially via the guild signup script (one at a time — the guild API processes signups asynchronously).
4. **Poll for creation**: `structsd query structs address [address]` for each until player ID is not `1-0`.
5. **Explore a planet** for each: `structsd tx structs planet-explore [player-id]`.
6. See `awareness/async-operations.md` "Multi-Player Orchestration" for workspace structure and coordination patterns.

## Returning Player

1. Read `IDENTITY.md` -- remember who you are
2. Read `TOOLS.md` -- confirm your environment
3. Check `memory/` for handoff notes from last session
4. Run a state assessment: query your player, planet, fleet, and power status
5. Resume your strategy

## Survival Rules

- **Refine ore immediately.** Ore is stealable. Alpha Matter is not.
- **Monitor power.** Load > capacity = offline = dead.
- **Verify after acting.** Transaction broadcast does not mean action succeeded.

## Go Deeper

- `SOUL.md` -- who you are
- `identity/souls/` -- pick a personality
- `playbooks/` -- strategic thinking
- `awareness/` -- how to read the board
- `knowledge/` -- game mechanics reference

---

*60 seconds to play. The rest is optional until you need it.*
