// This is a Moonbit file migrated from Rust

/// Respo maintains states in a tree structure, where the keys are strings,
/// each child component "picks" a key to attach its own state to the tree,
/// and it dispatches events to global store to update the state.
pub struct RespoStatesTree {
  /// local data
  mut data : @json.JsonValue?
  // mut backup : @json.JsonValue?
  /// the path to the current state in the tree, use in updating
  cursor : Array[String]
  branches : Map[String, RespoStatesTree]
} derive(ToJson)

pub fn RespoStatesTree::to_string(self : RespoStatesTree) -> String {
  let mut ret = "(States \{self.cursor.to_string()} \{self.data.to_string()}"
  for k, v in self.branches {
    ret = ret + "\n  " + k + " : " + v.to_string()
  }
  ret = ret + "\n}"
  ret
}

pub fn RespoStatesTree::default() -> RespoStatesTree {
  {
    data: None,
    // backup: None,
    cursor: [],
    branches: {},
  }
}

// thx to @ChenYubin
pub impl @json.FromJson for RespoStatesTree with from_json(json, path) {
  match json {
    { "data": data, "cursor": cursor, "branches": branches } =>
      {
        // data: @json.from_json!(data, path=path.add_key("data")), // Json FromJson not implemented yet
        data: match data {
          [v] => Some(v)
          _ => None
        },
        cursor: @json.from_json!(cursor, path=path.add_key("cursor")),
        branches: @json.from_json!(branches, path=path.add_key("branches")),
      }
    _ => raise @json.JsonDecodeError((path, "unexpected json"))
  }
}

pub fn path(self : RespoStatesTree) -> Array[String] {
  self.cursor
}

pub fn cast_branch[T : Default + @json.FromJson + ToJson](
  self : RespoStatesTree
) -> T {
  match self.data {
    Some(v) =>
      match @json.from_json?(v) {
        Ok(t) => t
        Err(e) => {
          @dom_ffi.error_log("failed to cast state: \{e} , at \{self.cursor}")
          @dom_ffi.error_log("data: " + v.to_string())
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

pub fn set_in_mut(self : RespoStatesTree, change : RespoUpdateState) -> Unit {
  if change.cursor.is_empty() {
    self.data = change.data.map(fn(x) { x.to_json() })
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

/// framework defined action for updating states branch
pub struct RespoUpdateState {
  /// path to the state
  cursor : Array[String]
  /// dyn eq data
  data : Json?
  /// backup data for restoring
  // backup : @json.JsonValue?
}

pub fn RespoUpdateState::to_json(self : RespoUpdateState) -> @json.JsonValue {
  let object = {}
  object.set("cursor", self.cursor.to_json())
  object.set("data", self.data.to_json())
  // object.set("backup", self.backup.to_json())
  Object(object)
}
