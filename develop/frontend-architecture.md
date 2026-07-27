# Frontend architecture

**Purpose**: The MVVM layer structs-webapp wraps around its client subsystems — router,
view models, components, build — and an honest read on which parts to copy.

This is the scaffolding. The interesting machinery is in
[develop/client/](client/index.md); the visual system is in [develop/ui/](ui/index.md).

---

## No framework

There is no React, Vue or Svelte. The pattern is hand-rolled:

| Layer | Location | Role |
|---|---|---|
| Model | `js/models/`, `js/dtos/` | Plain classes holding game data |
| ViewModel | `js/view_models/` | Builds HTML strings, binds DOM events |
| Controller | `js/controllers/` | Instantiates a view model per page |
| Shell | `js/framework/MenuPage.js` | The DOM chrome: nav, body, dialogue panels |

Templates are **template literals returning HTML strings**, injected with `innerHTML`.
There is no virtual DOM and no reactivity — a component that needs to update listens for
an event and rewrites its own text node.

---

## The view model lifecycle

The base class is one method:

```js
export class AbstractViewModel {
  render() {
    throw new NotImplementedError();
  }
}
```

Everything else is convention rather than contract:

1. **Constructor** — take dependencies (`gameState`, `guildAPI`, managers, element IDs).
2. **`render()`** — fetch if async, build the HTML string, inject it via
   `MenuPage.setBodyContent()` or `setPageTemplateContent()`, then call `initPageCode()`.
3. **`initPageCode()`** — attach listeners, initialise child components.

> **There is no teardown.** Navigating away replaces the DOM by assignment; listeners on
> removed nodes are collected with them. That works for listeners bound to elements
> inside the page, and **not** for listeners bound to `window` — which is most
> live-updating components. Those self-remove by checking whether their element still
> exists when they fire.
>
> The exceptions are the components that hold external resources: map layers and struct
> viewers implement real `destroy()` methods, because `lottie-web` keeps its own registry
> and dropping the reference is not enough. See
> [rendering-entities.md](client/rendering-entities.md#lottie).

Nested components use a parallel base with two methods:

```js
export class AbstractViewModelComponent {
  initPageCode() { throw new NotImplementedError(); }
  renderHTML()   { throw new NotImplementedError(); }
}
```

The parent interpolates `component.renderHTML()` into its template, then calls
`component.initPageCode()` after the DOM exists. Getting that order wrong — calling
`initPageCode()` before injection — is the most common way a component silently fails to
bind, because `getElementById` returns null and nothing throws.

---

## Routing

**Not hash-based, and not the History API.** Navigation is a direct call:

```js
MenuPage.router.goto('Fleet', 'scanResults', { page: 2 });
```

There is no route table. A controller is an object registered by `name`, and **its method
names are the pages**:

```js
registerController(controller) {
  this.controllers.set(controller.name, controller);
}
// …
this.controllers.get(controllerName)[pageName](options);
```

Five controllers: `Auth` (about 30 pages, including the whole onboarding sequence),
`Fleet`, `Guild`, `Account`, `Generic`.

Position is persisted to `localStorage` as `currentMenuPage` and `lastMenuPage`, which is
what lets `restore()` put you back where you were after a reload. `back()` walks one step
using the same stored values — so it is a single-step back, not a stack.

Two details worth borrowing:

**A preview mode** that skips the `localStorage` writes, used when viewing another
player's profile so that browsing someone else's data doesn't become your restore point.

**A `navigationId` counter** incremented on every `goto()`. Async work can snapshot it and
check on completion whether the user has navigated away, rather than writing into a page
that no longer exists. The mechanism is there; how consistently view models use it is
another matter.

The trade-off in all of this: no URLs. You cannot link to a page, the browser back button
does nothing useful, and reloading depends on the `localStorage` restore. For a
full-screen game that is a defensible choice. **For a companion app or dashboard it is
usually the wrong one** — hash routing costs little and gives you shareable links and
working history.

---

## Worth reading as examples

| File | Shows |
|---|---|
| `view_models/fleet/ScanViewModel.js` | Form page: filters, async prefetch, handing off to the router |
| `view_models/fleet/ScanResultsViewModel.js` | List page: parallel fetch of results and count, row rendering, shared pagination |
| `view_models/templates/partials/Pagination.js` | The [pagination contract](ui/components.md#pagination--a-precise-contract), which is exact and worth matching |
| `view_models/components/EnergyUsageComponent.js` | Live-updating component: event subscription and self-cleaning |
| `view_models/account/AccountProfileViewModel.js` | Multi-fetch page with loading states |
| `view_models/HUDViewModel.js` | A static singleton rendered once and alive for the session |

`ScanResultsViewModel` is the one to read first if you are building a list view — it
fetches page and count together, which is the difference between pagination that can show
"page 3 of 16" and pagination that can only offer a next button:

```js
Promise.all([
  this.guildAPI.raidSearch(this.raidSearchRequest),
  this.guildAPI.raidSearchCount(this.raidSearchRequest)
]).then(([players, count]) => {
  // … rows …
  const pagination = new Pagination(
    this.raidSearchRequest.page, PAGINATION_LIMITS.DEFAULT, count,
    'scan', 'Fleet', 'scanResults', this.raidSearchRequest
  );
  this.initPageCode();
  pagination.init();
});
```

Note the last two lines: `initPageCode()` then `pagination.init()`, both **after** the
HTML is in the DOM.

### Directory conventions

```
view_models/
  account/ fleet/ guild/ login/ signup/ logout/ generic/    pages by domain
  components/                 reusable pieces (map, HUD, offcanvas, sequences)
  templates/partials/         shared HTML builders
  banners/                    victory and defeat overlays
```

Named `{Feature}{Purpose}ViewModel.js`; controllers mirror the folders.

---

## Dialogue and banners

`NotificationDialogue` is a separate overlay from the menu page's own dialogue, for
in-game notifications. It hides the HUD while shown and restores it on close —
symmetrically, which is easy to get wrong and produces a permanently hidden HUD:

```js
static hideAndClearDialoguePanel() {
  document.getElementById(NotificationDialogue.dialoguePanelId).classList.add('hidden');
  NotificationDialogue.clearDialogueScreen();
  NotificationDialogue.setDialogueScreenThemeToNeutral();
  NotificationDialogue.clearDialogueBtnAHandler();
  HUDViewModel.show();
}
```

`BannerLayer` is a thin full-width `innerHTML` slot.

---

## Build

Plain Webpack, not Symfony Encore, with three entry points:

```js
entry: {
  index: './js/index.js',
  test:  './js/tests/test.js',
  "workers/TaskWorker": "./js/workers/TaskWorker.js",
},
output: { path: path.resolve(__dirname, 'public/js') },
experiments: { topLevelAwait: true },
resolve: { extensions: [".ts", ".tsx", ".js"] },
module: { rules: [{ test: /\.([cm]?ts|tsx)$/, loader: "ts-loader", options: { transpileOnly: true } }] },
plugins: [new NodePolyfillPlugin()],
```

Three things to note. The proof-of-work worker is a **separate entry point**, because a
worker cannot share the main bundle. `topLevelAwait` is enabled, which the boot sequence
relies on. And `NodePolyfillPlugin` is there for CosmJS, which expects Node globals —
expect to need the same if you use CosmJS in a browser.

Webpack's extension resolution is also why `SUI.js` gets away with an extensionless
import that breaks everywhere else. See [ui/runtime.md](ui/runtime.md#loading-them).

Symfony serves one route (`/`) rendering a shell template that defines the mount points —
`#menu-page-layout`, `#hud-container`, the map containers, `#loading-screen` — and loads
the bundle. Everything inside them is owned by JavaScript.

---

## What to copy, and what not to

**Copy:** the [dual-lane signing queue](client/actions-and-signing.md#the-dual-lane-queue),
the [animation event queue](client/rendering-entities.md#the-animation-event-queue),
[restoring work from the server](client/work-and-pow.md#restoring-after-a-reload) rather
than from local storage, and the explicit Lottie teardown. These are hard-won solutions to
real problems and they transfer to any stack.

**Don't copy:** the plaintext mnemonic in `localStorage`, uncontrolled `GameState`
mutation, the missing HTTP status check in the fetch wrapper, per-factory numeric
coercion, and the absence of any UI for a failed transaction. Each of these is a known
weakness rather than a design choice, and each is called out where it appears.

---

*Verified against structs-webapp `6eec7f7` (2026-07-21): `src/js/framework/`,
`src/js/controllers/`, `src/js/view_models/`, `src/webpack.config.js`.*
