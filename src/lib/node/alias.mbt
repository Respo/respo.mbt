/// <div> element with children.
pub fn div[T](
  ~attrs : Map[String, String] = {},
  children : Array[RespoNode[T]]
) -> RespoNode[T] {
  RespoNode::Element(
    {
      name: "div",
      attributes: attrs,
      event: @hashmap.new(),
      style: respo_style(),
      children: children.mapi(
        fn(idx, child) { (RespoIndexKey(idx.to_string()), child) },
      ),
    },
  )
}

pub fn span[T](
  ~attrs : Map[String, String] = {},
  children : Array[RespoNode[T]]
) -> RespoNode[T] {
  RespoNode::Element(
    {
      name: "span",
      attributes: attrs,
      event: @hashmap.new(),
      style: respo_style(),
      children: children.mapi(
        fn(idx, child) { (RespoIndexKey(idx.to_string()), child) },
      ),
    },
  )
}

pub fn button[T](
  ~attrs : Map[String, String] = {},
  children : Array[RespoNode[T]]
) -> RespoNode[T] {
  RespoNode::Element(
    {
      name: "button",
      attributes: attrs,
      event: @hashmap.new(),
      style: RespoStyle::new(),
      children: children.mapi(
        fn(idx, child) { (RespoIndexKey(idx.to_string()), child) },
      ),
    },
  )
}
