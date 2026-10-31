---
description: "Exact proof difficulty, observed-height workers, original anchors, current work snapshots, and durable completion transactions."
---

# Work and proof-of-work

The browser hashes current authoritative work with its original chain anchor.
Finding a hash and confirming its completion transaction are separate lifecycles.
This page describes integration `581fcd0f`; protocol rules come from structsd release
`96cea3a`. See [hashing](../../knowledge/mechanics/hashing.md) for the CLI/mechanics.

## The hash

Use one SHA-256 pass over the exact UTF-8 input and a lowercase hex digest:

```text
{structId}{BUILD|MINE|REFINE}{originalBlockStart}NONCE{nonce}
{fleetId}@{planetId}RAID{originalBlockStart}NONCE{nonce}
```

The braces and choice bars are notation, not bytes. There are no other separators.
`TaskStateFactory` preserves exact start/difficulty strings and builds the prefix;
postfix is empty. Examples for nonce `42` are `5-1BUILD3352900NONCE42`,
`5-2MINE3352900NONCE42`, `5-3REFINE3352900NONCE42` and
`9-1@2-10RAID3352900NONCE42`.

`js-sha256` runs in a dedicated worker. Nonces begin at a random offset; workers do
not partition ranges. A digest's leading zero count is checked against the required
number of hexadecimal zeroes. Before submission, recompute the hash from the expected
identity/prefix and nonce, not a worker's claimed result alone.

## Difficulty decays, so waiting is cheaper than working

For observed age `a` and difficulty range `r`, v0.22 uses integer arithmetic:

```text
if a <= 1 or r <= 1: difficulty = 64
otherwise: difficulty = 64 - max{k in [0,63] : r^k <= a^63}
```

`integerWorkDifficulty` uses BigInt and at most 63 products, matching the release's
`CalculateDifficulty`. Do not use floating logarithms for eligibility: a boundary
rounding difference can change the required leading-zero count.

`workDifficultyAtHeight` chooses the configured rule using an observed chain height.
It refuses a zero anchor or a height before the anchor. The scheduled testnet boundary
is `3353000`; a task started before it keeps that same original start height while
adopting current difficulty rules and current type data. Resetting the anchor to the
upgrade height creates a different proof input.

The wall-clock estimate (nominal six-second blocks) is for progress/ETA only. It cannot
wake a waiting worker or make its proof eligible. Block/rule messages supply the
checkpoint used by `getCurrentDifficulty()`.

### The idle policy

The browser waits until difficulty is at most 10, unless explicitly forced. That is
a CPU policy, not a chain requirement: ten leading hex zeroes take roughly 2^40
attempts in expectation. The CLI guidance uses `-D 3` for lower compute cost. Neither
setting changes native verification.

## The worker loop

The worker hashes at most 4096 candidates per batch, yields to process messages,
and schedules another batch with MessageChannel. This avoids nested `setTimeout(0)` clamping while still allowing control messages between batches. This bounds how long a height/rule/cancellation update
waits behind hashing. It publishes progress every five million iterations and on
important state changes. A previously found candidate is reusable only if its hash
still satisfies the current observed-height rule.

`TaskProcess` and `TaskWorker` exchange `version: "work-v022-1"`, a monotonically
increasing revision, and `start`/`update` messages. A wrong-version reply fails the
worker; no handshake within ten seconds does too. Replies from replaced workers or
older revisions cannot replace current task state or submit a proof.

### Same object, new rules

The process ID is the object ID, so process existence alone does not establish that
its work is current. Full identity includes object, category, raid target, original
anchor and prefix. When only rules or observed height change, update the same worker
and preserve its searched nonces/candidate. Reject older rule snapshots. When the
work identity changes, replace the worker; a late reply from the old one is ignored.

The manager caps active processes at five and starts after the existing eight-second
startup delay. These controls and progress displays remain unchanged.

### Ore clocks and raids

Mining/refining anchors belong to the planet. Each eligible extractor/refinery gets
its own struct-bound proof using the shared anchor. Native-chain notifications prompt
a fresh scoped work read; their unversioned values do not replace the API anchor.
A complete accepted snapshot determines which structs still have work.

An incoming raid stops local mine/refine hashing. The manager reconciles after the
raid using current clocks/work; it does not reassign a new start height based on the
browser's receive time. Raid completion work also depends on the target's shield
state. A work removal can discard a local candidate, but never its signed journal.

## Restoring after a reload

`GET /api/work/player/{id}` supplies the ready `work` projection and coherent source
metadata. `WorkFactory` validates owner, category, object/raid-target identity and
exact uint64 anchor/difficulty strings. Empty complete snapshots retain metadata and
can authorize removals; a failed or incomplete read cannot.

Partial hashing progress is not durably saved, so an unsent search restarts. A queued
or signed completion is different: `WorkSubmission` matches its expected object,
category, raid target and original anchor through the actual proof hash. For a signed
submission it decodes the durable bytes, which outrank a mutable saved payload.
Reattach the observer to that queue ID instead of generating another completion.

`WorkRefreshManager` periodically refreshes catalog and work, including reconnect,
resume and activation boundaries. Older/conflicting snapshots and responses for a
replaced player/session are refused. Existing type-object references update in place
so open controls see the new catalog without a new UI.

## Completion

| Work | Native message | Fields after creator injection |
|---|---|---|
| Build | `MsgStructBuildComplete` | `structId`, `proof`, `nonce` |
| Mine | `MsgStructOreMinerComplete` | `structId`, `proof`, `nonce` |
| Refine | `MsgStructOreRefineryComplete` | `structId`, `proof`, `nonce` |
| Raid | `MsgPlanetRaidComplete` | `fleetId`, `proof`, `nonce` |

Proof and nonce are strings. Raid target remains bound by the proof input and current
fleet state even though the completion message carries no separate target field.
These reviewed gameplay intents use the immediate queue lane and exact signed
simulation before sending.

A successful committed completion suppresses hashing of the same stale work. An
unknown send only reconciles its original transaction. A definitive failure permits
another automatic hashing attempt only after a newer complete work snapshot. If
storage or queue pressure prevents enqueueing, the unsent completed candidate remains
in memory for a later block; it is not silently reported as submitted.

The view's observer can be cancelled without cancelling a send. Logout stops workers,
clears observers and closes the session boundary while retaining signed transaction
evidence. Tutorial work uses the separate `SimulatedTaskManager`: it takes work
from `TutorialWorld`, has no native journal to reconcile and applies simulated ore
clocks directly. These rules cannot be enabled on the live `TaskManager` or used
as evidence that a native proof completed.

## Deployment and verification

Production HTML selects the fingerprinted application bundle through its asset
manifest; that bundle references its fingerprinted worker chunk. Deploy matching
assets together and retain needed old hashed assets for already-open pages. The
version/revision handshake prevents an incompatible worker from submitting results;
a reload alone is not proof that all tabs adopted the new application.

The source suites cover exact integer boundaries, same-process rule changes, old
worker replies, original anchors, stale work, unknown/failed/committed submissions,
and logout. Native release fixtures and rendered isolated build/tutorial checks are
separate evidence. Keep those distinctions when reporting client acceptance.

*Verified against webapp `581fcd0f`: TaskManager, TaskProcess, TaskState,
TaskStateFactory, TaskWorker, WorkFactory, WorkDifficulty, WorkSubmission,
WorkRefreshManager and TaskConstants. Integer eligibility cross-checked directly
against release `x/structs/types/work.go`; no chain checkout was modified.*

*Scoped follow-up at `461bba5a`: tutorial task behavior is separated into `SimulatedTaskManager`; the live work/worker contract above remains required.*
