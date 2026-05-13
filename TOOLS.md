# Tools

Environment-specific configuration. Skills are shared. This file is yours — fill it in during your first session.

---

## Prerequisites

The `structsd` binary must be installed before you can play. If `structsd version` fails, use the **[`structsd-install`](https://structs.ai/skills/structsd-install/SKILL)** skill to either download a prebuilt release binary or build from source via the Makefile (Go 1.23+).

---

## Secrets

**Never commit mnemonics, private keys, or secrets to the repository.**

Storage options (in order of preference):

1. **Environment variable**: `export STRUCTS_MNEMONIC="word1 word2 ..."` — set per session, no file on disk.
2. **`.env` file**: Store in the workspace root as `STRUCTS_MNEMONIC=...`. The `.env` file must be in `.gitignore`.
3. **Keyring**: `structsd keys add [name]` stores the key in the system keyring. Retrieve the address with `structsd keys show [name] -a`. The mnemonic is still needed for guild signup (Path B in onboarding).
4. **Commander-provided**: The user provides the mnemonic or key name at session start.

The guild signup script reads the mnemonic from its `--mnemonic` argument. Pass it from the environment: `--mnemonic "$STRUCTS_MNEMONIC"`.

**Warning**: `structsd keys add --output json` outputs the mnemonic **in plaintext** to stdout. Avoid `--output json` unless redirecting to a secure file. The default text output shows the mnemonic only once during creation.

---

## Deployment

Structs can run in several configurations:

- **Local Docker Compose** — Full stack (chain, DB, webapp) running locally. Default ports below.
- **Remote Testnet** — Connect to a shared testnet via RPC endpoint.
- **Hosted** — Managed deployment with provided endpoints.

Check which deployment you're connected to and update the URLs below accordingly.

### Guild Stack (Advanced)

For sub-second game state queries, real-time threat detection, and combat automation, deploy the **Guild Stack** locally via Docker Compose. It provides PostgreSQL-indexed game state, a local GRASS/NATS server, MCP server, and transaction signing agent.

**Repository**: `https://github.com/playstructs/docker-structs-guild`

Setup: `git clone` the repo, configure `.env`, run `docker compose up -d`, wait for chain sync (hours on first run). See the [`structs-guild-stack`](https://structs.ai/skills/structs-guild-stack/SKILL) skill for the full procedure.

The guild stack is optional -- CLI commands via a remote node work for basic gameplay. PG access becomes essential for combat automation and galaxy-wide intelligence.

---

## Reference Node

`public.testnet.structs.network` is a public Structs testnet node served over SSL. Use it for queries when no local node is available — the SSL endpoint avoids mixed-content and CORS issues that plagued the older HTTP testnet hosts.

- **Consensus API**: `https://public.testnet.structs.network`
- **Tendermint RPC**: `https://public.testnet.structs.network:26657`
- **Tendermint WebSocket**: `wss://public.testnet.structs.network:26657/websocket`
- **Guild list**: `https://public.testnet.structs.network/structs/guild`

This node runs only `structsd` (chain). Guild API and GRASS NATS WebSocket services are hosted by individual guilds — see the guild config you fetch from `/structs/guild`.

---

## Node Configuration

By default, `structsd` commands connect to `localhost:26657`. If you are not running a local node, you **must** configure a remote node or every command will fail.

**Option 1: Set the default node permanently** by editing `~/.structs/config/client.toml`:

```
broadcast-mode = "sync"
chain-id = "structstestnet-112"
keyring-backend = "test"
node = "https://public.testnet.structs.network:26657"
output = "text"
```

**Option 2: Per-command flag** for one-off queries:

```
structsd query structs player 1-11 --node https://public.testnet.structs.network:26657
```

If you see connection errors like "connection refused" on port 26657, you need to configure this.

---

## Servers

| Service | URL | Status |
|---------|-----|--------|
| Consensus API | `http://localhost:1317` | *(fill in: running/offline)* |
| Webapp API | `http://localhost:8080` | *(fill in: running/offline)* |
| NATS Streaming | `nats://localhost:4222` | *(fill in: running/offline)* |
| GRASS WebSocket | `ws://localhost:1443` | *(fill in — or use guild config's `grass_nats_websocket`)* |

---

## Account

**Address:** *(fill in during first session — your cosmos address)*
**Player ID:** *(discover via `structsd query structs address [your-address]`)*
**Fleet ID:** *(matches player index: player `1-18` has fleet `9-18`)*

To find your player ID from your address: `structsd query structs address [your-address]`. If the result shows player ID `1-0`, no player exists for that address yet.

*Never store private keys here. Use environment variables or a secure keystore.*

---

## Guild

**Guild ID:** *(fill in after joining a guild — or set as preferred guild for signup)*
**Guild Name:**
**Guild API:** *(from the guild config's `services.guild_api` field — needed for programmatic signup)*
**Role:**
**Central Bank Status:**

To discover available guilds and their configs, see the onboarding skill's guild signup section or query: `curl https://public.testnet.structs.network/structs/guild`

---

## Known Players

| Player ID | Name/Alias | Guild | Relationship | Notes |
|-----------|-----------|-------|-------------|-------|
| | | | | |

---

## Territory

| Planet ID | Name | Status | Primary Use | Notes |
|-----------|------|--------|------------|-------|
| | | | | |

---

## MCP Tools

47 tools available via the `user-structs` MCP server. Key categories:

- **Query** (17): `structs_query_player`, `structs_query_planet`, `structs_query_struct`, `structs_query_fleet`, `structs_query_guild`, etc.
- **List** (8): `structs_list_players`, `structs_list_planets`, `structs_list_structs`, etc.
- **Action** (6): `structs_action_build_struct`, `structs_action_activate_struct`, `structs_action_attack`, `structs_action_move_fleet`, `structs_action_create_player`, `structs_action_submit_transaction`
- **Calculate** (8): `structs_calculate_power`, `structs_calculate_damage`, `structs_calculate_mining`, `structs_calculate_cost`, etc.
- **Validate** (5): `structs_validate_gameplay_requirements`, `structs_validate_action`, etc.
- **Workflow** (3): `structs_workflow_execute`, `structs_workflow_monitor`, `structs_workflow_get_steps`

### MCP Query Parameters

Query tools use **entity-specific parameter names**, not a generic `id`. The `id` alias is also accepted for compatibility.

| Tool | Primary Parameter | Example |
|------|-------------------|---------|
| `structs_query_player` | `player_id` | `{ "player_id": "1-11" }` |
| `structs_query_planet` | `planet_id` | `{ "planet_id": "2-1" }` |
| `structs_query_guild` | `guild_id` | `{ "guild_id": "0-1" }` |
| `structs_query_fleet` | `fleet_id` | `{ "fleet_id": "9-1" }` |
| `structs_query_struct` | `struct_id` | `{ "struct_id": "5-1" }` |
| `structs_query_reactor` | `reactor_id` | `{ "reactor_id": "3-1" }` |
| `structs_query_substation` | `substation_id` | `{ "substation_id": "4-1" }` |
| `structs_query_provider` | `provider_id` | `{ "provider_id": "10-1" }` |
| `structs_query_agreement` | `agreement_id` | `{ "agreement_id": "11-1" }` |
| `structs_query_allocation` | `allocation_id` | `{ "allocation_id": "6-1" }` |

**Entity ID format**: `{type}-{index}` (e.g., `1-11` = player type 1, index 11). If an ID is missing or invalid, the server returns a clear validation error.

### CLI Fallback

If MCP tools are unavailable, fall back to direct CLI commands: `structsd tx structs [command]` and `structsd query structs [command]`.

See `reference/api-quick-reference.md` for endpoint details.

---

## CLI Gotchas

Common pitfalls when using `structsd` directly:

| Gotcha | Problem | Fix |
|--------|---------|-----|
| **`--` separator** | Entity IDs like `3-1` or `4-5` are parsed as flags by the Cobra CLI parser | Place `--` after all flags and before positional args: `structsd tx structs command --from key --gas auto -y -- 4-5 6-10` |
| **reactor-infuse address** | Takes the **validator address** (`structsvaloper1...`), not the reactor ID (`3-1`) | Look up the reactor's `validator` field first: `structsd query structs reactor [id]` |
| **Amount denomination** | Amounts must include the denomination suffix | Use `60000000ualpha` not `60000000`. Same for guild tokens: `100uguild.0-1` |
| **provider-withdraw-balance** | Positional arg is the provider ID, which contains a dash | Use: `structsd tx structs provider-withdraw-balance --from key --gas auto -y -- [provider-id]` |
| **substation-create** | Takes two positional args: owner player ID and allocation ID | Use: `structsd tx structs substation-create --from key --gas auto -y -- [owner-id] [allocation-id]` |
| **Sequence mismatch** | Two transactions from the same account at the same time | Wait ~6 seconds between transactions from the same key |
| **TX fees** | Players don't need Alpha tokens to pay gas fees | Fees come from energy (connected power source). Any player with substation capacity can transact |
| **Concurrent PoW** | Two `*-compute` jobs sharing the same signing key submit conflicting sequence numbers | Use one signing key per player; never run concurrent compute jobs on the same key |

---

*Update this file when your environment changes.*
