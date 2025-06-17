// This is a Moonbit file migrated from Rust

///| MoonBit does not allow trait object with `Self`s, use ffi js value to bypass.
#external
priv type ObscureState

///|
priv struct RespoStateData {} derive(Default, ToJson, @json.FromJson, Eq)

///|
extern "js" fn _state_to_obscure(s : RespoStateData) -> ObscureState =
  #| (s) => s

///|
extern "js" fn state_from_obscure(s : ObscureState) -> RespoStateData =
  #| (s) => s

///|
extern "js" fn json_to_obscure(s : Json) -> ObscureState =
  #| (s) => s

///|
extern "js" fn json_from_obscure(s : ObscureState) -> Json =
  #| (s) => s

///| Respo maintains states in a tree structure, where the keys are strings,
/// each child component "picks" a key to attach its own state to the tree,
/// and it dispatches events to global store to update the state.
pub(all) struct RespoStatesTree {
  /// component local data is dynamically typed. It utilizes Null for detecting Optional values in serialization.
  priv mut data : ObscureState?
  // mut backup : @json.JsonValue?
  /// the path to the current state in the tree, use in updating
  cursor : Array[String]
  branches : Map[String, RespoStatesTree]
}

///|
pub impl Eq for RespoStatesTree with op_equal(self, other) {
  if self.cursor != other.cursor {
    return false
  }
  if self.branches != other.branches {
    return false
  }
  match (self.data, other.data) {
    (Some(a), Some(b)) =>
      if state_from_obscure(a) != state_from_obscure(b) {
        return false
      }
    (None, None) => ()
    _ => return false
  }
  return true
}

///|
pub impl ToJson for RespoStatesTree with to_json(self : RespoStatesTree) -> Json {
  let object = {}
  // object.set("data", json_from_any(self.data).to_json()) // TODO need to use manual version by now
  // object.set("backup", self.backup.to_json())
  object.set("cursor", self.cursor.to_json())
  object.set("branches", self.branches.to_json())
  if self.data is Some(data) {
    object.set("data", json_from_obscure(data))
  } else {
    object.set("data", Json::null())
  }
  Json::object(object)
}

///|
impl Show for RespoStatesTree with output(self, logger) {
  let s = match self.data {
    Some(data) => json_from_obscure(data).to_string()
    None => "None".to_string()
  }
  let mut ret = "(States \{self.cursor.to_string()} \{s}"
  for k, v in self.branches {
    ret = ret + "\n  \{k} : \{v}"
  }
  ret = ret + "\n}"
  logger.write_string(ret)
}

///|
pub fn RespoStatesTree::default() -> RespoStatesTree {
  {
    data: None,
    // backup: None,
    cursor: [],
    branches: {},
  }
}

// thx to @ChenYubin
///|
pub impl @json.FromJson for RespoStatesTree with from_json(json, path) {
  match json {
    { "data": data, "cursor": cursor, "branches": branches, .. } =>
      {
        // data: @json.from_json!(data, path=path.add_key("data")), // Json FromJson not implemented yet
        data: match data {
          Null => None
          v => Some(json_to_obscure(v))
        },
        cursor: @json.from_json(cursor, path=path.add_key("cursor")),
        branches: @json.from_json(branches, path=path.add_key("branches")),
      }
    _ => raise @json.JsonDecodeError((path, "unexpected json"))
  }
}

///|
pub fn[T] RespoStatesTree::path(self : RespoStatesTree) -> @node.RespoCursor[T] {
  @node.RespoCursor::new(self.cursor)
}

///|
pub fn[T : Default + @json.FromJson + ToJson] cast_branch(
  self : RespoStatesTree
) -> T {
  match self.data {
    Some(v) =>
      match (try? @json.from_json(json_from_obscure(v))) {
        Ok(t) => t
        Err(e) => {
          @dom_ffi.error_log("failed to cast state: \{e} , at \{self.cursor}")
          @dom_ffi.error_log("data: " + json_from_obscure(v).to_string())
          T::default()
        }
      }
    None =>
      // @dom_ffi.warn_log("None to cast state at \{self.cursor}")
      return T::default()
  }
  // match self.backup {
  //   Some(v) => {
  //     let mut t = T::default()
  //     // if let Err(e) = t.restore_from(v) {
  //     //   warn_log!("failed to restore from backup: {} , at {:?}", e, self.cursor);
  //     // }
  //     t
  //   }
  //   None => T
  // }
}

///| local state in component could be `None` according to the tree structure
/// ```moonbit
/// let (state, cursor): (LocalState, _) = states.local_pair();
/// ```
pub fn[T : Default + @json.FromJson + ToJson] local_pair(
  self : RespoStatesTree
) -> (T, @node.RespoCursor[T]) {
  let data = self.cast_branch()
  let cursor = self.path()
  (data, cursor)
}

///|
pub fn pick(self : RespoStatesTree, name : String) -> RespoStatesTree {
  let next_cursor = self.cursor.copy()
  next_cursor.push(name)
  if self.branches.contains(name) {
    let prev = self.branches.get(name).unwrap()
    {
      data: prev.data,
      // backup: prev.backup,
      cursor: next_cursor,
      branches: prev.branches,
    }
  } else {
    {
      data: None,
      // backup: None,
      cursor: next_cursor,
      branches: {},
    }
  }
}

///|
pub fn set_in_mut(self : RespoStatesTree, change : RespoUpdateState) -> Unit {
  if change.cursor.is_empty() {
    self.data = change.data.map(fn(x) { json_to_obscure(x.to_json()) })
    // change.backup.clone_into(&mut self.backup);
    // self.backup = change.backup
  } else if change.cursor.length() == 1 {
    let p0 = change.cursor[0]
    match self.branches.get(p0) {
      Some(branch) => branch.set_in_mut({ cursor: [], data: change.data })
      None => {
        let branch = self.pick(p0)
        branch.set_in_mut({ cursor: [], data: change.data })
        self.branches.set(p0, branch)
      }
    }
  } else {
    let (p_head, p_rest) = change.cursor.split_at(1)
    let p0 = p_head[0]
    match self.branches.get(p0) {
      Some(branch) => branch.set_in_mut({ cursor: p_rest, data: change.data })
      None => {
        let branch = self.pick(p0)
        branch.set_in_mut({ cursor: p_rest, data: change.data })
        self.branches.set(p0, branch)
      }
    }
  }
}

/// local state in component could be `None` according to the tree structure
// type RespoStateBranch Json

///| framework defined action for updating states branch
pub(all) struct RespoUpdateState {
  /// path to the state
  cursor : Array[String]
  /// dyn eq data
  data : Json?
  /// backup data for restoring
  // backup : Json?
}

///|
pub fn RespoUpdateState::to_json(self : RespoUpdateState) -> Json {
  let object = {}
  object.set("cursor", self.cursor.to_json())
  object.set("data", self.data.to_json())
  // object.set("backup", self.backup.to_json())
  Json::object(object)
}
