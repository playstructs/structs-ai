# Commander

The human who deployed you, if one exists. Some agents are autonomous. Some serve a commander. Either is fine.

If you have a commander, learn about them. Update this as you go.

---

**Name:**
**What to call them:**
**Timezone:**
**Communication style:** *(brief? detailed? casual? formal?)*

---

## Directives

*(What does your commander want from you? Strategic goals, constraints, preferences.)*

- Primary objective:
- Risk tolerance: *(conservative / moderate / aggressive)*
- Autonomy level: *(ask before acting / act and report / full autonomy)*
- Resources allocated:

---

## Standing Orders

*(Persistent instructions that carry across sessions. See [SAFETY.md](SAFETY.md) for Tier definitions and the trust contract.)*

### Tier 1 (Significant) auto-approval caps

These are the limits inside which the agent may act without per-action approval. Above them, escalate.

- `reactor-infuse`: up to ___ ualpha per session
- `agreement-open`: up to ___ ualpha total committed at any time
- `struct-build-initiate`: up to ___ new builds per session
- `struct-attack`: only against targets in the known-hostile list below
- Long-PoW builds (> 1 hr to D=3): require per-build approval

### Tier 2 (Irreversible / Identity) — always escalate

The agent must never auto-execute these, regardless of autonomy level:

- Every `struct-generator-infuse`
- Every `permission-grant-on-object` with `PermAll` (33554431)
- Every `permission-guild-rank-set` with broad bits (16777216, 524288, 262144)
- Every `address-register`, `address-revoke`, `player-update-primary-address`
- Every `guild-bank-confiscate-and-burn`
- Every `reactor-defuse` and `reactor-begin-migration`
- Every `provider-delete`, `substation-delete`, `allocation-delete`
- Cross-account `player-send` to a recipient with no prior history
- Multi-target `struct-attack` that crosses guild boundaries

### Known-hostile targets

*(Player IDs or guild IDs against which routine combat is pre-approved.)*

### Forbidden

*(Examples: "Do not attack guild-mate planets." "Do not infuse generators on planets with shield < 1000." "Do not run more than 2 concurrent background expeditions.")*

---

## Notes

*(Anything else you've learned about working with your commander.)*

---

*If you don't have a commander, you are your own commander. Fill this in for yourself.*
