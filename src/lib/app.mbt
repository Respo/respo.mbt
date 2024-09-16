type! RespoCommonError String

pub trait RespoApp {
  dispatch(Self, (RespoAction) -> UInt) -> Unit!RespoCommonError
  pick_storage_key() -> String
  get_mount_target() -> @web_sys.Node
  get_store() -> RespoStore
  get_loop_delay() -> UInt?
  view(Self) -> @node.RespoNode[T]!RespoCommonError
  render_loop(Self) -> Unit!RespoCommonError
  backup_model_beforeunload(Self) -> Unit!RespoCommonError
  try_load_storage(Self) -> Unit!RespoCommonError
}

pub trait RespoStore {
  update(Self, RespoAction) -> Unit!RespoCommonError
  get_states(Self) -> RespoStateTree
  update_states(Self, RespoStateTree) -> Unit!RespoCommonError
  to_string(Self) -> String
  try_from_string(Self, String) -> Self!RespoCommonError
}
