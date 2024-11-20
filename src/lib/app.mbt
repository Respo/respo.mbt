/// get basic App structure
pub(all) struct RespoApp[Model] {
  store : Ref[Model]
  storage_key : String
  mount_target : @dom_ffi.Node
}

/// backup store to local storage before unload

pub fn backup_model_beforeunload[Model : ToJson](
  self : RespoApp[Model]
) -> Unit {
  let window = @dom_ffi.window()
  let storage = window.local_storage()
  let p = self.storage_key
  let store = self.store.val
  let beforeunload = fn(_e : @dom_ffi.BeforeUnloadEvent) {
    let content = store.to_json().stringify()
    // util::log!("before unload {} {}", p, content);
    storage.set_item(p, content)
  }
  window.set_onbeforeunload(beforeunload)
}

pub fn try_load_storage[Model : @json.FromJson + Default](
  key : String
) -> Model {
  let window = @dom_ffi.window()
  let storage = window.local_storage()
  match storage.get_item(key) {
    Some(s) =>
      match @json.parse?(s) {
        Ok(j) =>
          match @json.from_json?(j) {
            Ok(s) => s
            Err(e) => {
              @dom_ffi.log("failed to parse storage: \{e}")
              Model::default()
            }
          }
        Err(e) => {
          @dom_ffi.log("failed to parse storage: \{e}")
          Model::default()
        }
      }
    None => {
      @dom_ffi.log("no storage")
      Model::default()
    }
  }
}

pub fn RespoApp::render_loop[Model, ActionOp](
  self : RespoApp[Model],
  renderer : () -> @node.RespoNode[ActionOp]!@node.RespoCommonError,
  dispatch_action : (ActionOp) -> Unit!@node.RespoCommonError
) -> Unit {
  let mount_target = self.mount_target
  let ret = render_node?(
    mount_target,
    self.store,
    renderer,
    dispatch_action,
    Some(100),
  )
  match ret {
    Ok(_) => ()
    Err(e) => @dom_ffi.error_log(e.to_string())
  }
}

// pub trait RespoStore: ToJson + @json.FromJson {
//   // TODO better use RespoAction instead of Show
//   update(Self, Show) -> Unit!@node.RespoCommonError
//   get_states(Self) -> RespoStatesTree
//   update_states(Self, RespoStatesTree) -> Unit!@node.RespoCommonError
//   to_string(Self) -> String
//   try_from_string(Self, String) -> Self!@node.RespoCommonError
// }
