# The Structs repositories

**Purpose**: Which repository to read for what, and which one wins when they disagree.

All under [github.com/playstructs](https://github.com/playstructs).

---

## The hierarchy of truth

When two sources conflict — and they do — resolve in this order:

1. **[structsd](https://github.com/playstructs/structsd)** for chain rules. What the
   validator accepts is not negotiable.
2. **[structs-webapp](https://github.com/playstructs/structs-webapp)** for the design
   system and client behaviour. It is what the game is actually played through.
3. **[structs-desktop](https://github.com/playstructs/structs-desktop)** for
   agent-facing and desktop-specific patterns.
4. **[structs-ui](https://github.com/playstructs/structs-ui)** for illustrative markup
   only. It is years behind.

Everything in `develop/ui/` and `develop/client/` is written from source at a pinned
revision, recorded in `.structs-webapp-version` and cited at the foot of each page.

---

## structsd — the chain

The Cosmos SDK application. Go, module at `x/structs/`.

Read it when you need to know what the chain *actually enforces*: message handlers in
`x/structs/keeper/msg_server_*.go`, the proof-of-work validator in
`x/structs/types/work.go`, permission bits, and the event definitions that become GRASS
messages.

Install: [structsd-install skill](../.cursor/skills/structsd-install/SKILL.md).

## structs-webapp — the flagship client

Symfony 7.2 backend, custom vanilla-JS MVVM frontend, Webpack. This is the canonical
source for two separate things, and it is worth being clear which is which.

**The SUI design system** lives in `src/public/css/sui/sui.css`,
`src/public/css/structicons.css`, `src/js/sui/`, and the fonts and art under
`src/public/fonts/` and `src/public/img/`. Documented in [develop/ui/](ui/index.md).

**The reference client** lives in `src/js/` — signing queue, proof-of-work workers, GRASS
listeners, game state, map. Documented in [develop/client/](client/index.md).

Layout worth knowing:

```
src/
  public/css/sui/sui.css        the design system
  public/css/structicons.css    glyph icon font
  public/img/sui/               component art (checkboxes, panels, battery)
  js/sui/                       the four optional SUI behaviours
  js/framework/                 MenuPage, router, GrassManager, base classes
  js/managers/                  wallet, signing, tasks, auth, raid, struct
  js/grass_listeners/           26 real-time listeners
  js/view_models/               pages and components
  js/factories/                 JSON to model
  js/workers/TaskWorker.js      proof-of-work
  js/ts/structs.structs/        generated protobuf types and registry
  src/                          Symfony PHP: API controllers, auth, managers
```

## structs-desktop — Tauri app and embedded MCP

Rust backend hosting an MCP server, plus a SUI-based Team Ops board in a webview. The
primary agent interface. Extending it: [develop/client/desktop-extensions.md](client/desktop-extensions.md).
Using it: [TOOLS.md](../TOOLS.md).

## structs-pg — the guild database

PostgreSQL schema and views backing the Guild API. Read it when you need query shapes or
want to understand where a REST field comes from.
See [knowledge/infrastructure/database-schema.md](../knowledge/infrastructure/database-schema.md)
and the [guild-stack skill](../.cursor/skills/structs-guild-stack/SKILL.md).

## structs-grass — the event fan-out

NATS-based real-time event distribution. Client side:
[develop/client/realtime-grass.md](client/realtime-grass.md). Event catalogue:
[api/streaming](../api/streaming/event-types.md).

## structs-ui — the published gallery

Serves <https://structs.design>. A single `index.html` with sections for icons, messages,
panels, screens, text and the cheatsheet.

**Treat it as illustrative, not authoritative.** Its last commit is June 2024. Its
`sui.css` is 2,323 lines against the webapp's 2,701, and it is missing `SUIOffcanvas` and
`SUICheatsheet` entirely. It is genuinely useful for seeing components rendered and for
copying markup shapes — just verify anything you take from it against the webapp before
relying on it.

---

## Working with these locally

The docs assume checkouts under `.references/`:

```bash
mkdir -p .references && cd .references
git clone --depth 50 https://github.com/playstructs/structs-webapp.git
git clone --depth 50 https://github.com/playstructs/structs-desktop.git
git clone --depth 50 https://github.com/playstructs/structsd.git
git clone --depth 50 https://github.com/playstructs/structs-pg.git
git clone --depth 50 https://github.com/playstructs/structs-ui.git
```

`.references/` is git-ignored. The documentation tooling reads `structs-webapp` from
there by default, overridable with `STRUCTS_WEBAPP`:

```bash
scripts/gen-sui-inventory.sh      # extract the SUI ground truth
scripts/check-webapp-drift.sh     # what changed upstream since the pin
```

See [develop/maintenance.md](maintenance.md) for the review cycle these support.
