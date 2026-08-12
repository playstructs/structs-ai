---
title: Runnable SUI example files
description: Runnable SUI example files. Note that the stylesheet resolves assets from the web root, so serve them over HTTP rather than opening directly.
permalink: /develop/ui/examples/
redirect_from:
  - /develop/ui/examples/README
  - /develop/ui/examples/README.html
---

# Runnable SUI example files

Three files you can copy into a project as-is.

| File | What it is |
|---|---|
| [starter.html](starter.html) | A working page with a dashboard, list, form, states, pagination and a drawer. Every SUI contract in one place |
| [sui-kit.js](sui-kit.js) | Helper functions that encode each markup contract exactly once |
| [sui-patch.css](sui-patch.css) | Local additions filling documented gaps: alert severity, focus rings, tabular numerals, overflow guards |

---

## Running it

SUI's stylesheet references its assets from the **web root** — `url("/img/sui/…")` and
`url('/fonts/Structicons.woff')`. Opening `starter.html` over `file://` will render an
unstyled page with invisible icons and no error. You need the SUI assets served at `/`.

The simplest path is to serve a directory that has `css/`, `fonts/`, `img/` and `js/`
copied out of a [structs-webapp](../../repos.md) checkout:

```bash
WEBAPP=../path/to/structs-webapp
mkdir -p /tmp/sui-demo && cd /tmp/sui-demo
cp -R "$WEBAPP"/src/public/{css,fonts,img} .
mkdir -p js && cp -R "$WEBAPP"/src/js/sui js/
cp /path/to/structs-ai/develop/ui/examples/* .
python3 -m http.server 8000
```

Then open <http://localhost:8000/starter.html>.

If icons are missing, the page logs a specific error to the console — that check is at
the bottom of `starter.html` and is worth keeping in your own app.

Serving from a subpath instead? You have to rewrite the `url()` targets in `sui.css`.
Structs Desktop does this to serve the Team Ops board under `/board/`; see
`rebase_css_urls` in `src-tauri/src/mcp/web_board.rs` for a reference implementation
that prefixes root-absolute targets and leaves relative, `data:` and scheme URLs alone.

---

## What each file demonstrates

**`starter.html`** is annotated with the reason behind each decision, not just the
markup. The scaling overrides at the top, the direct SUI imports rather than `SUI.js`,
the drawer's `classList.remove` before `setPlacement`, and the font self-check are all
things that go wrong quietly if you skip them.

**`sui-kit.js`** exists because SUI's contracts are strict enough that repeating them by
hand is how they drift. Its `stepper()` deliberately wires its own handlers rather than
relying on `SUIInputStepper`, which binds once at init and so never sees controls created
from data. `paginationSlots()` is exported separately so the five-slot logic can be
unit-tested without a DOM.

**`sui-patch.css`** only fills gaps — it never overrides a deliberate SUI choice, and it
uses real tokens throughout. Each block cites the gotcha it addresses. The alert severity
rules are the ones you will miss immediately if you drop them: without them all four
states in `starter.html` render with identical body-coloured text.

---

## Related

- [components.md](../components.md) — the contracts these files encode
- [gotchas.md](../gotchas.md) — why `sui-patch.css` exists
- [runtime.md](../runtime.md) — why `starter.html` avoids `SUI.js`
- [recipes.md](../recipes.md) — the prose walkthrough of each surface here
