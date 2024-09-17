/// <div> element with children.
pub fn div[T](
  domAttrs : @hashmap.T[String, String],
  children : Array[RespoNode[T]]
) -> RespoNode[T] {
  RespoNode::Element(
    {
      name: "div",
      attributes: domAttrs,
      event: @hashmap.new(),
      style: respo_style(),
      children: children.mapi(
        fn(idx, child) { (RespoIndexKey(idx.to_string()), child) },
      ),
    },
  )
}
