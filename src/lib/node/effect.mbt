// trait RespoEffect {
//   run(Self, RespoEffectType, @dom_ffi.Node) -> Unit

//   // def derive: RespoEffectBox
// }

///|
pub(all) struct RespoEffectBox {
  args : Json
  /// third argument `at_place` is not implemented yet
  handler : (RespoEffectType, @dom_ffi.Node) -> Unit
}

///| implement this on data which creates effect
pub(open) trait RespoEffect: ToJson {
  build_effect(Self) -> RespoEffectBox = _
  make_handler(Self) -> (RespoEffectType, @dom_ffi.Node) -> Unit = _

  /// dispatch to different handlers
  run(Self, RespoEffectType, @dom_ffi.Node) -> Unit = _
  mounted(Self, @dom_ffi.Node) -> Unit = _
  before_update(Self, @dom_ffi.Node) -> Unit = _
  updated(Self, @dom_ffi.Node) -> Unit = _
  before_unmount(Self, @dom_ffi.Node) -> Unit = _
}

///|
impl RespoEffect with build_effect(self) -> RespoEffectBox {
  { args: self.to_json(), handler: self.make_handler() }
}

///|
impl RespoEffect with make_handler(self) -> (RespoEffectType, @dom_ffi.Node) -> Unit {
  fn(effect_type, el) { self.run(effect_type, el) }
}

///|
impl RespoEffect with run(self, effect_type, el) -> Unit {
  match effect_type {
    Mounted => self.mounted(el)
    BeforeUpdate => self.before_update(el)
    Updated => self.updated(el)
    BeforeUnmount => self.before_unmount(el)
  }
}

///| default handler is empty
impl RespoEffect with mounted(_self, _node) -> Unit {

}

///| default handler is empty
impl RespoEffect with before_update(_self, _node) -> Unit {

}

///| default handler is empty
impl RespoEffect with updated(_self, _node) -> Unit {

}

///| default handler is empty
impl RespoEffect with before_unmount(_self, _node) -> Unit {

}

///|
pub impl Eq for RespoEffectBox with op_equal(
  self : RespoEffectBox,
  b : RespoEffectBox,
) -> Bool {
  self.args == b.args
}

///| currently only support `Mounted`, `BeforeUpdate`, `Updated`, `BeforeUnmount`
pub(all) enum RespoEffectType {
  Mounted
  BeforeUpdate
  Updated
  BeforeUnmount
} derive(Eq)

///|
pub impl Show for RespoEffectType with output(self, logger) {
  let ret = match self {
    Mounted => "Mounted"
    BeforeUpdate => "BeforeUpdate"
    Updated => "Updated"
    BeforeUnmount => "BeforeUnmount"
  }
  logger.write_string("(RespoEffectType " + ret + ")")
}

///|
pub fn RespoEffectType::to_cirru(self : RespoEffectType) -> Cirru {
  match self {
    Mounted => Leaf("::mounted")
    BeforeUpdate => Leaf("::before-update")
    Updated => Leaf("::updated")
    BeforeUnmount => Leaf("::before-unmount")
  }
}
