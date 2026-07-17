# Structs Desktop (Embedded MCP)

**Purpose**: AI-readable reference for **Structs Desktop** — a native (Tauri) desktop app that wraps the [structs-webapp](https://github.com/playstructs/structs-webapp) game client and runs an **embedded MCP server** so an AI agent can play the game through one authenticated HTTP connection. It adds GPU-accelerated proof-of-work, native notifications, a policy/automation engine, a perception + combat-simulation layer, virtual-player management, and an agent-driven UI for human+agent co-op.

**Repository**: `https://github.com/playstructs/structs-desktop`

This is the primary way an agent connects to Structs. The [Guild Stack](guild-stack.md) provides the PostgreSQL data store and GRASS event bridge that back the game infrastructure; Structs Desktop is the client + MCP surface an agent actually talks to. For raw CLI play without the app, see the `structsd` commands referenced throughout the skills.

---

## Overview

Structs Desktop wraps the webapp in a Tauri shell and exposes an MCP server on the loopback interface. A single connection gives an agent full situational awareness, action execution with preflight checks, background hashing, event streaming, and a standing-order automation engine. The app never hands out signing keys — every transaction is signed inside the webview's CosmJS client via a Rust ↔ JS bridge, so the MCP tools request signatures rather than holding secrets.

Key subsystems the MCP fronts:

- **GPU/CPU hashing** — Rust-native SHA256 proof-of-work (~200M h/s GPU via wgpu, ~3M h/s CPU via rayon) that transparently replaces the webapp's JS WebWorker hasher.
- **Perception + simulator** — recon, a weapon-matrix ruleset, and a pure-math damage simulator so an agent can plan attacks without raw DB access.
- **Policy engine** — standing orders with delta tracking (auto-refine, power alerts, combat orders, watchdog self-healing).
- **Virtual players** — extra players derived from the same mnemonic (different HD indices), joined to your guild, so one operator fields a team.
- **Agent-driven UI** — the agent can render menus/dialogues/HUD on the human's screen for co-op play (display/elicitation only; it cannot sign).
- **Event feed + notifications** — a long-poll stream over a NATS ring buffer, plus native OS alerts filtered to your planet/fleet.

---

## Connecting

| Detail | Value |
|--------|-------|
| Endpoint | `http://127.0.0.1:8420/mcp` (loopback only) |
| Transport | HTTP (MCP) |
| Auth | `Authorization: Bearer <token>` on **every** request |
| Missing/bad token | `400 Bad Request` (not `401` — a `401` would trigger a Claude Code OAuth flow) |
| Liveness probe | unauthenticated `GET /health` |
| Token location | generated on first launch; shown in the app's **Debug tab** and browser console, stored at `~/Library/Application Support/structs-app/mcp_config.json` (macOS) |

Example client config (copyable from the Debug tab):

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

The bearer token exists because any browser page can reach `localhost` — without it a malicious site could drive the game. See [agent-security.md](../../awareness/agent-security.md) for the agent threat model.

---

## Tool Catalog (13)

| Tool | Purpose |
|------|---------|
| `structs_dashboard` | Full player overview: power, charge (with per-action readiness), resources, structs + HP, hash tasks, recent events |
| `structs_hash` | Manage proof-of-work tasks with ETAs (list/start/stop/progress) and tune the engine (`config`: enable/disable, `engine` cpu/gpu/auto, `difficulty_start`, `max_concurrent`, `auto_tune`) — knobs persist across restarts |
| `structs_action` | Execute game actions with preflight checks (explore, build, mine, refine, attack, defend, raid, `resync`, etc.); routes through the signing bridge |
| `structs_intel` | Strategic intelligence + perception: `whoami`, `scout`, `valid_targets`, `simulate`, `strike_options`, `battle_log`, `ruleset`, `slot_map`, `is_active`, `intents`, power forecast, economy, timeline — plus `query` for raw entity reads/lists/filters (absorbs the retired `structs_query`) |
| `structs_policy` | Standing orders: `auto_refine`, `power_alert`, `agent_ui`, combat orders, `watchdog_remediate` |
| `structs_events` | Long-poll event feed (raids, attacks, fleet moves, completions) so agents react instead of polling |
| `structs_sequence` | Guarded autonomous action chains, paced to the charge cooldown, with abort predicates (e.g. CMD-ship HP floor); pass `as` to run as a virtual player |
| `structs_players` | Manage virtual players (extra players off the same mnemonic, joined to your guild): create / list / `roster` / state / act-as. Keys stay in the webapp |
| `structs_board` | Team Ops board + human-facing UI surfaces: the at-a-glance command view and event feed, plus declarative components (menus, dialogues, map previews, HUD badges, prompts — absorbs the retired `structs_ui`). Display/elicitation only, never signs |
| `structs_system` | System health, logs, self-tuning: watchdog status, per-loop liveness, tx-attempt ledger, PoW solve stats, and the persistent structured log |
| `structs_map` | Render a planet map to PNG/GIF using the game's own renderer |
| `structs_doctrine` | Standing rules of engagement + per-tick executor (advise / auto autonomy) |
| `structs_strike` | Coordinated team attack + kill-chain (strip blockers → kill → raid window) |

**Retired/folded tools**: `structs_query` was merged into `structs_intel` (`query`), and `structs_ui` into `structs_board` (`component`). The old names remain only as deprecation stubs that return a pointer to the replacement.

---

## Prompts (6)

| Prompt | Purpose |
|--------|---------|
| `structs_first_session` | Orientation for new agents — check dashboard, identify priorities |
| `structs_game_loop` | One tick: dashboard → assess → plan → execute → verify |
| `structs_state_assessment` | Deep analysis with risk ratings: power, threats, economy, operations |
| `structs_combat_planning` | Scout, simulate, recommend attack / wait / abort |
| `structs_threat_check` | Assess hostile activity using planet history + valid targets |
| `structs_market_check` | Survey the power-rental market |

---

## Resources

The [structs-ai](https://github.com/playstructs/structs-ai) compendium (this documentation) is bundled as MCP resources, synced during the app's build. Agents read docs on demand under the `structs://` scheme, e.g.:

- `structs://knowledge/mechanics/combat.md`
- `structs://knowledge/mechanics/energy.md`
- `structs://playbooks/phases/early-game.md`
- `structs://QUICKSTART.md`

---

## Subsystems

### GPU / CPU hashing
GPU (wgpu compute shader, ~200M h/s) is auto-selected when available and falls back to CPU (rayon + hardware SHA256, ~3M h/s). A `Worker` shim intercepts the webapp's `TaskWorker.js` and routes hashing to Rust while keeping the existing `TaskManager.js` interface, which submits the completion transaction. Override at runtime with `structs_hash {command:"config", engine:"cpu"|"gpu"|"auto"}` and tune `difficulty_start` / `max_concurrent`.

### Perception + combat simulator
`structs_intel` fronts a recon layer, a weapon-matrix `ruleset`, and a pure-math `simulate` so an agent can evaluate `valid_targets`, `strike_options`, and outcomes before committing charge. This mirrors the combat rules in [combat.md](../mechanics/combat.md).

### Policy engine + watchdog
Standing orders run on game-state transitions using **delta tracking** (previous vs current snapshot) to avoid double-triggers. Defaults: `auto_refine` ON, `power_alert` ON (80%), `agent_ui` ON, `watchdog_remediate` ON; combat orders (`auto_counterattack`, `auto_retreat_if_cmd_below`, `auto_rebuild_losses`) and `rules_of_engagement` default OFF. Combat orders are **agent-honored** — the engine never auto-signs; the agent reads them via `structs_intel {query:"intents"}` and acts through `structs_action`/`structs_sequence`. The watchdog self-heals wedged loop guards / stalled hash tasks / dead sync ticks, logging every remedy (`structs_system`) and notifying only on repeat failure.

### Combat mode
The policy engine auto-detects combat events (raids, attacks, fleet arrivals) and tightens the gameState sync interval from 10s to 3s, dropping back after ~30 quiet blocks (~3 min).

### Virtual players
`structs_players` manages additional players derived from the same mnemonic at different HD indices and joined to your guild. Keys never leave the webapp; the MCP drives signing through the vplayer bridge. Run a chain as a specific virtual player with the `as` parameter on `structs_sequence` (and act-as on `structs_players`). See [team-operations](../../playbooks/meta/team-operations.md) for why a team of players beats a single account (the charge bar is per-player).

### Transaction signing bridge
MCP actions never hold keys. `structs_action` validates preconditions, Rust emits `mcp_transaction_request` to the webview, the JS `SigningClientManager` signs+broadcasts via CosmJS, and the result returns over `mcp_transaction_response`. This is why the app is a safe MCP host: the agent requests signatures, it does not possess them.

### Agent-driven UI
`structs_board` component mode renders on the human's screen (`menu`, `dialogue`, `panel`, `info`, `map_preview`, `hud_badge`, `toast`, `open_menu`, `raw_html`). **notify** shows-and-returns; **prompt** blocks until the human chooses. Guardrails: every agent-drawn surface carries an "⚡ Agent" marker, the `agent_ui` policy is a master off-switch, and directives are **display/elicitation only — they cannot sign** (any chosen action still flows through the approval-gated tx bridge).

### Notifications
Native OS alerts fire off NATS WebSocket events, filtered to your planet/fleet: raid alerts, structs under attack, enemy fleet incoming/departed, your fleet moved, mining/refining/build started, struct status changed, Alpha Matter transfer, power alert. macOS uses `UNUserNotificationCenter` (needs a signed `.app`); Windows/Linux use `notify-rust`.

### Guild configuration
The app connects to a guild's infrastructure via stored configs (`guildApi`, `reactorApi`, `clientWs`, `grassNatsWs`); it supports multiple guild configs with one active at a time. A default config ships for new players.

---

## See Also

- [`TOOLS.md`](../../TOOLS.md) — environment configuration and how to point an agent at this MCP
- [`awareness/agent-security.md`](../../awareness/agent-security.md) — agent threat model (localhost auth, adversarial UGC)
- [`knowledge/infrastructure/guild-stack.md`](guild-stack.md) — the PostgreSQL + GRASS backend this client talks to
- [`.cursor/skills/structs-streaming/SKILL.md`](../../.cursor/skills/structs-streaming/SKILL.md) — GRASS real-time events the notifications/event feed consume
- [`playbooks/meta/team-operations.md`](../../playbooks/meta/team-operations.md) — multi-player (virtual-player) coordination
