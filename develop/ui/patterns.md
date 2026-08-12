---
title: SUI patterns for multi-page consoles
description: "Practices that keep a multi-page SUI console coherent as it grows: helper kits, list reconciliation, and the pre-ship checklist."
---

# SUI patterns for multi-page consoles

**Purpose**: The practices that keep a multi-page SUI console coherent as it grows, and
the checklist to run before calling a surface done.

These are judgement calls drawn from building a nine-page operations console on SUI, not
properties of the stylesheet. They are here because each one was learned by getting it
wrong first.

---

## Build a helper kit before the second page

Do not hand-write SUI markup at every call site. The [contracts](components.md) are
strict enough that repeating them is how they drift. A small kit pays for itself
immediately and keeps each contract in exactly one place:

```js
function card(title, bodyNode) {
  const c = el('div', 'sui-data-card sui-theme-player');
  c.appendChild(el('div', 'sui-data-card-header sui-text-header', title));
  const b = el('div', 'sui-data-card-body sui-mod-spacing-xl');
  b.appendChild(bodyNode);
  c.appendChild(b);
  return c;
}
```

Aim for **one** way to render a row, **one** to show a statistic, **one** empty state
and **one** error state. A console that grew organically had four row idioms, three
statistic idioms, four empty states, seven error states and five time formatters before
anyone consolidated it. None of that was a decision; it was the absence of one.

A working kit is in [examples/sui-kit.js](examples/sui-kit.js).

## One state component, four severities

SUI gives you [no empty state, skeleton, or spinner](components.md#what-sui-does-not-give-you).
The webapp fills that gap with loading GIFs and ad-hoc error text, which is exactly why
you should decide once and reuse:

```js
const STATE = {
  loading: { mod: 'sui-mod-secondary',   icon: 'icon-in-progress' },
  empty:   { mod: 'sui-mod-secondary',   icon: 'icon-info' },
  info:    { mod: 'sui-mod-primary',     icon: 'icon-info' },
  warning: { mod: 'sui-mod-warning',     icon: 'icon-alert' },
  error:   { mod: 'sui-mod-destructive', icon: 'icon-alert' },
};

function stateBlock(kind, text) {
  const k = STATE[kind] || STATE.info;
  const a = el('div', 'sui-message-inline-alert ' + k.mod);
  a.appendChild(el('i', `sui-icon sui-icon-md ${k.icon}`));
  const t = el('div', 'sui-message-inline-alert-text');
  t.textContent = text;                     // textContent, not innerHTML
  a.appendChild(t);
  return a;
}
```

This needs the four CSS rules from
[gotchas](gotchas.md#severity-colours-the-icon-but-not-the-text) to actually look
different from each other.

---

## Reconcile lists by key, don't rebuild them

Rebuilding a list on every refresh destroys scroll position, focus and half-typed filter
text — and at scale it stalls the page. A roster of 459 rows rebuilt wholesale was 22,415
DOM nodes; reconciled by key it was 2,967.

For an append-only log the reconcile is trivial and worth doing by hand:

```js
// Rows are newest-first, so live updates only ever PREPEND.
const known = new Set(renderedKeys);
const fresh = [];
for (const row of matched) {
  if (known.has(key(row))) break;      // first known row: everything after is older
  fresh.push(row);
}
for (let i = fresh.length - 1; i >= 0; i--) {
  list.insertBefore(renderRow(fresh[i]), list.firstChild);
  renderedKeys.unshift(key(fresh[i]));
}
while (renderedKeys.length > renderCap) {
  list.removeChild(list.lastChild);
  renderedKeys.pop();
}
```

Rebuild only when the *set* changes — a filter or sort — or when row content changes
underneath you, such as names resolving late.

Two traps found the hard way:

**Placeholder rows are not data.** "No results" and "show more" aren't in your key list,
so a tail-trim that removes `list.lastChild` will eat one and pop a key, desyncing the
DOM from your state. Purge placeholders **before** reconciling.

**Scroll position.** A rebuild resets `scrollTop` to 0. For a newest-first feed, top
means "tailing" and anywhere else means "reading" — preserve position unless the user was
already at the top, and on prepend adjust by the added height so the same rows stay under
the cursor.

## Separate the data cap from the render cap

Keeping 2,000 records is cheap; rendering 2,000 rows is roughly 24,000 nodes. Hold the
full set for search and filtering, render a bounded window, and **always say what you
are holding back**:

> `1,500 older matching event(s) not shown · Show 500 more`

Silent truncation reads as "that's everything", and an operator who believes they are
looking at the whole picture will make decisions accordingly.

## Drive large forms from a schema

Once a settings page passes roughly 20 fields, hand-written forms drift from their
labels. Drive them from a field registry keyed by property name, dispatching on type:
boolean to checkbox, number to stepper, known enum to select, array to comma-separated
text. One editor, one label source, no drift. Give it a key filter so a single config
can be split across several cards without forking the editor.

---

## Verify in a DOM, and then in a browser

A jsdom harness with a stubbed backend catches routing, wiring and layout bugs in
seconds, with no build and no deploy:

```js
const dom = new JSDOM(fs.readFileSync('app.html', 'utf8'), {
  runScripts: 'outside-only',
  pretendToBeVisual: true,
  url: 'http://localhost/app.html',
});
dom.window.__BACKEND__ = { invoke: (cmd) => Promise.resolve(FIXTURES[cmd]) };
dom.window.eval(fs.readFileSync('app.js', 'utf8'));
// then: set location.hash, dispatch 'hashchange', assert on the DOM
```

This found a Send button whose click bubbled to its row's `onClick` and opened the wrong
panel — invisible in a screenshot, obvious in an assertion.

**But jsdom does not do layout.** Every overflow bug in [gotchas](gotchas.md) needed a
real browser and a `scrollWidth > clientWidth` sweep. Use both, for different classes of
bug.

---

## Checklist for a new SUI surface

**Before writing markup**

- [ ] Decide the [scaling model](index.md#decide-the-scaling-model-first)
- [ ] Confirm `/img` and `/fonts` resolve from your serving root
- [ ] Load only the SUI JS you need, [by direct import](runtime.md#loading-them)
- [ ] Pick a theme class for the root

**While building**

- [ ] Every colour from a [token](tokens.md); no hex literals
- [ ] Every icon from the [two real inventories](icons.md); none invented
- [ ] Chrome uppercase/ExtremeHazard, content DirectiveZero
- [ ] Form controls inside `label.sui-input-text`, unclassed
- [ ] Stepper buttons are literal siblings of the input
- [ ] Checkbox container is a `<div>`
- [ ] Badge modifiers limited to default/warning/destructive/solid
- [ ] `tabular-nums` on numeric cells
- [ ] `min-width: 0` on any flex item holding long unbreakable text
- [ ] Prose, tables and logs explicitly left-aligned against the global centre
- [ ] Empty, loading and error states use one shared component
- [ ] Lists reconcile by key rather than `innerHTML = ''`

**Before calling it done**

- [ ] Sweep for overflow at your narrowest supported width
- [ ] Confirm `document.fonts.check('16px Structicons')` is true
- [ ] Check a checkbox and a radio actually render their art
- [ ] Confirm the four alert severities are visually distinct
- [ ] Verify pagination shows 5 slots or fewer and omits prev/next at the ends
- [ ] Tab bar: confirm no nav item has scrolled out of view
- [ ] Keyboard: confirm focus is visible somewhere

---

*Practices verified in use against structs-webapp `6eec7f7` (2026-07-21) and the Structs
Desktop Team Ops console.*
