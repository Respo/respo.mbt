// trait RespoEffect {
//   run(Self, RespoEffectType, @web_sys.Node) -> Unit
//   mount(Self, @web_sys.Node) -> Unit
//   mounted(Self, @web_sys.Node) -> Unit
//   before_update(Self, @web_sys.Node) -> Unit
//   updated(Self, @web_sys.Node) -> Unit
//   before_mount(Self, @web_sys.Node) -> Unit

//   // def derive: RespoEffectBox
// }

pub struct RespoEffectBox {
  args : Json
  handler : (RespoEffectType, @web_sys.Node, Bool) -> Unit
}

pub fn op_equal(self : RespoEffectBox, b : RespoEffectBox) -> Bool {
  self.args == b.args
}

pub enum RespoEffectType {
  Mount
  Mounted
  BeforeUpdate
  Updated
  BeforeUnmount
} derive(Eq)

// TODO to Cirru
