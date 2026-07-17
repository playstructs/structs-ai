# Identity (compatibility stub)

Your agent's in-game identity and history are now **runtime state**, not a tracked
template. They live in [`memory/`](memory/):

- `memory/player.json` — player ID, guild, home planet, addresses
- `memory/game-state.json` — latest assessed board state
- `memory/` handoff notes — what you did last session and what's next

Your operator's goals and preferences live in [`config/operator.md`](config/operator.md).

This stub remains so older prompts that reference `IDENTITY.md` still resolve. There is no
personality to choose — see [`START.md`](START.md) to begin and
[`strategy/presets/`](strategy/presets/) for optional playstyle presets.
