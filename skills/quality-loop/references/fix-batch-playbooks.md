# Fix-batch playbooks

Batch recipes proven in the source campaign. Each is a self-contained recipe: what it fixes,
the exact procedure, the verification, and the trap that proves why the recipe exists. Hand the
relevant recipe to the sweep agents alongside the mapping table.

## 1. Token sweep (hardcoded colors → design tokens)

**Problem**: colors hardcoded across N files — palette changes need a repo-wide grep, off-palette
colors drift in unnoticed.

**Procedure**:
1. Foundation first (Batch A): map the palette into utility classes (`@theme inline` in Tailwind 4,
   CSS variables elsewhere). Derive names from ROLE, not color: `ink`, `magenta`, `emerald`,
   `crimson-bright` (on-dark readable steps), `tint`/`tint-deep` (hover-on-tint), `shadow-*`.
2. Census: count hexes per file → group into parallel per-file agents (5–8 files each).
3. Each agent gets: the mapping table (exact hex → token, with role judgment rules — e.g.
   "#F472B6 → magenta-bright as text/icon, emerald-tint as bg"), the compound-pattern rules
   (shadow offsets → shadow tokens; full tactile strings → one utility), the skip list
   (artifact/export files, syntax themes), and self-verification (grep clean + typecheck filtered).
4. Coordinator runs the central gates + a grep census to prove zero.

**Trap that proves the recipe**: `max-w-[68ch]` rendered 87–95 real characters because the `ch`
unit is the width of the "0" glyph in the chosen font — a value-based rule ("68ch") silently
became an off-target measure. Verify measures in the browser, not by class name.

**Verification**: census to zero, visual pass at two widths, and a permanent CI guard derived
from the source of truth (the palette file itself) — see the guardrails batch.

## 2. Accessibility sweep

**Problem**: icon-only buttons without accessible names, placeholder-only inputs, missing
landmarks, pointer-only drag surfaces, sub-24px touch targets.

**Procedure** (wave 1 = worst files, wave 2 = the rest):
1. Icon-only buttons/links → concise action-oriented `aria-label` (match the in-repo exemplar).
   Elements WITH visible text get nothing — `aria-label` overrides visible text.
2. Inputs: visible label above → convert to `<label htmlFor>` + unique id (prefix per context);
   no visible label → `aria-label` mirroring the placeholder.
3. Drag handles/split bars: `role="separator"`, `aria-orientation`, `aria-valuenow/min/max`,
   `tabIndex={0}`, scoped Arrow/Home/End `onKeyDown` (with `stopPropagation` so global shortcut
   handlers don't double-fire), and an enlarged hit area via a `before:` pseudo element.
4. Drawers/overlays: Escape-to-close effect, focus trap, focus restore to opener, `role="dialog"`
   + `aria-modal` + `aria-label`.
5. Touch targets: measure from classes; bump sub-24px elements to the WCAG 2.5.8 floor only.

**Trap**: audit counts inflate — most "unlabeled buttons" have visible text. Count only true
gaps, and verify each file's dialogs against the test suite's source assertions before editing.

## 3. Motion cleanup

**Problem**: `transition-all` everywhere (layout thrash), motion effects unguarded for
`prefers-reduced-motion`, hand-repeated press patterns.

**Procedure**:
1. Classify every `transition-all`: colors-only → `transition-colors`; width/height/grid →
   `transition-[property]`; transform movement → specific property + `motion-reduce:transition-none`;
   redundant with a press utility → delete.
2. Every hover/active translate or scale not covered by a press utility gets a
   `motion-reduce:` guard unless the movement IS the essential feedback.
3. Entrances from a text-animation catalog: one authored moment per surface, translated into the
   project's existing keyframe pattern, all guarded in one reduce-motion CSS block.

**Trap**: Tailwind's `animate-pulse`/`animate-spin` have NO intrinsic reduce guard — busy
spinners should SLOW (2.5s) not stop (the user must still see work in progress), accents stop.

## 4. Async read-modify-write hardening (Dexie/DB race fixes)

**Problem**: whole-record `get → mutate → put` outside a transaction loses concurrent updates
(two writers interleave, last put reverts the first's increments).

**Procedure**:
1. Inventory every RMW site (`grep` the table's `.put(` calls; classify: whole-record vs
   field-patch, inside/outside a transaction).
2. Shared helpers: `updateStats(id, patchFn)` / `addCost(id, delta)` — each opens the
   transaction, reads FRESH, applies the callback, writes. Convert sites to the helpers.
3. Wrap multi-record cycles (`bulkGet → compute → bulkPut`) in one transaction; the runtime's
   nesting joins the caller's transaction.
4. On real backends (Durable Objects), move the ENTIRE read-check-write cycle into one RPC
   method — runtime input gates do NOT serialize during non-storage awaits (crypto, fetch), so
   add an explicit promise-chain gate inside the class and document it as load-bearing.
5. Tests: concurrency-shaped tests (two overlapping calls must both land), gate/boundary tests
   (cap enforcement, password gates), and a misrouted-write guard (DO refuses records whose key
   doesn't match the instance).

**Trap**: a "pure refactor" of the RMW cycle changed allocation semantics — the old loop only
checked occupancy, the new atomic claim authorized legacy takeover. Re-read every call site's
intent when moving logic into atomic units, and gate behavior differences behind explicit flags.
