pub enum RespoNode[T] {
  Component(RespoComponent[T])
  Element(RespoElement[T])
  Referenced(RespoNode[T])
}

pub fn op_equal[T](self : RespoNode[T], other : RespoNode[T]) -> Bool {
  match (self, other) {
    (Component(left), Component(right)) => left == right
    (Element(left), Element(right)) => left == right
    (Referenced(left), Referenced(right)) => left == right
    _ => false
  }
}

fn to_string[T](self : RespoNode[T]) -> String {
  match self {
    Component(component) => component.to_string()
    Element(element) => element.to_string()
    Referenced(node) => node.to_string()
  }
}

// TODO

// pub trait RespoAction {
//   build_states_action(Array[String], RespoStateBranch?) -> Self
//   detect_intent(Self) -> ActonOp? // TODO
//   build_intent_action(ActonOp) -> Self
// }

pub type! RespoCommonError String

pub fn to_string(self : RespoCommonError) -> String {
  match self {
    RespoCommonError(msg) => "(RespoError \{msg})"
  }
}

pub fn load_coord_target_tree[T](
  tree : RespoNode[T],
  coord : ArrayView[RespoCoord]
) -> RespoNode[T]!RespoCommonError {
  @web_sys.log("looking for " + coord.to_string() + tree.to_string())
  if coord.length() == 0 {
    match tree {
      RespoNode::Referenced(cell) => cell
      _ => tree
    }
  } else {
    let branch = coord[0]
    match (tree, branch) {
      (Component(left), Comp(target_name)) => {
        let { name, tree, .. } = left
        if name == target_name {
          load_coord_target_tree!(tree, coord[1:])
        } else {
          raise RespoCommonError(
            "Mismatch in expected component name: expected \{target_name}, found \{name}",
          )
        }
      }
      (Element(left), Key(idx)) => {
        let { children, .. } = left
        match children.search_by(fn(x) { x.0 == idx }) {
          Some(i) => {
            let child = children
              .get(i)
              .or_error!(RespoCommonError("to get child \{idx} \{i}")).1
            load_coord_target_tree!(child, coord[1:])
          }
          None => raise RespoCommonError("no child at index key \{idx}")
        }
      }
      // match children.get(*idx as usize) {
      //   Some((_k, child)) => load_coord_target_tree(child, &coord[1..]),
      //   None => Err(format!("no child at index key {:?}", idx)),
      // },
      (Component(_), Key(_)) =>
        raise RespoCommonError(
          "Type mismatch: expected a DOM element, but found a component",
        )
      (Element(_), Comp(_)) =>
        raise RespoCommonError(
          "expected component at \{coord}, found target being an element",
        )
      (Referenced(cell), _) => load_coord_target_tree!(cell, coord)
    }
  }
}

/// creates a DOM tree from virtual DOM with proxied event handler attached
pub fn build_dom_tree[T](
  tree : RespoNode[T],
  coord : Array[RespoCoord],
  handle_event : (RespoEventMark) -> Unit!RespoCommonError
) -> @web_sys.Node!RespoCommonError {
  let window = @web_sys.window()
  let document = window.document()
  match tree {
    RespoNode::Component({ name, tree: child, .. }) => {
      let next_coord = coord.copy()
      next_coord.push(RespoCoord::Comp(name))
      build_dom_tree!(child, next_coord, handle_event)
    }
    RespoNode::Element({ name, attrs, style, event, children }) => {
      let element = document.create_element(name)
      let mut inner_set = false
      for pair in attrs {
        let (key, value) = pair
        match key {
          "style" => @web_sys.warn_log("style is handled outside attrs")
          "innerText" => {
            inner_set = true
            element.set_inner_text(value)
          }
          "innerHTML" => {
            inner_set = true
            element.set_inner_html(value)
          }
          "htmlFor" => element.set_html_for(value)
          "value" =>
            if name == "input" {
              element.reinterpret_as_html_input_element().set_value(value)
            } else if name == "textarea" {
              element.reinterpret_as_html_textarea_element().set_value(value)
            } else {
              element.set_attribute(key, value)
            }
          _ => element.set_attribute(key, value)
        }
      }
      if not(style.is_empty()) {
        element.set_attribute("style", style.to_string())
      }
      if inner_set && not(children.is_empty()) {
        @web_sys.warn_log(
          "innerText or innerHTML is set, it's conflicted with children: \{inner_set} {TODO children}",
        )
      }
      for pair in children {
        let (k, child) = pair
        let next_coord = coord.copy()
        next_coord.push(RespoCoord::Key(k))
        element
        .reinterpret_as_node()
        .append_child(build_dom_tree!(child, next_coord, handle_event))
      }

      // util::log!("create handler for element: {} {:?}", name, event);

      for pair in event {
        let (key, _) = pair
        attach_event!(element, key, coord, handle_event)
      }
      element.reinterpret_as_node()
    }
    RespoNode::Referenced(cell) => build_dom_tree!(cell, coord, handle_event)
  }
}

// pub type DispatchFn[T] (T) -> Unit!RespoCommonError

// pub fn DispatchFn::to_string[T](self : DispatchFn[T]) -> String {
//   "(DispatchFn)"
// }

// trait RespoAction {
//   build_states_action(Array[String], Json) -> Self
// }

// pub fn DispatchFn::run[T : RespoAction](
//   self : DispatchFn[T],
//   op : T
// ) -> Unit!RespoCommonError {
//   let f = self._
//   f!(op)
// }
