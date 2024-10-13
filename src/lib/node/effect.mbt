// trait RespoEffect {
//   run(Self, RespoEffectType, @dom_ffi.Node) -> Unit
//   mount(Self, @dom_ffi.Node) -> Unit
//   mounted(Self, @dom_ffi.Node) -> Unit
//   before_update(Self, @dom_ffi.Node) -> Unit
//   updated(Self, @dom_ffi.Node) -> Unit
//   before_mount(Self, @dom_ffi.Node) -> Unit

//   // def derive: RespoEffectBox
// }

pub struct RespoEffectBox {
  args : Json
  /// third argument `at_place` is not implemented yet
  handler : (RespoEffectType, @dom_ffi.Node) -> Unit
}

/// implement this on data which creates effect
pub trait RespoEffect: ToJson {
  turn_effect(Self) -> RespoEffectBox
  make_handler(Self) -> (RespoEffectType, @dom_ffi.Node) -> Unit
}

impl RespoEffect with turn_effect(self) -> RespoEffectBox {
  { args: self.to_json(), handler: (self as RespoEffect).make_handler() }
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

pub fn RespoEffectType::to_string(self : RespoEffectType) -> String {
  match self {
    Mount => "Mount"
    Mounted => "Mounted"
    BeforeUpdate => "BeforeUpdate"
    Updated => "Updated"
    BeforeUnmount => "BeforeUnmount"
  }
}

// TODO to Cirru
