pub type RespoIndexKey String derive(Eq)

pub fn to_string(self : RespoIndexKey) -> String {
  self._
}

/// internal abstraction for an element
pub struct RespoElement[T] {
  /// tagName
  name : String
  attributes : @hashmap.T[String, String]
  event : @hashmap.T[String, RespoListenerFn[T]]
  /// inlines styles, partially typed.
  /// there's also a macro called `static_styles` for inserting CSS rules
  style : RespoStyle
  /// each child as a key like a string, by default generated from index,
  /// they are used in diffing, so it's better to be distinct, although not required to be.
  children : Array[(RespoIndexKey, RespoNode[T])]
}

pub impl[T : Eq] Eq for RespoElement[T] with op_equal(
  self : RespoElement[T],
  other : RespoElement[T]
) {
  if self.name != other.name {
    return false
  }
  if not(hashmap_eq(self.attributes, other.attributes)) {
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
