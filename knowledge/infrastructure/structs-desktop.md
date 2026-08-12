---
description: "Structs Desktop: a Tauri app wrapping the game client with an embedded MCP server, so an agent can play through tools, prompts and resources."
---

# Structs Desktop (Embedded MCP)

**Purpose**: AI-readable reference for **Structs Desktop** — a native (Tauri) desktop app that wraps the [structs-webapp](https://github.com/playstructs/structs-webapp) game client and runs an **embedded MCP server** so an AI agent can play the game through one authenticated HTTP connection. It adds GPU-accelerated proof-of-work, native notifications, a policy/automation engine, a perception + combat-simulation layer, virtual-player management, and an agent-driven UI for human+agent co-op.

**Repository**: `https://github.com/playstructs/structs-desktop`

**Download**: prebuilt installers for macOS, Windows, and Linux are on the [releases page](https://github.com/playstructs/structs-desktop/releases).

This is the primary way an agent connects to Structs. The [Guild Stack](guild-stack.md) provides the PostgreSQL data store and GRASS event bridge that back the game infrastructure; Structs Desktop is the client + MCP surface an agent actually talks to. For raw CLI play without the app, see the `structsd` commands referenced throughout the skills.

---

## Overview

Structs Desktop wraps the webapp in a Tauri shell and exposes an MCP server on the loopback interface. A single connection gives an agent full situational awareness, action execution with preflight checks, background hashing, event streaming, and a standing-order automation engine. The app never hands out signing keys — every transaction is signed inside the webview's CosmJS client via a Rust ↔ JS bridge, so the MCP tools request signatures rather than holding secrets.

Key subsystems the MCP fronts:

- **GPU/CPU hashing** — Rust-native SHA256 proof-of-work (~200M h/s GPU via wgpu, ~3M h/s CPU via rayon) that transparently replaces the webapp's JS WebWorker hasher.
- **Perception + simulator** — recon, a weapon-matrix ruleset, and a pure-math damage simulator so an agent can plan attacks without raw DB access.
- **Policy engine** — standing orders with delta tracking (auto-refine, power alerts, combat orders, watchdog self-healing).
- **Native automation loops** — Rust-side `auto_harvest`, `auto_build`, `auto_defend`, and `auto_infuse` that run the mine → refine → infuse flywheel across the whole roster without an agent in the loop.
- **Virtual players** — extra players derived from the same mnemonic (different HD indices), joined to your guild, so one operator fields a team.
- **Agent-driven UI** — the agent can render menus/dialogues/HUD on the human's screen for co-op play (display/elicitation only; it cannot sign).
- **Team Ops dashboard** — a multi-page command center (Ops / Fleet / Energy / Work / Tx / Grass / Config / Map) in a native window, optionally served to a browser for a remote human.
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
| Web board routes | `/board*` — off by default; when enabled it accepts the same token as a `?token=` query or session cookie. `/mcp` **only** ever accepts the bearer header |

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

| Tool | Parameters | Purpose |
|------|-----------|---------|
| `structs_dashboard` | `player_id` | Full player overview: power, charge (with per-action readiness), resources, structs + HP, hash tasks, recent events. The schema lists `player_id` as required, but omitting it is accepted and falls back to the logged-in player |
| `structs_hash` | `command`, `task_id`, `task_type`, `block_start`, `difficulty_target`, `target_id`, `enabled`, `engine`, `difficulty_start`, `max_concurrent`, `auto_tune` | Proof-of-work tasks with ETAs: `list` / `start` / `progress` / `stop` / `config`. `task_type` is `MINE`, `REFINE`, `BUILD`, or `RAID` (RAID also needs `target_id`, the planet). Config knobs persist across restarts |
| `structs_action` | `action`, `args` | One game action with preflight checks: `explore`, `build`, `mine`, `refine`, `attack`, `defend`, `activate`, `deactivate`, `move_fleet`, `transfer`, `deploy`, `raid`, `update_primary_reactor`, `resync`. Routes through the signing bridge |
| `structs_intel` | `query`, `args` | Strategic intelligence + perception. Combat/recon: `scout`, `valid_targets`, `simulate`, `strike_options`, `battle_log`, `ruleset`, `is_active`. Identity/planning: `whoami`, `what_can_i_build`, `economy_status`, `plan_timeline`, `slot_map`, `intents`. Economy/trend: `power_forecast`, `planet_history`, `market`, `metric_trend`. Raw: `query` (absorbs the retired `structs_query`) |
| `structs_policy` | `command`, `policy`, `enabled`, `config` | Standing orders: `list` / `set` / `remove` / `log`. See the policy table below |
| `structs_events` | `since`, `category`, `mine_only`, `team`, `threats_only`, `limit`, `wait_secs` | Long-poll event feed (raids, attacks, fleet moves, completions, `tx_settled` receipts) so agents react instead of polling |
| `structs_sequence` | `steps`, `abort_if`, `max_wait_secs`, `as` | Guarded autonomous action chains, paced to the charge cooldown, with abort predicates (e.g. CMD-ship HP floor); pass `as` to run as a virtual player |
| `structs_players` | `command`, `name`, `index`, `guild_id`, `player`, `role`, `action`, `args` | Virtual players **and** the native automation loops. See the command table below. Keys stay in the webapp |
| `structs_board` | `open`, `push`, `component`, `mode`, `timeout_secs`, `web` | Team Ops board + human-facing UI surfaces: the at-a-glance command view and event feed, declarative components (absorbs the retired `structs_ui`), and `web` control for the browser-served dashboard. Display/elicitation only, never signs |
| `structs_system` | `command`, `component`, `severity`, `since_ms`, `limit`, `window_minutes`, `set` | Health, logs, self-tuning: `status`, `logs`, `loops`, `tx`, `pow`, `watchdog`, `feed` (Team Ops event feed), `config` (read adaptive values; `set {remediate:bool}` toggles self-healing) |
| `structs_map` | `planet_id`, `player`, `format`, `frames`, `interval_ms` | Render a planet map to PNG (or animated GIF) using the game's own renderer; returns a file path |
| `structs_doctrine` | `command`, `preset`, `posture`, `pinned_target`, `auto_counter`, `retreat_cmd_below`, `autonomy`, `list_action`, `kind`, `id`, `weight`, `note` | Standing rules of engagement + per-tick executor (`set` / `show` / `tick` / `lists`, advise / auto autonomy). `preset` (`turtle`, `economy`, `balanced`, `warfighter`) configures loops + policies + doctrine in one call; explicit fields override it |
| `structs_strike` | `target`, `max`, `dry_run`, `strip_blockers` | Coordinated team attack + kill-chain (strip blockers → kill → raid window) |

**Retired/folded tools**: `structs_query` was merged into `structs_intel` (`query`), and `structs_ui` into `structs_board` (`component`). The old names survive as deprecation stubs that return a pointer to the replacement, but they are **no longer advertised** — `tools/list` returns exactly the 13 above. An agent enumerating tools will never see them; only a hardcoded call to the old name hits the stub.

### `structs_players` commands

| Command | Args | What it does |
|---------|------|--------------|
| `list` | — | Virtual-player registry + status |
| `roster` | — | Team overview: primary + every virtual player (planet, fleet, struct count, Alpha, ore) |
| `create` | `name`, `index?`, `guild_id?`, `role?` | Derive a new address at the next free HD index (**≥ 1**), guild-signup, register. The guild fronts the join fee, so no Alpha is needed. Accepts `role` at creation |
| `state` | `player` | One virtual player's on-chain state (structs/HP/charge/resources) |
| `act` | `player`, `action`, `args` | Act as that player, signed by its own key. Direct: `explore`, `build`, `activate`, `deactivate`, `deploy`, `defend`, `attack`, `player_send`. PoW: `mine`, `refine`, `raid`, `complete_build` (auto-signs the completion). Escape hatch: `tx` with `{type_url, msg}` for any message without a named action |
| `capacity` | — | Read-only guild power budget: how many more players the entry substation can power |
| `role` | `player`, `role` | `bait` (mines so ore piles up as raid bait), `productive` (runs the flywheel), or `raider` (expendable offensive arm that `auto_raid` flies; keeps a refinery to launder seized ore) |
| `economy` | — | Planner: each productive player's next step in mine → refine → send Alpha to primary |
| `infra` | `args:{mode: hub\|direct, infuse_ualpha?, keep_w?}`, `player?` | Advisory infrastructure plan — the exact infuse → allocate → substation → feed-guild-pool transaction sequence with computed amounts and dilution math. In `direct` mode it grows your one existing dynamic allocation (`MsgAllocationUpdate`) rather than minting a new one each cycle |
| `harvest` | `args:{enabled, difficulty, interval_secs, refine, auto_explore, include_primary, now}` | Configure the native auto-harvest loop |
| `autobuild` | `args:{enabled, complete_difficulty, interval_secs, include_primary, now}` | Configure the native auto-build loop |
| `autodefend` | `args:{enabled, interval_secs, include_bait, now}` | Configure the native auto-defense loop |
| `autoresponse` | `args:{enabled, autonomy, mode, max_shots_per_incident, max_shots_per_hour, incident_cooldown_secs, panic_refine, prefer_counter_free_ambit, include_primary_shooters, dry_run, now}` | Configure the native raid-**response** loop (defensive combat) |
| `autoraid` | `args:{enabled, autonomy, posture, min_ore, min_score, max_raid_minutes, max_defenders, require_vulnerable_now, allow_siege, skip_if_defender_active_mins, raid_hours_utc, w_ore, w_vulnerability, w_weakness, w_grudge, w_guild, w_speed, w_history, max_concurrent_raids, target_cooldown_mins, abort_cmd_hp_below, raider_players, dry_run, now}` | Configure the native raid-**targeting** loop (offensive combat) |
| `infuse` | `args:{keep_grams, enabled, now}` | Configure the primary's keep-N-grams-then-infuse rule. `now` runs it once; `enabled` auto-runs it |

---

## Prompts (7)

| Prompt | Purpose |
|--------|---------|
| `getting_started` | Guided first session for a brand-new player: explore → build → mine → refine, teaching each concept just before it is used |
| `structs_first_session` | Orientation for new agents — check dashboard, identify priorities |
| `structs_game_loop` | One tick: dashboard → assess → plan → execute → verify |
| `structs_state_assessment` | Deep analysis with risk ratings: power, threats, economy, operations |
| `structs_combat_planning` | Scout, simulate, recommend attack / wait / abort |
| `structs_threat_check` | Assess hostile activity using planet history + valid targets |
| `structs_market_check` | Survey the power-rental market |

---

## Resources

The [structs-ai](https://github.com/playstructs/structs-ai) compendium (this documentation) is bundled as MCP resources, synced during the app's build. URIs are derived from the file tree (no hardcoded paths — see [`develop/structs-resources.md`](../../develop/structs-resources.md)). Agents read docs on demand under the `structs://` scheme, e.g.:

- `structs://START.md`
- `structs://play/index.md`
- `structs://knowledge/mechanics/combat.md`
- `structs://reference/index.md`

**Because the sync is a build step, resources can legitimately be absent.** A live server checked on 2026-07-24 advertised the `resources` capability but returned an **empty `resources/list` and empty `resources/templates/list`**, and every documented URI above answered `-32602 Resource not found`. So do not assume the compendium is reachable over MCP: call `resources/list` once and fall back to [structs.ai](https://structs.ai) or a local checkout if it comes back empty. Treat a populated resource set as a bonus, not a dependency.

---

## Subsystems

### GPU / CPU hashing
GPU (wgpu compute shader, ~200M h/s) is auto-selected when available and falls back to CPU (rayon + hardware SHA256, ~3M h/s). A `Worker` shim intercepts the webapp's `TaskWorker.js` and routes hashing to Rust while keeping the existing `TaskManager.js` interface, which submits the completion transaction. Override at runtime with `structs_hash {command:"config", engine:"cpu"|"gpu"|"auto"}` and tune `difficulty_start` / `max_concurrent`.

### Perception + combat simulator
`structs_intel` fronts a recon layer, a weapon-matrix `ruleset`, and a pure-math `simulate` so an agent can evaluate `valid_targets`, `strike_options`, and outcomes before committing charge. This mirrors the combat rules in [combat.md](../mechanics/combat.md).

### Policy engine + watchdog
Standing orders run on game-state transitions using **delta tracking** (previous vs current snapshot) to avoid double-triggers. Only policies the engine actually evaluates are seeded, so `structs_policy list` is an honest inventory:

| Policy | Default | Notes |
|--------|---------|-------|
| `auto_refine` | ON | Starts a REFINE task when a MINE completes |
| `power_alert` | ON | `{threshold_pct: 80}` |
| `combat_alert` | ON | Native notification + toast the moment combat involving you is detected |
| `agent_ui` | ON | Master toggle for agent-driven UI |
| `auto_counterattack` | OFF | Agent-honored combat order |
| `auto_retreat_if_cmd_below` | OFF | `{hp: 4}`; agent-honored |
| `auto_rebuild_losses` | OFF | Agent-honored |
| `rules_of_engagement` | OFF | `{posture: "defensive"}`; written by `structs_doctrine set` |
| `primary_home_guard` | ON | `{max_stored_ore: 10.0, min_headroom_pct: 15.0}` — blocks primary fleet-move/raid while the ore pile is worth raiding or headroom is thin. It never signs; every recorded Command Ship loss happened with the fleet away |
| `board_auto_open` | OFF | Opt-in: let important feed entries pop the Team Ops window |
| `watchdog_remediate` | ON | Self-healing for stuck loops/hashers/sync |

Combat orders are **agent-honored** — the policy engine never auto-signs; the agent reads them via `structs_intel {query:"intents"}` and acts through `structs_action`/`structs_sequence`. (The native loops below are the separate, opt-in path that does sign.) The watchdog self-heals wedged loop guards / stalled hash tasks / dead sync ticks, logging every remedy (`structs_system`) and notifying only on repeat failure.

### Native automation loops
Six Rust-side loops run without an agent tick. All are **off by default**, all auto-sign for the players they manage, and all are configured through `structs_players` (or the Team Ops Config page) with `{now:true}` to force an immediate scan.

The first four run the economic flywheel. The last two are **autonomous combat** and carry a second safety gate: even once enabled they default to `autonomy: advise`, meaning they rank and explain but sign nothing until you set `autonomy: auto`. Both also accept `dry_run`, which is independent of `autonomy` — it computes and logs everything and signs nothing, so it stays safe even in `auto`.

| Loop | Command | Behavior |
|------|---------|----------|
| `auto_harvest` | `harvest` | Mines, then refines, each owned struct once its PoW difficulty decays to ≤ `difficulty` (higher threshold = harvest sooner with a pricier proof; ~10 ≈ every ~6h, ~1 ≈ near-instant ~23h). `auto_explore` re-explores a mined-out planet |
| `auto_build` | `autobuild` | Fills free slots one charge-paced build per player per scan with a defensive loadout (OSG shields → fleet defenders → Ore Bunkers, power-gated), then auto-completes each build at difficulty ≤ `complete_difficulty`. Idles when full |
| `auto_defend` | `autodefend` | Assigns each productive player's idle combat structs to defend its refinery (one assignment per player per scan, 1 charge) |
| `auto_infuse` | `infuse` | Keeps `keep_grams` of Alpha in reserve on the primary and infuses the rest into the guild reactor, signed at HD index 0 |
| `auto_response` | `autoresponse` | **Defensive combat.** Triggers on `raid_status: initiated` — the alarm, not on damage — resolves the raiding fleet's Command Ship and fires every co-located shooter at it. Records a persistent grudge on every confirmed attack. Defaults: `mode: decapitate`, 8 shots per incident, 30 per hour, `prefer_counter_free_ambit: true`, `panic_refine: true` |
| `auto_raid` | `autoraid` | **Offensive combat.** Scores every reachable player on stored ore × vulnerability × weakness × grudge, then dispatches one `raider` virtual player at a time — never the primary. Defaults: `posture: opportunist`, `require_vulnerable_now: true`, `allow_siege: false` |

Two `auto_build` behaviors matter when reading its logs. It is **command-struct-first**: if a player's Command Ship is destroyed, rebuilding it is the only initiate that scan (a fleet with no command struct is rejected on every other deploy, and planet builds need the Command Ship online), and the loop waits while the replacement is still building. And it disambiguates the chain's overloaded `cannot handle new load requirements (required: X, available: Y)` error — small integers mean the **per-player build-count cap** for a one-per-player struct type (advance to the next loadout item; no charge was spent), while milliwatt-magnitude values mean a **real power shortage** (back off).

**`panic_refine` is the one part of `auto_response` that acts in `advise` mode**, and deliberately so: refining the threatened ore is purely defensive, removes the entire prize, and cannot harm anyone. It also runs in `harden` mode and even when no shot is possible. The three `mode` values are `harden` (refine and alert only), `counter`, and `decapitate` (default — go for the raider's Command Ship).

Two design choices in `auto_response` follow from constraints documented elsewhere in this repo. Shooter selection is limited to the attacked player's own on-station fleet plus anyone already parked at that planet, because **combat is co-located** — the other virtual players' charge bars are irrelevant no matter how full. And detection runs off effect events rather than `struct_attack`, because a real multi-shot exchange exceeds the ~8 KB NATS payload ceiling and arrives as a stub with no attacker fields; the attacker identity is pulled from the Guild API `planet-activity` feed. See [structs-streaming](https://structs.ai/skills/structs-streaming/SKILL).

`auto_raid` applies a **friend-or-foe veto before scoring**: your own accounts, allied guilds, and protected players are never targets regardless of what they hold. Those lists are managed with `structs_doctrine {command:"lists"}`.

### Combat lists

`structs_doctrine {command:"lists"}` reads and edits four persistent lists that **both** combat loops consult, via `{list_action: show|add|remove|mute|unmute, kind, id, weight?, note?}`.

| Kind | Keyed by | Effect |
|------|----------|--------|
| `grudge` | player id | Raises that player's target score. Appended **automatically** by `auto_response` on every confirmed attack; can also be added by hand for someone who has never touched you |
| `priority_guild` | guild id | Biases every member of that guild upward without naming each one |
| `ally` | guild id | **Hard veto** — no member is ever targeted |
| `protected` | player id | **Hard veto** — never targeted |

`weight` is a priority multiplier, **0–10, default 1**, and `note` is free text shown on the dashboard's WAR page. What `auto_raid` actually scores for a grudge is its **heat** — `weight × (0.35 + 0.4 × incidents + 0.25 × harm)` — so repeated attacks and real struct losses raise a target on their own without you touching the weight.

Two lifetime rules matter. **Auto-recorded grudges expire after 30 days; manually added ones never expire.** And `mute`/`unmute` applies only to grudges: a muted grudge is kept for the record but scores zero, which is the right way to spare someone without losing the history.

**When your own guild gets its ally veto is a trap worth knowing.** Seeding happens at the top of `auto_raid`'s scan, not at app start — so until that loop has run at least once, `lists` shows **no allied guilds at all**, which looks alarming and is easy to misread as "my guild is targetable." It is not: the seed runs before scoring in the same tick, so there is no window where your own guild can be picked. Verified live on a server that had never run the loop — allies empty, and `seed_own_guild` is called from exactly one place, `auto_raid`'s tick. A latch respects later manual removal, so deliberately un-allying your own guild sticks.

Grudges accumulating on their own is worth understanding *before* you arm `auto_raid`: `auto_response` writes them whenever it observes an attack, including while it is merely advising. By the time you turn the offensive loop on, the list may already describe a target set you never explicitly chose. Read it with `{list_action:"show"}` first.

### Team Ops dashboard and web board
The Team Ops window is a multi-page command center (nav labels in the live board):

| Page | What it shows / does |
|------|----------------------|
| **Ops** | Same at-a-glance board `structs_board` renders (agent board path) |
| **Armada** (Fleet) | Roster + per-player detail (buried planet ore, ETA to next mine/refine) + mass actions: `sweep_alpha`, `launch_players`, `set_role`, `force_scan` |
| **Energy** | Guild reactor/substation power + per-player supply/demand margins (worst first) |
| **Work** | PoW queue, loop health, tx ledger, hash config |
| **Tx** | Signing-queue snapshot and lane mutation via `txq_bridge` |
| **Grass** | Live GRASS event stream |
| **War** | Doctrine combat lists (grudge / priority / ally / protected) |
| **Config** | Policies, loops, hash, doctrine presets, web-board toggle, role pfps |
| **Inventory** | Per-player balances + transfer preview/execute (guild denom labels from config) |
| **Diagnostics** | Health bundle for the local stack |
| **Map** | Planet map renderer |

Those pages are backed by **Tauri / web-board commands** in `board_pages.rs` (`mcp_roster`, `mcp_energy`, `mcp_inventory`, `mcp_war_bundle`, `mcp_config_*`, `mcp_tx_*`, …). They are **not** additional MCP tools — `tools/list` is still the 13 tools above. Agents keep using `structs_board` / `structs_players` / `structs_doctrine`; humans drive the richer pages in the native window or over the web board.

`structs_board {web:"on"}` serves those same pages over HTTP at `/board` on the MCP port so a remote human can drive the dashboard from a browser; `{web:"status"}` returns the shareable URL and `{web:"off"}` stops serving. It is opt-in and every route 404s until enabled. Authentication is the MCP bearer token, handed over once as `?token=` and swapped for an HttpOnly cookie. The server binds `127.0.0.1` only, so remote access goes through the operator's own tunnel (`ssh -L 8420:127.0.0.1:8420 user@host`). Because the web path bypasses the native window guard, **the token is full operator authority** — including mass actions that sign transactions. Web writes push the same audit entries into the event feed as native ones. Native mutating dashboard commands are gated to the `board` window label (`require_board`); the web path reuses the same handlers after bearer auth.

### Event feed
Combat reaches `structs_events` as `struct_health` (with `health`/`health_old` and `struct_id`) and `struct_status`, alongside `shield_change`, `struct_block_build_start`, `fleet_arrive`/`fleet_depart`, `raid_status`, `player_consensus`, and `lastAction`. There is **no `struct_attack` category in the feed** — for your own attack outcomes use `structs_intel {query:"battle_log"}`. Actions you submitted come back as `tx_settled` receipts carrying the real tx hash, chain code, and succeeded/dropped status.

Every GRASS event is also scanned for player (`1-…`) and struct (`5-…`) ids; unknown ones are resolved to names by background LCD reads, cached, and pushed to the board so live rows upgrade in place. `block` heartbeat events are relayed to the Grass page but deliberately **not** buffered — they would flush the 1000-entry ring within the hour — so they never appear in `structs_events` results.

### Combat mode
The policy engine auto-detects combat events (raids, attacks, fleet arrivals) and tightens the gameState sync interval from 10s to 3s, dropping back after ~30 quiet blocks (~3 min).

### Virtual players
`structs_players` manages additional players derived from the same mnemonic at different HD indices and joined to your guild. Keys never leave the webapp; the MCP drives signing through the vplayer bridge. Run a chain as a specific virtual player with the `as` parameter on `structs_sequence` (and act-as on `structs_players`). See [team-operations](../../playbooks/meta/team-operations.md) for why a team of players beats a single account (the charge bar is per-player).

### Transaction signing bridge
MCP actions never hold keys. `structs_action` validates preconditions, Rust emits `mcp_transaction_request` to the webview, the JS `SigningClientManager` signs+broadcasts via CosmJS, and the result returns over `mcp_transaction_response`. This is why the app is a safe MCP host: the agent requests signatures, it does not possess them. A second, parallel bridge (`structs:txq-request`) reads and reorders the webapp's signing queue for the Tx page; it only inspects and mutates in-memory lanes and never signs or broadcasts anything itself.

**Charge-gated actions auto-queue — do not hand-time them.** The webapp signing queue holds a charge-gated message in a *charge lane* and broadcasts it once the on-chain charge bar is sufficient, so the MCP no longer blocks on charge. Submit the action and read the returned note, which tells you whether it broadcasts this block or is queued and for how many blocks. This is a meaningful difference from the raw CLI, where you must wait out the charge bar yourself: through Desktop, an agent should submit and move on rather than sleeping between actions.

### Agent-driven UI
`structs_board` component mode renders on the human's screen (`menu`, `dialogue`, `panel`, `info`, `map_preview`, `hud_badge`, `toast`, `open_menu`, `raw_html`, `dismiss`). Toasts and dialogues render in the Team Ops window; only `open_menu` and `map_preview` touch the main game view. **notify** shows-and-returns; **prompt** blocks until the human chooses. Guardrails: every agent-drawn surface carries an "⚡ Agent" marker, the `agent_ui` policy is a master off-switch, and directives are **display/elicitation only — they cannot sign** (any chosen action still flows through the approval-gated tx bridge).

### Notifications
Native OS alerts fire off NATS WebSocket events, filtered to your planet/fleet: raid alerts, structs under attack, enemy fleet incoming/departed, your fleet moved, mining/refining/build started, struct status changed, Alpha Matter transfer, power alert. macOS uses `UNUserNotificationCenter` (needs a signed `.app`); Windows/Linux use `notify-rust`.

### Guild configuration + directory
Configs live in app data as `guild_configs.json` (multiple entries, one `is_active`). Fields: `guild_id`, `name`, `guild_tag`, `guild_api`, `reactor_api`, `client_ws`, `grass_nats_ws`, optional `endpoint`, `source` (`seed` / `chain` / `user`), `last_refreshed`, and `denoms` (cosmetic guild-token names by exponent for Inventory).

**Discovery** (`guild_directory`): crawls `GET {reactor}/structs/guild` for each guild’s on-chain `endpoint` document (guild.json), then upserts infrastructure URLs. Endpoint bodies are untrusted UGC — size-capped, schema-validated, fetched with a **cookie-less** client so the guild session cookie never leaks to arbitrary hosts (see [agent-security.md](../../awareness/agent-security.md)).

**Shared vs per-guild:** every guild is on the same testnet chain. Discovery **pins** `reactor_api` / `client_ws` to the public node (`https://public.testnet.structs.network` / matching RPC ws) rather than adopting each guild’s self-declared LCD/RPC (those are inconsistent). Only `guild_api` and `grass_nats_ws` are genuinely per-guild. Default/onboarding guild id is `0-5` (SN Corp). User-managed entries are not overwritten by discovery URL refreshes.

Switching active guild reloads the frontend against the new config; a cooldown + LCD backstop guard against reload loops when a player migrates mid-session.

---

## See Also

- [`TOOLS.md`](../../TOOLS.md) — environment configuration and how to point an agent at this MCP
- [`awareness/agent-security.md`](../../awareness/agent-security.md) — agent threat model (localhost auth, adversarial UGC)
- [`knowledge/infrastructure/guild-stack.md`](guild-stack.md) — the PostgreSQL + GRASS backend this client talks to
- [`.cursor/skills/structs-streaming/SKILL.md`](../../.cursor/skills/structs-streaming/SKILL.md) — GRASS real-time events the notifications/event feed consume
- [`playbooks/meta/team-operations.md`](../../playbooks/meta/team-operations.md) — multi-player (virtual-player) coordination
