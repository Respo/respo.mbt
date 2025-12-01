///|
pub(all) struct RespoIndexKey(String) derive(Eq)

///|
pub fn RespoIndexKey::to_cirru(self : RespoIndexKey) -> Cirru {
  Leaf(self.0)
}

///|
pub impl Show for RespoIndexKey with output(self, logger) {
  logger.write_string(self.0)
}

///|
/// internal abstraction for an element
pub(all) struct RespoElement[T] {
  /// tagName
  name : String
  attrs : Map[String, String]
  event : Map[
    RespoEventType,
    (RespoEvent, DispatchFn[T]) -> Unit raise RespoCommonError,
  ]
  /// inlines styles, partially typed.
  /// there's also a macro called `static_styles` for inserting CSS rules
  style : RespoStyle
  /// each child as a key like a string, by default generated from index,
  /// they are used in diffing, so it's better to be distinct, although not required to be.
  children : Array[(RespoIndexKey, RespoNode[T])]
}

///|
pub fn[T] RespoElement::to_node(self : RespoElement[T]) -> RespoNode[T] {
  Element(self)
}

///|
pub impl[T] Eq for RespoElement[T] with equal(
  self : RespoElement[T],
  other : RespoElement[T],
) -> Bool {
  if self.name != other.name {
    return false
  }
  if self.attrs != other.attrs {
    return false
  }
  if self.event.length() != other.event.length() {
    return false
  }

  // do not compare the function itself
  for pair in self.event {
    let (key, _value) = pair
    if not(other.event.contains(key)) {
      return false
    }
  }
  if not(self.style == other.style) {
    return false
  }
  if not(self.children == other.children) {
    return false
  }
  true
}

///|
pub impl[T] Show for RespoElement[T] with output(self, logger) {
  let ret = "(RespoElement \{self.name})"
  logger.write_string(ret)
}

///|
pub fn[T] RespoElement::set_attribute(
  self : RespoElement[T],
  key : String,
  value : String,
) -> Unit {
  self.attrs.set(key, value)
}

// TODO implement methods for RespoElement

///|
/// create attributes for an element
pub fn respo_attrs(
  id? : String,
  class_name? : String,
  // ~style? : RespoStyle,
  hidden? : Bool,
  disabled? : Bool,
  value? : String,
  src? : String,
  href? : String,
  alt? : String,
  title? : String,
  placeholder? : String,
  /// actually type
  type_? : String,
  name? : String,
  checked? : Bool,
  selected? : Bool,
  read_only? : Bool,
  max_length? : Int,
  min_length? : Int,
  tab_index? : Int,
  content_editable? : Bool,
  width? : String,
  height? : String,
  inner_text? : String,
  innerHTML? : String,
) -> Map[String, String] {
  let result = {}
  if id is Some(value) {
    result.set("id", value)
  }
  if class_name is Some(value) {
    result.set("class", value)
  }
  // style properties at top level
  // match style {
  //   Some(value) => result.set("style", value.to_string())
  //   None => ()
  // }
  if hidden is Some(value) {
    result.set("hidden", value.to_string())
  }
  if disabled is Some(value) {
    result.set("disabled", value.to_string())
  }
  if value is Some(value) {
    result.set("value", value)
  }
  if src is Some(value) {
    result.set("src", value)
  }
  if href is Some(value) {
    result.set("href", value)
  }
  if alt is Some(value) {
    result.set("alt", value)
  }
  if title is Some(value) {
    result.set("title", value)
  }
  if placeholder is Some(value) {
    result.set("placeholder", value)
  }
  if type_ is Some(value) {
    result.set("type", value)
  }
  if name is Some(value) {
    result.set("name", value)
  }
  if checked is Some(value) {
    result.set("checked", value.to_string())
  }
  if selected is Some(value) {
    result.set("selected", value.to_string())
  }
  if read_only is Some(value) {
    result.set("readOnly", value.to_string())
  }
  if max_length is Some(value) {
    result.set("maxLength", value.to_string())
  }
  if min_length is Some(value) {
    result.set("minLength", value.to_string())
  }
  if tab_index is Some(value) {
    result.set("tabIndex", value.to_string())
  }
  if content_editable is Some(value) {
    result.set("contentEditable", value.to_string())
  }
  if width is Some(value) {
    result.set("width", value)
  }
  if height is Some(value) {
    result.set("height", value)
  }
  if inner_text is Some(value) {
    result.set("innerText", value)
  }
  if innerHTML is Some(value) {
    result.set("innerHTML", value)
  }
  result
}

///|
pub fn[T] RespoElement::to_cirru(self : RespoElement[T]) -> Cirru {
  let attrs = self.attrs
  // let event = self.event
  // let style = self.style
  let children = self.children
  let attrs_in_list : Array[Cirru] = []
  for pair in attrs {
    let (key, value) = pair
    attrs_in_list.push(List([Leaf(key), Leaf(value)]))
  }
  let children_mark : Array[Cirru] = []
  for pair in children {
    let (key, child) = pair
    children_mark.push(List([key.to_cirru(), child.to_cirru()]))
  }
  List([Leaf(self.name), List(attrs_in_list), List(children_mark)])
}
