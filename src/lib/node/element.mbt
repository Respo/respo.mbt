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
} derive(Eq)

fn to_string[T](self : RespoElement[T]) -> String {
  "(RespoElement \{self.name})"
}

// TODO implement methods for RespoElement
