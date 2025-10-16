///|
pub(all) struct RespoIndexKey(String) derive(Eq)

///|
pub fn RespoIndexKey::to_cirru(self : RespoIndexKey) -> Cirru {
  Leaf(self.inner())
}

///|
pub impl Show for RespoIndexKey with output(self, logger) {
  logger.write_string(self.inner())
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
pub fn[T] set_attribute(
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
  match id {
    Some(value) => result.set("id", value)
    None => ()
  }
  match class_name {
    Some(value) => result.set("class", value)
    None => ()
  }
  // style properties at top level
  // match style {
  //   Some(value) => result.set("style", value.to_string())
  //   None => ()
  // }
  match hidden {
    Some(value) => result.set("hidden", value.to_string())
    None => ()
  }
  match disabled {
    Some(value) => result.set("disabled", value.to_string())
    None => ()
  }
  match value {
    Some(value) => result.set("value", value)
    None => ()
  }
  match src {
    Some(value) => result.set("src", value)
    None => ()
  }
  match href {
    Some(value) => result.set("href", value)
    None => ()
  }
  match alt {
    Some(value) => result.set("alt", value)
    None => ()
  }
  match title {
    Some(value) => result.set("title", value)
    None => ()
  }
  match placeholder {
    Some(value) => result.set("placeholder", value)
    None => ()
  }
  match type_ {
    Some(value) => result.set("type", value)
    None => ()
  }
  match name {
    Some(value) => result.set("name", value)
    None => ()
  }
  match checked {
    Some(value) => result.set("checked", value.to_string())
    None => ()
  }
  match selected {
    Some(value) => result.set("selected", value.to_string())
    None => ()
  }
  match read_only {
    Some(value) => result.set("readOnly", value.to_string())
    None => ()
  }
  match max_length {
    Some(value) => result.set("maxLength", value.to_string())
    None => ()
  }
  match min_length {
    Some(value) => result.set("minLength", value.to_string())
    None => ()
  }
  match tab_index {
    Some(value) => result.set("tabIndex", value.to_string())
    None => ()
  }
  match content_editable {
    Some(value) => result.set("contentEditable", value.to_string())
    None => ()
  }
  match width {
    Some(value) => result.set("width", value)
    None => ()
  }
  match height {
    Some(value) => result.set("height", value)
    None => ()
  }
  match inner_text {
    Some(value) => result.set("innerText", value)
    None => ()
  }
  match innerHTML {
    Some(value) => result.set("innerHTML", value)
    None => ()
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
