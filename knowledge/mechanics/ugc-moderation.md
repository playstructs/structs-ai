# UGC and Decentralized Moderation

**Purpose**: Explain how user-generated content (names and profile pictures) works in Structs, why it is moderated by guilds rather than by a global authority, and what the chain validates before it accepts anything.

---

## What "UGC" means in Structs

Five things on chain accept player-supplied identity:

| Object | Field | Transaction(s) |
|--------|-------|----------------|
| Player | `name` (a.k.a. username) | `MsgPlayerUpdateName` |
| Player | `pfp` (profile picture) | `MsgPlayerUpdatePfp` |
| Guild | `name` | `MsgGuildUpdateName` |
| Guild | `pfp` | `MsgGuildUpdatePfp` |
| Planet | `name` | `MsgPlanetUpdateName` |
| Substation | `name` | `MsgSubstationUpdateName` |
| Substation | `pfp` | `MsgSubstationUpdatePfp` |

These are the only mutable identity fields under the chain's control. Everything else (struct types, planet coordinates, ore type, etc.) is system-generated and not user-editable.

---

## Why moderation is decentralized

Structs is permissionless. Anyone can create a player, anyone can create a guild, and anyone can name themselves whatever passes the chain's structural validators (see below). The chain deliberately does **not** maintain a global blacklist of "bad" names, a global allowlist of approved pfps, or a moderator role with cross-guild authority. There is no Structs admin who can rename your player.

Instead, the chain ships:

1. **Strict structural validators** that every name and pfp must pass on every update. These reject the categories of input most likely to break a UI or be used for impersonation/spoofing -- invalid UTF-8, combining marks (Zalgo), bidi overrides, zero-width characters, names that look like object IDs, and pfp values pointing at unsafe URI schemes. Structural validation is policy-neutral: it does not care whether the resulting string is "appropriate", only that it can be safely displayed.
2. **A guild-scoped moderation permission** (`PermGuildUGCUpdate`, bit 24, value `16777216`) that lets guilds rewrite the names and pfps of objects owned by their own members. Each guild decides who holds it and what standards trigger its use.
3. **An auditable moderation event** (`ugc_moderated`) that the chain emits whenever a UGC update is performed by someone other than the target's owner. Members and outside observers can watch this stream to understand how a guild moderates.

Different communities want different things:

- A competitive PvP guild may tolerate edgy in-character names because those names are the conflict. They never grant the moderation bit and never override anyone.
- A family-friendly mining co-op may require strict, descriptive names. They rank-grant `PermGuildUGCUpdate` to officers and treat moderation overrides as routine.
- A chaos-RP guild may forbid moderators from touching names entirely as a community pact, and any override triggers social consequences inside the guild.
- A guild can also moderate the names of guild-owned **planets** and **substations**, giving them shared, branded infrastructure.

The chain does not decide which model is correct. It gives each guild the bit to flip and the audit log to argue over.

Players who don't like a particular guild's moderation policy can leave the guild. When they do, the guild loses its `PermGuildUGCUpdate` reach into their identity (the check requires the target to be owned by a guild member). This makes moderation reach a feature of guild membership, not a property of the player.

---

## How the permission check works

UGC updates on player, planet, and substation objects route through the `UGCPermissionCheck` helper in the keeper. The flow is:

1. Try `PermissionCheck(target, actor, PermUpdate)`. Owners pass automatically because ownership grants every permission, so this is the **self-service** path: players can rename themselves; planet owners can rename their planets; substation owners can rename their substations.
2. If self-service fails, find the target object's owner. If the owner has no guild, deny.
3. Otherwise, run `PermissionCheck(ownerGuild, actor, PermGuildUGCUpdate)`. This is the **guild moderation** path: anyone who has been granted `PermGuildUGCUpdate` on that guild (directly or via a guild rank register entry) can rewrite the target's name/pfp.

`MsgGuildUpdateName` and `MsgGuildUpdatePfp` use the standard `PermissionCheck(guild, actor, PermUpdate)` flow instead -- there is no "moderate the guild itself" hook. Renaming a guild requires `PermUpdate` (4) on that guild, which the owner has automatically and which can be granted to others by direct grant or rank register.

See `knowledge/mechanics/permissions.md#ugc-permission-check-ugcpermissioncheck` for the full code reference.

---

## The `ugc_moderated` event

Whenever the actor of a UGC update is not the target object's owner, the chain emits a Cosmos `sdk.Event` of type `ugc_moderated`. Self-service updates (where the actor IS the owner) do **not** emit this event -- they're indistinguishable from any other normal update.

Attributes:

| Key | Description |
|-----|-------------|
| `actor_player_id` | Player ID of the moderator who performed the update |
| `actor_address` | The signing address that authored the tx |
| `target_object_id` | Object ID being moderated (player ID, planet ID, substation ID, or guild ID) |
| `target_owner_player_id` | Player ID of the target's owner at the time of the update |
| `field` | `name` or `pfp` |
| `old_value` | The string the field held before this update |
| `new_value` | The string the field now holds |

The event is untyped (it uses `sdk.NewEvent`, not a typed protobuf event). Watch for it via Tendermint event subscriptions or by tailing block events. The PostgreSQL Guild Stack also surfaces the resulting `player_meta` / `guild_meta` UPDATEs as `player_meta` and `guild_meta` GRASS categories; planet and substation UGC changes surface only via the chain event for now.

---

## Validation rules (the parts the chain enforces)

All inputs are NFC-normalized before any structural check, so visually-equivalent strings collapse to the same form. Strings are then run through a small ladder of rejections.

### Rejected globally

These rejections apply to **every** name and pfp regardless of object type:

- Invalid UTF-8.
- Combining marks (Unicode categories `Mn` non-spacing or `Me` enclosing). This blocks Zalgo / stacked-diacritic abuse.
- Bidi/format/zero-width runes: `U+202A..U+202E` (LRE/RLE/PDF/LRO/RLO), `U+2066..U+2069` (LRI/RLI/FSI/PDI), `U+200B..U+200D` (ZWSP/ZWNJ/ZWJ), `U+2060` (word joiner), `U+00AD` (soft hyphen), `U+FEFF` (BOM), and any rune in category `Cf` (format) or `Cs` (surrogate).

These three checks are shared by `ValidatePlayerName`, `ValidateEntityName`, `ValidatePlanetName`, and `ValidatePfp`.

### Names

Player, entity (guild/substation), and planet names share a structural shape but differ in length and allowed characters.

| Rule | Player | Entity (guild/substation) | Planet |
|------|--------|---------------------------|--------|
| Length (runes after NFC) | 3-20 | 3-20 | 3-25 |
| Letters (any script) `\p{L}` | yes | yes | yes |
| Digits `0-9` | yes | yes | yes |
| `-` `_` | yes | yes | yes |
| Space ` ` | no | yes (no leading/trailing, no double) | yes (no leading/trailing, no double) |
| Apostrophe `'` | no | yes | yes |
| Combining marks | rejected | rejected | rejected |
| Bidi/zero-width/format | rejected | rejected | rejected |
| Looks like object id (matches `^[0-9]+-[0-9]+$`) | rejected | rejected | rejected |
| Invalid UTF-8 | rejected | rejected | rejected |

The full regex (after NFC normalization and the rejections above):

```text
playerNameRegex = ^[\p{L}0-9\-_]{3,20}$
entityNameRegex = ^[\p{L}0-9\-_' ]{3,20}$
planetNameRegex = ^[\p{L}0-9\-_' ]{3,25}$
```

The "looks like object id" rule rejects strings such as `1-2`, `4-99`, `12345-67` so that names cannot impersonate the chain's `{type}-{seq}` ID format anywhere it might be displayed.

### Pfps

Pfps are optional. The empty string clears the field. Non-empty values may either be opaque content identifiers (no `:`) or URLs in a strictly limited scheme set.

Shared rejections (apply to any non-empty pfp):

- More than 256 runes (`MaxPfpLength`).
- Invalid UTF-8.
- Any control character in `0x00..0x1F` or `0x7F`.
- Bidi/zero-width/format runes (same set as names).
- Any of these characters anywhere in the string: `<`, `>`, `` ` ``, `"`, `\`, or whitespace (space, tab, newline, etc.).

Then exactly one of the two paths must be satisfied:

**Path A -- opaque identifier (no `:` in the string).** Must match:

```text
opaquePfpRegex = ^[a-zA-Z0-9._/\-]{1,256}$
```

This is the path for content-addressed identifiers (CIDs, asset hashes, Arweave tx IDs without scheme, etc.) where the renderer knows how to resolve them.

**Path B -- URL (contains `:`).** The substring before the first `:` (case-insensitive) must be one of:

```text
https | http | ipfs | ipns | ar
```

Anything else (`data:`, `javascript:`, `vbscript:`, `file:`, `ftp:`, `gopher:`, ...) is rejected before parsing. The remainder must then `url.Parse` successfully and:

- For `https` and `http`: `Host` must be non-empty.
- For `ipfs`, `ipns`, `ar`: at least one of `Host`, `Opaque`, or `Path` must be non-empty (so `ipfs://CID`, `ipfs:CID`, and `ipfs:/CID` all work).

The scheme allow-list is intentionally narrow. Renderers in the webapp and other clients can hard-code support for these schemes without worrying about legacy or dangerous handlers.

### Name uniqueness comparison

Two names are considered the same for uniqueness purposes when their `NormalizeName` form matches. The chain's `NormalizeName` function applies, in order:

1. NFC normalization
2. ASCII lowercasing
3. Trim leading/trailing whitespace

Any uniqueness index (for example, the guild name index) MUST key off this form, so that case tricks (`MyGuild` vs `myguild`) and surrounding-whitespace tricks cannot be used to register a near-duplicate.

---

## Reference validator snippets

These are intentionally faithful translations of the on-chain Go validators. They are useful as preflight in clients (the webapp's `SigningClientManager` runs equivalent checks) so that bad input gets rejected locally with a clear error before paying the round-trip cost of a tx submission.

### Python

This snippet uses the third-party [`regex`](https://pypi.org/project/regex/) package because Python's stdlib `re` does not support Unicode property escapes (`\p{L}`). Install with `pip install regex`.

```python
import unicodedata
from urllib.parse import urlparse
import regex  # third-party, supports \p{L}

PLAYER_NAME_RE = regex.compile(r"^[\p{L}0-9\-_]{3,20}$")
ENTITY_NAME_RE = regex.compile(r"^[\p{L}0-9\-_' ]{3,20}$")
PLANET_NAME_RE = regex.compile(r"^[\p{L}0-9\-_' ]{3,25}$")
OPAQUE_PFP_RE  = regex.compile(r"^[A-Za-z0-9._/\-]{1,256}$")
OBJECT_ID_RE   = regex.compile(r"^[0-9]+-[0-9]+$")

ALLOWED_SCHEMES = {"https", "http", "ipfs", "ipns", "ar"}
INVISIBLE = {0x202A, 0x202B, 0x202C, 0x202D, 0x202E,
             0x2066, 0x2067, 0x2068, 0x2069,
             0x200B, 0x200C, 0x200D, 0x2060,
             0x00AD, 0xFEFF}
MAX_PFP_LEN = 256


def _normalize_and_check(s: str) -> str:
    try:
        s.encode("utf-8")
    except UnicodeEncodeError as e:
        raise ValueError("invalid UTF-8") from e
    s = unicodedata.normalize("NFC", s)
    for r in s:
        cp = ord(r)
        cat = unicodedata.category(r)
        if cat in ("Mn", "Me"):
            raise ValueError("name contains combining marks (Zalgo)")
        if cat in ("Cf", "Cs") or cp in INVISIBLE:
            raise ValueError("name contains bidi/zero-width/format characters")
    return s


def _check_relaxed(s: str) -> None:
    if s.startswith(" ") or s.endswith(" "):
        raise ValueError("name cannot have leading or trailing spaces")
    if "  " in s:
        raise ValueError("name cannot contain consecutive spaces")


def validate_player_name(name: str) -> str:
    s = _normalize_and_check(name)
    if OBJECT_ID_RE.match(s):
        raise ValueError("name cannot resemble an object ID")
    if not PLAYER_NAME_RE.match(s):
        raise ValueError("player name must be 3-20 chars of letters/digits/-/_")
    return s


def validate_entity_name(name: str) -> str:
    s = _normalize_and_check(name)
    if OBJECT_ID_RE.match(s):
        raise ValueError("name cannot resemble an object ID")
    _check_relaxed(s)
    if not ENTITY_NAME_RE.match(s):
        raise ValueError("entity name must be 3-20 chars of letters/digits/-/_/'/space")
    return s


def validate_planet_name(name: str) -> str:
    s = _normalize_and_check(name)
    if OBJECT_ID_RE.match(s):
        raise ValueError("name cannot resemble an object ID")
    _check_relaxed(s)
    if not PLANET_NAME_RE.match(s):
        raise ValueError("planet name must be 3-25 chars of letters/digits/-/_/'/space")
    return s


def validate_pfp(pfp: str) -> str:
    if pfp == "":
        return pfp
    if len(pfp) > MAX_PFP_LEN:
        raise ValueError(f"pfp must be at most {MAX_PFP_LEN} characters")
    try:
        pfp.encode("utf-8")
    except UnicodeEncodeError as e:
        raise ValueError("pfp contains invalid UTF-8") from e
    for r in pfp:
        cp = ord(r)
        if cp < 0x20 or cp == 0x7F:
            raise ValueError(f"pfp contains forbidden control character (0x{cp:02X})")
        if cp in INVISIBLE or unicodedata.category(r) in ("Cf", "Cs"):
            raise ValueError("pfp contains bidi/zero-width/format characters")
    if any(c in pfp for c in "<>`\"\\ \t\n\r\f\v"):
        raise ValueError("pfp must not contain <, >, backtick, quote, backslash, or whitespace")

    if ":" not in pfp:
        if not OPAQUE_PFP_RE.match(pfp):
            raise ValueError("opaque pfp must match [A-Za-z0-9._/-]{1,256}")
        return pfp

    scheme = pfp.split(":", 1)[0].lower()
    if scheme not in ALLOWED_SCHEMES:
        raise ValueError(f"pfp URL scheme {scheme!r} is not allowed")
    u = urlparse(pfp)
    if scheme in ("https", "http") and not u.netloc:
        raise ValueError(f"pfp {scheme} URL must include a host")
    if scheme in ("ipfs", "ipns", "ar") and not (u.netloc or u.path):
        raise ValueError(f"pfp {scheme} URL must include a content identifier")
    return pfp
```

> Note: this matches the Go validators in `x/structs/types/ugc.go` rule-for-rule. If you copy it into a client, also mirror the chain's `NormalizeName` (NFC + lowercase + trim) for any uniqueness comparison you perform locally.

### JavaScript

```js
const INVISIBLE = new Set([
  0x202A, 0x202B, 0x202C, 0x202D, 0x202E,
  0x2066, 0x2067, 0x2068, 0x2069,
  0x200B, 0x200C, 0x200D, 0x2060,
  0x00AD, 0xFEFF,
]);

const PLAYER_NAME = /^[\p{L}0-9\-_]{3,20}$/u;
const ENTITY_NAME = /^[\p{L}0-9\-_' ]{3,20}$/u;
const PLANET_NAME = /^[\p{L}0-9\-_' ]{3,25}$/u;
const OBJECT_ID   = /^[0-9]+-[0-9]+$/;
const OPAQUE_PFP  = /^[A-Za-z0-9._/\-]{1,256}$/;
const ALLOWED_SCHEMES = new Set(["https", "http", "ipfs", "ipns", "ar"]);

function normalizeAndCheck(s) {
  s = s.normalize("NFC");
  for (const r of s) {
    const cp = r.codePointAt(0);
    if (INVISIBLE.has(cp)) throw new Error("invisible character");
    // Combining marks and format/surrogate categories require a Unicode tables
    // library (e.g. unicode-properties). The webapp uses a thin wrapper.
  }
  return s;
}

export function validatePlayerName(name) {
  const s = normalizeAndCheck(name);
  if (OBJECT_ID.test(s)) throw new Error("name cannot resemble an object ID");
  if (!PLAYER_NAME.test(s)) throw new Error("player name 3-20 letters/digits/-/_");
  return s;
}

export function validateEntityName(name) {
  const s = normalizeAndCheck(name);
  if (OBJECT_ID.test(s)) throw new Error("name cannot resemble an object ID");
  if (s.startsWith(" ") || s.endsWith(" ")) throw new Error("no leading/trailing space");
  if (s.includes("  ")) throw new Error("no double space");
  if (!ENTITY_NAME.test(s)) throw new Error("entity name 3-20 letters/digits/-/_/'/space");
  return s;
}

export function validatePlanetName(name) {
  const s = normalizeAndCheck(name);
  if (OBJECT_ID.test(s)) throw new Error("name cannot resemble an object ID");
  if (s.startsWith(" ") || s.endsWith(" ")) throw new Error("no leading/trailing space");
  if (s.includes("  ")) throw new Error("no double space");
  if (!PLANET_NAME.test(s)) throw new Error("planet name 3-25 letters/digits/-/_/'/space");
  return s;
}

export function validatePfp(pfp) {
  if (pfp === "") return "";
  if ([...pfp].length > 256) throw new Error("pfp too long");
  for (const r of pfp) {
    const cp = r.codePointAt(0);
    if (cp < 0x20 || cp === 0x7F) throw new Error("control character");
    if (INVISIBLE.has(cp)) throw new Error("invisible character");
  }
  if (/[<>`"\\\s]/.test(pfp)) throw new Error("forbidden punctuation/whitespace");
  if (!pfp.includes(":")) {
    if (!OPAQUE_PFP.test(pfp)) throw new Error("opaque pfp must match [A-Za-z0-9._/-]{1,256}");
    return pfp;
  }
  const scheme = pfp.slice(0, pfp.indexOf(":")).toLowerCase();
  if (!ALLOWED_SCHEMES.has(scheme)) throw new Error(`scheme ${scheme} not allowed`);
  let u;
  try { u = new URL(pfp); } catch { throw new Error("malformed URL"); }
  if ((scheme === "https" || scheme === "http") && !u.host) throw new Error("URL must include host");
  if (["ipfs", "ipns", "ar"].includes(scheme) && !u.host && !u.pathname) {
    throw new Error("URL must include content identifier");
  }
  return pfp;
}
```

The webapp's `SigningClientManager` runs equivalent checks before calling the corresponding `queueMsg*` function. Other clients should mirror this so users get fast, clear errors instead of opaque on-chain rejections.

---

## Examples

### Acceptable

| Field | Value | Why |
|-------|-------|-----|
| Player name | `Andromeda7` | Letters + digit, 10 chars |
| Player name | `星のさだめ` | Non-ASCII letters allowed |
| Player name | `chaos_bot-9` | Letter, underscore, hyphen, digit |
| Guild name | `Iron Veil` | Space allowed for entities |
| Guild name | `O'Connor's Crew` | Apostrophes allowed for entities |
| Planet name | `New Terra II` | Space + digit, 12 chars |
| Pfp (opaque) | `bafybeigdyrztktx4...abc` | CID-like opaque identifier |
| Pfp (URL) | `ipfs://bafybeigdyrztktx4...abc` | IPFS scheme |
| Pfp (URL) | `https://cdn.example.org/avatar.png` | HTTPS scheme |

### Rejected

| Field | Value | Reason |
|-------|-------|--------|
| Player name | `ab` | Too short (< 3 runes) |
| Player name | `Name With Spaces` | Spaces not allowed in player names |
| Player name | `Andromeda 7` | Same |
| Player name | `1-2` | Looks like object id |
| Player name | `Zalgo\u0301\u0302` | Combining marks rejected (Zalgo) |
| Player name | `evil\u202Eorder` | Bidi override rejected |
| Guild name | `  leading-space` | Leading whitespace |
| Guild name | `double  space` | Double space |
| Planet name | (26-rune string) | Exceeds planet length 25 |
| Pfp | `data:image/png;base64,...` | Disallowed scheme |
| Pfp | `javascript:alert(1)` | Disallowed scheme |
| Pfp | `https://example.com/path with space` | Whitespace in pfp value |
| Pfp | `https://` | Missing host |
| Pfp | (300-rune string) | Exceeds 256 |

---

## Operational guidance for guilds

- **Decide your policy before you grant the bit.** A rank-register entry that grants `PermGuildUGCUpdate` to rank `5` makes every officer at rank 5 or better a moderator. Removing it later does not retroactively undo any name change they have already made.
- **Watch the audit stream.** Subscribe to `ugc_moderated` events (or the corresponding `player_meta` / `guild_meta` GRASS categories from the Guild Stack) and log them somewhere your members can see. Decentralized moderation only works when the community can see what moderators are doing.
- **Use post-hoc, not pre-approval.** There is no chain mechanism for "approve before commit". Names land immediately, and moderators correct after the fact. Build your social workflow around that.
- **Communicate when you correct.** Your members chose their identity once; if you overwrite it, tell them why. The chain captures `actor_player_id` and `old_value`, but it does not capture intent.
- **Don't moderate planets and substations you don't actually run.** The check requires the object's owner to be a member of your guild. If a member transfers a planet to another player or leaves the guild, your reach evaporates -- as it should.
- **Remember that moderation is a guild service, not a chain service.** A new player who hasn't joined any guild has no moderator. They can name themselves anything that passes structural validation, and only the next guild they join will gain reach into their identity.

---

## See Also

- [permissions.md](permissions.md) -- `PermGuildUGCUpdate` and the full `UGCPermissionCheck` flow
- [transactions.md](transactions.md) -- All UGC messages run on the free Structs gas path
- [factions.md](../lore/factions.md) -- Why guilds exist and what they're allowed to enforce
- `.cursor/skills/structs-guild/SKILL` -- Operational commands for guild moderation
- `schemas/validation.md` -- Quick-reference index of every chain validator
