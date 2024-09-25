let app_store_key : String = "demo_respo_store"

struct App {
  store : Store
  mount_target : @web_sys.Node
}

fn App::get_store(self : App) -> Store {
  self.store
}

fn App::get_mount_target(self : App) -> @web_sys.Node {
  self.mount_target
}

fn App::dispatch(
  self : App,
  op : ActionOp
) -> Unit!@respo_node.RespoCommonError {
  // TODO intent

  self.store.update!(op)
}

fn App::view(
  self : App
) -> @respo_node.RespoNode[ActionOp]!@respo_node.RespoCommonError {
  let states = self.store.get_states()
  @respo_node.div(
    attrs=@respo_node.respo_attrs(class_name=ui_global()),
    style=@respo_node.RespoStyle::new(padding="12"),
    [comp_counter!(states.pick("counter"), self.store.counted)],
    // space(None, Some(80)).to_node(),
    // comp_panel(&states.pick("panel"))?,
    // comp_todolist(&states.pick("todolist"), &store.tasks)?.to_node(),
    // space(None, Some(80)).to_node(),
    // comp_plugins_demo(&states.pick("plugins-demo"))?.to_node(),
    // space(None, Some(80)).to_node(),
    // comp_inner_text(&states.pick("inner-text"))?.to_node(),
    // space(None, Some(80)).to_node(),
  )
}

fn main {
  let app : App = {
    mount_target: @web_sys.window()
    .document()
    .query_selector(".app")
    .unwrap()
    .reinterpret_as_node(),
    store: Store::default(),
  }
  // app.try_load_storage().expect("load storage")
  // app.backup_model_beforeunload().expect("backup model beforeunload")
  // util::log!("store: {:?}", app.store)
  // app.render_loop().expect("app render")
}

fn ui_global() -> String {
  "TODO ui-global"
}
