/// <div> element with children.
pub fn div[T](
  ~attrs : Map[String, String] = {},
  ~event : Map[
    String,
    (RespoEvent, (T) -> Unit!RespoCommonError) -> Unit!RespoCommonError,
  ] = {},
  ~style : RespoStyle = RespoStyle::new(),
  children : Array[RespoNode[T]]
) -> RespoNode[T] {
  RespoNode::Element(
    {
      name: "div",
      attrs,
      event,
      style,
      children: children.mapi(
        fn(idx, child) { (RespoIndexKey(idx.to_string()), child) },
      ),
    },
  )
}

pub fn div_listed[T](
  ~attrs : Map[String, String] = {},
  ~event : Map[
    String,
    (RespoEvent, (T) -> Unit!RespoCommonError) -> Unit!RespoCommonError,
  ] = {},
  ~style : RespoStyle = RespoStyle::new(),
  children : Array[(RespoIndexKey, RespoNode[T])]
) -> RespoNode[T] {
  RespoNode::Element({ name: "div", attrs, event, style, children })
}

pub fn span[T](
  ~attrs : Map[String, String] = {},
  ~event : Map[
    String,
    (RespoEvent, (T) -> Unit!RespoCommonError) -> Unit!RespoCommonError,
  ] = {},
  ~style : RespoStyle = RespoStyle::new(),
  children : Array[RespoNode[T]]
) -> RespoNode[T] {
  RespoNode::Element(
    {
      name: "span",
      attrs,
      event,
      style,
      children: children.mapi(
        fn(idx, child) { (RespoIndexKey(idx.to_string()), child) },
      ),
    },
  )
}

pub fn button[T](
  ~attrs : Map[String, String] = {},
  ~event : Map[
    String,
    (RespoEvent, (T) -> Unit!RespoCommonError) -> Unit!RespoCommonError,
  ] = {},
  ~style : RespoStyle = RespoStyle::new()
) -> RespoNode[T] {
  RespoNode::Element({ name: "button", attrs, event, style, children: [] })
}

pub fn input[T](
  ~attrs : Map[String, String] = {},
  ~event : Map[
    String,
    (RespoEvent, (T) -> Unit!RespoCommonError) -> Unit!RespoCommonError,
  ] = {},
  ~style : RespoStyle = RespoStyle::new()
) -> RespoNode[T] {
  RespoNode::Element({ name: "input", attrs, event, style, children: [] })
}

pub fn br[T](
  ~attrs : Map[String, String] = {},
  ~event : Map[
    String,
    (RespoEvent, (T) -> Unit!RespoCommonError) -> Unit!RespoCommonError,
  ] = {},
  ~style : RespoStyle = RespoStyle::new()
) -> RespoNode[T] {
  RespoNode::Element({ name: "br", attrs, event, style, children: [] })
}

pub fn space[T](~width : Int = 1, ~height : Int = 1) -> RespoNode[T] {
  div(
    attrs=respo_attrs(style=RespoStyle::new(width=Px(width), height=Px(height))),
    [],
  )
}
