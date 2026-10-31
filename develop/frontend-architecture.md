---
description: The MVVM layer the webapp wraps around its client subsystems, with an honest read on what to copy and what not to.
---

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

The base view-model interface does not impose universal teardown. The router now
provides a navigation AbortSignal, and reviewed asynchronous views bind reads and
outcome observers to that lifetime. Replacing the DOM alone still cannot remove
listeners registered on `window`; components must release them explicitly or use
their existing element-lifetime checks.

Map layers and struct viewers implement `destroy()` because Lottie keeps its own
registry. Drawers have a separate content AbortSignal. Neither navigation nor
closing a drawer cancels an already submitted transaction; the account-scoped
journal and outcome reconciliation outlive its observer. See
[rendering-entities.md](client/rendering-entities.md#lottie).

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

The ordinary controllers are `Auth`, `Fleet`, `Guild`, `Account` and `Generic`.
Combat Training registers `Tutorial` with simulated game/signing/API dependencies;
its rendered activity is not evidence of a native transaction.

Position is persisted to `localStorage` as `currentMenuPage` and `lastMenuPage`, which is
what lets `restore()` put you back where you were after a reload. `back()` walks one step
using the same stored values — so it is a single-step back, not a stack.

Two details worth borrowing:

**A preview mode** that skips the `localStorage` writes, used when viewing another
player's profile so that browsing someone else's data doesn't become your restore point.

**Navigation identity and cancellation.** Every `goto()` aborts the old
`navigationSignal`, creates a fresh controller and increments `navigationId` before
calling `onNavigate` and rendering the destination. Capture identity/signal when
starting async work; late completion must not overwrite another page or session.
`goto(..., {replace: true})` updates the current route without moving the previous
route into the one-step back slot.

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

Plain Webpack, not Symfony Encore, with `index` and `test` entry points. Entry and
chunk filenames include `contenthash`. `AssetManifestPlugin` writes
`public/js/manifest.json`, mapping the logical entry paths to those emitted files;
Symfony's webpack asset package resolves the shell's index URL through that manifest.

The proof worker is created using `new Worker(new URL(..., import.meta.url))`, so
Webpack emits it as a chunk referenced by its matching parent build. It is not a
separate fixed `workers/TaskWorker.js` entry. Deploy source, manifest, bundles and
worker output together; a new page must not reuse an incompatible cached worker.
The worker's protocol handshake remains required. An already-running old tab cannot
acquire new guards merely because assets were deployed.

`topLevelAwait` is enabled for startup. TypeScript transpilation uses `ts-loader` with
`transpileOnly: true`, so run type checks separately. The Node compatibility surface
is Buffer-only: CosmJS gets `Buffer` as a global, while `crypto: false` satisfies its
browser-side Node probe without pulling in a broad crypto polyfill.

Webpack's extension resolution is also why `SUI.js` gets away with an extensionless
import that breaks everywhere else. See [ui/runtime.md](ui/runtime.md#loading-them).

Symfony serves one route (`/`) rendering a shell template that defines the mount points —
`#menu-page-layout`, `#hud-container`, the map containers, `#loading-screen` — and loads
the bundle. Everything inside them is owned by JavaScript. The clean Docker image
creates writable Symfony cache/log directories for Apache; runtime caches are not
a substitute for the source/build manifest. Preserve deployment session/token
revocation storage separately when replacing a serving container.

---

## Local builds and running containers

A development container bind-mounts its configured source directory at `/src`.
Run `npm run dev` (watch) or `npm run build` (one production build) from that
mounted directory's `src/` on the host, then refresh the browser. Both emit the
manifest and hashed application/worker files. An image rebuild or restart is not
needed for those asset edits; watch mode itself does not reload an open page.
Building a different Git worktree does not change the mounted checkout. Check the
mount and the page's selected manifest URL before diagnosing a container failure.

The current native-read deployment assumes one PHP container, with sessions,
cache and locks coordinated across its workers. Shared storage is required before
adding replicas. See the [migration guide](client/migration.md#7-prepare-your-backend-if-you-operate-one)
for deployment order, proxy routing and native source configuration.

## What to copy, and what not to

**Copy:** the [dual-lane signing queue](client/actions-and-signing.md#the-dual-lane-queue),
the [animation event queue](client/rendering-entities.md#the-animation-event-queue),
[restoring work from the server](client/work-and-pow.md#restoring-after-a-reload) rather
than from local storage, and the explicit Lottie teardown. These are hard-won solutions to
real problems and they transfer to any stack.

**Choose deliberately:** the reference browser stores its mnemonic in localStorage;
that custody model belongs to the page's trust boundary. `GameState` is mutable, so
retain source/owner/session checks at updates. Current `JsonAjaxer` rejects failed
HTTP responses, bounds requests and supports cancellation; do not restore older
silent-failure behavior. Definitive transaction failure returns existing flows to
their retained intent. Preserve uncertain signed identity; whether it reserves new
sends depends on the [recovery evidence](client/actions-and-signing.md#retries-and-settlement).

---

*Reviewed against structs-webapp `ae4457e2`: router/request lifetimes, controller
registration, accepted view flows, webpack/manifest/worker integration and Docker
runtime ownership. Unchanged base interfaces and examples were compared with the
previous source revision.*

*Scoped follow-up against webapp `461bba5a`: mounted build/manifest workflow and deployment requirements; rendering and router interfaces retain the baseline above.*
