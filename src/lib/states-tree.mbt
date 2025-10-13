// This is a Moonbit file migrated from Rust

///|
/// MoonBit does not allow trait object with `Self`s, use ffi js value to bypass.
type ObscureState

// TODO encode type information in the tree for better conversion safety

///|
fn[T : ToJson] ObscureState::from(v : T) -> ObscureState = "%identity"

///|
fn[T : ToJson] ObscureState::unsafe_cast(self : ObscureState) -> T = "%identity"

///|
/// Respo maintains states in a tree structure, where the keys are strings,
/// each child component "picks" a key to attach its own state to the tree,
/// and it dispatches events to global store to update the state.
pub(all) struct RespoStatesTree {
  /// component local data is dynamically typed. It utilizes Null for detecting Optional values in serialization.
  priv mut data : ObscureState?
  mut backup : Json?
  /// the path to the current state in the tree, use in updating
  cursor : Array[String]
  branches : Map[String, RespoStatesTree]
} derive(Default)

///|
pub impl Eq for RespoStatesTree with equal(self, other) {
  if self.cursor != other.cursor {
    return false
  }
  if self.branches != other.branches {
    return false
  }
  match (self.data, other.data) {
    (Some(a), Some(b)) => {
      if physical_equal(a, b) {
        return true
      }
      return false
    }
    (None, None) => ()
    _ => return false
  }
  match (self.backup, other.backup) {
    (Some(a), Some(b)) => if a != b { return false }
    _ => ()
  }
  return true
}

///|
pub impl ToJson for RespoStatesTree with to_json(self : RespoStatesTree) -> Json {
  let object = {}
  object.set("cursor", self.cursor.to_json())
  object.set("branches", self.branches.to_json())
  object.set("backup", self.backup.to_json())
  object.set("data", Json::null()) // represent variant `None` with null
  Json::object(object)
}

///|
impl Show for RespoStatesTree with output(self, logger) {
  let s = match self.backup {
    Some(data) => data.to_string()
    None => "None".to_string()
  }
  let mut ret = "(States \{self.cursor.to_string()} \{s}"
  for k, v in self.branches {
    ret = ret + "\n  \{k} : \{v}"
  }
  ret = ret + "\n}"
  logger.write_string(ret)
}

// thx to @ChenYubin

///|
pub impl @json.FromJson for RespoStatesTree with from_json(json, path) {
  match json {
    {
      "data": _data,
      "backup": backup,
      "cursor": cursor,
      "branches": branches,
      ..
    } =>
      {
        // when recovered from JSON, data is nothing, information is stored in `backup`.
        // however we cannot restore data from backup here, because we do not know the type.
        data: None,
        backup: @json.from_json(backup, path=path.add_key("backup")),
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
pub extern "js" fn show_obscure_state(msg : String, v : ObscureState) -> Unit =
  #| (msg, v) => { console.log(msg, v) }

///|
pub fn[T : Default + @json.FromJson + ToJson] cast_branch(
  self : RespoStatesTree,
) -> T {
  if self.data is Some(v) {
    // show_obscure_state("cast_branch: got data at \{self.cursor}", v)
    let t : T = v.unsafe_cast()
    // no way to safe guard here since type information is erased
    // @dom_ffi.warn_log("None to cast state at \{self.cursor}")
    return t
  } else if self.backup is Some(v) {
    // println("cast_branch: restore from backup \{v}")
    if (try? @json.from_json(v)) is Ok(t) {
      let t : T = t
      self.data = Some(ObscureState::from(t))
      t
    } else {
      @dom_ffi.warn_log("failed to restore from backup at \{self.cursor}")
      T::default()
    }
  } else {
    // println("cast_branch: no data or backup at \{self.cursor}, use default")
    T::default()
  }
}

///|
/// local state in component could be `None` according to the tree structure
/// ```moonbit
/// let (state, cursor): (LocalState, _) = states.local_pair();
/// ```
pub fn[T : Default + @json.FromJson + ToJson] local_pair(
  self : RespoStatesTree,
) -> (T, @node.RespoCursor[T]) {
  let data = self.cast_branch()
  let cursor = self.path()
  (data, cursor)
}

///|
pub fn pick(self : RespoStatesTree, name : String) -> RespoStatesTree {
  let next_cursor = self.cursor.copy()
  next_cursor.push(name)
  if self.branches.get(name) is Some(prev) {
    {
      data: prev.data,
      backup: prev.backup,
      cursor: next_cursor,
      branches: prev.branches,
    }
  } else {
    { data: None, backup: None, cursor: next_cursor, branches: {} }
  }
}

///|
/// TODO prefer immutable update in future
pub fn set_in_mut(self : RespoStatesTree, change : RespoUpdateState) -> Unit {
  if change.cursor.is_empty() {
    self.data = change.data
    self.backup = change.backup
  } else if change.cursor.length() == 1 {
    let p0 = change.cursor[0]
    match self.branches.get(p0) {
      Some(branch) =>
        branch.set_in_mut({
          cursor: [],
          data: change.data,
          backup: change.backup,
        })
      None => {
        let branch = self.pick(p0)
        branch.set_in_mut({
          cursor: [],
          data: change.data,
          backup: change.backup,
        })
        self.branches.set(p0, branch)
      }
    }
  } else {
    let (p_head, p_rest) = change.cursor.split_at(1)
    let p0 = p_head[0]
    match self.branches.get(p0) {
      Some(branch) =>
        branch.set_in_mut({
          cursor: p_rest,
          data: change.data,
          backup: change.backup,
        })
      None => {
        let branch = self.pick(p0)
        branch.set_in_mut({
          cursor: p_rest,
          data: change.data,
          backup: change.backup,
        })
        self.branches.set(p0, branch)
      }
    }
  }
}

/// local state in component could be `None` according to the tree structure
// type RespoStateBranch Json

///|
/// framework defined action for updating states branch
pub(all) struct RespoUpdateState {
  /// path to the state
  cursor : Array[String]
  /// dyn eq data
  data : ObscureState?
  /// backup data for restoring
  backup : Json?
}

///|
pub impl ToJson for RespoUpdateState with to_json(self) -> Json {
  let object = {}
  object.set("cursor", self.cursor.to_json())
  object.set("backup", self.backup.to_json())
  Json::object(object)
}

///|
pub impl Eq for RespoUpdateState with equal(self, other) {
  if self.cursor != other.cursor {
    return false
  }
  match (self.data, other.data) {
    (Some(a), Some(b)) => {
      if physical_equal(a, b) {
        return true
      }
      return false
    }
    (None, None) => ()
    _ => return false
  }
  match (self.backup, other.backup) {
    (Some(a), Some(b)) => if a != b { return false }
    _ => ()
  }
  return true
}
