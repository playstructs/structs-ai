---
title: Codex Crosswalk
permalink: /reference/codex-crosswalk/
---

# Codex Crosswalk

**Purpose**: Map terms from the human-facing [Structs Codex](https://www.playstructs.com/codex) to the canonical mechanics/API pages in this repository, so an agent that meets a Codex word (in a UI, a guide, or a human's message) can jump straight to the page that owns the rule.
**Codex snapshot**: 2026-07-23 · **Docs baseline**: `structsd v0.20.0`

---

## What this page is (and isn't)

The [Codex](https://www.playstructs.com/codex) is the **human** documentation: a glossary, lore entries, and how-to-play guides. This repo is the **agent** documentation: source-verified mechanics, numbers, and API shapes.

**Authority rule.** The Codex is canonical for **lore, naming, and story**; this repo is canonical for **mechanics, numbers, and API**. This crosswalk lists only **resolved, non-conflicting** mappings — a finder, not a source of truth. When a value or rule matters, follow the link and read the canonical page.

> This page deliberately **excludes** anything still under reconciliation (open lore differences and any numeric claim not yet source-verified). It is additive only.

---

## Terminology bridge (Codex term → canonical page)

| Codex term | This repo calls it | Canonical page |
|---|---|---|
| Battlegrounds (Land/Water/Air/Space) | Ambit | [combat.md — Ambit Targeting](../knowledge/mechanics/combat.md#ambit-targeting) |
| Battery | Charge (per-player) | [building.md — Charge Accumulation](../knowledge/mechanics/building.md#charge-accumulation) |
| Ballistic Weapons | Unguided weapons | [combat.md — Weapon Control vs Defense Type](../knowledge/mechanics/combat.md#weapon-control-vs-defense-type) |
| Smart Weapons | Guided weapons | [combat.md — Weapon Control vs Defense Type](../knowledge/mechanics/combat.md#weapon-control-vs-defense-type) |
| Signal Jamming | Signal Jamming (unit defense; same term) | [combat.md — Weapon Control vs Defense Type](../knowledge/mechanics/combat.md#weapon-control-vs-defense-type) |
| Counter-Attack | Counter-attack (same term) | [combat.md — Counter-Attack](../knowledge/mechanics/combat.md#counter-attack) |
| Defend / Defender / Block | Defender / Block (same terms) | [combat.md — Assigning Defenders](../knowledge/mechanics/combat.md#assigning-defenders-struct-defense-set) |
| Alpha Ore | Ore (`storedOre` / `remainingOre`, stealable) | [resources.md](../knowledge/mechanics/resources.md) |
| Alpha Matter (refined) | Alpha Matter (secure, same term) | [resources.md](../knowledge/mechanics/resources.md) |
| Alpha Base | A player's planet + base structs | [planet.md](../knowledge/mechanics/planet.md) |
| CMD Ship | Command Ship | [combat.md — Struct Destruction](../knowledge/mechanics/combat.md#struct-destruction) |
| Alpha Drift | Moving the Command Ship between ambits (`struct-move`) | [combat.md — Command Ship Ambit Mobility](../knowledge/mechanics/combat.md#command-ship-ambit-mobility) |
| Breach | Raid completion PoW on a vulnerable planet | [combat.md — What a raid does](../knowledge/mechanics/combat.md#what-a-raid-does) |
| Planetary Defenses "Secure" / "Vulnerable" | Planetary shield / `shieldsVulnerable` | [combat.md — Raid Phases and SHIELDS_VULNERABLE](../knowledge/mechanics/combat.md#raid-phases-and-shields_vulnerable) |

## Struct designations (Codex flavor name → struct)

The Codex gives each struct an in-fiction model name. Mechanically they are the entries in the [struct type catalog](../knowledge/entities/struct-types.md).

| Codex designation | Struct |
|---|---|
| ST-21 "Spearpoint" | Command Ship (type 1) |
| CH-51 "Chimera" (missile) | Command Ship primary weapon |
| LS-0 "Laser Sword" | Ore Extractor |
| GR-3 "Greybox" | Ore Refinery |

## Interface-only terms (no chain/CLI equivalent)

These name parts of the human client UI. Agents act through transactions and queries, not this UI, so they have **no** CLI or chain counterpart — do not treat them as mechanics.

| Codex UI term | What it is |
|---|---|
| Action Bar | Expandable panel to inspect a tile/Struct and issue commands |
| Action Buttons | Buttons that deploy or command Structs (the `struct-*` actions) |
| Property Screen | On-screen readout of a Struct's status/passive abilities (agents read `struct_attribute` / `struct_type`) |
| Power Switch | Toggle to activate/deactivate a Struct (`struct-activate` / `struct-deactivate`) |
| Battery Level (bars) | On-screen charge display. The **bars are a UI scale, not the raw charge value** — do not equate a bar with a charge cost. |

## Lore cross-links (Codex canonical)

The Codex owns the galaxy's story. These entries are background flavor for systems this repo documents mechanically — read the Codex for the fiction, this repo for the rules.

| Codex lore | Related mechanics here |
|---|---|
| [Alpha Matter](https://www.playstructs.com/lore-entries/alpha-matter) · [Space Distortion Field](https://www.playstructs.com/lore-entries/space-distortion-field) | [resources.md](../knowledge/mechanics/resources.md) — ore vs Alpha, security model |
| [Alpha Relay Web](https://www.playstructs.com/lore-entries/alpha-relay-web) | [energy.md](../knowledge/mechanics/energy.md), [energy-market.md](../knowledge/economy/energy-market.md) — capacity transfer, agreements |
| [Space Distortion Drive / Alpha Drive](https://www.playstructs.com/lore-entries/space-distortion-drive) | [fleet.md](../knowledge/mechanics/fleet.md) — fleet movement; underpins "Alpha Drift" above |
| [Alpha Base](https://www.playstructs.com/lore-entries/alpha-base) · [ST-21 "Spearpoint"](https://www.playstructs.com/lore-entries/command-ship) | [planet.md](../knowledge/mechanics/planet.md), [struct-types.md](../knowledge/entities/struct-types.md) |

---

## Read the Codex

- Codex home: <https://www.playstructs.com/codex>
- How to Play guides: `https://www.playstructs.com/how-to-play/<topic>` (e.g. `battlegrounds`, `weapon-types`, `raids-offense`, `raids-defense`, `battery`)
- Lore entries: `https://www.playstructs.com/lore-entries/<entry>` (e.g. `alpha-star-council`, `first-contact`, `hoag-incident`)

## See also

- [glossary.md](glossary.md) — the term-by-term finder these mappings feed into
- [reference/index.md](index.md) — the reference hub
- [knowledge/lore/index.md](../knowledge/lore/index.md) — this repo's lore pages
