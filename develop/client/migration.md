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

The reference application is `bde1cec8`; `5e10d9d2` adds test instructions/fixtures.
The chain source is release `96cea3a322c406b46ca1feb880dc4497ebd9353f`; the paired
schema reference is structs-pg `400e1c1`. These are review identities, not a claim
that those application bytes are published or activated on every guild.

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
After expiry, an authoritative not-found result plus unchanged account sequence
can establish a dropped transaction. An advanced native sequence can release its
reservation without claiming success or failure. Preserve the original identity
and unknown outcome; do not manufacture a replacement send.

Historical records without usable signed identity remain unknown and are never
resent; they do not reserve all future gameplay. Logout must not erase public
uncertain-send evidence. Device-action journals retain referenced submission
records. A refused enqueue must leave no phantom build or permanently locked action
bar. A definitive transfer rejection returns to the existing confirmation flow
with recipient and amount preserved; uncertain broadcasts are not retry prompts.

CheckTx acceptance is not DeliverTx success. Verify exact signed messages and
required committed events, then wait for ready indexed state through inclusion.
A delayed balance change or notification must never trigger another send.

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
Configure trusted proxies deliberately so registration rate limits see real client
identity rather than placing every user behind a proxy in one bucket.

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

TSA uses its dedicated database login and versioned guarded worker APIs. Reconcile
local key inventory into SQL without promoting uncertain registrations. Manual new
keys require explicit masks; automatic pool growth copies an eligible same-role
grant, with a 40-key role limit. Role creation stays manual. Preserve key-volume
and database submission evidence together.

## 8. Acceptance checklist

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
- [ ] Record human review, artifact distribution and deployment decisions separately.

*Integration checklist assembled from the scoped source reviews recorded in the
linked references: webapp application `bde1cec8` / test HEAD `5e10d9d2`, structsd
v0.22.0 and structs-pg `400e1c1`. Those pages retain their own verification scope.
A local HTTP smoke check is not acceptance of a third party's deployment.*
