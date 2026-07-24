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

Reads generated/structsd-signatures.txt so it needs no structsd binary in CI.
Regenerate that snapshot with scripts/ci/snapshot-commands.sh.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SIGS = ROOT / "generated" / "structsd-signatures.txt"

SKIP_DIRS = {".references", ".git", "archive", "node_modules", "skills", ".review"}
SKIP_FILES = {"CHANGELOG.md", "BASELINE.md"}

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


def main():
    sigs = load_signatures()
    findings = []

    for f in sorted(ROOT.rglob("*.md")):
        if any(p in SKIP_DIRS for p in f.parts) or f.name in SKIP_FILES:
            continue
        rel = f.relative_to(ROOT)
        for lineno, raw in enumerate(f.read_text().splitlines(), 1):
            s = raw.strip().lstrip("$").strip()
            # Line continuations and pipelines are out of scope.
            if s.endswith("\\"):
                continue
            s = re.sub(r"\s+#.*$", "", s)
            s = re.sub(r"\s*\|.*$", "", s)
            m = re.match(r"^structsd\s+(tx|query)\s+structs\s+([a-z][a-z0-9-]*)(.*)$", s)
            if not m:
                continue
            kind, cmd, rest = m.groups()
            if "..." in rest or (kind, cmd) not in sigs:
                continue

            expanded = rest
            for macro, exp in MACROS.items():
                expanded = expanded.replace(macro, exp)

            # ORDER: `--` before a flag means the flag becomes a positional.
            if " -- " in expanded:
                after = expanded.split(" -- ", 1)[1]
                stray = [t for t in after.split() if t.startswith("-") and len(t) > 1]
                if stray:
                    findings.append((rel, lineno,
                                     f"[{cmd}] `--` precedes {stray[0]} — pflag will treat it "
                                     f"as a positional arg, not a flag", s))
                    continue

            want = sigs[(kind, cmd)]
            got = positionals(expanded)
            lo = len(want) - OPTIONAL_ARGS.get((kind, cmd), 0)
            if not (lo <= len(got) <= len(want)):
                findings.append((rel, lineno,
                                 f"[{cmd}] takes {len(want)} positional arg(s) "
                                 f"{want}, got {len(got)} {got}", s))

            if kind == "tx" and "--gas auto" not in expanded and "--gas=auto" not in expanded:
                findings.append((rel, lineno, f"[{cmd}] missing `--gas auto`", s))

    for rel, lineno, issue, s in findings:
        print(f"{rel}:{lineno}: {issue}\n    {s}")

    if findings:
        print(f"\nFAIL: {len(findings)} unrunnable invocation(s)")
        return 1
    print("OK: all documented structsd invocations parse (arity, -- order, --gas auto)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
