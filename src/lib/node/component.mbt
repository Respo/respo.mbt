pub struct RespoComponent[T] {
  name : String
  effects : Array[RespoEffectBox]
  tree : RespoNode[T]
} derive(Eq)

fn to_string[T](self : RespoComponent[T]) -> String {
  "(RespoComponent \{self.name})"
}
