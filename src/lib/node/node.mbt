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

pub fn load_coord_target_tree[T](
  tree : RespoNode[T],
  coord : ArrayView[RespoCoord]
) -> RespoNode[T]!RespoCommonError {
  // util::log!("looking for {:?}\n  {}", coord, &tree);
  if coord.length() == 0 {
    match tree {
      RespoNode::Referenced(cell) => cell
      _ => tree
    }
  } else {
    let branch = coord[0]
    match (tree, branch) {
      (RespoNode::Component(left), RespoCoord::Comp(target_name)) => {
        let { name, tree, .. } = left
        if name == target_name {
          load_coord_target_tree!(tree, coord[1:])
        } else {
          raise RespoCommonError(
            "Mismatch in expected component name: expected \{target_name}, found \{name}",
          )
        }
      }
      (RespoNode::Element(left), RespoCoord::Key(idx)) => {
        let { children, .. } = left
        match children.search_by(fn(x) { x.0 == k }) {
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
      (RespoNode::Component(_), RespoCoord::Key(_)) =>
        raise RespoCommonError(
          "Type mismatch: expected a DOM element, but found a component",
        )
      (RespoNode::Element(_), RespoCoord::Comp(_)) =>
        raise RespoCommonError(
          "expected component at \{coord}, found target being an element",
        )
      (RespoNode::Referenced(cell), _) => load_coord_target_tree!(cell, coord)
    }
  }
}

/// creates a DOM tree from virtual DOM with proxied event handler attached
pub fn build_dom_tree[T](
  tree : RespoNode[T],
  coord : Array[RespoCoord],
  handle_event : RespoEventMarkFn
) -> @web_sys.Node!RespoCommonError {
  let window = @web_sys.window()
  let document = window.document()
  match tree {
    RespoNode::Component({ name, tree: child, .. }) => {
      let mut next_coord = coord
      next_coord.push(RespoCoord::Comp(name))
      build_dom_tree!(child, next_coord, handle_event)
    }
    RespoNode::Element({ name, attributes: attrs, style, event, children }) => {
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
            if name == "textarea" {
              element.reinterpret_as_html_textarea_element().set_value(value)
            } else {
              element.set_attribute(key, value)
            }
          "value" =>
            if name == "input" {
              element.reinterpret_as_html_input_element().set_value(value)
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
          "innerText or innerHTML is set, it's conflicted with children: \{inner_set} \{children}",
        )
      }
      for pair in children {
        let (k, child) = pair
        let mut next_coord = coord
        next_coord.push(RespoCoord::Key(k))
        let handler = handle_event.to_owned()
        element.append_child(build_dom_tree!(child, next_coord, handler))
      }

      // util::log!("create handler for element: {} {:?}", name, event);

      for pair in event {
        let (key, _) = pair
        let handler = handle_event.to_owned()
        attach_event!(element, key, coord, handler)
      }
      element.reinterpret_as_node()
    }
    RespoNode::Referenced(cell) => build_dom_tree!(cell, coord, handle_event)
  }
}
