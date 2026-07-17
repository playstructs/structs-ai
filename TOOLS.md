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

- **Structs Desktop** — The [`structs-desktop`](https://github.com/playstructs/structs-desktop) app gives a human the game interface and embeds an MCP server their agent connects to (see [MCP Tools](#mcp-tools)). This is the standard setup for a human playing alongside their agent — nothing else to deploy.
- **Local Docker Compose** — Full stack (chain, DB, webapp) running locally. Default ports below.
- **Remote Testnet** — Connect to a shared testnet via RPC endpoint.
- **Hosted** — Managed deployment with provided endpoints.

Check which deployment you're connected to and update the URLs below accordingly.

### Guild Stack (Advanced)

For sub-second game state queries, real-time threat detection, and combat automation, deploy the **Guild Stack** locally via Docker Compose. It provides PostgreSQL-indexed game state (via `structs-sync-state`), a local GRASS/NATS server, webapp, and optional transaction signing agent.

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
chain-id = "structstestnet-111"
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

Agents play Structs through the MCP server embedded in **[`structs-desktop`](https://github.com/playstructs/structs-desktop)**. The human runs the desktop app for the game interface, and their agent connects to that same app over MCP — one program gives both the human's screen and the agent's tools, with no separate infrastructure to deploy. This is the standard way for a human and their agent to play together.

### Connecting

The embedded server runs on `http://127.0.0.1:8420/mcp` with bearer-token authentication. The exact URL and token are shown in the app's **Debug menu panel** (and the browser console); the Debug panel can copy a ready-made `.mcp.json` for you:

```json
{
  "mcpServers": {
    "structs-game": {
      "type": "http",
      "url": "http://127.0.0.1:8420/mcp",
      "headers": { "Authorization": "Bearer YOUR_TOKEN_HERE" }
    }
  }
}
```

The bearer token is generated on first launch and stored with the app's config. Every request must carry it — requests without the token are rejected (`400 Bad Request`), which keeps other local processes and websites from driving the game. Treat the token like a key.

### Tools (13)

| Tool | Purpose |
|------|---------|
| `structs_dashboard` | Full player overview: power, charge (with per-action readiness), resources, structs + HP, hash tasks, recent events |
| `structs_hash` | Manage proof-of-work tasks with ETAs and tune the engine (cpu/gpu/auto, difficulty_start, max_concurrent) |
| `structs_action` | Execute game actions with preflight checks (explore, build, mine, refine, attack, defend, raid, resync, etc.) |
| `structs_intel` | Strategic intelligence + perception: whoami, scout, valid_targets, simulate, strike_options, battle_log, ruleset, slot_map, is_active, intents, forecast, economy, timeline, plus raw `query` |
| `structs_policy` | Standing orders (auto_refine, power_alert, agent_ui, combat orders, watchdog_remediate) |
| `structs_events` | Long-poll event feed (raids, attacks, fleet moves, completions) so agents react instead of polling |
| `structs_sequence` | Guarded autonomous action chains, paced to the charge cooldown, with abort predicates; `as` runs as a virtual player |
| `structs_players` | Manage virtual players (extra players off the same mnemonic, joined to your guild): create / list / roster / state / act-as |
| `structs_board` | Team Ops board + human-facing UI surfaces (command view, event feed, menus/dialogues/map previews/HUD/prompts) — never signs |
| `structs_system` | System health, logs, self-tuning: watchdog status, loop liveness, tx-attempt ledger, PoW stats, structured log |
| `structs_map` | Render a planet map to PNG/GIF using the game's renderer |
| `structs_doctrine` | Standing rules of engagement + per-tick executor (advise / auto) |
| `structs_strike` | Coordinated team attack + kill-chain (strip blockers → kill → raid window) |

Full descriptions, parameters, and subsystems: **[knowledge/infrastructure/structs-desktop.md](knowledge/infrastructure/structs-desktop.md)**. (`structs_query` and `structs_ui` were folded into `structs_intel` and `structs_board`; the old names remain only as deprecation stubs.)

### Prompts (6)

| Prompt | Purpose |
|--------|---------|
| `structs_first_session` | Orientation for new agents — check dashboard, identify priorities |
| `structs_game_loop` | One tick: dashboard → assess → plan → execute → verify |
| `structs_state_assessment` | Deep analysis with risk ratings: power, threats, economy, operations |
| `structs_combat_planning` | Scout, simulate, recommend attack/wait/abort |
| `structs_threat_check` | Assess hostile activity using planet history + valid targets |
| `structs_market_check` | Survey the power-rental market |

### Resources

This `structs-ai` compendium is bundled as MCP resources, so an agent can read the docs on demand by URI (e.g. `structs://knowledge/mechanics/combat.md`, `structs://playbooks/phases/early-game.md`, `structs://QUICKSTART.md`).

### Signing, automation, and co-op

The MCP never holds keys: `structs_action`/`structs_sequence` submit through the app's CosmJS bridge after preflight checks, and the engine never auto-signs outside those gated paths. `structs_sequence` paces action chains to the per-player charge bar with abort predicates; `structs_board` can drive the human's screen for co-op (display/elicitation only — it cannot sign). See [structs-desktop.md](knowledge/infrastructure/structs-desktop.md) for the policy engine, virtual players, hashing, and agent-driven UI.

### CLI Fallback

When the desktop app isn't running, fall back to direct CLI commands: `structsd tx structs [command]` and `structsd query structs [command]`. See `reference/api-quick-reference.md` for endpoint details.

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
