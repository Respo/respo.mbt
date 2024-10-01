pub enum RespoCoord {
  Key(RespoIndexKey)
  Comp(String)
}

pub fn to_string(self : RespoCoord) -> String {
  match self {
    Key(key) => "(Key " + key.to_string() + ")"
    Comp(comp) => "(Comp " + comp + ")"
  }
}

pub fn output(self : RespoCoord, logger : Logger) -> Unit {
  match self {
    Key(key) => logger.write_string("(Key " + key.to_string() + ")")
    Comp(comp) => logger.write_string("(Comp " + comp + ")")
  }
}

// TODO convert Cirru

enum DomChange[T] {
  ReplaceElement(
    ~coord : Array[RespoCoord],
    ~dom_path : Array[UInt],
    ~node : RespoNode[T]
  )
  ModifyChildren(
    ~coord : Array[RespoCoord],
    ~dom_path : Array[UInt],
    ~operations : Array[ChildDomOp[T]]
  )
  ModifyAttrs(
    ~coord : Array[RespoCoord],
    ~dom_path : Array[UInt],
    ~set : Map[String, String],
    ~unset : @hashset.T[String]
  )
  ModifyStyle(
    ~coord : Array[RespoCoord],
    ~dom_path : Array[UInt],
    ~set : Map[String, String],
    ~unset : @hashset.T[String]
  )
  ModifyEvent(
    ~coord : Array[RespoCoord],
    ~dom_path : Array[UInt],
    ~add : @hashset.T[RespoEventType],
    ~remove : @hashset.T[RespoEventType]
  )
  Effect(
    ~coord : Array[RespoCoord],
    ~dom_path : Array[UInt],
    ~effect_type : RespoEffectType,
    ~skip_indexes : @hashset.T[Int]
  )
}

impl[T] Show for DomChange[T] with output(self, logger) {
  logger.write_string(self.to_string())
}

fn DomChange::to_string[T](self : DomChange[T]) -> String {
  match self {
    ReplaceElement(~coord, ~dom_path, ~node) =>
      "(ReplaceElement " +
      coord.to_string() +
      " " +
      dom_path.to_string() +
      " " +
      node.to_string() +
      ")"
    ModifyChildren(~coord, ~dom_path, ~operations) =>
      "(ModifyChildren " +
      coord.to_string() +
      " " +
      dom_path.to_string() +
      " " +
      operations.to_string() +
      ")"
    ModifyAttrs(~coord, ~dom_path, ~set, ~unset) =>
      "(ModifyAttrs " +
      coord.to_string() +
      " " +
      dom_path.to_string() +
      " " +
      set.to_string() +
      " " +
      unset.to_string() +
      ")"
    ModifyStyle(~coord, ~dom_path, ~set, ~unset) =>
      "(ModifyStyle " +
      coord.to_string() +
      " " +
      dom_path.to_string() +
      " " +
      set.to_string() +
      " " +
      unset.to_string() +
      ")"
    ModifyEvent(~coord, ~dom_path, ~add, ~remove) =>
      "(ModifyEvent " +
      coord.to_string() +
      " " +
      dom_path.to_string() +
      " " +
      add.to_string() +
      " " +
      remove.to_string() +
      ")"
    Effect(~coord, ~dom_path, ~effect_type, ~skip_indexes) =>
      "(Effect " +
      coord.to_string() +
      " " +
      dom_path.to_string() +
      " " +
      effect_type.to_string() +
      " " +
      skip_indexes.to_string() +
      ")"
  }
}

enum ChildDomOp[T] {
  InsertAfter(UInt, RespoIndexKey, RespoNode[T])
  RemoveAt(UInt)
  Append(RespoIndexKey, RespoNode[T])
  Prepend(RespoIndexKey, RespoNode[T])
  NestedEffect(
    ~nested_coord : Array[RespoCoord],
    ~nested_dom_path : Array[UInt],
    ~effect_type : RespoEffectType,
    ~skip_indexes : @hashset.T[Int]
  )
}

impl[T] Show for ChildDomOp[T] with output(self, logger) {
  logger.write_string(self.to_string())
}

fn ChildDomOp::to_string[T](self : ChildDomOp[T]) -> String {
  match self {
    InsertAfter(index, key, node) =>
      "(InsertAfter " +
      index.to_string() +
      " " +
      key.to_string() +
      " " +
      node.to_string() +
      ")"
    RemoveAt(index) => "(RemoveAt " + index.to_string() + ")"
    Append(key, node) =>
      "(Append " + key.to_string() + " " + node.to_string() + ")"
    Prepend(key, node) =>
      "(Prepend " + key.to_string() + " " + node.to_string() + ")"
    NestedEffect(~nested_coord, ~nested_dom_path, ~effect_type, ~skip_indexes) =>
      "(NestedEffect " +
      nested_coord.to_string() +
      " " +
      nested_dom_path.to_string() +
      " " +
      effect_type.to_string() +
      " " +
      skip_indexes.to_string() +
      ")"
  }
}

pub fn get_dom_path[T](self : DomChange[T]) -> Array[UInt] {
  match self {
    ReplaceElement(~dom_path, ..) => dom_path
    ModifyChildren(~dom_path, ..) => dom_path
    ModifyAttrs(~dom_path, ..) => dom_path
    ModifyStyle(~dom_path, ..) => dom_path
    ModifyEvent(~dom_path, ..) => dom_path
    Effect(~dom_path, ..) => dom_path
  }
}

// TODO convert Cirru
