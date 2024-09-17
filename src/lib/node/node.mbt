pub enum RespoNode[T] {
  Component(RespoComponent[T])
  Element(RespoElement[T])
  Referenced(RespoNode[T])
} derive(Eq)

fn to_string[T](self : RespoNode[T]) -> String {
  match self {
    RespoNode::Component(component) => component.to_string()
    RespoNode::Element(element) => element.to_string()
    RespoNode::Referenced(node) => node.to_string()
  }
}

type DispatcherFn[T] (T) -> Unit

// TODO

pub trait RespoAction {
  build_states_action(Array[String], RespoStateBranch?) -> Self
  detect_intent(Self) -> ActonOp? // TODO
  build_intent_action(ActonOp) -> Self
}

pub type! RespoCommonError String

type DispatchFn[T] (T) -> Unit!RespoCommonError
