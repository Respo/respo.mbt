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
    ~set : @hashmap.T[String, String],
    ~unset : @hashset.T[String]
  )
  ModifyStyle(
    ~coord : Array[RespoCoord],
    ~dom_path : Array[UInt],
    ~set : @hashmap.T[String, String],
    ~unset : @hashset.T[String]
  )
  ModifyEvent(
    ~coord : Array[RespoCoord],
    ~dom_path : Array[UInt],
    ~add : @hashset.T[String],
    ~remove : @hashset.T[String]
  )
  Effect(
    ~coord : Array[RespoCoord],
    ~dom_path : Array[UInt],
    ~effect_type : RespoEffectType,
    ~skip_indexes : @hashset.T[Int]
  )
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
