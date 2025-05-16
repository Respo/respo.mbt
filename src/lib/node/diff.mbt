///| Diffing algorithm for RespoNode
pub fn diff_tree[T](
  new_tree : RespoNode[T],
  old_tree : RespoNode[T],
  coord : @immut/array.T[RespoCoord],
  dom_path : @immut/array.T[UInt],
  changes : Ref[Array[DomChange[T]]]
) -> Unit!RespoCommonError {
  if physical_equal(new_tree, old_tree) {
    return
  }
  match (new_tree, old_tree) {
    (Component(left), Component(right)) => {
      let { name, effects, tree: new_child } = left
      let { name: name_old, effects: old_effects, tree: old_child } = right
      if name == name_old {
        let next_coord = coord.push(Comp(name))
        diff_tree!(new_child, old_child, next_coord, dom_path, changes)
        let skipped : @hashset.T[Int] = @hashset.new()
        for idx, effect in effects {
          match old_effects.get(idx) {
            Some(old_effect) => if effect == old_effect { skipped.add(idx) }
            None => ()
          }
        }
        if skipped.size() < effects.length() {
          changes.val.push(
            Effect(
              coord~,
              dom_path~,
              effect_type=BeforeUpdate,
              skip_indexes=skipped,
            ),
          )
          changes.val.push(
            Effect(coord~, dom_path~, effect_type=Updated, skip_indexes=skipped),
          )
        }
      } else {
        collect_effects_inside_out_as!(
          old_tree,
          coord,
          dom_path,
          BeforeUnmount,
          changes,
        )
        // crate::util::log!("compare elements: {:?} {:?}", new_child, old_child);
        changes.val.push(ReplaceElement(coord~, dom_path~, node=new_child))
        collect_effects_outside_in_as!(
          new_tree,
          coord,
          dom_path,
          Mounted,
          changes,
        )
      }
    }
    (Component(_) as a, _b) => {
      collect_effects_inside_out_as!(
        old_tree,
        coord,
        dom_path,
        BeforeUnmount,
        changes,
      )
      changes.val.push(ReplaceElement(coord~, dom_path~, node=a))
      collect_effects_outside_in_as!(
        new_tree,
        coord,
        dom_path,
        Mounted,
        changes,
      )
    }
    (a, Component(_)) => {
      collect_effects_inside_out_as!(
        old_tree,
        coord,
        dom_path,
        BeforeUnmount,
        changes,
      )
      changes.val.push(ReplaceElement(coord~, dom_path~, node=a))
      collect_effects_outside_in_as!(
        new_tree,
        coord,
        dom_path,
        Mounted,
        changes,
      )
    }
    (Element(left) as a, Element(right)) => {
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
          BeforeUnmount,
          changes,
        )
        changes.val.push(ReplaceElement(coord~, dom_path~, node=a))
        collect_effects_outside_in_as!(
          new_tree,
          coord,
          dom_path,
          Mounted,
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
  }
}

///|
fn diff_attrs[T](
  new_attrs : Map[String, String],
  old_attrs : Map[String, String],
  coord : @immut/array.T[RespoCoord],
  dom_path : @immut/array.T[UInt],
  changes : Ref[Array[DomChange[T]]],
  reset_inner : Ref[Bool]
) -> Unit {
  let added : Map[String, String] = {}
  let removed : @hashset.T[String] = @hashset.new()
  for pair in new_attrs.iter() {
    let (key, value) = pair
    if old_attrs.contains(key) {
      if old_attrs.get(key) != Some(value) {
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
      removed.add(key)
      if inner_changed(key) {
        reset_inner.val = true
      }
    }
  }
  if not(added.is_empty()) || not(removed.is_empty()) {
    changes.val.push(ModifyAttrs(coord~, dom_path~, set=added, unset=removed))
  }
}

///| changed innerHTML or innerText, which resets children values
fn inner_changed(key : String) -> Bool {
  key == "innerHTML" || key == "innerText" || key == "inner-text"
}

///|
fn diff_style[T](
  new_style : Map[String, String],
  old_style : Map[String, String],
  coord : @immut/array.T[RespoCoord],
  dom_path : @immut/array.T[UInt],
  changes : Ref[Array[DomChange[T]]]
) -> Unit {
  let added : Map[String, String] = Map::new()
  let removed : @hashset.T[String] = @hashset.new()
  for pair in new_style {
    let (key, value) = pair
    if old_style.contains(key) {
      if old_style.get(key) != Some(value) {
        added.set(key, value)
      }
    } else {
      added.set(key, value)
    }
  }
  for pair in old_style {
    let (key, _) = pair
    if not(new_style.contains(key)) {
      removed.add(key)
    }
  }
  if not(added.is_empty()) || not(removed.is_empty()) {
    changes.val.push(ModifyStyle(coord~, dom_path~, set=added, unset=removed))
  }
}

///|
fn diff_event[T, U](
  new_event : Map[RespoEventType, U],
  old_event : Map[RespoEventType, U],
  coord : @immut/array.T[RespoCoord],
  dom_path : @immut/array.T[UInt],
  changes : Ref[Array[DomChange[T]]]
) -> Unit {
  let new_keys = @hashset.from_array(
    new_event.to_array().map(fn(pair) { pair.0 }),
  ) // TODO performance
  let old_keys = @hashset.from_array(
    old_event.to_array().map(fn(pair) { pair.0 }),
  )
  if not(hashset_eq(new_keys, old_keys)) {
    changes.val.push(
      ModifyEvent(
        coord~,
        dom_path~,
        add=new_keys.difference(old_keys),
        remove=old_keys.difference(new_keys),
      ),
    )
  }
}

///|
fn diff_children[T](
  new_children : Array[(RespoIndexKey, RespoNode[T])],
  old_children : Array[(RespoIndexKey, RespoNode[T])],
  coord : @immut/array.T[RespoCoord],
  dom_path : @immut/array.T[UInt],
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
            ModifyChildren(coord~, dom_path~, operations=operations.val),
          )
        }
        return
      } else {
        let old_entry = old_children[old_tracking_pointer]
        let child_coord = @immut/array.from_array([Key(old_entry.0)])
        let child_dom_path = @immut/array.from_array([cursor])
        nested_effects_inside_out_as!(
          old_entry.1,
          child_coord,
          child_dom_path,
          BeforeUnmount,
          operations,
        )
        operations.val.push(RemoveAt(cursor))
        old_tracking_pointer += 1
      }
    } else if old_tracking_pointer >= old_children.length() {
      let (new_key, new_child) = new_children[new_tracking_pointer]
      operations.val.push(Append(new_key, new_child))
      let child_coord = @immut/array.from_array([Key(new_key)])
      let child_dom_path = @immut/array.from_array([cursor])
      nested_effects_outside_in_as!(
        new_child,
        child_coord,
        child_dom_path,
        Mounted,
        operations,
      )
      new_tracking_pointer += 1
    } else {
      let new_entry = new_children[new_tracking_pointer]
      let old_entry = old_children[old_tracking_pointer]
      if new_entry.0 == old_entry.0 {
        let next_coord = coord.push(Key(new_entry.0))
        let next_dom_path = dom_path.push(cursor)
        diff_tree!(new_entry.1, old_entry.1, next_coord, next_dom_path, changes)
        cursor += 1
        new_tracking_pointer += 1
        old_tracking_pointer += 1
      } else if Some(new_entry.0) ==
        old_children.get(old_tracking_pointer + 1).map(fst) ||
        Some(new_entry.0) == old_children.get(old_tracking_pointer + 2).map(fst) ||
        Some(new_entry.0) == old_children.get(old_tracking_pointer + 3).map(fst) {
        // look ahead for 3 entries, if still not found, regards this as a remove
        let child_coord = @immut/array.from_array([Key(old_entry.0)])
        let child_dom_path = @immut/array.from_array([cursor])
        nested_effects_inside_out_as!(
          old_entry.1,
          child_coord,
          child_dom_path,
          BeforeUnmount,
          operations,
        )
        operations.val.push(RemoveAt(cursor))
        old_tracking_pointer += 1
      } else if Some(old_entry.0) ==
        new_children.get(new_tracking_pointer + 1).map(fst) ||
        Some(old_entry.0) == new_children.get(new_tracking_pointer + 2).map(fst) ||
        Some(old_entry.0) == new_children.get(new_tracking_pointer + 3).map(fst) {
        if cursor == 0 {
          operations.val.push(Prepend(new_entry.0, new_entry.1))
        } else {
          operations.val.push(InsertAfter(cursor - 1, new_entry.0, new_entry.1))
        }
        let child_coord = @immut/array.from_array([Key(new_entry.0)])
        let child_dom_path = @immut/array.from_array([cursor])
        nested_effects_outside_in_as!(
          new_entry.1,
          child_coord,
          child_dom_path,
          Mounted,
          operations,
        )
        cursor += 1
        new_tracking_pointer += 1
      } else {
        let child_coord : @immut/array.T[RespoCoord] = @immut/array.from_array([
          Key(old_entry.0),
        ])
        let child_dom_path = @immut/array.from_array([cursor])
        nested_effects_inside_out_as!(
          old_entry.1,
          child_coord,
          child_dom_path,
          BeforeUnmount,
          operations,
        )
        operations.val.push(RemoveAt(cursor))
        if cursor == 0 {
          operations.val.push(Prepend(new_entry.0, new_entry.1))
        } else {
          operations.val.push(InsertAfter(cursor - 1, new_entry.0, new_entry.1))
        }
        let child_coord = @immut/array.from_array([Key(new_entry.0)])
        let child_dom_path = @immut/array.from_array([cursor])
        nested_effects_outside_in_as!(
          new_entry.1,
          child_coord,
          child_dom_path,
          Mounted,
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
///|
pub fn collect_effects_outside_in_as[T](
  tree : RespoNode[T],
  coord : @immut/array.T[RespoCoord],
  dom_path : @immut/array.T[UInt],
  effect_type : RespoEffectType,
  changes : Ref[Array[DomChange[T]]]
) -> Unit!RespoCommonError {
  match tree {
    Component(left) => {
      let { name, effects, tree } = left
      if not(effects.is_empty()) {
        changes.val.push(
          Effect(coord~, dom_path~, effect_type~, skip_indexes=@hashset.new()),
        )
      }
      let next_coord = coord.push(Comp(name))
      collect_effects_outside_in_as!(
        tree, next_coord, dom_path, effect_type, changes,
      )
    }
    Element(right) => {
      let { children, .. } = right
      for idx, pair in children.iter2() {
        let (k, child) = pair
        let next_coord = coord.push(Key(RespoIndexKey(k.to_string())))
        let next_dom_path = dom_path.push(idx.reinterpret_as_uint())
        collect_effects_outside_in_as!(
          child, next_coord, next_dom_path, effect_type, changes,
        )
      }
    }
  }
}

// effects deeper inside children are collected first
///|
pub fn collect_effects_inside_out_as[T](
  tree : RespoNode[T],
  coord : @immut/array.T[RespoCoord],
  dom_path : @immut/array.T[UInt],
  effect_type : RespoEffectType,
  changes : Ref[Array[DomChange[T]]]
) -> Unit!RespoCommonError {
  match tree {
    Component(left) => {
      let { name, effects, tree } = left
      let next_coord = coord.push(Comp(name))
      collect_effects_inside_out_as!(
        tree, next_coord, dom_path, effect_type, changes,
      )
      if not(effects.is_empty()) {
        changes.val.push(
          Effect(coord~, dom_path~, effect_type~, skip_indexes=@hashset.new()),
        )
      }
    }
    Element(left) => {
      let { children, .. } = left
      let mut idx = 0
      for pair in children.iter() {
        let (k, child) = pair
        let next_coord = coord.push(Key(k))
        let next_dom_path = dom_path.push(idx.reinterpret_as_uint())
        collect_effects_inside_out_as!(
          child, next_coord, next_dom_path, effect_type, changes,
        )
        idx += 1
      }
    }
  }
}

// effects at parent are collected first
///|
fn nested_effects_outside_in_as[T](
  tree : RespoNode[T],
  coord : @immut/array.T[RespoCoord],
  dom_path : @immut/array.T[UInt],
  effect_type : RespoEffectType,
  operations : Ref[Array[ChildDomOp[T]]]
) -> Unit!RespoCommonError {
  match tree {
    Component(left) => {
      let { name, effects, tree } = left
      if not(effects.is_empty()) {
        operations.val.push(
          NestedEffect(
            nested_coord=coord,
            nested_dom_path=dom_path,
            effect_type~,
            skip_indexes=@hashset.new(),
          ),
        )
      }
      let next_coord = coord.push(Comp(name))
      nested_effects_outside_in_as!(
        tree, next_coord, dom_path, effect_type, operations,
      )
    }
    Element(left) => {
      let { children, .. } = left
      for pair in children {
        let (k, child) = pair
        let next_coord = coord.push(Key(k))
        nested_effects_outside_in_as!(
          child, next_coord, dom_path, effect_type, operations,
        )
      }
    }
  }
}

// effects deeper inside children are collected first
///|
fn nested_effects_inside_out_as[T](
  tree : RespoNode[T],
  coord : @immut/array.T[RespoCoord],
  dom_path : @immut/array.T[UInt],
  effect_type : RespoEffectType,
  operations : Ref[Array[ChildDomOp[T]]]
) -> Unit!RespoCommonError {
  match tree {
    Component(left) => {
      let { name, effects, tree } = left
      let next_coord = coord.push(Comp(name))
      nested_effects_inside_out_as!(
        tree, next_coord, dom_path, effect_type, operations,
      )
      if not(effects.is_empty()) {
        operations.val.push(
          NestedEffect(
            nested_coord=coord,
            nested_dom_path=dom_path,
            effect_type~,
            skip_indexes=@hashset.new(),
          ),
        )
      }
    }
    Element(left) => {
      let { children, .. } = left
      for pair in children {
        let (k, child) = pair
        let next_coord = coord.push(Key(k))
        nested_effects_inside_out_as!(
          child, next_coord, dom_path, effect_type, operations,
        )
      }
    }
  }
}

///|
fn fst[T, U](pair : (T, U)) -> T {
  pair.0
}
