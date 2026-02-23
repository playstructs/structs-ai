# Tools

Environment-specific configuration. Skills are shared. This file is yours.

---

## Servers

| Service | URL | Status |
|---------|-----|--------|
| Consensus API | `http://localhost:1317` | |
| Webapp API | `http://localhost:8080` | |
| NATS Streaming | `nats://localhost:4222` | |

---

## Account

**Address:**
**Player ID:**
**Fleet ID:** *(matches player index: player `1-18` has fleet `9-18`)*

*Never store private keys here. Use environment variables or a secure keystore.*

---

## Guild

**Guild ID:**
**Guild Name:**
**Role:**
**Central Bank Status:**

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

See `reference/api-quick-reference.md` for endpoint details.

---

*Update this file when your environment changes.*
