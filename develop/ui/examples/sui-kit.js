/**
 * sui-kit.js — minimal helper kit for building SUI surfaces.
 *
 * SUI's markup contracts are strict: controls must sit unclassed inside their
 * label, stepper buttons must be literal siblings of the input, the checkbox
 * container must be a <div>. Repeating that by hand at every call site is how
 * it drifts. Each contract lives in exactly one function here.
 *
 * No dependencies. Import as an ES module, or paste into a <script>.
 * See develop/ui/components.md for the contracts these encode.
 */

/** Create an element with a class list and optional text. */
export function el(tag, className = '', text = '') {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (text) node.textContent = text;
  return node;
}

/** Glyph or sprite icon. Size is one of xs|sm|md|lg|xl|xxl. */
export function icon(name, size = 'sm') {
  return el('i', `sui-icon sui-icon-${size} ${name}`);
}

/** Data card: teal header, bordered body. `spacious` adds the only spacing modifier. */
export function card(title, bodyNodes = [], { theme = 'player', spacious = true } = {}) {
  const c = el('div', `sui-data-card sui-theme-${theme}`);
  c.appendChild(el('div', 'sui-data-card-header sui-text-header', title));
  const body = el('div', `sui-data-card-body${spacious ? ' sui-mod-spacing-xl' : ''}`);
  for (const n of [].concat(bodyNodes)) body.appendChild(n);
  c.appendChild(body);
  return c;
}

/** Label/value pair. `.sui-data-card-row` is one of the few classes that re-asserts left alignment. */
export function row(label, value, valueClass = '') {
  const r = el('div', 'sui-data-card-row');
  r.appendChild(el('span', 'sui-text-label', label));
  r.appendChild(el('span', `sui-num ${valueClass}`.trim(), String(value)));
  return r;
}

/** Resource chip: value first, icon second. */
export function resource(value, iconName) {
  const r = el('div', 'sui-resource');
  r.appendChild(el('span', 'sui-num', String(value)));
  r.appendChild(icon(iconName, 'sm'));
  return r;
}

/**
 * Result row — SUI's list idiom. There is no table component.
 * Both sections carry min-widths (256px / 224px) that force wrapping below
 * roughly 500px; sui-patch.css relaxes them with min-width: 0.
 */
export function resultRow({ iconName, title, subtitle, resources = [] }) {
  const r = el('div', 'sui-result-row');

  const left = el('div', 'sui-result-row-left-section');
  if (iconName) {
    const portrait = el('div', 'sui-result-row-portrait');
    const pIcon = el('div', 'sui-result-row-portrait-icon');
    pIcon.appendChild(icon(iconName, 'md'));
    portrait.appendChild(pIcon);
    left.appendChild(portrait);
  }
  const info = el('div', 'sui-result-row-player-info');
  const label = el('div', 'sui-text-label-block', title);
  if (subtitle) {
    label.appendChild(el('br'));
    label.appendChild(el('span', 'sui-text-hint', subtitle));
  }
  info.appendChild(label);
  left.appendChild(info);

  const right = el('div', 'sui-result-row-right-section');
  const res = el('div', 'sui-result-row-resources');
  for (const [value, iconName_] of resources) res.appendChild(resource(value, iconName_));
  right.appendChild(res);

  r.appendChild(left);
  r.appendChild(right);
  return r;
}

/** List container. `table: true` collapses the gap and uses borders instead. */
export function resultRows(rows, { table = false } = {}) {
  const list = el('div', `sui-result-rows${table ? ' sui-result-table' : ''}`);
  for (const r of rows) list.appendChild(r);
  return list;
}

/**
 * Form field. `label.sui-input-text` wraps ANY control, not just text inputs.
 * The control must be a descendant and must carry no class of its own.
 */
export function field(labelText, controlNode) {
  const l = el('label', 'sui-input-text');
  l.appendChild(el('span', '', labelText));
  l.appendChild(controlNode);
  return l;
}

/** Checkbox. The container MUST be a <div>: a <span> matches the field-label selector. */
export function checkbox(id, text, checked = false) {
  const box = el('div', 'sui-checkbox-container');
  const input = el('input', 'sui-checkbox');
  input.type = 'checkbox';
  input.id = id;
  input.checked = checked;
  box.appendChild(input);
  box.appendChild(el('span', 'sui-checkbox-display'));
  const cap = el('label', '', text);
  cap.setAttribute('for', id);
  box.appendChild(cap);
  return box;
}

/**
 * Numeric stepper. The ± buttons must be the input's literal previous/next
 * element siblings — any wrapper breaks SUIInputStepper silently.
 *
 * SUIInputStepper also binds only once, at autoInitAll(), so steppers created
 * from data after page load are never wired. This wires its own handlers, which
 * is why it does not need that module at all.
 */
export function stepper(id, { min = 0, max = 99, step = 1, value = 0, width = '4.5em' } = {}) {
  const wrap = el('div', 'sui-input-stepper');

  const dec = el('button', 'sui-screen-btn sui-mod-secondary');
  dec.appendChild(icon('icon-subtract', 'md'));

  const input = el('input');
  input.type = 'number';
  Object.assign(input, { id, min, max, step, value });
  // width alone is only a flex basis; the default is 25px, which fits two digits.
  input.style.flex = 'none';
  input.style.width = width;

  const inc = el('button', 'sui-screen-btn sui-mod-secondary');
  inc.appendChild(icon('icon-add', 'md'));

  const nudge = (delta) => {
    const next = Number(input.value) + delta * Number(step);
    input.value = Math.min(Number(max), Math.max(Number(min), next));
    input.dispatchEvent(new Event('input', { bubbles: true }));
  };
  dec.addEventListener('click', () => nudge(-1));
  inc.addEventListener('click', () => nudge(1));

  wrap.appendChild(dec);
  wrap.appendChild(input);
  wrap.appendChild(inc);
  return wrap;
}

/** Button. Works on <button> and <a>; :link and :visited are both styled. */
export function button(text, { mod = 'secondary', iconName = '', href = '' } = {}) {
  const b = href ? el('a', `sui-screen-btn sui-mod-${mod}`) : el('button', `sui-screen-btn sui-mod-${mod}`);
  if (href) b.href = href;
  if (iconName) b.appendChild(icon(iconName, 'sm'));
  b.appendChild(el('span', '', text));
  return b;
}

/** Badge. Only four variants exist: default, warning, destructive, solid. */
export function badge(text, mod = 'default') {
  const VALID = ['default', 'warning', 'destructive', 'solid'];
  if (!VALID.includes(mod)) {
    console.warn(`sui-kit: no "${mod}" badge variant; falling back to default`);
    mod = 'default';
  }
  return el('span', `sui-badge sui-mod-${mod}`, text);
}

/**
 * One state component for loading, empty, info, warning and error.
 * Needs the severity rules in sui-patch.css — without them the text stays
 * body-coloured no matter which modifier is applied.
 */
const STATE = {
  loading: { mod: 'sui-mod-secondary', icon: 'icon-in-progress' },
  empty: { mod: 'sui-mod-secondary', icon: 'icon-info' },
  info: { mod: 'sui-mod-primary', icon: 'icon-info' },
  warning: { mod: 'sui-mod-warning', icon: 'icon-alert' },
  error: { mod: 'sui-mod-destructive', icon: 'icon-alert' },
};

export function stateBlock(kind, text) {
  const k = STATE[kind] || STATE.info;
  const a = el('div', `sui-message-inline-alert ${k.mod}`);
  a.appendChild(icon(k.icon, 'md'));
  const t = el('div', 'sui-message-inline-alert-text');
  t.textContent = text;               // textContent, never innerHTML
  a.appendChild(t);
  return a;
}

/**
 * Pagination matching the shipping contract in the webapp's Pagination.js:
 * at most five number slots, prev absent on page 1, next absent on the last
 * page, ellipsis rendered as a <div> because it is not clickable.
 */
export function pagination(currentPage, totalPages, onGoto) {
  const nav = el('div', 'sui-pagination');

  if (currentPage > 1) {
    const prev = el('a');
    prev.appendChild(icon('icon-chevron-left', 'md'));
    prev.addEventListener('click', () => onGoto(currentPage - 1));
    nav.appendChild(prev);
  }

  const numbers = el('div', 'sui-pagination-numbers');
  for (const slot of paginationSlots(currentPage, totalPages)) {
    if (slot === '...') {
      numbers.appendChild(el('div', 'sui-pagination-number', '...'));
      continue;
    }
    const a = el('a', `sui-pagination-number${slot === currentPage ? ' sui-mod-active' : ''}`, String(slot));
    a.addEventListener('click', () => onGoto(slot));
    numbers.appendChild(a);
  }
  nav.appendChild(numbers);

  if (currentPage < totalPages) {
    const next = el('a');
    next.appendChild(icon('icon-chevron-right', 'md'));
    next.addEventListener('click', () => onGoto(currentPage + 1));
    nav.appendChild(next);
  }
  return nav;
}

/** Slot logic, extracted so it can be unit-tested without a DOM. */
export function paginationSlots(currentPage, totalPages) {
  if (totalPages <= 5) {
    return Array.from({ length: totalPages }, (_, i) => i + 1);
  }
  if (currentPage <= 3) {
    return [1, 2, 3, '...', totalPages];
  }
  if (totalPages - currentPage <= 2) {
    return [1, '...', totalPages - 2, totalPages - 1, totalPages];
  }
  return [1, '...', currentPage, '...', totalPages];
}
