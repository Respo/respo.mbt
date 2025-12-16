// This is a Moonbit file migrated from Rust
// Refactored to use immutable data structures following Respo's design philosophy

///|
/// MoonBit does not allow trait object with `Self`s, use ffi js value to bypass.
type ObscureState

// TODO encode type information in the tree for better conversion safety

///|
// fn[T : ToJson] ObscureState::from(v : T) -> ObscureState = "%identity"

///|
fn[T : ToJson] ObscureState::unsafe_cast(self : ObscureState) -> T = "%identity"

///|
/// Respo maintains states in a tree structure, where the keys are strings,
/// each child component "picks" a key to attach its own state to the tree,
/// and it dispatches events to global store to update the state.
///
/// This is an immutable data structure - all updates return new trees.
pub(all) struct RespoStatesTree {
  /// component local data is dynamically typed. It utilizes Null for detecting Optional values in serialization.
  priv data : ObscureState?
  backup : Json?
  /// the path to the current state in the tree, use in updating
  cursor : @immut/array.T[String]
  branches : @immut/hashmap.HashMap[String, RespoStatesTree]
}

///|
pub impl Default for RespoStatesTree with default() {
  {
    data: None,
    backup: None,
    cursor: @immut/array.new(),
    branches: @immut/hashmap.new(),
  }
}

///|
pub impl Eq for RespoStatesTree with equal(self, other) {
  if self.cursor.to_array() != other.cursor.to_array() {
    return false
  }
  // Compare branches by converting to arrays for comparison
  let self_branches = self.branches.to_array()
  let other_branches = other.branches.to_array()
  if self_branches.length() != other_branches.length() {
    return false
  }
  for k, v in self.branches {
    match other.branches.get(k) {
      Some(ov) => if v != ov { return false }
      None => return false
    }
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
  object.set("cursor", self.cursor.to_array().to_json())
  // Convert branches to a mutable Map for JSON serialization
  let branches_map : Map[String, RespoStatesTree] = {}
  for k, v in self.branches {
    branches_map.set(k, v)
  }
  object.set("branches", branches_map.to_json())
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
  let mut ret = "(States \{self.cursor.to_array().to_string()} \{s}"
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
    } => {
      // when recovered from JSON, data is nothing, information is stored in `backup`.
      // however we cannot restore data from backup here, because we do not know the type.
      let cursor_arr : Array[String] = @json.from_json(
        cursor,
        path=path.add_key("cursor"),
      )
      let branches_map : Map[String, RespoStatesTree] = @json.from_json(
        branches,
        path=path.add_key("branches"),
      )
      {
        data: None,
        backup: @json.from_json(backup, path=path.add_key("backup")),
        cursor: @immut/array.from_array(cursor_arr),
        branches: @immut/hashmap.from_iter(branches_map.iter()),
      }
    }
    _ => raise @json.JsonDecodeError((path, "unexpected json"))
  }
}

///|
pub fn[T] RespoStatesTree::path(self : RespoStatesTree) -> @node.RespoCursor[T] {
  @node.RespoCursor::new(self.cursor.to_array())
}

///|
pub extern "js" fn show_obscure_state(msg : String, v : ObscureState) -> Unit =
  #| (msg, v) => { console.log(msg, v) }

///|
/// Cast the data in the branch to the specified type.
/// If data is not present but backup exists, restore from backup.
pub fn[T : Default + @json.FromJson + ToJson] RespoStatesTree::cast_branch(
  self : RespoStatesTree,
) -> T {
  if self.data is Some(v) {
    // show_obscure_state("cast_branch: got data at \{self.cursor}", v)
    let t : T = v.unsafe_cast()
    // no way to safe guard here since type information is erased
    t
  } else if self.backup is Some(v) {
    // println("cast_branch: restore from backup \{v}")
    try {
      let t : T = @json.from_json(v)
      t
    } catch {
      _ => {
        @dom_ffi.warn_log(
          "failed to restore from backup at \{self.cursor.to_array()}",
        )
        T::default()
      }
    }
  } else {
    // println("cast_branch: no data or backup at \{self.cursor}, use default")
    T::default()
  }
}

///|
/// local state in component could be `None` according to the tree structure
/// Returns (state, cursor)
/// ```ignore
/// let (state, cursor) = states.local_pair();
/// ```
pub fn[T : Default + @json.FromJson + ToJson] RespoStatesTree::local_pair(
  self : RespoStatesTree,
) -> (T, @node.RespoCursor[T]) {
  let data : T = self.cast_branch()
  let cursor = self.path()
  (data, cursor)
}

///|
/// Pick a branch from the tree by name, returns a new tree representing that branch.
pub fn RespoStatesTree::pick(
  self : RespoStatesTree,
  name : String,
) -> RespoStatesTree {
  let next_cursor = self.cursor.push(name)
  if self.branches.get(name) is Some(prev) {
    {
      data: prev.data,
      backup: prev.backup,
      cursor: next_cursor,
      branches: prev.branches,
    }
  } else {
    {
      data: None,
      backup: None,
      cursor: next_cursor,
      branches: @immut/hashmap.new(),
    }
  }
}

///|
/// Immutably update the tree at the specified cursor path.
/// Returns a new tree with the update applied.
pub fn RespoStatesTree::set_in(
  self : RespoStatesTree,
  change : RespoUpdateState,
) -> RespoStatesTree {
  if change.cursor.is_empty() {
    // Update at current position
    { ..self, data: change.data, backup: change.backup }
  } else if change.cursor.length() == 1 {
    let p0 = change.cursor[0]
    let branch = match self.branches.get(p0) {
      Some(existing) => existing.set_in({ ..change, cursor: [] })
      None => {
        let new_branch = self.pick(p0)
        new_branch.set_in({ ..change, cursor: [] })
      }
    }
    { ..self, branches: self.branches.add(p0, branch) }
  } else {
    // Use ArrayView slices and convert to Array for recursive call
    let p0 = change.cursor[0]
    let p_rest = change.cursor[1:].to_array()
    let branch = match self.branches.get(p0) {
      Some(existing) => existing.set_in({ ..change, cursor: p_rest })
      None => {
        let new_branch = self.pick(p0)
        new_branch.set_in({ ..change, cursor: p_rest })
      }
    }
    { ..self, branches: self.branches.add(p0, branch) }
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
