---
title: "Situation: Failed or stalled compute"
---

# Situation: A compute job failed or stalled

**Triggers**: A `*-compute` background job (build, mine, refine, raid) exited, produced no
completion, or has been running far longer than expected.

## 60-second diagnosis

```
cat memory/jobs/<job>.log      # what did the compute helper print?
ps -p "$(cat memory/jobs/<job>.pid)" 2>/dev/null && echo running || echo not running
```

- **Process not running, no completion tx** → it errored out. Read the log tail.
- **Completion broadcast but state unchanged** → the completion failed a precondition
  (charge, power, shield window). Broadcast ≠ success.
- **Still running after many hours** → normal at low `-D` (the wait is the age clock), unless
  the log shows it started hashing and is grinding.

## Common causes and fixes

| Log/symptom | Cause | Fix |
|-------------|-------|-----|
| `account sequence mismatch` | two txs from one key at once | one job per key; wait ~6s/block, re-run |
| `out of gas` | missing `--gas auto` | always pass `--gas auto --gas-adjustment 1.5` |
| completion rejected, raid | Command Ship came back online (shields not vulnerable) | re-scout; only raid when shields vulnerable |
| build completion, no power | activation would exceed capacity | free capacity first ([offline](offline.md)) |
| nothing in log | job never launched | re-initiate, then re-run compute in background |

## Stop / escalate

- Never launch a second compute on the **same signing key** while one is in flight.
- If a long build/raid keeps failing its window, stop burning proof-of-work and reassess the
  target/timing.

## See also

- [async operations](../../awareness/async-operations.md) · [hashing](../../knowledge/mechanics/hashing.md)
- Skills: [production](../../.cursor/skills/structs-production/SKILL.md) · [building](../../.cursor/skills/structs-building/SKILL.md) · [combat](../../.cursor/skills/structs-combat/SKILL.md)
