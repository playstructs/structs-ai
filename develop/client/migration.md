---
title: Migrating a Structs client to v0.22.0
description: "An implementation and acceptance checklist for webapp forks, JavaScript clients, API operators and signing workers adopting Structs v0.22.0."
---

# Migrating a Structs client to v0.22.0

Use this checklist to adapt a client derived from structs-webapp, its PHP API or
JavaScript modules. Existing screens can stay the same: the integration work is in
data interpretation, transaction preparation, authority, completion and refresh.
The linked subsystem pages provide the detailed current contracts.

## Select your adoption scope

| Client | Required work |
|---|---|
| Browser using a shared Guild API | Codecs, message builders, proofs, exact values, response adapters, signing recovery, workers and refresh; verify that server's contract |
| Fork operating its own API | All browser work plus authentication, private-data ownership, API readiness and coherent deployment of PHP and assets |
| Fork operating its own database and indexer | Also deploy the paired Sqitch/writer contracts, complete canonical event coverage and native staking refresh |
| Direct-chain SDK | Release protobufs, native queries, proof bytes, exact numeric values and native inclusion; Guild API field names do not automatically apply |
| TSA/managed-key client | Worker SQL contracts, explicit authority, key inventory, registration proofs and durable submission recovery |

Record the actual chain ID, activation configuration, source revisions, image
identities and schema target for your deployment. The reference testnet is
`structstestnet-111`, with activation at **3,353,000**. Those values are not portable
network defaults. Source availability, a container tag and a document date do not
establish the protocol or readiness of a running service.

The reference application is the `0.22.0-migration` branch at
[`461bba5a5093c42355a8452caee5398092fa249e`](https://github.com/playstructs/structs-webapp/tree/461bba5a5093c42355a8452caee5398092fa249e).
Use an exact revision when adopting it; the branch can continue moving.
The chain source is release `96cea3a322c406b46ca1feb880dc4497ebd9353f`; the paired
schema reference is structs-pg `400e1c1`. These are review identities, not a claim
that those application bytes are published or activated on every guild.

### Implementation order and source map

Start with a read-only client against a disposable or known-compatible API. Adopt
exact values and snapshot validation before enabling writes. Then port the durable
signing lifecycle, action-specific preparation/completion, and refresh/work flows.
Enable an action only after its acceptance cases pass. Regenerated codecs alone
cannot migrate an old primary-address transaction builder.

Paths below are relative to the reference webapp checkout. Port equivalent
contracts if your client has a different architecture; copying these filenames
is not a requirement.

| Contract | Source to inspect together | Acceptance suite under `tools/proto/` |
|---|---|---|
| Exact codecs and values | `tools/proto/generate.cjs`, `src/js/util/MessagePayload.js`, `ExactInteger.js`, generated `src/js/ts/structs.structs/` | `wire`, `query` |
| Readiness and state | `src/js/util/ChainProtocol.js`, `src/js/models/KeyPlayer.js`, `src/js/api/GuildAPI.js`, PHP `ResponseMetaUtil` | `freshness`, `alpha-refresh` |
| Signed lifecycle | `src/js/managers/SigningSubmission.js`, `SigningQueueManager.js`, `TransactionJournal.js`; `src/js/util/SignedSubmission.js` | `submission`, `session`, `startup` |
| Transfer/funding | `TransferPreparation.js`, `VaultFunding.js` in managers; `TransferCompletion.js`, `VaultFundingCompletion.js` in util | `transfer`, `transfer-flow`, `retained-funding` |
| Reactor/generator | `ReactorPreparation.js`, `ReactorSnapshot.js`, `GeneratorPreparation.js`, `GeneratorSnapshot.js` and matching util completion/receipt modules | `reactor`, `reactor-flow`, `generator`, `generator-flow` |
| Device lifecycle | `AuthManager.js`, `DeviceRegistrationStore.js`, registration/device preparation and completion; PHP `PlayerAddressManager` | `registration`, `device-change` |
| Gameplay/work | `GameplayPreparation.js`, `TaskManager.js`, `WorkRefreshManager.js`, `TaskWorker.js`; `SimulatedTaskManager.js` for tutorials | `gameplay`, `work`, `work-recovery`, `tutorial`, `combat` |

The suites use `.test.js` filenames. They are integration examples and regression
fixtures, not substitutes for testing your own adapters against a running stack.

## 1. Adopt codecs and exact values together

Carry the reference client's reproducible protobuf generation, registry, request
schemas and encoding adapters together. Generate from the pinned release and Buf
lock; do not edit generated types by hand. The webapp's `tools/proto/README.md`
documents its `proto:sync`, `proto:check` and `test:proto` commands.

- Preserve int64/uint64 fields as decimal strings through API, queue and journal
  JSON. Use exact arithmetic; reject Numbers that have already lost precision.
- Keep raw units separate from display conversion. Native Coin amounts and
  arbitrary-precision totals do not all have a uint64 limit.
- Apply Cosmos LegacyDec conversion only at the annotated encoding boundary:
  human decimal `0.1` becomes protobuf integer text `100000000000000000`.
  Do not double-scale saved intent or pass human decimals to a raw encoder.
  Decode annotated protobuf query fields with `legacyDecimalFromWire`; LCD JSON
  already carries human decimal text and must not receive that conversion.
- Confirm `MsgVaultSend` and owner selectors survive encoding. Decode signed
  transaction bodies with the release Go types; object properties alone do not
  prove the encoder transmitted them.

See [state and data](state-and-data.md) and [actions and signing](actions-and-signing.md).

## 2. Resolve owners, funds and reactor positions

A player's signing address, primary address and vault are separate identities.
Query the canonical vault and current ownership. The vault query describes its
address/provisioning, not its spendable balance. An unprovisioned recipient can
receive a valid first transfer; missing required evidence is not a reason to debit
its primary address instead.

The reference player response distinguishes exact vault `spendable_alpha_p` from
`available_alpha_p`, which can include verified retained-address funds. Interpret
`retained_funds_meta` and its completeness flag: the bounded source window is not
necessarily the player's entire wealth. Unavailable retained evidence is unknown,
not zero; verified vault funds remain usable.

For a confirmed transfer, reactor infusion or generator infusion:

1. Read vault funds, source ownership, permissions and native spendability at one
   height. Use Player Account funds first.
2. If needed, prepend `MsgPlayerSend` messages collecting only the shortfall from
   eligible retained addresses into that account. Collection needs the signer's
   own TokenTransfer bit, even for an infusion action.
3. Append the intended spend and simulate/sign the complete atomic group. Never
   broadcast a collection prefix separately or sweep in the background.
4. Preserve the signed group through reload and reconcile its actual inclusion.

For example, a confirmed 3 Alpha spend with 2 Alpha in the vault and 5 Alpha
eligible on a retained address collects **1,000,000 ualpha**, then spends
**3,000,000 ualpha** in that same transaction. It does not collect all five Alpha.
A selected-player spend uses `MsgVaultSend` with `ownerId`, `recipientOwnerId`
and `amount: [{denom: 'ualpha', amount: '3000000'}]`; the collection leg is
`MsgPlayerSend` from the freshly verified retained address to the vault. These
are prepared message fields, not complete signed transactions. Creator injection,
authority, simulation and receipt checks still apply.

A selected-player transfer resolves the recipient's vault. A literal external
address receives funds at that exact address. Generator funding follows the same
atomic shortfall rule; its HUD uses stored applied output rather than recalculating
all fuel at the current type rate.

Withdraw reactor stake from the vault position first, then eligible retained
positions in deterministic order, with the correct selector on each leg. Bound
native pagination, query count, messages, encoded size and gas; simulate the entire
withdrawal. Do not split it into partial submissions. Native share rounding can
make the resulting cooldown differ from the requested delta. Matured refunds
return to their originating address and become eligible only after fresh ownership
and spendability checks.

See [player/funds](../../api/webapp/player.md), [reactor positions](../../api/webapp/infusion.md),
[defusion](../../api/webapp/defusion.md) and [struct/generator data](../../api/webapp/struct.md).

## 3. Keep registration consent and signing authority separate

Address registration signs these exact UTF-8 bytes:

```text
CHAIN<chainId>|REGISTERADDRESSPLAYER<playerId>ADDRESS<address>NONCE<nonce>
```

Read the nonce from the native single-address query. It survives revocation and is
separate from account sequence and proxy-join nonce. Sign the unencoded bytes;
URL-encoding for HTTP transport is a separate operation. Login and proxy signup
use their own proof formats. A changed registration context requires fresh consent
from the device holding that key.

Carry the issued `activation_id` UUID through activation-code reads, pending
consent, permission selection and deletion. A reused short code is not the same
activation. Persist the generated key and exact consent context before submission;
reload must recover that identity rather than create another key or transaction.
The reference browser expires abandoned recovery-key records after one hour
when no other tab holds their recovery lock; missing/invalid timestamps also
expire. This removes local private material, not native authority or public
submission evidence. An expired record is not proof that registration failed.
Require committed transaction evidence and the expected native/indexed association
through inclusion. Missing codes, poll timeouts and GRASS messages are not outcomes.

Device permission changes use `MsgPermissionSetOnAddress`. The legacy SQL-edit
endpoint returns 410 with `chain_transaction_required`. Preserve bits absent from
the existing controls and check the signing key's ceiling over both removed and
added permissions. Revocation requires Delete authority and cannot revoke the
primary address. Self-logout without that bit clears the browser key/session;
it does not perform a native revoke. Keep public uncertain-send evidence.

See [authentication](../../api/webapp/auth.md), [device APIs](../../api/webapp/player-address.md)
and [permissions](../../knowledge/mechanics/permissions.md).

## 4. Preserve transaction identity and recover without replay

Adopt the signing queue, preparation/simulation, submission observer and durable
journal as one contract. Store exact bytes, hash, chain/account context and expiry
before broadcast. Same-origin tabs must coordinate; browser Web Locks need a
secure context. HTTP localhost qualifies, public HTTP does not. Test HTTPS/WSS
and actual signing support on your deployment origin.

The reference client prepares signed transactions with a 60-block lifetime.
After expiry, an authoritative not-found result plus a later committed native
snapshot proving the same chain/address/account number and unchanged sequence
can establish a dropped transaction. With that same identity, a proven advanced
sequence can release its reservation without claiming success or failure. Preserve the original identity
and unknown outcome; do not manufacture a replacement send.

Historical records without usable signed identity remain unknown and are never
resent; they do not reserve all future gameplay. Logout must not erase public
uncertain-send evidence. Device-action journals retain referenced submission
records. Unparseable active records are a different case from readable historical unknown
records. The reference Account page offers an explicit set-aside action: copy the
unreadable queue/journal/device-action record unchanged under the quarantine
journal prefix, verify the copy before removal, and reload under the account lock.
Explain that its outcome may still be unknown; never automatically clear storage,
replay its action or claim failure. Keep quarantined copies through logout.

Before writing the broadcasting marker, check that the connection epoch and
signing account still match. A refusal before that marker leaves the intent
provably unsent. An ambiguous error after the marker requires reconciliation.
Queue snapshot writes must preserve other tabs' unseen unsent intents as well as
signed journals. Historical lookups back off from 10 to 600 blocks; active possible
sends keep priority. Reactor/generator preparation also compares the account
sequence at the indexed height with the latest native sequence and defers if they
differ. A generic post-activation payload lacking current-protocol preparation is
a final unsent refusal, not an indefinitely deferred lane head.

A refused enqueue must leave no phantom build or permanently locked action
bar. A definitive transfer rejection returns to the existing confirmation flow
with recipient and amount preserved; uncertain broadcasts are not retry prompts.

CheckTx acceptance is not DeliverTx success. Verify exact signed messages and
required committed events, then wait for ready indexed state through inclusion.
A delayed balance change or notification must never trigger another send.
Transfer and reactor waiting views allow navigation away without cancelling the
transaction. Separate "committed on chain" from "indexed display caught up";
returning to a form must not turn a committed or uncertain send into a retry.

See [actions and signing](actions-and-signing.md) and [ledger identity](../../api/webapp/ledger.md).

## 5. Treat API readiness and authorization as contracts

Use API metadata to verify chain, protocol, contract, indexed height, observed tip,
requested model readiness and native evidence completeness. Keep SQL and native
snapshot heights distinct. Cache keys need chain/protocol/contract identity as well
as entity identity. An unavailable read must not become empty ownership or zero funds.

Guild profiles, directory, rosters and published guild statistics are explicitly
public. Account/device metadata and management remain authenticated and scoped to
the owning player. Session cookies and opaque bearer tokens are distinct from
native authority. An invalid bearer must not silently fall back to a cookie.
Logout uses **POST `/api/auth/logout`** with the current cookie and/or bearer;
GET is not supported. Clear private local state even when logout HTTP fails, while
retaining public uncertain-send evidence. Device `/state` returns 404
`address_not_owned` if either native or indexed ownership identifies another
player. Public `/registration` is a separate, narrower contract. Escape stored
user-agent/OS text before HTML insertion; it remains client-supplied data even
when returned by an authenticated API.

Configure trusted proxies deliberately so registration rate limits see real client
identity rather than placing every user behind a proxy in one bucket. Client keys
normalize IPv4-mapped IPv6 to IPv4 and group other IPv6 addresses by /64. Three
budgets coexist: registration requests, uncached retained-funds windows, and each
outbound read made through `ChainSnapshotManager`. The latter defaults to a
120-token client burst replenished at 12/second and a 480-token global burst at
48/second. Registration rejection is 429 with `Retry-After`; native evidence
exhaustion can instead produce an unavailable field/model or 503. Do not assume
every budget failure is a 429 or interpret it as zero funds.

| Observation | Client response |
|---|---|
| 401/403 private API response | Resolve authentication/ownership; never replace a native send as part of login recovery |
| 429 registration request | Honor `Retry-After`, preserve key/consent and back off |
| `data_ready` true, `transaction_ready` false | Display only what that response proves; wait before signing |
| Native evidence unavailable | Retain uncertainty; independently verified vault funds may still be usable |
| Chain receipt committed, indexed model behind | Keep the receipt/queue ID and retry reads through inclusion |
| Connection lost after send marker | Reconcile the original bytes/hash; do not retry broadcasting |
| Wrong chain/protocol or malformed values | Reject the response rather than borrowing metadata from another request |

See the [Guild API index](../../api/webapp/README.md), [system metadata](../../api/webapp/system.md)
and [guild access](../../api/webapp/guild.md).

## 6. Update work, catalogs and live refresh

Keep exact work difficulty and original on-chain task anchors. Do not restart a
job's age when restoring a worker or changing protocol. Re-evaluate rules and
current type catalogs against authoritative state. Deploy the matching worker
protocol, parent bundle and hashed assets together.

GRASS is a notification channel without replay. Reconcile after reconnect and use
notifications to wake authoritative reads. Process ordered combat counter/rebound
information without letting final destruction flags suppress an emitted counter.
Only emit a funds-changed event for changed values or readiness, not solely an
advancing read height. Keep a valid generator preview during routine background
refresh, but re-read before submission and discard it on protocol/session change.
Use cancellable reads with backoff rather than a tight loop while readable state
is not yet signable. `PollUntil` starts at two seconds and doubles to 30 seconds;
GRASS may wake a read early, but it cannot supply the outcome.

Keep tutorial work isolated in `SimulatedTaskManager`; its simulated clocks and
lack of native evidence are not exceptions for the real `TaskManager`.
Use final canonical health/state after animations; do not treat aggregate balance
deltas or notifications as transaction receipts.

See [proof-of-work](work-and-pow.md), [GRASS](realtime-grass.md) and
[event integration notes](../../api/integration-notes.md).

## 7. Prepare your backend, if you operate one

Follow the [Guild Stack](../../knowledge/infrastructure/guild-stack.md) and
[database contracts](../../knowledge/infrastructure/database-schema.md). Deploy
canonical schema through Sqitch with the matching writer. The selected migration
target can stop before the image's tip; repeated successful verification of that
staging target does not certify complete activation. Keep denomination-aware
ledger identity, ordered event positions, contiguous coverage and native claims
consistent with the canonical cursor. Never lower a cursor over newer state or
invent coverage to satisfy a guard.

Fence writers for a coordinated switch. Preserve application/signing rows, keys,
leases, uncertain transaction history, sequences, role attributes, role memberships,
role/database defaults (including search paths), and operator configuration.
Rehearse restoration and test actual restricted-role HTTP reads. Row counts alone
cannot detect a missing role default that breaks an unqualified SQL query.

The stock PHP deployment is **one webapp replica**. Sessions, bearer revocation,
onboarding/rate limits, retained caches and locks require coordinated shared
storage before scaling out; changing only the lock DSN is insufficient. Configure
`STRUCTS_LCD_URL` for injected native snapshot reads. Treat it as a scoped endpoint
setting: inspect any manually constructed native clients too; it does not configure
browser RPC/GRASS or make a different chain supported. Use the reference
[`docker/deployment.md`](https://github.com/playstructs/structs-webapp/blob/461bba5a5093c42355a8452caee5398092fa249e/docker/deployment.md)
for proxy/session requirements. Set `SYMFONY_TRUSTED_PROXIES` to actual controlled
proxy addresses and `SYMFONY_TRUSTED_HEADERS` to the headers they manage. A TLS
Apache virtual host needs its own `AllowEncodedSlashes NoDecode`; the port-80
virtual-host directive is not inherited on port 443.

TSA uses its dedicated database login and versioned guarded worker APIs. Reconcile
local key inventory into SQL without promoting uncertain registrations. Manual new
keys require explicit masks; automatic pool growth copies an eligible same-role
grant, with a 40-key role limit. Role creation stays manual. Preserve key-volume
and database submission evidence together.

## 8. Reproduce the checks in your client

Run these from the reference checkout root, or adapt them to your fork's layout:

```bash
npm ci --prefix src
npm ci --prefix tools/proto --ignore-scripts
npm --prefix src run proto:check -- --source /path/to/structsd
npm --prefix src run test:proto
node tools/assets/test.cjs
```

The supplied chain checkout must contain release commit `96cea3a`; the generator
reads that exact commit, not its working-tree edits. The proto suite performs
TypeScript checks and discovers all `tools/proto/*.test.js` suites. Its runner
reports failures across suites and rejects a main promise that never settles.
These tests include offline signatures and controlled RPC fixtures; they do not
prove a live node accepted your fork's signed transaction.

Use `tools/proto/verify-release.cjs` with a generated signed fixture for independent
Go decoding/signature checks. The gameplay, reactor and generator release verifiers
exercise the pinned native app separately. Follow their README for fixture outputs;
never substitute a locally edited chain for release verification.

For PHP, follow `tools/api/README.md` and run `node tools/api/php-integration.cjs`
against a **labelled disposable PG fixture** with the required Sqitch target.
The runner restores its own `webapp_test_*` clone, requires its disposable marker,
runs with `--fail-on-skipped`, and removes that clone. An ordinary PHPUnit run that
skips database tests is not acceptance. Do not point destructive test setup at the
live guild database or relabel a live container as a fixture. HTTP runners test
Apache/proxy routing and restricted SQL roles; build and select your candidate
image with `STRUCTS_PHP_TEST_IMAGE` or `STRUCTS_WEBAPP_TEST_IMAGE` as documented.
A tag alone does not establish that the image's schema prerequisites are applied.

Finish with real browser cases from `tools/browser/README.md`: login, two tabs,
reload, dropped/uncertain sends, device activation, retained funding, generator
funding, reactor cooldown and worker completion. Keep fixture outputs outside the
checkout. Record the actual source/image/schema/origin and failures; do not copy
the reference client's test counts as evidence for your fork.

### Local development and packaging

From the **mounted** `src/` directory, `npm run dev` watches and `npm run build`
performs one production build. Both write the manifest and hashed chunks used by
the running container. Refresh the browser to load the new entry; no image rebuild
or restart is needed with that bind mount. A separate Git worktree has different
files and does not update the mounted checkout. Verify Docker's `/src` mount and
the page's actual script URL if changes do not appear. Do not restore an unversioned
bundle fallback; it breaks the parent/worker pairing.

## 9. Acceptance checklist

- [ ] Exact large-value JSON/codec round trips and independent release decoding.
- [ ] Vault transfer, literal-address transfer, retained shortfall collection,
  generator funding and bounded vault-first reactor withdrawal.
- [ ] Native cooldown/refund maturity, share rounding and incomplete evidence.
- [ ] Registration, nonce reuse protection, revoke/re-register, permission changes,
  local logout and private metadata ownership.
- [ ] Dropped sends, consumed sequences, historical unknown records, reload,
  two tabs, API/RPC outage and missed/duplicate notifications without replay.
- [ ] Work restored with its original anchor, stale workers/catalogs, and ordered
  combat counter/rebound handling.
- [ ] Matching PHP/templates, manifest, application bundles and worker chunks;
  retain older immutable chunks for still-open pages. A source bind mount must
  have its own matching build because it hides image assets.
- [ ] Running schema target, coverage, API readiness and real PG → GRASS → browser
  block delivery; test backend restoration as well as a clean install.
- [ ] Public-origin HTTPS/WSS, proxy identity and real browser signing checks.
- [ ] POST logout, foreign-device refusal, escaped device metadata, IPv6/proxy
  rate limits and partial native-read exhaustion.
- [ ] Other-tab queued-intent preservation, connection change before the send
  marker, explicit corrupt-state recovery and abandoned recovery-key expiry.
- [ ] Confirmed-but-not-indexed waiting states remain navigable without replay;
  background reads do not reset input or misreport an unchanged balance.
- [ ] Record human review, artifact distribution and deployment decisions separately.

*Reviewed adoption contracts against webapp `0.22.0-migration` at `461bba5a`:
source diff from `bde1cec8`, current funding/protocol/queue/device modules,
PHP auth/read budgets, build configuration and test runners. Linked subsystem
pages retain their own verification scope. Structsd is pinned to v0.22.0 and
structs-pg to `400e1c1`. This is not acceptance of a third party's deployment.*
