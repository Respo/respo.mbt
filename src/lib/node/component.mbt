///|
pub(all) struct RespoComponent[T] {
  name : String
  effects : Array[RespoEffectBox]
  tree : RespoNode[T]
}

///|
pub impl[T] Eq for RespoComponent[T] with op_equal(
  self : RespoComponent[T],
  other : RespoComponent[T]
) -> Bool {
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

///|
fn RespoComponent::to_string[T](self : RespoComponent[T]) -> String {
  "(RespoComponent \{self.name})"
}

///|
pub fn RespoComponent::named[T](
  name : String,
  tree : RespoNode[T],
  effects~ : Array[&RespoEffect] = []
) -> RespoComponent[T] {
  { name, effects: effects.map(fn(x) { x.build_effect() }), tree }
}

///|
pub fn RespoComponent::to_node[T](self : RespoComponent[T]) -> RespoNode[T] {
  Component(self)
}

///|
pub fn to_cirru[T](self : RespoComponent[T]) -> @cirru.Cirru {
  List([
    Leaf("component"),
    Leaf(self.name),
    // self.effects.to_cirru(), // TODO
    self.tree.to_cirru(),
  ])
}
