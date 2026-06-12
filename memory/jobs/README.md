# Background Jobs

One set of files per long-running proof-of-work compute (mine ~17h, refine ~34h, large builds, raids). These are **expeditions** — they run unattended and auto-submit a completion transaction when their proof lands.

Each job leaves three files:

- `<job>.json` — structured record (schema in [`../README.md`](../README.md#jobs--background-proof-of-work-jobs))
- `<job>.log` — captured stdout/stderr
- `<job>.pid` — process ID

Launch template (one transaction per account at a time):

```bash
nohup structsd tx structs struct-ore-mine-compute -D 3 TX_FLAGS_APPROVED -- 14-5 \
  > memory/jobs/mine-14-5.log 2>&1 & echo $! > memory/jobs/mine-14-5.pid
```

Naming: `<type>-<structId>` (e.g. `mine-14-5`, `refine-15-5`, `build-22-3`, `raid-2-117`).

**On resume, check this directory first.** Use `scripts/job-status.sh` or walk the four-state reconnect flow in [`awareness/async-operations.md`](../../awareness/async-operations.md#reconnecting-to-a-long-job): is the PID alive, did it land on chain, does on-chain state match expectation, and if not — diagnose the silent failure.

This directory is intentionally tracked with only this README; your `.json`/`.log`/`.pid` files are created at runtime.
