///|
/// get basic App structure
pub(all) struct RespoApp[Model] {
  store : Ref[Model]
  storage_key : String
  mount_target : @dom_ffi.Node
}

///|
/// backup store to local storage before unload
pub fn[Model : ToJson] RespoApp::backup_model_beforeunload(
  self : RespoApp[Model],
) -> Unit {
  let window = @dom_ffi.window()
  let storage = window.local_storage()
  let p = self.storage_key
  let store = self.store.val
  let beforeunload = (_e : @dom_ffi.BeforeUnloadEvent) => {
    let content = store.to_json().stringify()
    @dom_ffi.log("before unload \{p} \{content}")
    storage.set_item(p, content)
  }
  window.set_onbeforeunload(beforeunload)
}

///|
pub fn[Model : @json.FromJson + Default] try_load_storage(
  key : String,
) -> Model {
  let window = @dom_ffi.window()
  let storage = window.local_storage()
  match storage.get_item(key) {
    Some(s) => {
      println("loaded storage:\n\{s}")
      try {
        let j = @json.parse(s)
        @json.from_json(j) catch {
          _e => {
            @dom_ffi.log("failed to parse storage: {_e}")
            Model::default()
          }
        }
      } catch {
        _e => {
          @dom_ffi.log("failed to parse storage: {_e}")
          Model::default()
        }
      }
    }
    None => {
      @dom_ffi.log("no storage")
      Model::default()
    }
  }
}

///|
pub fn[Model, ActionOp] RespoApp::render_loop(
  self : RespoApp[Model],
  renderer : () -> @node.RespoNode[ActionOp] raise @node.RespoCommonError,
  dispatch_action : (ActionOp) -> Unit raise @node.RespoCommonError,
) -> Unit {
  let mount_target = self.mount_target
  render_node(mount_target, self.store, renderer, dispatch_action, Some(100)) catch {
    e => @dom_ffi.error_log(e.to_string())
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
