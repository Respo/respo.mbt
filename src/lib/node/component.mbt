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
impl[T] Show for RespoComponent[T] with output(self, logger) {
  let ret = "(RespoComponent \{self.name})"
  logger.write_string(ret)
}

///|
pub fn[T] RespoComponent::named(
  name : String,
  tree : RespoNode[T],
  effects~ : Array[&RespoEffect] = []
) -> RespoComponent[T] {
  { name, effects: effects.map(fn(x) { x.build_effect() }), tree }
}

///|
pub fn[T] RespoComponent::to_node(self : RespoComponent[T]) -> RespoNode[T] {
  Component(self)
}

///|
pub fn[T] to_cirru(self : RespoComponent[T]) -> @cirru.Cirru {
  List([
    Leaf("component"),
    Leaf(self.name),
    // self.effects.to_cirru(), // TODO
    self.tree.to_cirru(),
  ])
}
