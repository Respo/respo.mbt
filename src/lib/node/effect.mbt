trait RespoEffect {
  run(Self, RespoEffectType, @web_sys.Node) -> Unit
  mount(Self, @web_sys.Node) -> Unit
  mounted(Self, @web_sys.Node) -> Unit
  before_update(Self, @web_sys.Node) -> Unit
  updated(Self, @web_sys.Node) -> Unit
  before_mount(Self, @web_sys.Node) -> Unit

  // def derive: RespoEffectBox
}

type RespoEffectBox RespoEffect derive(Eq)

pub enum RespoEffectType {
  Mount
  Mounted
  BeforeUpdate
  Updated
  BeforeUnmount
}

// TODO to Cirru
