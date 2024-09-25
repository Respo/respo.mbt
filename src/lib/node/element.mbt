pub type RespoIndexKey String derive(Eq)

pub fn to_string(self : RespoIndexKey) -> String {
  self._
}

/// internal abstraction for an element
pub struct RespoElement[T] {
  /// tagName
  name : String
  attributes : Map[String, String]
  event : @hashmap.T[String, (RespoEvent, (T) -> Unit!RespoCommonError) -> Unit]
  /// inlines styles, partially typed.
  /// there's also a macro called `static_styles` for inserting CSS rules
  style : RespoStyle
  /// each child as a key like a string, by default generated from index,
  /// they are used in diffing, so it's better to be distinct, although not required to be.
  children : Array[(RespoIndexKey, RespoNode[T])]
}

pub fn op_equal[T](self : RespoElement[T], other : RespoElement[T]) -> Bool {
  if self.name != other.name {
    return false
  }
  if self.attributes != other.attributes {
    return false
  }
  if self.event.size() != other.event.size() {
    return false
  }

  // do not compare the function itself
  for pair in self.event {
    let (key, value) = pair
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

fn to_string[T](self : RespoElement[T]) -> String {
  "(RespoElement \{self.name})"
}

// TODO implement methods for RespoElement

pub type RespoAttrs Map[String, String]

pub fn RespoAttrs::new(
  ~id? : String,
  ~className? : String,
  ~style? : String,
  ~hidden? : Bool,
  ~disabled? : Bool,
  ~value? : String,
  ~src? : String,
  ~href? : String,
  ~alt? : String,
  ~title? : String,
  ~placeholder? : String,
  /// actaully type
  ~type_? : String,
  ~name? : String,
  ~checked? : Bool,
  ~selected? : Bool,
  ~readOnly? : Bool,
  ~maxLength? : Int,
  ~minLength? : Int,
  ~tabIndex? : Int,
  ~contentEditable? : Bool,
  ~width? : String,
  ~height? : String
) -> RespoAttrs {
  let mut result = {}
  match id {
    Some(value) => result.set("id", value)
    None => ()
  }
  match className {
    Some(value) => result.set("class", value)
    None => ()
  }
  match style {
    Some(value) => result.set("style", value)
    None => ()
  }
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
  match readOnly {
    Some(value) => result.set("readOnly", value.to_string())
    None => ()
  }
  match maxLength {
    Some(value) => result.set("maxLength", value.to_string())
    None => ()
  }
  match minLength {
    Some(value) => result.set("minLength", value.to_string())
    None => ()
  }
  match tabIndex {
    Some(value) => result.set("tabIndex", value.to_string())
    None => ()
  }
  match contentEditable {
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
  RespoAttrs(result)
}
