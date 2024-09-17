let need_to_rerender : Ref[Bool] = Ref::new(false)

/// check where need to trigger rerendering, also resets the status to false
fn drain_rerender_status() -> Bool {
  let ret = need_to_rerender.val
  if ret {
    need_to_rerender.val = false
  }
  ret
}

pub fn mark_need_rerender() -> Unit {
  let ret = need_to_rerender.val
  if not(ret) {
    need_to_rerender.val = true
  }
}

/// render elements
pub fn render_node[T, U](
  mount_target: @web_sys.Node,
  // TODO it copies the whole store, need to optimize
  get_store: () -> U,
  renderer: () -> @node.RespoNode[T]!@node.RespoCommonError,
  dispatch_action: DispatchFn<T>,
  interval: Option[Float],
) -> Unit!@node.RespoCommonError  {
  let prev_store = @ref.new(get_store());
  let tree0: @node.RespoNode[T] = renderer!();
  let prev_tree = @ref.new(tree0);

  let to_prev_tree = prev_tree;
  let handle_event = RespoEventMarkFn::new(fn (mark: @web_sys.RespoEventMark) -> Unit!@node.RespoCommonError {
    match request_for_target_handler(to_prev_tree.val, mark.name, mark.coord) {
      Ok(handler) => match handler.run(mark.event_info, dispatch_action.to_owned()) {
        Ok(()) => {
          // util::log!("finished event: {} {:?}", mark.name, mark.coord);
          mark_need_rerender();
        }
        Err(e) => {
          @web_sys.error_log("event handler error:"+e)
        }
      }
      Err(msg) => {
        @web_sys.error_log("event not handled: "+msg)
      }
    }
  })

  let handler = handle_event.to_owned();
  let element = build_dom_tree!(tree0, [], handler)

  // collection mounted effects
  let mut mount_changes: Ref[Array[@node.DomChange[T]]] = Ref::new([])
  @node.collect_effects_outside_in_as!(tree0, [], [], @node.RespoEffectType::Mounted, mount_changes)

  mount_target.append_child(element)
  let handler = handle_event.to_owned();
  // util::log!("mounted changed: {:?}", mount_changes);
  @node.patch_tree!(tree0, prev_tree, mount_target, &mount_changes, handler)

  let to_prev_tree = prev_tree
  match interval {
    Some(v) => {
      raf_loop_slow(
        v,
        fn () -> Unit!@node.RespoCommonError {
          if drain_rerender_status() {
            let store = get_store();
            // if store == prev_store.borrow().to_owned() {
            //   // no need to update if store not changed
            //   return Ok(());
            // }

            prev_store.val=store;

            let new_tree = renderer!()
            let changes: Ref[Array[@node.DomChange[T]]] = Ref::new([])
            @node.diff_tree!(new_tree, to_prev_tree.val, [], [],  changes)

            // use cirru_parser::CirruWriterOptions;
            // util::log!(
            //   "prev tree: {}",
            //   cirru_parser::format(&[to_prev_tree.borrow().to_owned().into()], CirruWriterOptions { use_inline: true }).unwrap()
            // );
            // use crate::dom_change::changes_to_cirru;
            // util::log!(
            //   "changes: {}",
            //   cirru_parser::format(&[changes_to_cirru(&changes)], CirruWriterOptions { use_inline: true }).unwrap()
            // );

            let handler = handle_event.to_owned();
            @node.patch_tree!(new_tree, prev_tree.val, mount_target, changes.val, handler)
            prev_tree.val = new_tree
          }
        }
      )
    }

    None => {
      raf_loop(fn () -> Unit!@node.RespoCommonError {
        if drain_rerender_status() {
          let new_tree = renderer!()
          let mut changes: Ref[Array[@node.DomChange[T]]] = Ref::new([])
          @node.diff_tree!(new_tree, to_prev_tree.val, [], [],  changes)

          let handler = handle_event.to_owned();
          @node.patch_tree!(new_tree, prev_tree.val, mount_target, changes.val, handler)
          prev_tree.val =new_tree
        }
      })
    }
  }
}

pub fn load_coord_target_tree[T](tree: @node.RespoNode[T], coord: ArrayView[@node.RespoCoord]) -> @node.RespoNode[T]!@node.RespoCommonError {
  // util::log!("looking for {:?}\n  {}", coord, &tree);
  if coord.length() == 0 {
    match tree {
      @node.RespoNode::Referenced(cell) => cell
      _ => tree
    }
  } else {
    let branch = coord[0];
    match (tree, branch) {
      (@node.RespoNode::Component(left), @node.RespoCoord::Comp(target_name)) => {
        let {name, tree, .. }=left
        if name == target_name {
          load_coord_target_tree!(tree, coord[1:])
        } else {
          raise @node.RespoCommonError("Mismatch in expected component name: expected \{target_name}, found \{name}")
        }
      }
      (@node.RespoNode::Element(left), @node.RespoCoord::Key(idx)) => {
        let { children, .. } = left
        match children.iter().position(|(k, _)| idx == k) {
          Some(i) => {
            let child = children.get(i).ok_or_else( format!("to get child {:?} {}", idx, i))?.1;
            load_coord_target_tree!(child, coord[1:])
          }
          None => raise @node.RespoCommonError("no child at index key \{idx}")
        }
      }
      // match children.get(*idx as usize) {
      //   Some((_k, child)) => load_coord_target_tree(child, &coord[1..]),
      //   None => Err(format!("no child at index key {:?}", idx)),
      // },
      (@node.RespoNode::Component(_), @node.RespoCoord::Key(_)) => {
        raise @node.RespoCommonError("Type mismatch: expected a DOM element, but found a component")
      }
      (@node.RespoNode::Element(_), @node.RespoCoord::Comp(_)) => {
        raise @node.RespoCommonError("expected component at \{coord}, found target being an element")
      }
      (@node.RespoNode::Referenced(cell), _) => load_coord_target_tree!(cell, coord)
    }
  }
}

fn request_for_target_handler[T](
  tree : @node.RespoNode[T],
  event_name : String,
  coord : Array[@node.RespoCoord]
) -> RespoListenerFn[T]!@node.RespoCommonError {
  let target_node = load_coord_target_tree!(tree, coord)
  match target_node {
    @node.RespoNode::Component({ name, .. }) =>
      raise @node.RespoCommonError(
        "expected element, found target being a component: " + name,
      )
    @node.RespoNode::Element({ name: tag_name, event, .. }) =>
      match event.get(event_name) {
        Some(v) => v
        None =>
          raise @node.RespoCommonError(
            "No event handler found for event '\{event_name}' on element '\{tag_name}', available events: \{event.keys()}",
          )
      }
    @node.RespoNode::Referenced(cell) =>
      request_for_target_handler!(cell, event_name, coord)
  }
}

/// creates a DOM tree from virtual DOM with proxied event handler attached
pub fn build_dom_tree[T](
  tree : @node.RespoNode[T],
  coord : Array[@node.RespoCoord],
  handle_event : RespoEventMarkFn
) -> @web_sys.Node!@node.RespoCommonError {
  let window = @web_sys.window()
  let document = window.document()
  match tree {
    @node.RespoNode::Component({ name, tree: child, .. }) => {
      let mut next_coord = coord
      next_coord.push(@node.RespoCoord::Comp(name))
      build_dom_tree!(child, next_coord, handle_event)
    }
    @node.RespoNode::Element(
      { name, attributes: attrs, style, event, children }
    ) => {
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
        next_coord.push(@node.RespoCoord::Key(k))
        let handler = handle_event.to_owned()
        element.append_child(build_dom_tree!(child, next_coord, handler))
      }

      // util::log!("create handler for element: {} {:?}", name, event);

      for key in event.keys() {
        let handler = handle_event.to_owned()
        attach_event(element, key, coord, handler)
      }
      element.reinterpret_as_node()
    }
    @node.RespoNode::Referenced(cell) =>
      build_dom_tree!(cell, coord, handle_event)
  }
}
