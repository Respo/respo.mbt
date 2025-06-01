///| coord of on virtual dom
pub(all) enum RespoCoord {
  Key(RespoIndexKey)
  Comp(String)
}

///|
pub impl Show for RespoCoord with output(self, logger) -> Unit {
  match self {
    Key(key) => logger.write_string("(Key " + key.to_string() + ")")
    Comp(comp) => logger.write_string("(Comp " + comp + ")")
  }
}

///| Diff/patch for virtual DOM, note that children are not included in this type
enum DomChange[T] {
  ReplaceElement(
    coord~ : @immut/array.T[RespoCoord],
    dom_path~ : @immut/array.T[UInt],
    node~ : RespoNode[T]
  )
  ModifyChildren(
    coord~ : @immut/array.T[RespoCoord],
    dom_path~ : @immut/array.T[UInt],
    operations~ : Array[ChildDomOp[T]]
  )
  ModifyAttrs(
    coord~ : @immut/array.T[RespoCoord],
    dom_path~ : @immut/array.T[UInt],
    set~ : Map[String, String],
    unset~ : @hashset.T[String]
  )
  ModifyStyle(
    coord~ : @immut/array.T[RespoCoord],
    dom_path~ : @immut/array.T[UInt],
    set~ : Map[String, String],
    unset~ : @hashset.T[String]
  )
  ModifyEvent(
    coord~ : @immut/array.T[RespoCoord],
    dom_path~ : @immut/array.T[UInt],
    add~ : @hashset.T[RespoEventType],
    remove~ : @hashset.T[RespoEventType]
  )
  Effect(
    coord~ : @immut/array.T[RespoCoord],
    dom_path~ : @immut/array.T[UInt],
    effect_type~ : RespoEffectType,
    skip_indexes~ : @hashset.T[Int]
  )
}

///|
pub impl[T] Show for DomChange[T] with output(self, logger) {
  let ret = match self {
    ReplaceElement(coord~, dom_path~, node~) =>
      str_spaced(wrap_parens=true, ["ReplaceElement", coord, dom_path, node])
    ModifyChildren(coord~, dom_path~, operations~) =>
      str_spaced(wrap_parens=true, [
        "ModifyChildren", coord, dom_path, operations,
      ])
    ModifyAttrs(coord~, dom_path~, set~, unset~) =>
      str_spaced(wrap_parens=true, ["ModifyAttrs", coord, dom_path, set, unset])
    ModifyStyle(coord~, dom_path~, set~, unset~) =>
      str_spaced(wrap_parens=true, ["ModifyStyle", coord, dom_path, set, unset])
    ModifyEvent(coord~, dom_path~, add~, remove~) =>
      str_spaced(wrap_parens=true, ["ModifyEvent", coord, dom_path, add, remove])
    Effect(coord~, dom_path~, effect_type~, skip_indexes~) =>
      str_spaced(wrap_parens=true, [
        "Effect ", coord, dom_path, effect_type, skip_indexes,
      ])
  }
  logger.write_string(ret)
}

///|
pub fn[T] DomChange::to_cirru(self : DomChange[T]) -> @cirru.Cirru {
  match self {
    Effect(coord~, dom_path~, effect_type~, skip_indexes~) =>
      @cirru.List([
        @cirru.Leaf("::effect"),
        effect_type.to_cirru(),
        coord_path_to_cirru(coord),
        dom_path_to_cirru(dom_path),
        indexes_to_cirru(skip_indexes),
      ])
    ReplaceElement(coord~, dom_path~, node~) =>
      @cirru.List([
        @cirru.Leaf("::replace-element"),
        coord_path_to_cirru(coord),
        dom_path_to_cirru(dom_path),
        node.to_cirru(),
      ])
    ModifyChildren(coord~, dom_path~, operations~) =>
      @cirru.List([
        @cirru.Leaf("::modify-children"),
        coord_path_to_cirru(coord),
        dom_path_to_cirru(dom_path),
        @cirru.List(operations.map(fn(x) { x.to_cirru() })),
      ])
    ModifyAttrs(coord~, dom_path~, set~, unset~) => {
      let set_data : Array[@cirru.Cirru] = []
      for pair in set {
        let (key, value) = pair
        set_data.push(@cirru.List([@cirru.Leaf(key), @cirru.Leaf(value)]))
      }
      let unset_data : Array[@cirru.Cirru] = []
      for key in unset {
        unset_data.push(@cirru.Leaf(key))
      }
      @cirru.List([
        @cirru.Leaf("::modify-attrs"),
        coord_path_to_cirru(coord),
        dom_path_to_cirru(dom_path),
        @cirru.List([@cirru.List(set_data), @cirru.List(unset_data)]),
      ])
    }
    ModifyStyle(coord~, dom_path~, set~, unset~) => {
      let set_data : Array[@cirru.Cirru] = []
      for pair in set {
        let (key, value) = pair
        set_data.push(@cirru.List([@cirru.Leaf(key), @cirru.Leaf(value)]))
      }
      let unset_data : Array[@cirru.Cirru] = []
      for key in unset {
        unset_data.push(@cirru.Leaf(key))
      }
      @cirru.List([
        @cirru.Leaf("::modify-style"),
        coord_path_to_cirru(coord),
        dom_path_to_cirru(dom_path),
        @cirru.List([@cirru.List(set_data), @cirru.List(unset_data)]),
      ])
    }
    ModifyEvent(coord~, dom_path~, add~, remove~) => {
      let add_data : Array[@cirru.Cirru] = []
      for event in add {
        add_data.push(event.to_cirru())
      }
      let remove_data : Array[@cirru.Cirru] = []
      for event in remove {
        remove_data.push(event.to_cirru())
      }
      @cirru.List([
        @cirru.Leaf("::modify-event"),
        coord_path_to_cirru(coord),
        dom_path_to_cirru(dom_path),
        @cirru.List([@cirru.List(add_data), @cirru.List(remove_data)]),
      ])
    }
  }
}

///|
enum ChildDomOp[T] {
  InsertAfter(UInt, RespoIndexKey, RespoNode[T])
  RemoveAt(UInt)
  Append(RespoIndexKey, RespoNode[T])
  Prepend(RespoIndexKey, RespoNode[T])
  NestedEffect(
    nested_coord~ : @immut/array.T[RespoCoord],
    nested_dom_path~ : @immut/array.T[UInt],
    effect_type~ : RespoEffectType,
    skip_indexes~ : @hashset.T[Int]
  )
}

///|
impl[T] Show for ChildDomOp[T] with output(self, logger) {
  let ret = match self {
    InsertAfter(index, key, node) =>
      str_spaced(wrap_parens=true, ["InsertAfter", index, key, node])
    RemoveAt(index) => str_spaced(wrap_parens=true, ["RemoveAt", index])
    Append(key, node) => str_spaced(wrap_parens=true, ["Append", key, node])
    Prepend(key, node) => str_spaced(wrap_parens=true, ["Prepend", key, node])
    NestedEffect(nested_coord~, nested_dom_path~, effect_type~, skip_indexes~) =>
      str_spaced(wrap_parens=true, [
        "NestedEffect", nested_coord, nested_dom_path, effect_type, skip_indexes,
      ])
  }
  logger.write_string(ret)
}

///|
pub fn[T] ChildDomOp::to_cirru(self : ChildDomOp[T]) -> @cirru.Cirru {
  match self {
    InsertAfter(index, key, node) =>
      @cirru.List([
        @cirru.Leaf("::insert-after"),
        @cirru.Leaf(index.to_string()),
        key.to_cirru(),
        node.to_cirru(),
      ])
    RemoveAt(index) =>
      @cirru.List([@cirru.Leaf("::remove-at"), @cirru.Leaf(index.to_string())])
    Append(key, node) =>
      @cirru.List([@cirru.Leaf("::append"), key.to_cirru(), node.to_cirru()])
    Prepend(key, node) =>
      @cirru.List([@cirru.Leaf("::prepend"), key.to_cirru(), node.to_cirru()])
    NestedEffect(nested_coord~, nested_dom_path~, effect_type~, skip_indexes~) =>
      @cirru.List([
        @cirru.Leaf("::nested-effect"),
        coord_path_to_cirru(nested_coord),
        dom_path_to_cirru(nested_dom_path),
        effect_type.to_cirru(),
        indexes_to_cirru(skip_indexes),
      ])
  }
}

///|
pub fn[T] get_dom_path(self : DomChange[T]) -> @immut/array.T[UInt] {
  match self {
    ReplaceElement(dom_path~, ..) => dom_path
    ModifyChildren(dom_path~, ..) => dom_path
    ModifyAttrs(dom_path~, ..) => dom_path
    ModifyStyle(dom_path~, ..) => dom_path
    ModifyEvent(dom_path~, ..) => dom_path
    Effect(dom_path~, ..) => dom_path
  }
}

///|
pub fn RespoCoord::to_cirru(self : RespoCoord) -> @cirru.Cirru {
  match self {
    Key(key) => Leaf(key.to_string())
    Comp(comp) => List([@cirru.Leaf("::Comp"), @cirru.Leaf(comp)])
  }
}

///|
pub fn coord_path_to_cirru(coord : @immut/array.T[RespoCoord]) -> @cirru.Cirru {
  let items = coord.map(fn(x) { x.to_cirru() })
  @cirru.List(items.to_array())
}

///|
pub fn dom_path_to_cirru(dom_path : @immut/array.T[UInt]) -> @cirru.Cirru {
  let items = dom_path.map(fn(x) { @cirru.Leaf(x.to_string()) })
  @cirru.List(items.to_array())
}

// turn @hashset.T[Int] to Cirru
///|
pub fn indexes_to_cirru(xs : @hashset.T[Int]) -> @cirru.Cirru {
  let items = []
  for x in xs {
    items.push(@cirru.Leaf(x.to_string()))
  }
  @cirru.List(items)
}
