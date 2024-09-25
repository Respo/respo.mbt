pub fn diff_tree[T](
  new_tree : RespoNode[T],
  old_tree : RespoNode[T],
  coord : Array[RespoCoord],
  dom_path : Array[UInt],
  changes : Ref[Array[DomChange[T]]]
) -> Unit!RespoCommonError {
  match (new_tree, old_tree) {
    (RespoNode::Component(left), RespoNode::Component(right)) => {
      let { name, effects, tree: new_child } = left
      let { name: name_old, effects: old_effects, tree: old_child } = right
      if name == name_old {
        let next_coord = coord
        next_coord.push(RespoCoord::Comp(name))
        diff_tree!(new_child, old_child, next_coord, dom_path, changes)
        let skipped : @hashset.T[Int] = @hashset.new()
        for idx, effect in effects {
          match old_effects.get(idx) {
            Some(old_effect) => if effect == old_effect { skipped.insert(idx) }
            None => ()
          }
        }
        if skipped.size() < effects.length() {
          changes.val.push(
            DomChange::Effect(
              ~coord,
              ~dom_path,
              effect_type=RespoEffectType::BeforeUpdate,
              skip_indexes=skipped,
            ),
          )
          changes.val.push(
            DomChange::Effect(
              ~coord,
              ~dom_path,
              effect_type=RespoEffectType::Updated,
              skip_indexes=skipped,
            ),
          )
        }
      } else {
        collect_effects_inside_out_as!(
          old_tree,
          coord,
          dom_path,
          RespoEffectType::BeforeUnmount,
          changes,
        )
        // crate::util::log!("compare elements: {:?} {:?}", new_child, old_child);
        changes.val.push(
          DomChange::ReplaceElement(~coord, ~dom_path, node=new_child),
        )
        collect_effects_outside_in_as!(
          new_tree,
          coord,
          dom_path,
          RespoEffectType::Mounted,
          changes,
        )
      }
    }
    (RespoNode::Component(_) as a, _b) => {
      collect_effects_inside_out_as!(
        old_tree,
        coord,
        dom_path,
        RespoEffectType::BeforeUnmount,
        changes,
      )
      changes.val.push(DomChange::ReplaceElement(~coord, ~dom_path, node=a))
      collect_effects_outside_in_as!(
        new_tree,
        coord,
        dom_path,
        RespoEffectType::Mounted,
        changes,
      )
    }
    (a, RespoNode::Component(_)) => {
      collect_effects_inside_out_as!(
        old_tree,
        coord,
        dom_path,
        RespoEffectType::BeforeUnmount,
        changes,
      )
      changes.val.push(DomChange::ReplaceElement(~coord, ~dom_path, node=a))
      collect_effects_outside_in_as!(
        new_tree,
        coord,
        dom_path,
        RespoEffectType::Mounted,
        changes,
      )
    }
    (RespoNode::Element(left) as a, RespoNode::Element(right)) => {
      let { name, attrs, style, event, children } = left
      let {
        name: old_name,
        attrs: old_attrs,
        style: old_style,
        event: old_event,
        children: old_children,
      } = right
      if name != old_name {
        collect_effects_inside_out_as!(
          old_tree,
          coord,
          dom_path,
          RespoEffectType::BeforeUnmount,
          changes,
        )
        changes.val.push(DomChange::ReplaceElement(~coord, ~dom_path, node=a))
        collect_effects_outside_in_as!(
          new_tree,
          coord,
          dom_path,
          RespoEffectType::Mounted,
          changes,
        )
      } else {
        let reset_inner = @ref.new(false)
        diff_attrs(attrs, old_attrs, coord, dom_path, changes, reset_inner)
        diff_style(
          Map::from_array(style._),
          Map::from_array(old_style._),
          coord,
          dom_path,
          changes,
        )
        diff_event(event, old_event, coord, dom_path, changes)
        if reset_inner.val {
          // children is empty after innerHTML or innerText changed
          diff_children!(children, [], coord, dom_path, changes)
        } else {
          diff_children!(children, old_children, coord, dom_path, changes)
        }
      }
    }
    (RespoNode::Referenced(new_cell), RespoNode::Referenced(old_cell)) =>
      // pointer compare https://stackoverflow.com/a/60241585/883571
      if physical_equal(new_cell, old_cell) {
        return
      } else {
        diff_tree!(new_cell, old_cell, coord, dom_path, changes)
      }
    (RespoNode::Referenced(new_cell), b) =>
      diff_tree!(new_cell, b, coord, dom_path, changes)
    (a, RespoNode::Referenced(old_cell)) =>
      diff_tree!(a, old_cell, coord, dom_path, changes)
  }
}

fn diff_attrs[T](
  new_attrs : Map[String, String],
  old_attrs : Map[String, String],
  coord : Array[RespoCoord],
  dom_path : Array[UInt],
  changes : Ref[Array[DomChange[T]]],
  reset_inner : Ref[Bool]
) -> Unit {
  let added : Map[String, String] = {}
  let removed : @hashset.T[String] = @hashset.new()
  for pair in new_attrs.iter() {
    let (key, value) = pair
    if old_attrs.contains(key) {
      if old_attrs[key] != Some(value) {
        added.set(key, value)
        if inner_changed(key) {
          reset_inner.val = true
        }
      }
    } else {
      added.set(key, value)
      if inner_changed(key) {
        reset_inner.val = true
      }
    }
  }
  for pair in old_attrs.iter() {
    let (key, _) = pair
    if not(new_attrs.contains(key)) {
      removed.insert(key)
      if inner_changed(key) {
        reset_inner.val = true
      }
    }
  }
  if not(added.is_empty()) || not(removed.is_empty()) {
    changes.val.push(
      DomChange::ModifyAttrs(~coord, ~dom_path, set=added, unset=removed),
    )
  }
}

/// changed innerHTML or innerText, which resets children values
fn inner_changed(key : String) -> Bool {
  key == "innerHTML" || key == "innerText" || key == "inner-text"
}

fn diff_style[T](
  new_style : Map[String, String],
  old_style : Map[String, String],
  coord : Array[RespoCoord],
  dom_path : Array[UInt],
  changes : Ref[Array[DomChange[T]]]
) -> Unit {
  let added : Map[String, String] = Map::new()
  let removed : @hashset.T[String] = @hashset.new()
  for pair in new_style {
    let (key, value) = pair
    if old_style.contains(key) {
      if old_style[key] != Some(value) {
        added.set(key, value)
      }
    } else {
      added.set(key, value)
    }
  }
  for pair in old_style {
    let (key, _) = pair
    if not(new_style.contains(key)) {
      removed.insert(key)
    }
  }
  if not(added.is_empty()) || not(removed.is_empty()) {
    changes.val.push(
      DomChange::ModifyStyle(~coord, ~dom_path, set=added, unset=removed),
    )
  }
}

fn difference[T : Eq + Hash](
  a : @hashset.T[T],
  b : @hashset.T[T]
) -> @hashset.T[T] {
  let m = @hashset.new()
  a.each(fn(k) { if not(b.contains(k)) { m.insert(k) } })
  m
}

fn diff_event[T, U](
  new_event : Map[String, U],
  old_event : Map[String, U],
  coord : Array[RespoCoord],
  dom_path : Array[UInt],
  changes : Ref[Array[DomChange[T]]]
) -> Unit {
  let new_keys = @hashset.from_array(
    new_event.to_array().map(fn(pair) { pair.0 }),
  ) // TODO performance
  let old_keys = @hashset.from_array(
    old_event.to_array().map(fn(pair) { pair.0 }),
  )
  if hashset_eq(new_keys, old_keys).not() {
    changes.val.push(
      DomChange::ModifyEvent(
        ~coord,
        ~dom_path,
        add=new_keys.difference(old_keys),
        remove=old_keys.difference(new_keys),
      ),
    )
  }
}

fn diff_children[T](
  new_children : Array[(RespoIndexKey, RespoNode[T])],
  old_children : Array[(RespoIndexKey, RespoNode[T])],
  coord : Array[RespoCoord],
  dom_path : Array[UInt],
  changes : Ref[Array[DomChange[T]]]
) -> Unit!RespoCommonError {
  let mut cursor : UInt = 0
  let operations : Ref[Array[ChildDomOp[T]]] = @ref.new([])
  let mut new_tracking_pointer : Int = 0
  let mut old_tracking_pointer : Int = 0
  for {
    if new_tracking_pointer >= new_children.length() {
      if old_tracking_pointer >= old_children.length() {
        if not(operations.val.is_empty()) {
          changes.val.push(
            DomChange::ModifyChildren(
              ~coord,
              ~dom_path,
              operations=operations.val,
            ),
          )
        }
        return
      } else {
        let old_entry = old_children[old_tracking_pointer]
        let child_coord = [RespoCoord::Key(old_entry.0)]
        let child_dom_path = [cursor]
        nested_effects_inside_out_as!(
          old_entry.1,
          child_coord,
          child_dom_path,
          RespoEffectType::BeforeUnmount,
          operations,
        )
        operations.val.push(ChildDomOp::RemoveAt(cursor))
        old_tracking_pointer += 1
      }
    } else if old_tracking_pointer >= old_children.length() {
      let (new_key, new_child) = new_children[new_tracking_pointer]
      operations.val.push(ChildDomOp::Append(new_key, new_child))
      let child_coord = [RespoCoord::Key(new_key)]
      let child_dom_path = [cursor]
      nested_effects_outside_in_as!(
        new_child,
        child_coord,
        child_dom_path,
        RespoEffectType::Mounted,
        operations,
      )
      new_tracking_pointer += 1
    } else {
      let new_entry = new_children[new_tracking_pointer]
      let old_entry = old_children[old_tracking_pointer]
      if new_entry.0 == old_entry.0 {
        let next_coord = coord
        next_coord.push(RespoCoord::Key(new_entry.0))
        let next_dom_path = dom_path
        next_dom_path.push(cursor)
        diff_tree!(new_entry.1, old_entry.1, next_coord, next_dom_path, changes)
        cursor += 1
        new_tracking_pointer += 1
        old_tracking_pointer += 1
      } else if Some(new_entry.0) ==
        old_children.get(old_tracking_pointer + 1).map(fst) ||
        Some(new_entry.0) == old_children.get(old_tracking_pointer + 2).map(fst) ||
        Some(new_entry.0) == old_children.get(old_tracking_pointer + 3).map(fst) {
        // look ahead for 3 entries, if still not found, regards this as a remove
        let child_coord = [RespoCoord::Key(old_entry.0)]
        let child_dom_path = [cursor]
        nested_effects_inside_out_as!(
          old_entry.1,
          child_coord,
          child_dom_path,
          RespoEffectType::BeforeUnmount,
          operations,
        )
        operations.val.push(ChildDomOp::RemoveAt(cursor))
        old_tracking_pointer += 1
      } else if Some(old_entry.0) ==
        new_children.get(new_tracking_pointer + 1).map(fst) ||
        Some(old_entry.0) == new_children.get(new_tracking_pointer + 2).map(fst) ||
        Some(old_entry.0) == new_children.get(new_tracking_pointer + 3).map(fst) {
        if cursor == 0 {
          operations.val.push(ChildDomOp::Prepend(new_entry.0, new_entry.1))
        } else {
          operations.val.push(
            ChildDomOp::InsertAfter(cursor - 1, new_entry.0, new_entry.1),
          )
        }
        let child_coord = [RespoCoord::Key(new_entry.0)]
        let child_dom_path = [cursor]
        nested_effects_outside_in_as!(
          new_entry.1,
          child_coord,
          child_dom_path,
          RespoEffectType::Mounted,
          operations,
        )
        cursor += 1
        new_tracking_pointer += 1
      } else {
        let child_coord = [RespoCoord::Key(old_entry.0)]
        let child_dom_path = [cursor]
        nested_effects_inside_out_as!(
          old_entry.1,
          child_coord,
          child_dom_path,
          RespoEffectType::BeforeUnmount,
          operations,
        )
        operations.val.push(ChildDomOp::RemoveAt(cursor))
        if cursor == 0 {
          operations.val.push(ChildDomOp::Prepend(new_entry.0, new_entry.1))
        } else {
          operations.val.push(
            ChildDomOp::InsertAfter(cursor - 1, new_entry.0, new_entry.1),
          )
        }
        let child_coord = [RespoCoord::Key(new_entry.0)]
        let child_dom_path = [cursor]
        nested_effects_outside_in_as!(
          new_entry.1,
          child_coord,
          child_dom_path,
          RespoEffectType::Mounted,
          operations,
        )
        cursor += 1
        new_tracking_pointer += 1
        old_tracking_pointer += 1
      }
    }
  }
}

// effects at parent are collected first
pub fn collect_effects_outside_in_as[T](
  tree : RespoNode[T],
  coord : Array[RespoCoord],
  dom_path : Array[UInt],
  effect_type : RespoEffectType,
  changes : Ref[Array[DomChange[T]]]
) -> Unit!RespoCommonError {
  match tree {
    RespoNode::Component(left) => {
      let { name, effects, tree } = left
      if not(effects.is_empty()) {
        changes.val.push(
          DomChange::Effect(
            ~coord,
            ~dom_path,
            ~effect_type,
            skip_indexes=@hashset.new(),
          ),
        )
      }
      let next_coord = coord
      next_coord.push(RespoCoord::Comp(name))
      collect_effects_outside_in_as!(
        tree, next_coord, dom_path, effect_type, changes,
      )
    }
    RespoNode::Element(right) => {
      let { children, .. } = right
      for idx, pair in children.iter2() {
        let (k, child) = pair
        let next_coord = coord
        next_coord.push(RespoCoord::Key(RespoIndexKey(k.to_string())))
        let next_dom_path = dom_path
        next_dom_path.push(idx.reinterpret_as_uint())
        collect_effects_outside_in_as!(
          child, next_coord, next_dom_path, effect_type, changes,
        )
      }
    }
    RespoNode::Referenced(cell) =>
      collect_effects_outside_in_as!(
        cell, coord, dom_path, effect_type, changes,
      )
  }
}

// effects deeper inside children are collected first
pub fn collect_effects_inside_out_as[T](
  tree : RespoNode[T],
  coord : Array[RespoCoord],
  dom_path : Array[UInt],
  effect_type : RespoEffectType,
  changes : Ref[Array[DomChange[T]]]
) -> Unit!RespoCommonError {
  match tree {
    RespoNode::Component(left) => {
      let { name, effects, tree } = left
      let next_coord = coord
      next_coord.push(RespoCoord::Comp(name))
      collect_effects_inside_out_as!(
        tree, next_coord, dom_path, effect_type, changes,
      )
      if not(effects.is_empty()) {
        changes.val.push(
          DomChange::Effect(
            ~coord,
            ~dom_path,
            ~effect_type,
            skip_indexes=@hashset.new(),
          ),
        )
      }
    }
    RespoNode::Element(left) => {
      let { children, .. } = left
      let mut idx = 0
      for pair in children.iter() {
        let (k, child) = pair
        let next_coord = coord
        next_coord.push(RespoCoord::Key(k))
        let next_dom_path = dom_path
        next_dom_path.push(idx.reinterpret_as_uint())
        collect_effects_inside_out_as!(
          child, next_coord, next_dom_path, effect_type, changes,
        )
        idx += 1
      }
    }
    RespoNode::Referenced(cell) =>
      collect_effects_inside_out_as!(
        cell, coord, dom_path, effect_type, changes,
      )
  }
}

// effects at parent are collected first
fn nested_effects_outside_in_as[T](
  tree : RespoNode[T],
  coord : Array[RespoCoord],
  dom_path : Array[UInt],
  effect_type : RespoEffectType,
  operations : Ref[Array[ChildDomOp[T]]]
) -> Unit!RespoCommonError {
  match tree {
    RespoNode::Component(left) => {
      let { name, effects, tree } = left
      if not(effects.is_empty()) {
        operations.val.push(
          ChildDomOp::NestedEffect(
            nested_coord=coord,
            nested_dom_path=dom_path,
            ~effect_type,
            skip_indexes=@hashset.new(),
          ),
        )
      }
      let next_coord = coord
      next_coord.push(RespoCoord::Comp(name))
      nested_effects_outside_in_as!(
        tree, next_coord, dom_path, effect_type, operations,
      )
    }
    RespoNode::Element(left) => {
      let { children, .. } = left
      for pair in children {
        let (k, child) = pair
        let next_coord = coord
        next_coord.push(RespoCoord::Key(k))
        nested_effects_outside_in_as!(
          child, next_coord, dom_path, effect_type, operations,
        )
      }
    }
    RespoNode::Referenced(cell) =>
      nested_effects_outside_in_as!(
        cell, coord, dom_path, effect_type, operations,
      )
  }
}

// effects deeper inside children are collected first
fn nested_effects_inside_out_as[T](
  tree : RespoNode[T],
  coord : Array[RespoCoord],
  dom_path : Array[UInt],
  effect_type : RespoEffectType,
  operations : Ref[Array[ChildDomOp[T]]]
) -> Unit!RespoCommonError {
  match tree {
    RespoNode::Component(left) => {
      let { name, effects, tree } = left
      let next_coord = coord
      next_coord.push(RespoCoord::Comp(name))
      nested_effects_inside_out_as!(
        tree, next_coord, dom_path, effect_type, operations,
      )
      if not(effects.is_empty()) {
        operations.val.push(
          ChildDomOp::NestedEffect(
            nested_coord=coord,
            nested_dom_path=dom_path,
            ~effect_type,
            skip_indexes=@hashset.new(),
          ),
        )
      }
    }
    RespoNode::Element(left) => {
      let { children, .. } = left
      for pair in children {
        let (k, child) = pair
        let next_coord = coord
        next_coord.push(RespoCoord::Key(k))
        nested_effects_inside_out_as!(
          child, next_coord, dom_path, effect_type, operations,
        )
      }
    }
    RespoNode::Referenced(cell) =>
      nested_effects_inside_out_as!(
        cell, coord, dom_path, effect_type, operations,
      )
  }
}

fn fst[T, U](pair : (T, U)) -> T {
  pair.0
}
