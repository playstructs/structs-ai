---
title: structs:// MCP resource map
permalink: /develop/structs-resources
---

# `structs://` MCP resource map (resync notes)

Structs Desktop bundles this repo as MCP resources. This page documents how the URIs are
derived and what changed in the documentation redesign, so integrators and cached agents can
resync.

## How URIs are derived (no hardcoding)

Desktop scans the synced compendium tree and builds one URI per `*.md` file:

```
structs://<relative-path-from-compendium-root>
```

(see `structs-desktop/src-tauri/src/mcp/resources.rs`). It hardcodes **no** paths — after a
`make sync`, `resources/list` returns whatever files exist. So the redesign required **no
code change** in Desktop; URIs simply track the file tree.

## What changed

- **New entry + navigation** (new URIs): `structs://START.md`, `structs://play/index.md`,
  `structs://reference/index.md`, `structs://strategy/index.md`, `structs://develop/index.md`,
  `structs://lore/index.md`, `structs://config/operator.example.md`,
  `structs://strategy/presets/README.md`, plus new situation cards under
  `structs://playbooks/situations/` and `structs://play/errors.md`.
- **Retired ceremony** (now compatibility stubs, still resolvable):
  `structs://SOUL.md`, `structs://QUICKSTART.md`, `structs://IDENTITY.md`,
  `structs://COMMANDER.md`, `structs://USER.md` now return short "moved" pointers instead of
  personality/identity content. `structs://identity/souls/index.md` points to the presets.
- **Stable content** kept its paths this pass: mechanics, entities, economy, lore, playbooks,
  awareness, api, schemas URIs are unchanged, so existing cached URIs still resolve directly.

## Resync guidance

1. Run `make sync` in `structs-desktop` to refresh the compendium from `structs-ai`.
2. Re-run `resources/list` to pick up the new URIs; drop any cached references to soul/identity
   ceremony content and prefer `structs://START.md` and `structs://play/index.md`.
3. Illustrative URIs in docs (e.g. Desktop's README examples) should reference current pages
   such as `structs://reference/index.md` or `structs://START.md`.

For the human/agent-facing interface catalog see [`../TOOLS.md`](../TOOLS.md) and
[`../knowledge/infrastructure/structs-desktop.md`](../knowledge/infrastructure/structs-desktop.md).
