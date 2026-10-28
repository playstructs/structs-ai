---
description: The review cycle that stops the build docs drifting from the code they describe, and the prompt to run it with.
---

# Keeping the develop docs true

**Purpose**: Review cycles that stop the UI/client, Guild Stack, and Desktop docs from
drifting away from the code they describe.

These pages make specific, checkable claims about a codebase that keeps moving. Any
document like that is wrong eventually. The question is whether it is wrong *knowably*.

---

## The contract

**`structs-webapp` is the source of truth.** Every page in `develop/ui/` and
`develop/client/` is written from it at the revision recorded in
[`.structs-webapp-version`](https://github.com/playstructs/structs-ai/blob/main/.structs-webapp-version), and each page's footer names the
commit it was verified against. When a page and the code disagree, the page is wrong.

Two artifacts hold the line:

| Artifact | Role |
|---|---|
| [`generated/sui-inventory.md`](https://github.com/playstructs/structs-ai/blob/main/generated/sui-inventory.md) | Machine-extracted tokens, icons, classes, modifiers and breakpoints. Both the writing source and the drift baseline |
| [`scripts/check-webapp-drift.sh`](https://github.com/playstructs/structs-ai/blob/main/scripts/check-webapp-drift.sh) | Diffs a fresh extract against that baseline, and lists commits per watched directory |

A weekly GitHub Actions job (`.github/workflows/drift.yml`) runs the check and posts the
report to the run summary. It is **advisory** — `continue-on-error: true` — because
upstream moving is normal and should never fail a build. It exists to make drift visible,
not to gate on it.

---

## The weekly review

Ten minutes when nothing has changed; longer when the report has something to say.

```bash
# 1. Refresh the checkout and see what moved.
git -C .references/structs-webapp fetch
scripts/check-webapp-drift.sh --fetch
```

The report has two halves. **Inventory** changes are mechanical: a token renamed, an icon
added, a class removed. **Commit surface** is judgement: it names watched directories with
new commits and the pages that depend on them, because a behaviour change in
`SigningQueueManager.js` will never show up in a CSS diff.

```bash
# 2. If clean, you're done.
#    If not, read what actually changed in the pages' subject areas.
git -C .references/structs-webapp log --oneline <pinned-sha>..HEAD -- src/js/sui

# 3. Re-verify the affected claims against source, then refresh the baseline.
scripts/gen-sui-inventory.sh

# 4. Bump .structs-webapp-version and the "Verified against" footers together.
```

Step 4 is the one that gets skipped. **A footer claiming a revision the page was not
re-verified against is worse than a stale footer**, because it converts "possibly old"
into "certified current" without anyone having done the certifying. If you refresh the
inventory but do not re-read the affected prose, say so in the commit message and leave
the footers alone.

### The prompt

Paste this into an agent session with the repository open:

> Review `develop/ui/` and `develop/client/` against the current `structs-webapp`.
>
> 1. Run `scripts/check-webapp-drift.sh --fetch` and read the report.
> 2. For every watched directory with commits since the pin, read the actual diff — not
>    just the commit subjects — and decide whether it changes a claim any of these pages
>    makes. Most commits won't.
> 3. For each claim that did change: fix the page, and verify the fix against source
>    rather than against the commit message.
> 4. Pay particular attention to the things these pages assert precisely, because they
>    are the things most likely to have quietly moved: the fee constant and gas limit,
>    the charge formula, the proof-of-work input string format and difficulty constants,
>    the GRASS port and subject patterns, the PFP layer counts, the pagination slot
>    logic, and the upstream-defects table in `develop/ui/gotchas.md` — a defect that has
>    been fixed upstream must be removed, not left as a warning about a problem that no
>    longer exists.
> 5. Run `scripts/gen-sui-inventory.sh`, then update `.structs-webapp-version` and every
>    "Verified against" footer **only for pages you actually re-verified**.
> 6. Run `bash scripts/ci/check-links.sh` and report what you changed and what you chose
>    not to.
>
> `structs-webapp` is authoritative. If it contradicts these pages, the pages are wrong.

---

## structsd release review

A chain release moves more than the UI ever does: CLI verbs appear and disappear, catalog
numbers change, and whole mechanics (how Alpha is held, how guilds are founded) can be
replaced. The drift script catches the first kind; only reading the release catches the rest.

```bash
# 1. Pin the new tag and refresh the generated truth.
git -C .references/structsd fetch --tags && git -C .references/structsd checkout vX.Y.Z
echo vX.Y.Z > .structsd-version
scripts/ci/snapshot-commands.sh      # generated/structsd-commands.txt, structsd-signatures.txt
python3 scripts/gen-catalogs.py      # generated/commands.md, struct-types.md
scripts/check-drift.sh

# 2. Read the release, not the diff summary.
#    docs/upgrades/vX.Y.Z*.md, proto/structs/structs/{tx,query,events}.proto,
#    x/structs/types/{keys,errors,errors_structured,permission}.go, app/ante/errors.go,
#    and every keeper handler the upgrade notes name.

# 3. Removed verbs go into scripts/ci/deprecated-tokens.txt so the lint fails on them.
bash scripts/ci/lint-commands.sh
python3 scripts/ci/check-invocations.py
```

Then work outward from the skills: `.cursor/skills/*` first (they are what agents execute),
then `knowledge/`, then `api/`, `schemas/`, `reference/`, `play/errors.md`, and last the
top-level pages, `SAFETY.md` tiers and the playbooks. For each page, write the new release
as **the current state** — no "previously", no "as of vX.Y.Z" banners. The only page that
narrates before and after is `CHANGELOG.md`.

Things that have moved in past releases and are worth checking by name every time: the
charge costs in `struct-types`, build difficulties, the proof-of-work input strings and
the integer difficulty formula, which messages the ante treats as charge/proof/recovery,
the permission bit table and the composite masks, the `address-register` proof string,
where refined Alpha lands, what `guild-create` costs and checks, the substation capacity
formula, the pagination limits, and the event catalog (`events.proto` vs the emit sites —
an event that exists in proto but is never emitted belongs in the "not emitted" table).

Finish with `scripts/gen-skills-mirror.sh`, `scripts/generate-llms-full.sh`, the three lint
scripts, and `bash scripts/ci/check-links.sh`.

---

## PostgreSQL and Guild Stack review

Treat a `structs-pg` update as a co-versioned schema review, not a migration-name review:

1. Pull `structs-pg`, then read every new `deploy/`, matching `verify/`, and handoff file.
2. Compare `view.*` row shapes, `api_*` read models, attribution functions, signer
   wrappers, and migration guards against
   [database-schema.md](../knowledge/infrastructure/database-schema.md),
   [schemas/database-schema.md](../schemas/database-schema.md), and the webapp API pages.
3. Read the matching `structs-sync-state` and `structs-webapp` code for any guard that
   requires a new writer/refresher or query strategy. Schema deployment order is part of
   the contract.
4. Run the upstream verify scripts against a compatible disposable Guild Stack when
   available. If no database is available, state that limitation; source review is not a
   live migration rehearsal.

Pay special attention to JSON event paths, precision/display helpers, materialized read
models, compression policies, and columns that moved between entity scopes.

## Structs Desktop review

The Desktop runtime contract is its current source and advertised MCP schemas:

1. Pull `structs-desktop`; inspect changes under `src-tauri/src/mcp/`, `frontend/`, and
   the webapp/compendium submodule pins.
2. Diff `tools/list` and `prompts/list` descriptions against
   [TOOLS.md](../TOOLS.md), [structs-desktop.md](../knowledge/infrastructure/structs-desktop.md),
   [SAFETY.md](../SAFETY.md), and canonical skills under `.cursor/skills/`.
3. Reverify automation defaults and safety gates from implementation, not README prose.
   Native signing, source-selection knobs, and trusted board routes change the custody
   boundary even when the tool count is unchanged.
4. Run targeted Rust/harness tests and, when a current app is available, compare the
   live MCP schemas. Record any assets/submodules that prevented the full suite.

Desktop may bundle an older `structs-ai` submodule than the workspace. Document current
Desktop behavior from Desktop source, then regenerate this repository's mirrors/bundles;
do not treat the bundled compendium as an independent authority.

---

## When you find an upstream defect

[`develop/ui/gotchas.md`](ui/gotchas.md#known-upstream-defects) carries a table of real
bugs in SUI, with workarounds. That table is a liability if it is only ever appended to.

**Report it upstream, then document the workaround.** A defect documented here and never
reported becomes permanent: every future reader works around it, and nobody fixes it.
Opening an issue on the relevant repository costs a few minutes and is the only path by
which the table ever gets shorter.

Each row should be removable. When a fix lands upstream, delete the row and the
corresponding block in [`examples/sui-patch.css`](ui/examples/sui-patch.css) — a patch
that overrides a bug which no longer exists is a new bug.

Distinguish a **defect** from a **choice** before you file anything. `body { text-align:
center }` looks like a bug from a dashboard author's chair and is a deliberate decision
for the game's short HUD strings. That belongs in gotchas as a surprise to work with, not
as something to report. `SUIOffcanvas.setPlacement` removing the class it is about to add
is unambiguously a bug.

---

## Verifying a claim

The standard these pages are held to, in order of what counts:

1. **Read the code.** Not the comment above it, not the commit that added it.
2. **Prefer mechanical extraction** where a script can do the reading. That is what
   `gen-sui-inventory.sh` is for, and why counts like "68 glyph icons" are trustworthy.
3. **Distinguish the three kinds of claim.** A *mechanical* claim (a constant, a class
   name, a count) is verifiable from source and must be exact. A *behavioural* claim
   (the stepper only binds at init) is verifiable by reading the logic. A *judgement*
   (don't overuse `sui-mod-solid`) is neither, and should read as advice rather than
   fact.
4. **Say what you could not verify.** An honest gap is more useful than a confident
   guess, and it tells the next reviewer where to look.

That last one applies to reports from other agents too. Several claims that reached these
pages arrived via field reports and subagent research; every mechanical one was re-checked
against source before it was written down, and a few did not survive. Treat any report as
a hypothesis worth testing, not as a finding.

---

## Related

- [scripts/BASELINE.md](https://github.com/playstructs/structs-ai/blob/main/scripts/BASELINE.md) — the maintainer-facing record of every
  contract in this repository, including this one
- [develop/repos.md](repos.md) — the hierarchy of truth across all Structs repositories
