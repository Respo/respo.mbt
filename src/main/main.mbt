let app_store_key : String = "demo_respo_store"

struct App {
  store : Ref[Store]
  mount_target : @web_sys.Node
}

fn App::get_store(self : App) -> Ref[Store] {
  self.store
}

fn App::get_mount_target(self : App) -> @web_sys.Node {
  self.mount_target
}

fn App::dispatch(self : App, op : ActionOp) -> Unit {
  // TODO intent

  self.store.val.update(op)
}

fn App::view(
  self : App
) -> @respo_node.RespoNode[ActionOp]!@respo_node.RespoCommonError {
  let store = self.store.val
  let states = store.get_states()
  @web_sys.log("Global States: " + states.data.to_json().stringify(indent=2))
  @respo_node.div(
    attrs=@respo_node.respo_attrs(class_name=@respo.ui_global),
    style=@respo_node.RespoStyle::new(padding=Px(12)),
    [
      comp_counter(states.pick("counter"), store.counted),
      @respo_node.space(height=80),
      comp_panel(states.pick("panel")),
      comp_todolist(states.pick("todolist"), store.tasks),
      comp_plugins_demo!(states.pick("plugins-demo")),
    ],
  )
}

fn main {
  let app : App = {
    mount_target: @web_sys.window()
    .document()
    .query_selector(".app")
    .reinterpret_as_node(),
    store: Ref::new(Store::default()),
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
    @web_sys.log("Action: \{op.to_string()}")
    @web_sys.log("Global store: \{global_store.val.to_json()}")

    // Self::dispatch(store_to_action.to_owned(), op)?;
    // @web_sys.log("store after action: " + global_store.to_json().to_string())
    self.store.val.update(op)
    match op {
      Noop => raise @respo_node.RespoCommonError("TODO")
      _ => ()
    }
  }
  let renderer = fn() -> @respo_node.RespoNode[_]!@respo_node.RespoCommonError {
    self.view!()
  }
  let ret = @respo.render_node?(
    mount_target,
    fn() { self.store },
    renderer,
    dispatch_action,
    Some(100),
  )
  match ret {
    Ok(_) => ()
    Err(e) => @web_sys.error_log(e.to_string())
  }
}
