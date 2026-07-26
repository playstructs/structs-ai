#!/usr/bin/env python3
"""Runnability lint for documented `structsd` invocations.

`lint-commands.sh` validates command *names*. This validates that a documented
invocation would actually parse, which is a different failure mode: a command
with the right name but the wrong argument count, or with `--` in the wrong
place, fails at the CLI before it ever reaches the chain.

Three hard gates:

  ARITY     positional-argument count must match the binary's Usage line.
  ORDER     `--` must come after flags, never before them. pflag stops parsing
            flags at `--`, so `... -- 0-1 1 --from key` passes `--from` and
            `key` as *positional args* and the command dies with
            "accepts N arg(s), received M". Verified empirically on v0.20.0.
  GAS       every `tx` invocation needs `--gas auto` (AGENTS.md rule 6).

Coverage matters as much as the gates. Commands are documented in three shapes —
fenced code blocks, markdown table cells, and inline prose — and the skills use
the last two almost exclusively. Scanning only line-start text (and truncating
at the first `|`) therefore checked roughly nothing in the files agents actually
execute from, while still reporting OK. See `candidates()`.

Reads generated/structsd-signatures.txt so it needs no structsd binary in CI.
Regenerate that snapshot with scripts/ci/snapshot-commands.sh.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SIGS = ROOT / "generated" / "structsd-signatures.txt"

# Matched against path components relative to ROOT. `skills/` is excluded via
# MIRROR_DIR instead: it is a path *component* that also occurs in
# `.cursor/skills/`, and matching it here silently exempted every canonical
# skill file — the primary command surface — from this lint.
SKIP_DIRS = {".references", ".git", "archive", "node_modules", ".review"}
SKIP_FILES = {"CHANGELOG.md", "BASELINE.md"}
# Generated mirror of .cursor/skills/; lint the source, not the copy.
MIRROR_DIR = "skills"

# Flags that consume the following token as their value.
FLAGS_WITH_VALUE = {
    "--from", "--gas", "--gas-adjustment", "--fees", "--gas-prices", "--chain-id",
    "--node", "--keyring-backend", "--output", "-o", "--broadcast-mode", "-b",
    "--home", "--sequence", "-s", "--account-number", "-a", "--note",
    "--allocation-type", "--controller", "--fee-granter", "--fee-payer",
    "-D", "--difficulty",
}
# conventions.md macros.
MACROS = {
    "TX_FLAGS_APPROVED": "--from k --gas auto --gas-adjustment 1.5 -y",
    "TX_FLAGS": "--from k --gas auto --gas-adjustment 1.5",
}
# Args a Usage line marks as optional, so a shorter invocation is still valid.
OPTIONAL_ARGS = {("tx", "planet-explore"): 1}


def load_signatures():
    if not SIGS.exists():
        sys.exit(f"error: {SIGS.relative_to(ROOT)} missing. "
                 f"Run scripts/ci/snapshot-commands.sh")
    sigs = {}
    for line in SIGS.read_text().splitlines():
        if line.startswith("#") or not line.strip():
            continue
        parts = line.split("\t")
        if len(parts) < 2:
            continue
        kind, cmd = parts[0], parts[1]
        args = parts[2] if len(parts) > 2 else ""
        sigs[(kind, cmd)] = re.findall(r"\[([^\]]+)\]", args)
    return sigs


def positionals(rest):
    """Positional args, honouring `--` and flag/value pairs."""
    toks = rest.split()
    out, i = [], 0
    while i < len(toks):
        t = toks[i]
        if t == "--":
            out.extend(toks[i + 1:])
            break
        if t.startswith("-"):
            if "=" not in t and t in FLAGS_WITH_VALUE and i + 1 < len(toks):
                i += 2
                continue
            i += 1
            continue
        out.append(t)
        i += 1
    return out


INVOCATION = re.compile(r"^structsd\s+(tx|query)\s+structs\s+([a-z][a-z0-9-]*)(.*)$")
# Skills often write the bare subcommand: `provider-withdraw-balance TX_FLAGS -- [id]`.
BARE = re.compile(r"^([a-z][a-z0-9-]*)(\s+(?:TX_FLAGS\w*|--)\s*.*)$")


def candidates(raw):
    """Every invocation on a line: whole-line, and each backtick-quoted span.

    Commands are documented in three shapes — fenced blocks (line-start), table
    cells, and inline prose. Only the first starts the line, and a table row
    starts with `|`, so scanning the raw line alone misses the other two.
    """
    out = []
    line = raw.strip().lstrip("$").strip()
    if line.startswith("structsd"):
        out.append((line, False))
    for span in re.findall(r"`([^`]+)`", raw):
        span = span.strip().lstrip("$").strip()
        if span.startswith("structsd") or BARE.match(span):
            out.append((span, True))
    return out


def main():
    sigs = load_signatures()
    findings = []

    for f in sorted(ROOT.rglob("*.md")):
        rel = f.relative_to(ROOT)
        if any(p in SKIP_DIRS for p in rel.parts) or f.name in SKIP_FILES:
            continue
        if rel.parts and rel.parts[0] == MIRROR_DIR:
            continue
        for lineno, raw in enumerate(f.read_text().splitlines(), 1):
            # Line continuations are out of scope.
            if raw.rstrip().endswith("\\"):
                continue
            for s, inline in candidates(raw):
                # `\|` is a markdown-escaped alternation list, not one command.
                if "\\|" in s:
                    continue
                s = re.sub(r"\s+#.*$", "", s)
                # Only a *spaced* pipe is a shell pipeline; `static|dynamic` is
                # an alternation inside a placeholder and must survive.
                s = re.sub(r"\s+\|.*$", "", s).strip()

                m = INVOCATION.match(s)
                if m:
                    kind, cmd, rest = m.groups()
                    if (kind, cmd) not in sigs:
                        continue
                else:
                    m = BARE.match(s)
                    if not m:
                        continue
                    cmd, rest = m.group(1), m.group(2)
                    kind = next((k for k in ("tx", "query") if (k, cmd) in sigs), None)
                    if kind is None:
                        continue
                if "..." in rest:
                    continue
                # An inline mention with no args is prose citing a command name,
                # not an invocation someone is meant to run verbatim.
                if inline and not rest.strip():
                    continue

                findings.extend(check(sigs, kind, cmd, rest, rel, lineno, s))

    for rel, lineno, issue, s in findings:
        print(f"{rel}:{lineno}: {issue}\n    {s}")

    if findings:
        print(f"\nFAIL: {len(findings)} unrunnable invocation(s)")
        return 1
    print("OK: all documented structsd invocations parse (arity, -- order, --gas auto)")
    return 0


def check(sigs, kind, cmd, rest, rel, lineno, s):
    """ARITY / ORDER / GAS for one invocation. Returns a list of findings."""
    found = []
    expanded = rest
    for macro, exp in MACROS.items():
        expanded = expanded.replace(macro, exp)

    # ORDER: `--` before a flag means the flag becomes a positional.
    if " -- " in expanded:
        after = expanded.split(" -- ", 1)[1]
        stray = [t for t in after.split() if t.startswith("-") and len(t) > 1]
        if stray:
            return [(rel, lineno,
                     f"[{cmd}] `--` precedes {stray[0]} — pflag will treat it "
                     f"as a positional arg, not a flag", s)]

    want = sigs[(kind, cmd)]
    got = positionals(expanded)
    lo = len(want) - OPTIONAL_ARGS.get((kind, cmd), 0)
    if not (lo <= len(got) <= len(want)):
        found.append((rel, lineno,
                      f"[{cmd}] takes {len(want)} positional arg(s) "
                      f"{want}, got {len(got)} {got}", s))

    # A bare subcommand cited inline carries no flags of its own, so only a
    # full `structsd tx ...` line can be judged on --gas auto.
    if (kind == "tx" and s.startswith("structsd")
            and "--gas auto" not in expanded and "--gas=auto" not in expanded):
        found.append((rel, lineno, f"[{cmd}] missing `--gas auto`", s))

    return found


if __name__ == "__main__":
    sys.exit(main())
