///|
using @respo_node {contained_static_style}

///|
let app_store_key : String = "demo_respo_store"

///|
fn view(
  store : Store,
) -> RespoNode[ActionOp, GlobalEvent] raise RespoCommonError {
  // @dom_ffi.log("Store to render: " + store.to_json().stringify(indent=2))
  let states = store.get_states()
  div(
    class_list=[@respo.ui_global, @respo.preset, style_container],
    style=respo_style(padding=12 |> Px),
    [
      comp_counter(states.pick("counter"), store.counted),
      space(height=80),
      memo_comp_panel(states.pick("panel")),
      comp_todolist(states.pick("todolist"), store.tasks),
      comp_plugins_demo(states.pick("plugins-demo")),
      space(height=40),
      comp_shortcut_demo(states.pick("shortcut-demo")),
    ],
  )
}

///|
fn main {
  let window = @dom_ffi.window()
  let mount_target = window
    .document()
    .query_selector(".app")
    .unwrap()
    .reinterpret_as_node()
  let app : @respo.RespoApp[Store] = {
    store: Ref::new(@respo.try_load_storage(app_store_key)),
    mount_target,
    storage_key: app_store_key,
  }
  app.backup_model_beforeunload()
  // @dom_ffi.log("store: " + app.store.val.to_json().stringify(indent=2))

  // Store reference to current tree for global event handling
  let current_tree : Ref[RespoNode[ActionOp, GlobalEvent]?] = Ref::new(None)

  // Create action dispatch function
  let action_dispatch = fn(op : ActionOp) raise RespoCommonError {
    @dom_ffi.log("[main] Action dispatched")
    app.store.val = app.store.val.update(op)
    @respo.mark_need_rerender() // Trigger re-render after state update
  }

  // Create DispatchFn wrapper for global events
  let dispatch_fn : DispatchFn[ActionOp] = DispatchFn(action_dispatch)
  app.render_loop(
    fn() {
      let tree = view(app.store.val)
      current_tree.val = Some(tree) // Store current tree
      tree
    },
    action_dispatch,
  )

  // Setup global keyboard event listener
  @dom_ffi.log("[main] Setting up keyboard event listener")
  add_keydown_listener(window.document(), fn(event) {
    let key = event.key()
    @dom_ffi.log("[main] Keyboard event detected: \{key}")

    // Get current tree and dispatch global event
    match current_tree.val {
      Some(tree) => {
        @dom_ffi.log("[main] Dispatching global KeyPress event to tree")
        @respo.dispatch_global_event(KeyPress(key), tree, dispatch_fn) catch {
          e => @dom_ffi.error_log("[main] Error dispatching global event: \{e}")
        }
      }
      None => @dom_ffi.warn_log("[main] No tree available for global event")
    }
  })
  @dom_ffi.log("[main] Keyboard listener installed successfully!")
  let dev_mode = @dom_ffi.new_url_search_params(window.location().search()).get(
    "mode",
  )
  @dom_ffi.log("dev mode: " + dev_mode.to_string())
  // @respo.set_debug_mode(true)
}

///|
/// Add keyboard event listener to Document
/// This allows listening to keyboard events on the entire document
pub extern "js" fn add_keydown_listener(
  doc : @dom_ffi.Document,
  f : (@dom_ffi.KeyboardEvent) -> Unit,
) -> Unit =
  #| (doc, f) => { doc.addEventListener('keydown', f) }

///|
/// generates class name, for example `example-name`, with css content
/// ```css
/// @media only screen and (max-width: 600px) {
///  .example-name {
///   background-color: hsl(0, 0%, 95%);
/// }
/// ```
let style_container : String = contained_static_style([
  (
    Some("@media only screen and (max-width: 600px)"),
    "&",
    respo_style(background_color=Hsl(0, 0, 95)),
  ),
])
