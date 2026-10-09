---
description: "How to add capability to Structs Desktop: a new MCP tool, a new board page, serving SUI over HTTP, or agent-driven UI."
---

# Extending Structs Desktop

**Purpose**: How to add capability to [structs-desktop](../repos.md) — a new MCP tool, a
new board page, or agent-driven UI — rather than how to use what's already there.

For *using* the existing tools, see [TOOLS.md](../../TOOLS.md) and
[knowledge/infrastructure/structs-desktop.md](../../knowledge/infrastructure/structs-desktop.md).

Structs Desktop is Tauri 2: a Rust backend (`src-tauri/`) hosting an embedded MCP server,
and a webview frontend (`frontend/`) built on [SUI](../ui/index.md). The two halves are
worth understanding separately, because most contributions touch only one.

---

## Adding an MCP tool

Tools live in `src-tauri/src/mcp/tools/`, one module per surface:

```
action.rs   board.rs      board_pages.rs  dashboard.rs  doctrine.rs
events.rs   format.rs     hasher.rs       intel.rs      map.rs
mass_action.rs  players.rs  policy.rs     sequence.rs   strike.rs  system.rs
```

They surface as exactly 13 advertised tools: `structs_action`, `structs_dashboard`,
`structs_hash`, `structs_intel`, `structs_policy`, `structs_events`,
`structs_sequence`, `structs_players`, `structs_map`, `structs_board`,
`structs_doctrine`, `structs_strike`, and `structs_system`. Agent-driven components
belong to `structs_board`; `structs_ui` is only a retired-call migration stub.

The shape to follow is **one tool per surface with an operation parameter**, not one tool
per operation. `structs_action` covers every game action rather than exposing forty
separate build/move/attack tools. That keeps the tool list legible to a model — which is
the actual constraint, since a long flat tool list degrades selection accuracy.

Around the tools sit the pieces that make them safe and fast, and a new tool should reuse
rather than reimplement them:

| Module | Provides |
|---|---|
| `tx_queue.rs`, `tx_retry.rs`, `txq_bridge.rs` | Transaction queueing and retry — the same serialise-don't-track-sequences discipline as the [webapp queue](actions-and-signing.md#the-dual-lane-queue) |
| `policy.rs` | Capability gating. Anything that signs must pass policy |
| `error_translator.rs` | Chain errors into text an agent can act on |
| `enrich.rs`, `roster_cache.rs` | Resolving IDs to names without a round trip per lookup |
| `event_buffer.rs`, `board_feed.rs` | The event stream behind the board |
| `telemetry.rs`, `watchdog.rs` | Health and liveness |

The automation loops (`auto_build.rs`, `auto_harvest.rs`, `auto_defend.rs`,
`auto_raid.rs`, `auto_infuse.rs`, `auto_response.rs`) are the closest thing to worked
examples of a long-running background capability, and `loop_util.rs` holds the shared
cadence machinery.

---

## Adding a board page

The Team Ops board (`frontend/board.html` + `board.js` + `board-pages.js`) is a
six-area operations console built entirely on SUI: Command, Armada, Industry,
War, Explore, and System. Terminal is a customizable card workspace and Comms is
Matrix-backed. Pages still self-register:

```js
Board.registerPage = function (name, def) {
  def = def || {};
  def.lastRun = 0;
  Board.pages[name] = def;
};
```

A page definition is small:

```js
Board.registerPage('energy', {
  refresh: renderEnergy,
  cadenceMs: 30000,
  onEnter: renderEnergy,
});
```

| Key | Meaning |
|---|---|
| `refresh` | Called on the cadence while the page is visible. Return a promise if async |
| `cadenceMs` | How often. Existing pages range from 2.5s (`tx`) to 30s (`energy`) |
| `onEnter` | Called once when the page becomes visible — usually the same function, for an immediate paint |

**Pick the cadence from how fast the underlying thing changes**, not from how fresh you'd
like it to feel. Transactions settle per block, so `tx` polls at 2.5s. Energy allocations
change when someone changes them, so 30s is generous. Every page polling at 1s is how a
console becomes a load generator against its own backend.

The routing manifest in `board.js` is authoritative; several route pages host multiple
views. Read the nearest current section rather than copying an old page list. Shared
helpers at the top of `board.js` (`esc`, `el`, `row`, card builders) follow the same idea
as [sui-kit.js](../ui/examples/sui-kit.js).

### Tauri commands are not MCP tools

Internal `#[tauri::command]` handlers may back Team Ops without changing `tools/list`.
Industry → Infusions is the canonical example: `mcp_infusions`,
`mcp_infusion_preview`, `mcp_infusion_infuse`, `mcp_infusion_defuse`,
`mcp_infusion_migrate`, `mcp_infusion_cancel_defusion`, and
`mcp_infusion_restart` are native/web-board handlers, not a `structs_infusions`
MCP tool. Keep that distinction explicit in UI and docs.

Mutating native handlers must call `require_trusted`: windows that render external
content (game, Comms/chat, raid viewers) cannot sign or rewrite config. Trusted Team
Ops/Terminal surfaces can. The bearer-authenticated web board has its own explicit route
allowlist; add a web route only after deciding whether bearer possession should grant it.

Two lessons the board learned the hard way are documented in comments in `board.js` and
generalise to any agent-facing feed:

**Collapse repetition.** A live sample of the event stream was 85 of 104 entries from
three message templates, 54 of them the same automation line. Consecutive entries from
the same source with the same shape now collapse into one row with a count.

**Sort by severity, not only by time.** Important entries are pinned into a NEEDS YOU
card above the stream as well as appearing in it. Chronological order alone buries the
raid alarm under routine chatter.

---

## Serving SUI over HTTP: `rebase_css_urls`

The board is served under `/board`, but `sui.css` references its assets from the web root
(`url("/img/sui/…")`). This is [the asset-path gotcha](../ui/gotchas.md#asset-paths-are-root-absolute),
and Structs Desktop solves it by rewriting CSS on the way out:

```rust
/// Prefix root-absolute `url(...)` targets with `/board`. Leaves relative URLs,
/// `data:` URIs and absolute URLs with a scheme untouched.
fn rebase_css_urls(bytes: &[u8]) -> Vec<u8> {
    let Ok(css) = std::str::from_utf8(bytes) else {
        return bytes.to_vec();
    };
    let mut out = String::with_capacity(css.len() + 512);
    let mut rest = css;
    while let Some(i) = rest.find("url(") {
        out.push_str(&rest[..i + 4]);
        rest = &rest[i + 4..];
        // Preserve whichever quote style the source used.
        let quote = rest.chars().next().filter(|c| *c == '"' || *c == '\'');
        let after_quote = if quote.is_some() { &rest[1..] } else { rest };
        if let Some(q) = quote {
            out.push(q);
        }
        if after_quote.starts_with('/') {
            out.push_str("/board");
        }
        rest = after_quote;
    }
    out.push_str(rest);
    out.into_bytes()
}
```

It only touches targets beginning with `/`, so relative paths, `data:` URIs and
`https://` URLs pass through unchanged, and it preserves the original quote style. Port
this to whatever language you are serving from — it is about fifteen lines and it is the
difference between a styled board and a page of invisible icons.

The board is also available over SSE (`board_events`), with keep-alive comments roughly
every 15 seconds so SSH tunnels don't idle out. Lagged receivers are allowed to skip,
because each page re-polls on its own cadence anyway.

---

## Agent-driven UI, and its hard limit

`ui_bridge.rs` lets an agent push declarative UI directives into the webview — a `notify`
to say something, or a `prompt` to ask something and await the answer.

The constraint applies to the **agent directive channel** and is stated in the module header:

```
//! UI directives are display/elicitation only — they CANNOT sign. Any action the
```

An agent can ask a human a question. It cannot use a `structs_board.component` directive
to obtain a signature. Do not generalize that into “the whole board is read-only”:
trusted native Team Ops/Terminal handlers and selected bearer-authenticated web-board
routes can sign. Keeping the directive channel separate from those authority-bearing
paths is the relevant boundary — see [SAFETY.md](../../SAFETY.md).

Three further guards worth knowing before you build on it:

- The whole channel is behind an `agent_ui` policy toggle the human controls. Disabled
  means directives are dropped, not queued.
- Rate limiting is a sliding window; excess directives are dropped.
- A `notify` that cannot reach a window degrades to a one-line board entry rather than
  disappearing.

Directives are deduped by `directive_id`, so a repeated push is harmless. Take advantage
of that: retrying is safer than tracking whether the first attempt landed.

---

*Verified against structs-desktop `3f04437d5606d6736df41301bb980893129a7912`:
`src-tauri/src/mcp/handler.rs`, `tools/{board_pages,infusions}.rs`, `web_board.rs`,
`ui_bridge.rs`, `frontend/board.js`, `frontend/board-pages.js`, and harness tests.*
