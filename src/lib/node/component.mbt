pub struct RespoComponent[T] {
  name : String
  effects : Array[RespoEffectBox]
  tree : RespoNode[T]
}

fn to_string[T](self : RespoComponent[T]) -> String {
  "(RespoComponent \{self.name})"
}
