# Respo in MoonBit

> A tiny virtual DOM library ported from [Respo.rs](https://github.com/Respo/respo.rs).

- Home <https://mbt.respo-mvc.org/>
- [![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/Respo/respo.mbt)
- Types <https://mooncakes.io/docs/#/tiye/respo/>
- Demo <https://repo.respo-mvc.org/respo.mbt>

Core ideas:

- **Immutable data by design** - Store and component states must be immutable. Updates create new values using record update syntax (`{ ..old, field: new_value }`). Use `Ref[T]` for mutable references at the application level
- Hot reload friendly for better dev experience
- Embraces types and autocompletion
- States are stored in a single atom, which is a tree structure with a concept like `cursor`
- Uni-directional data flow, dispatching is only allowed when user events occur
- Effects are for DOM updates, rather than dispatching actions
- **Physical equality optimization** - Since data is immutable, unchanged references are skipped during re-rendering

This project is in beta stage. APIs and structure are relatively stable.

### Immutable Data Requirements

Respo requires all state to be immutable. This is not a style preference — it is
required for correctness of the render loop.

#### How the render loop works

Every animation frame, Respo checks whether the store has changed before
re-running the renderer:

```
raf_loop:
  if physical_equal(store.val, prev_store) → skip (same heap object)
  if store.val == prev_store               → skip (structurally equal)
  else                                     → diff vdom, patch DOM
```

Both checks are only reliable when the store is **genuinely immutable** (no
`mut` struct fields).

#### The `mut` field pitfall

If `Store` has `mut` fields and `update()` mutates them in place, then
`{ ..store.val }` creates a new struct header, but both `store.val` and
`prev_store` share the same field values via the mutation. The `==` check
returns `true` and the DOM is never updated — even though the data changed.

```moonbit
// ❌ WRONG — mut field, in-place mutation
struct Store {
  mut count : Int   // mut field!
} derive(Eq)

fn Store::update(self : Store, op : ActionOp) -> ActionOp? {
  self.count += 1   // mutates in place — prev_store sees this too
  None
}

// caller (broken pattern):
ignore(app.store.val.update(op))
app.store.val = { ..app.store.val }  // shallow copy, but fields already mutated
// Result: store.val == prev_store → render skipped → DOM frozen
```

```moonbit
// ✅ CORRECT — no mut, update returns new store
struct Store {
  count : Int
} derive(Eq)

fn Store::update(self : Store, op : ActionOp) -> (Store, ActionOp?) {
  match op {
    Increment => ({ ..self, count: self.count + 1 }, None)
  }
}

// caller (correct pattern):
let (new_store, maybe_op) = app.store.val.update(op)
app.store.val = new_store
// Result: physical_equal fails (new struct) → diff runs → DOM updated
```

#### MoonBit record update syntax

MoonBit's `{ ..self, field: new_value }` creates a new struct with one field
replaced. Use it freely for nested updates:

```moonbit
{ ..self, ui: { ..self.ui, username: value } }
```

#### Debugging render skips

Enable Respo's built-in debug logging to diagnose unexpected render skips:

```moonbit
@respo.set_debug_mode(true)  // add near app startup, remove after debugging
```

Console output:
- `[Respo Debug] Render: skipped - store reference unchanged` — `physical_equal` short-circuit (expected after no-op dispatches)
- `[Respo Debug] Render: skipped - store logically equal` — `==` short-circuit; if unexpected, check for `mut` fields in Store
- `[Respo Debug] Render: starting render cycle` — diff is running
- `[Respo Debug] Render: N DOM changes` — patches applied to DOM

### Usage

```bash
moon add tiye/respo
```

To use Respo, start with the boilerplate at <https://github.com/Respo/respo-moonbit-workflow>

### License

Apache-2.0
