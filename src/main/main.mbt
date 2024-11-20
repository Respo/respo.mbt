let app_store_key : String = "demo_respo_store"

fn view(
  store : Store
) -> @respo_node.RespoNode[ActionOp]!@respo_node.RespoCommonError {
  // @dom_ffi.log("Store to render: " + store.to_json().stringify(indent=2))
  let states = store.get_states()
  div(
    class_name=@respo.ui_global,
    style=respo_style(padding=Px(12)),
    [
      comp_counter(states.pick("counter"), store.counted),
      space(height=80),
      comp_panel(states.pick("panel")),
      comp_todolist(states.pick("todolist"), store.tasks),
      comp_plugins_demo!(states.pick("plugins-demo")),
    ],
  )
}

fn main {
  let window = @dom_ffi.window()
  let mount_target = window
    .document()
    .query_selector(".app")
    .reinterpret_as_node()
  let app : @respo.RespoApp[Store] = {
    store: Ref::new(@respo.try_load_storage(app_store_key)),
    mount_target,
    storage_key: app_store_key,
  }
  app.backup_model_beforeunload()
  // @dom_ffi.log("store: " + app.store.val.to_json().stringify(indent=2))
  app.render_loop(
    fn() { view!(app.store.val) },
    fn(op) {
      @dom_ffi.log("Action: " + op.to_string())
      app.store.val.update(op)
    },
  )
  let dev_mode = @dom_ffi.new_url_search_params(window.location().search()).get(
    "mode",
  )
  @dom_ffi.log("dev mode: " + dev_mode.to_string())
}
