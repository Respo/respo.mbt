pub enum RespoNode[T] {
  Component(RespoComponent[T])
  Element(RespoElement[T])
  Referenced(RespoNode[T])
}

fn to_string[T](self : RespoNode[T]) -> String {
  match self {
    RespoNode::Component(component) => component.to_string()
    RespoNode::Element(element) => element.to_string()
    RespoNode::Referenced(node) => node.to_string()
  }
}

type DispatcherFn[T] (T) -> Unit

// TODO
