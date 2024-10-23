// pub trait RespoApp {
//   // TODO better use RespoAction instead of Show
//   dispatch(Self, (Show) -> UInt) -> Unit!@node.RespoCommonError
//   pick_storage_key(Self) -> String
//   get_mount_target(Self) -> @dom_ffi.Node
//   get_store(Self) -> @json.FromJson
//   // get_loop_delay() -> UInt?
//   // view(Self) -> @node.RespoNode[T]!@node.RespoCommonError
//   // render_loop(Self) -> Unit!@node.RespoCommonError
//   backup_model_beforeunload(Self) -> Unit!@node.RespoCommonError
//   try_load_storage(Self) -> Unit!@node.RespoCommonError
// }

// impl RespoApp with try_load_storage(self) {
//   let window = @dom_ffi.window()
//   let storage = window.local_storage()
//   let key = self.pick_storage_key()
//   match storage.get_item(key) {
//     Some(s) => {
//       let store = self.get_store()
//       store.val = try_from_string!(s)
//     }
//     None => @dom_ffi.log("no storage")
//   }
// }

// pub trait RespoStore: ToJson + @json.FromJson {
//   // TODO better use RespoAction instead of Show
//   update(Self, Show) -> Unit!@node.RespoCommonError
//   get_states(Self) -> RespoStatesTree
//   update_states(Self, RespoStatesTree) -> Unit!@node.RespoCommonError
//   to_string(Self) -> String
//   try_from_string(Self, String) -> Self!@node.RespoCommonError
// }
