pub struct RespoComponent[T] {
  name : String
  effects : Array[RespoEffectBox]
  tree : RespoNode[T]
}

pub fn op_equal[T](self : RespoComponent[T], other : RespoComponent[T]) -> Bool {
  if self.name != other.name {
    return false
  }
  if not(self.effects == other.effects) {
    return false
  }
  if not(self.tree == other.tree) {
    return false
  }
  true
}

fn to_string[T](self : RespoComponent[T]) -> String {
  "(RespoComponent \{self.name})"
}

pub fn RespoComponent::named[T](
  name : String,
  tree : RespoNode[T]
) -> RespoComponent[T] {
  { name, effects: [], tree }
}

pub fn RespoComponent::to_node[T](self : RespoComponent[T]) -> RespoNode[T] {
  Component(self)
}
