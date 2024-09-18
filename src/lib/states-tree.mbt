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
  branches : @hashmap.T[String, RespoStatesTree]
}

pub fn path(self : RespoStatesTree) -> Array[String] {
  self.cursor
}

pub fn cast_branch[T : Default + @json.FromJson + ToJson](
  self : RespoStatesTree
) -> T {
  match self.data {
    Some(v) => return @json.from_json?(v).unwrap()
    None => {
      @web_sys.warn_log(
        "failed to cast state to \{self.data} , at \{self.cursor}",
      )
      return T::default()
    }
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
  let next_cursor = self.cursor
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
      branches: @hashmap.T::new(),
    }
  }
}

pub fn set_in_mut(self : RespoStatesTree, change : RespoUpdateState) -> Unit {
  if change.cursor.is_empty() {
    self.data = change.data.map(fn(x) { x.to_json() })
    // change.backup.clone_into(&mut self.backup);
    // self.backup = change.backup
  } else {
    let (p_head, p_rest) = change.cursor.split_at(1)
    let p0 = p_head[0]
    match self.branches.get(p0) {
      Some(branch) =>
        branch.set_in_mut(
          { cursor: p_rest, data: change.data, backup: change.backup },
        )
      None => {
        let branch = self.pick(p0)
        branch.set_in_mut(
          { cursor: p_rest, data: change.data, backup: change.backup },
        )
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
  backup : @json.JsonValue?
}
