// pub trait RespoApp {
//   dispatch(Self, (@node.RespoAction) -> UInt) -> Unit!@node.RespoCommonError
//   pick_storage_key() -> String
//   get_mount_target() -> @dom_ffi.Node
//   get_store() -> RespoStore
//   get_loop_delay() -> UInt?
//   view(Self) -> @node.RespoNode[T]!@node.RespoCommonError
//   render_loop(Self) -> Unit!@node.RespoCommonError
//   backup_model_beforeunload(Self) -> Unit!@node.RespoCommonError
//   try_load_storage(Self) -> Unit!@node.RespoCommonError
// }

// pub trait RespoStore {
//   update(Self, @node.RespoAction) -> Unit!@node.RespoCommonError
//   get_states(Self) -> RespoStatesTree
//   update_states(Self, RespoStatesTree) -> Unit!@node.RespoCommonError
//   to_string(Self) -> String
//   try_from_string(Self, String) -> Self!@node.RespoCommonError
// }
