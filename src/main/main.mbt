let app_store_key : String = "demo_respo_store"

struct App {
  store : Ref[Store]
  mount_target : @dom_ffi.Node
}

fn App::get_store(self : App) -> Ref[Store] {
  self.store
}

fn App::get_mount_target(self : App) -> @dom_ffi.Node {
  self.mount_target
}

fn App::dispatch(self : App, op : ActionOp) -> Unit {
  // TODO intent
  @dom_ffi.log("Action: " + op.to_string())
  self.store.val.update(op)
}

fn App::view(
  self : App
) -> @respo_node.RespoNode[ActionOp]!@respo_node.RespoCommonError {
  let store = self.store.val
  // @dom_ffi.log("Store to render: " + store.to_json().stringify(indent=2))
  let states = store.get_states()
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
    mount_target: @dom_ffi.window()
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

fn App::render_loop(self : App) -> Unit {
  let mount_target = self.mount_target
  // let store_to_action = global_store.to_owned()

  let dispatch_action = fn(op : ActionOp) -> Unit!@respo_node.RespoCommonError {
    // @dom_ffi.log("Action: \{op.to_string()}")
    // @dom_ffi.log("Global store: \{global_store.val.to_json()}")

    // Self::dispatch(store_to_action.to_owned(), op)?;
    self.store.val.update(op)
    match op {
      Noop => raise @respo_node.RespoCommonError("TODO")
      _ => ()
    }
  }
  let renderer = fn() -> @respo_node.RespoNode[_]!@respo_node.RespoCommonError {
    let node = self.view!()
    // @dom_ffi.log(
    //   @cirru.format?([node.to_cirru()], { use_inline: false }).unwrap(),
    // )
    node
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
    Err(e) => @dom_ffi.error_log(e.to_string())
  }
}
