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

Respo requires all state to be immutable:

```moonbit
// Store must be immutable - no `mut` fields
struct Store {
  counted : Int
  tasks : @immut/array.T[Task]  // Use immutable collections
  states : RespoStatesTree
}

// Update returns a new Store, never mutates in place
fn Store::update(self : Store, op : ActionOp) -> Store {
  match op {
    Increment => { ..self, counted: self.counted + 1 }
    // ...
  }
}

// At top level, wrap in Ref for mutability
let app_store : Ref[Store] = Ref::new(Store::default())
app_store.val = app_store.val.update(action)  // Replace with new value
```

This design enables:

- Efficient change detection via reference equality (`physical_equal`)
- Predictable state management
- Safe concurrent access patterns

### Usage

```bash
moon add tiye/respo
```

To use Respo, start with the boilerplate at <https://github.com/Respo/respo-moonbit-workflow>

### License

Apache-2.0
