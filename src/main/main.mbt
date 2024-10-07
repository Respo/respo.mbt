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

fn App::dispatch(self : App, op : ActionOp) -> Unit {
  // TODO intent

  self.store.update(op)
}

fn App::view(self : App) -> @respo_node.RespoNode[ActionOp] {
  let states = self.store.get_states()
  // @web_sys.log("States: " + states.to_string())
  @respo_node.div(
    attrs=@respo_node.respo_attrs(class_name=@respo.ui_global),
    style=@respo_node.RespoStyle::new(padding=Px(12)),
    [
      comp_counter(states.pick("counter"), self.store.counted),
      @respo_node.space(height=80),
      comp_panel(states.pick("panel")),
      comp_todolist(states.pick("todolist"), self.store.tasks),
      @respo_node.space(height=80),
    ],
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
    .reinterpret_as_node(),
    store: Store::default(),
  }
  // app.try_load_storage().expect("load storage")
  // app.backup_model_beforeunload().expect("backup model beforeunload")
  // util::log!("store: {:?}", app.store)
  app.render_loop()
}

pub fn App::render_loop(self : App) -> Unit {
  let mount_target = self.mount_target
  let global_store = self.store
  // let store_to_action = global_store.to_owned()

  let dispatch_action = fn(op : ActionOp) -> Unit!@respo_node.RespoCommonError {
    @web_sys.log("action \{op.to_string()} store, \{global_store.to_json()}")

    // Self::dispatch(store_to_action.to_owned(), op)?;
    // @web_sys.log("store after action: " + global_store.to_json().to_string())
    self.store.update(op)
    match op {
      Noop => raise @respo_node.RespoCommonError("TODO")
      _ => ()
    }
  }
  let renderer = fn() -> @respo_node.RespoNode[_] { self.view() }
  let ret = @respo.render_node?(
    mount_target,
    global_store,
    renderer,
    dispatch_action,
    Some(100),
  )
  match ret {
    Ok(_) => ()
    Err(e) => @web_sys.error_log(e.to_string())
  }
}
