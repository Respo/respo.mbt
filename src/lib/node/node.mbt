///|
pub(all) enum RespoNode[T] {
  Component(RespoComponent[T])
  Element(RespoElement[T])
}

///|
pub impl[T] Eq for RespoNode[T] with op_equal(
  self : RespoNode[T],
  other : RespoNode[T]
) -> Bool {
  match (self, other) {
    (Component(left), Component(right)) => left == right
    (Element(left), Element(right)) => left == right
    _ => false
  }
}

///|
impl[T] Show for RespoNode[T] with output(self, logger) {
  let ret = match self {
    Component(component) => component.to_string()
    Element(element) => element.to_string()
  }
  logger.write_string(ret)
}

///|
pub fn[T] RespoNode::to_cirru(self : RespoNode[T]) -> Cirru {
  match self {
    Component(component) => component.to_cirru()
    Element(element) => element.to_cirru()
  }
}

///| currently it's commonly used for all errors in Respo
pub(all) suberror RespoCommonError String

///|
pub impl Show for RespoCommonError with output(self, logger) {
  let ret = match self {
    RespoCommonError(msg) => "(RespoError \{msg})"
  }
  logger.write_string(ret)
}

///|
pub fn[T] load_coord_target_tree(
  tree : RespoNode[T],
  coord : ArrayView[RespoCoord]
) -> RespoNode[T] raise RespoCommonError {
  // @dom_ffi.log("looking for " + coord.to_string() + tree.to_string())
  if coord.length() == 0 {
    tree
  } else {
    let branch = coord[0]
    match (tree, branch) {
      (Component(left), Comp(target_name)) => {
        let { name, tree, .. } = left
        if name == target_name {
          load_coord_target_tree(tree, coord[1:])
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
              .or_error(RespoCommonError("to get child \{idx} \{i}")).1
            load_coord_target_tree(child, coord[1:])
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
    }
  }
}

///| creates a DOM tree from virtual DOM with proxied event handler attached
pub fn[T] build_dom_tree(
  tree : RespoNode[T],
  coord : @immut/array.T[RespoCoord],
  handle_event : (RespoEventMark) -> Unit raise RespoCommonError
) -> @dom_ffi.Node raise RespoCommonError {
  let window = @dom_ffi.window()
  let document = window.document()
  match tree {
    Component({ name, tree: child, .. }) => {
      let next_coord = coord.push(Comp(name))
      build_dom_tree(child, next_coord, handle_event)
    }
    Element({ name, attrs, style, event, children }) => {
      let element = document.create_element(name)
      let mut inner_set = false
      for pair in attrs {
        let (key, value) = pair
        match key {
          "style" => @dom_ffi.warn_log("style is handled outside attrs")
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
          _ =>
            if key.has_prefix("data-") {
              element.set_data_attribute(key.substring(start=5), value)
            } else {
              element.set_attribute(key, value)
            }
        }
      }
      if not(style.is_empty()) {
        element.set_attribute("style", style.to_string())
      }
      if inner_set && not(children.is_empty()) {
        @dom_ffi.warn_log(
          "innerText or innerHTML is set, it's conflicted with children: \{inner_set} {TODO children}",
        )
      }
      for pair in children {
        let (k, child) = pair
        let next_coord = coord.push(Key(k))
        element
        .reinterpret_as_node()
        .append_child(build_dom_tree(child, next_coord, handle_event))
      }

      // util::log!("create handler for element: {} {:?}", name, event);

      for pair in event {
        let (key, _) = pair
        attach_event(element, key, coord, handle_event)
      }
      element.reinterpret_as_node()
    }
  }
}

///|
pub(all) type DispatchFn[T] (T) -> Unit raise RespoCommonError

///|
pub impl[T] Show for DispatchFn[T] with output(self, logger) {
  let ret = match self {
    DispatchFn(_f) => "(DispatchFn ..)"
  }
  logger.write_string(ret)
}

///|
pub(open) trait RespoAction {
  /// a function for building action to update states is required
  build_states_action(Array[String], &ToJson?) -> Self
  // detect_intent(Self) -> ActonOp? // TODO
  // build_intent_action(ActonOp) -> Self
}

///|
pub fn[T : RespoAction] DispatchFn::run(
  self : DispatchFn[T],
  op : T
) -> Unit raise RespoCommonError {
  let f = self.inner()
  f(op)
}

///| abstract over cursor array with state type
pub struct RespoCursor[T] {
  cursor : Array[String]
  _phantom : T?
}

///|
pub fn[T] RespoCursor::new(cursor : Array[String]) -> RespoCursor[T] {
  { cursor, _phantom: None }
}

///| dispatch an action to update states, to empty the state, pass None
pub fn[T : RespoAction, S : ToJson] DispatchFn::set_state(
  self : DispatchFn[T],
  cursor : RespoCursor[S],
  state : S
) -> Unit raise RespoCommonError {
  let op = T::build_states_action(cursor.cursor, Some(state))
  self.run(op)
}

///|
#deprecated("use `set_state` instead")
pub fn[T : RespoAction] DispatchFn::run_state(
  self : DispatchFn[T],
  cursor : Array[String],
  state : &ToJson
) -> Unit raise RespoCommonError {
  let op = T::build_states_action(cursor, Some(state))
  self.run(op)
}

// pub fn DispatchFn::run_intent[T : RespoAction](
//   self : DispatchFn[T],
//   op : Json
// ) -> Unit!RespoCommonError {
//   let op = T::build_intent_action(op)
//   self.run!(op)
// }

///| dispatch an action to update states, to empty the state, pass None
pub fn[T : RespoAction, S] DispatchFn::empty_state(
  self : DispatchFn[T],
  cursor : RespoCursor[S]
) -> Unit raise RespoCommonError {
  let op = T::build_states_action(cursor.cursor, None)
  self.run(op)
}

///|
#deprecated("use `empty_state` instead")
pub fn[T : RespoAction] DispatchFn::run_empty_state(
  self : DispatchFn[T],
  cursor : Array[String]
) -> Unit raise RespoCommonError {
  let op = T::build_states_action(cursor, None)
  self.run(op)
}

///|
pub fn[T] DispatchFn::new(
  f : (T) -> Unit raise RespoCommonError
) -> DispatchFn[T] {
  f
}
