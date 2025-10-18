# Respo.mbt - MoonBit Virtual DOM Library

> A tiny virtual DOM library for MoonBit with hot reload support, type safety, and uni-directional data flow. Respo embraces functional programming patterns with immutable state management through a tree-based cursor system.

Respo.mbt is a port of Respo.rs designed for building interactive web applications in MoonBit. It provides a React-like component model with strong typing, efficient virtual DOM diffing, and a unique state management approach using cursors and trees.

## Core Concepts

### Virtual DOM and Components

- **RespoNode**: The fundamental building block representing virtual DOM elements or components
- **RespoComponent**: Named components with effects and child trees
- **RespoElement**: DOM elements with attributes, styles, events, and children
- Components are created using `RespoComponent::named(name, tree, effects)`
- Elements are created using helper functions like `div()`, `button()`, `input()`, etc.

### State Management

- **Store**: Central application state container with `counted`, `tasks`, and `states` fields
- **RespoStatesTree**: Tree structure for managing component-local state using cursors
- **Cursor**: Path-based navigation system for accessing specific parts of the state tree
- State updates are immutable and trigger re-renders automatically
- Use `states.local_pair()` to get local state and cursor for a component

### Actions and Dispatch

- **ActionOp**: Enum defining all possible actions (Increment, Decrement, AddTask, etc.)
- **DispatchFn**: Function type for dispatching actions and state changes
- Actions are dispatched through event handlers: `dispatch.run(ActionOp)`
- State changes: `dispatch.set_state(cursor, new_state)`
- All state updates must go through the dispatch system

### Event Handling

- Events are handled through `on_click`, `on_input`, etc. properties
- Event handlers receive `(RespoEvent, DispatchFn)` parameters
- Use `original_event.prevent_default()` to prevent browser default behavior
- Events can dispatch multiple actions and state changes

## Development Patterns

### Creating Components

```moonbit
fn comp_counter(states : RespoStatesTree, global_counted : Int) -> RespoNode[ActionOp] {
  let ((state : MainState), cursor) = states.local_pair()
  div(
    attrs=respo_attrs().set("data-comp", "counter"),
    [
      button(
        inner_text="Increment",
        class_name=@respo.ui_button,
        on_click=fn(e, dispatch) {
          dispatch.run(Increment)
          dispatch.set_state(cursor, { counted: state.counted + 1 })
        }
      ),
      text_node("Count: \{state.counted}")
    ]
  )
}
```

### State Structure

```moonbit
struct Store {
  mut counted : Int
  mut tasks : Array[Task]
  states : RespoStatesTree
} derive(ToJson, FromJson, Default)

struct MainState {
  counted : Int
} derive(Default, ToJson, FromJson)
```

### Application Setup

```moonbit
fn main {
  let mount_target = window.document().query_selector(".app").unwrap().reinterpret_as_node()
  let app : RespoApp[Store] = {
    store: Ref::new(try_load_storage(storage_key)),
    mount_target,
    storage_key: "app_store"
  }
  app.backup_model_beforeunload()
  app.render_loop(fn() { view(app.store.val) }, fn(op) {
    app.store.val.update(op)
  })
}
```

### Styling

- Use `respo_style()` for inline styles with type-safe CSS properties
- `static_style()` for generating CSS classes with scoped styles
- Pre-built UI components: `ui_button`, `ui_input`, `ui_global`
- CSS-in-MoonBit with support for responsive design and pseudo-selectors

#### Styling Examples

```moonbit
// Inline styles with respo_style()
div(
  style=respo_style(
    background_color=Hsl(200, 90, 96),
    padding=12 |> Px,
    border_radius=4,
    margin=8 |> Px
  ),
  [text_node("Styled content")]
)

// Static CSS classes with scoped styles
let style_container : String = static_style([
  ("&", respo_style(
    display=Flex,
    flex_direction=Column,
    gap=16 |> Px
  )),
  ("&:hover", respo_style(background_color=Hsl(0, 0, 98))),
  ("@media only screen and (max-width: 600px)", "&", respo_style(
    padding=8 |> Px,
    font_size=14
  ))
])

// Using pre-built UI components
button(
  inner_text="Click me",
  class_name=@respo.ui_button,
  style=respo_style(margin=4 |> Px)
)

input(
  placeholder="Enter text...",
  class_name=@respo.ui_input,
  value=state.input_value
)
```

### Effects and Lifecycle

- Effects are attached to components for DOM manipulation and side effects
- Use `RespoComponent::named(name, tree, effects)` to add effects
- Effects have lifecycle hooks: `mounted`, `before_update`, `updated`, `before_unmount`
- Implement `RespoEffect` trait for custom effects

#### Effects Examples

```moonbit
// Define a custom effect
struct PanelMount {} derive(Default, Eq, ToJson, FromJson)

impl RespoEffect for PanelMount with mounted(_self, el) {
  @dom_ffi.log("Component mounted, DOM element available")
  // Focus an input element, set up event listeners, etc.
  el.reinterpret_as_html_input_element().focus()
}

impl RespoEffect for PanelMount with before_update(_self, _el) {
  @dom_ffi.log("About to update component")
  // Clean up before DOM changes
}

impl RespoEffect for PanelMount with updated(_self, _el) {
  @dom_ffi.log("Component updated")
  // React to DOM changes, update third-party libraries
}

impl RespoEffect for PanelMount with before_unmount(_self, el) {
  @dom_ffi.log("About to unmount component")
  // Clean up event listeners, timers, etc.
  let window = @dom_ffi.window()
  window.remove_event_listener_with_callback("keydown", stored_listener)
}

// Use effect in component
fn comp_panel(states : RespoStatesTree) -> RespoNode[ActionOp] {
  let ((state : PanelState), cursor) = states.local_pair()
  let effect_panel_mount = PanelMount::default()

  RespoComponent::named(
    "panel",
    effects=[effect_panel_mount],
    div([
      input(placeholder="Focus me on mount", class_name=@respo.ui_input),
      text_node("Panel content")
    ])
  ).to_node()
}

// Task-specific effect example
struct TaskUpdateEffect {
  task : Task
} derive(Hash, Eq, Default, ToJson, FromJson)

impl RespoEffect for TaskUpdateEffect with updated(_self, _el) {
  @dom_ffi.log("Task component updated: \{_self.task.content}")
  // Trigger animations, update external state, etc.
}
```

## API Reference

### Core Functions

- `div(attrs?, style?, class_name?, class_list?, children)` - Create div element
- `button(inner_text?, on_click?, class_name?, style?)` - Create button
- `input(value?, on_input?, placeholder?, class_name?)` - Create input
- `text_node(content, style?)` - Create text node
- `space(width?, height?)` - Create spacing element

### State Management

- `states.local_pair()` - Get (local_state, cursor) tuple
- `dispatch.run(action)` - Dispatch action to store
- `dispatch.set_state(cursor, new_state)` - Update local state
- `try_load_storage(key)` - Load state from localStorage
- `backup_model_beforeunload()` - Auto-save on page unload

### Styling

- `respo_style(property=value, ...)` - Create inline styles
- `static_style(rules)` - Generate scoped CSS class
- `ui_button`, `ui_input`, `ui_global` - Pre-built UI styles

## Best Practices

1. **Component Design**: Keep components pure and predictable
2. **State Management**: Use cursors for component-local state, store for global state
3. **Event Handling**: Always use dispatch for state changes, never mutate directly
4. **Styling**: Prefer `static_style` for reusable styles, `respo_style` for dynamic styles
5. **Performance**: Use memoization for expensive computations
6. **Type Safety**: Leverage MoonBit's type system for compile-time guarantees

## Common Patterns

### Form Handling

```moonbit
input(
  value=state.input_value,
  placeholder="Enter text...",
  on_input=fn(e, dispatch) {
    if e is Input(value~, ..) {
      dispatch.set_state(cursor, { ...state, input_value: value })
    }
  }
)
```

### Conditional Rendering

```moonbit
if condition {
  [some_component()]
} else {
  [other_component()]
}
```

### List Rendering

```moonbit
tasks.map(fn(task) {
  div(key=task.id, [
    text_node(task.content),
    button(
      inner_text="Delete",
      on_click=fn(e, dispatch) { dispatch.run(RemoveTask(task.id)) }
    )
  ])
})
```

This documentation provides the essential knowledge for AI coding assistants to help developers build Respo applications effectively, following functional programming principles and MoonBit's type system.
