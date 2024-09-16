enum RespoCoord {
  Key(RespoIndexKey)
  Comp(String)
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

// TODO convert Cirru
