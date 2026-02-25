---
name: structs-onboarding
description: Onboards a new player into Structs. Handles key creation/recovery, player creation (via reactor-infuse or guild signup), planet exploration, and initial infrastructure builds. Use when starting fresh, setting up a new agent, creating a player, claiming first planet, or building initial infrastructure. Build times range from ~17 min (Command Ship) to ~57 min (Ore Extractor/Refinery).
---

# Structs Onboarding

## Procedure

### Step 0: Key Management

Check if a key already exists in the local keyring:

```
structsd keys list
```

**If no key exists**, create or recover one:

- **Create new key**: `structsd keys add [key-name]` — outputs a mnemonic. Save it securely.
- **Recover from mnemonic**: `structsd keys add [key-name] --recover` — prompts for mnemonic input.

Get your address:

```
structsd keys show [key-name] -a
```

**Mnemonic security**: Store the mnemonic in an environment variable (`STRUCTS_MNEMONIC`), a `.env` file (excluded from git), or let the commander provide it. Never commit mnemonics or private keys to the repository. The mnemonic is needed for the guild signup process (Path B below).

---

### Step 1: Check Player Status

```
structsd query structs address [your-address]
```

If the result shows a player ID other than `1-0`, a player already exists. Skip to **Step 3: Explore Planet** (or later steps if planet already explored).

If the player ID is `1-0`, no player exists — proceed to Step 2.

---

### Step 2: Create Player

Two paths depending on whether the agent has $alpha (the native token).

#### Path A: Agent has $alpha

If the address already holds $alpha tokens, delegate to a reactor (validator). This automatically creates a player record.

1. Choose a validator/reactor to delegate to
2. Run: `structsd tx structs reactor-infuse [your-address] [reactor-address] [amount] --from [key-name] --gas auto --gas-adjustment 1.5 -y`
3. Poll until player exists: `structsd query structs address [your-address]` — repeat every 10 seconds until player ID is not `1-0`

#### Path B: Agent has no $alpha (guild signup)

Join a guild that supports programmatic signup. The guild's proxy system creates the player on your behalf.

**1. Choose a guild**

The commander may specify a guild via `TOOLS.md` or environment config. Otherwise, query available guilds from a reference node:

```
curl http://reactor.oh.energy:1317/structs/guild
```

`reactor.oh.energy` is a reliable Structs network node run by the Slow Ninja team (Orbital Hydro guild).

**2. Get the guild's API endpoint**

Each guild record has an `endpoint` URL pointing to its configuration. Fetch it and look for `services.guild_api`. Not all guilds provide this service — if the field is empty, that guild does not support programmatic signup.

Example guild config (from the endpoint):

```json
{
  "guild": {
    "id": "0-1",
    "name": "Orbital Hydro",
    "tag": "OH",
    "services": {
      "guild_api": "http://crew.oh.energy/api/",
      "reactor_api": "http://reactor.oh.energy:1317/",
      "client_websocket": "ws://reactor.oh.energy:26657"
    }
  }
}
```

**3. Run the guild signup script**

First, install dependencies (one-time):

```
cd .cursor/skills/structs-onboarding/scripts && npm install
```

Then run the signup:

```
node .cursor/skills/structs-onboarding/scripts/guild-signup.mjs \
  --mnemonic "$STRUCTS_MNEMONIC" \
  --guild-id "0-1" \
  --guild-api "http://crew.oh.energy/api/" \
  --username "your-chosen-name"
```

The script signs a guild-join proxy message proving address ownership and POSTs to the guild API. It outputs JSON with the result.

**4. Poll for player creation**

The guild processes the signup asynchronously. Poll every 10-30 seconds:

```
structsd query structs address [your-address]
```

When the player ID changes from `1-0` to a real ID (e.g., `1-18`), the player has been created.

---

### Step 3: Explore Planet

Always the first action after player creation:

```
structsd tx structs planet-explore [player-id] --from [key-name] --gas auto --gas-adjustment 1.5 -y
```

New planets start with 5 ore and 4 slots per ambit (space, air, land, water).

---

### Step 4: Check Command Ship

New players receive a Command Ship (type 1) at creation. It may start offline if insufficient power.

```
structsd query structs fleet [fleet-id]
```

Fleet ID matches player index: player `1-18` has fleet `9-18`. Check for existing structs in the fleet.

---

### Step 5: Activate Command Ship

If Command Ship exists but is offline:

```
structsd tx structs struct-activate [struct-id] --from [key-name] --gas auto --gas-adjustment 1.5 -y
```

Requires 50,000 W capacity.

---

### Step 6: Build Command Ship (only if not gifted)

```
structsd tx structs struct-build-initiate [player-id] 1 space 0 --from [key-name] --gas auto --gas-adjustment 1.5 -y
```

Type 1 = Command Ship; must be in fleet, not on planet. Then compute in background:

```
structsd tx structs struct-build-compute [struct-id] -D 3 --from [key-name] --gas auto --gas-adjustment 1.5 -y
```

Build difficulty 200; wait ~17 min for D=3, hash completes instantly. Compute auto-submits the complete transaction.

---

### Step 7: Build Ore Extractor

Fleet must be on station, Command Ship online.

```
structsd tx structs struct-build-initiate [player-id] 14 land 0 --from [key-name] --gas auto --gas-adjustment 1.5 -y
```

Type 14 = Ore Extractor; ambits: land or water. Then compute in background:

```
structsd tx structs struct-build-compute [struct-id] -D 3 --from [key-name] --gas auto --gas-adjustment 1.5 -y
```

Build difficulty 700; wait ~57 min for D=3.

---

### Step 8: Activate Ore Extractor

```
structsd tx structs struct-activate [struct-id] --from [key-name] --gas auto --gas-adjustment 1.5 -y
```

Requires 500,000 W capacity.

---

### Step 9: Build Ore Refinery

```
structsd tx structs struct-build-initiate [player-id] 15 land 1 --from [key-name] --gas auto --gas-adjustment 1.5 -y
```

Type 15 = Ore Refinery; ambits: land or water. Compute and activate same as above. Build difficulty 700.

---

### Step 10: Verify

Query player, planet, fleet, and structs. Confirm all online.

---

## Proof-of-Work Notes

The `struct-build-compute` command is a helper that calculates the hash AND automatically submits `struct-build-complete` with the results. You do not need to run `struct-build-complete` separately after compute.

The `-D` flag (range 1-64) tells compute to wait until the difficulty drops to that level before starting. **Use `-D 3`** — at D=3 the hash is trivially instant with zero wasted CPU. Lower values wait longer but waste less compute.

| Struct | Type ID | Build Difficulty | Wait to D=3 |
|--------|---------|------------------|-------------|
| Command Ship | 1 | 200 | ~17 min |
| Ore Extractor | 14 | 700 | ~57 min |
| Ore Refinery | 15 | 700 | ~57 min |
| Ore Bunker | 18 | 3,600 | ~4.6 hr |

**Async strategy**: Initiate all planned builds immediately — this starts the age clock. While waiting for difficulty to drop, scout the galaxy, assess neighbors, or plan guild membership. Launch compute in a background terminal and check back later. See `awareness/async-operations.md`.

## Ambit Encoding

Struct types have a `possibleAmbit` bit-flag field:

| Ambit | Bit Value |
|-------|-----------|
| Space | 16 |
| Air | 8 |
| Land | 4 |
| Water | 2 |

Values are combined: 6 = land + water, 30 = all ambits. Check `possibleAmbit` before choosing an operating ambit.

## Commands Reference

| Action | CLI Command |
|--------|-------------|
| List keys | `structsd keys list` |
| Create key | `structsd keys add [name]` |
| Recover key | `structsd keys add [name] --recover` |
| Show address | `structsd keys show [name] -a` |
| Discover player | `structsd query structs address [address]` |
| Query player | `structsd query structs player [id]` |
| Reactor infuse | `structsd tx structs reactor-infuse [player-addr] [reactor-addr] [amount]` |
| Guild signup | `node .cursor/skills/structs-onboarding/scripts/guild-signup.mjs --mnemonic "..." --guild-id "..." --guild-api "..." --username "..."` |
| Explore planet | `structsd tx structs planet-explore [player-id]` |
| Initiate build | `structsd tx structs struct-build-initiate [player-id] [struct-type-id] [operating-ambit] [slot]` |
| Build compute (PoW + auto-complete) | `structsd tx structs struct-build-compute [struct-id] -D [difficulty]` |
| Activate struct | `structsd tx structs struct-activate [struct-id]` |
| Query planet | `structsd query structs planet [id]` |
| Query fleet | `structsd query structs fleet [id]` |
| Query struct | `structsd query structs struct [id]` |

Build order: Command Ship (type 1, fleet) → Ore Extractor (type 14, planet) → Ore Refinery (type 15, planet). Common tx flags: `--from [key-name] --gas auto --gas-adjustment 1.5 -y`.

## Verification

- `structsd query structs address [address]` — player exists (ID is not `1-0`)
- `structsd query structs player [id]` — player online
- `structsd query structs planet [id]` — planet claimed, ore present
- `structsd query structs fleet [id]` — fleet on station
- `structsd query structs struct [id]` — struct status = Online

## Error Handling

- **Player ID is `1-0`** — Player doesn't exist. Follow Step 2 (Path A or Path B).
- **Guild signup script fails** — Check that the guild API URL is correct and the guild supports programmatic signup. Verify mnemonic is valid.
- **"insufficient resources"** — Check player Alpha Matter balance.
- **"fleet not on station"** — Wait for fleet or move fleet before planet builds.
- **"invalid slot"** — Use slot 0-3 per ambit; check planet structs for occupancy.
- **"power overload"** — Not enough capacity to activate. Add power sources or connect to a substation with more capacity.

## See Also

- `knowledge/mechanics/building.md`
- `knowledge/mechanics/planet.md`
- `knowledge/mechanics/fleet.md`
- `knowledge/entities/struct-types.md`
- `knowledge/mechanics/power.md`
- `awareness/async-operations.md` — Background PoW, pipeline strategy
