///|
pub(all) struct RespoComponent[T, G] {
  name : String
  effects : Array[RespoEffectBox]
  tree : RespoNode[T, G]
  /// 用于监听全局分发事件的处理函数（可选）
  listeners : ((G, DispatchFn[T]) -> Unit raise RespoCommonError)?
}

///|
pub impl[T, G] Eq for RespoComponent[T, G] with equal(
  self : RespoComponent[T, G],
  other : RespoComponent[T, G],
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
  // listeners 不参与比较，因为它们是函数
  true
}

///|
impl[T, G] Show for RespoComponent[T, G] with output(self, logger) {
  let ret = "(RespoComponent \{self.name})"
  logger.write_string(ret)
}

///|
pub fn[T, G] RespoComponent::named(
  name : String,
  tree : RespoNode[T, G],
  effects? : Array[&RespoEffect] = [],
  listeners? : ((G, DispatchFn[T]) -> Unit raise RespoCommonError)? = None,
) -> RespoComponent[T, G] {
  { name, effects: effects.map(fn(x) { x.build_effect() }), tree, listeners }
}

///|
pub fn[T, G] RespoComponent::to_node(
  self : RespoComponent[T, G],
) -> RespoNode[T, G] {
  Component(self)
}

///|
pub fn[T, G] RespoComponent::to_cirru(self : RespoComponent[T, G]) -> Cirru {
  List([
    Leaf("component"),
    Leaf(self.name),
    // self.effects.to_cirru(), // TODO
    self.tree.to_cirru(),
  ])
}
