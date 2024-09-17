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
  mount_target : @web_sys.Node,
  // TODO it copies the whole store, need to optimize
  get_store : () -> U,
  renderer : () -> @node.RespoNode[T]!@node.RespoCommonError,
  dispatch_action : DispatchFn[T],
  interval : Float?
) -> Unit!@node.RespoCommonError {
  let prev_store = @ref.new(get_store())
  let tree0 : @node.RespoNode[T] = renderer!()
  let prev_tree = @ref.new(tree0)
  let to_prev_tree = prev_tree
  let handle_event = fn(
    mark : @node.RespoEventMark
  ) -> Unit!@node.RespoCommonError {
    match request_for_target_handler(to_prev_tree.val, mark.name, mark.coord) {
      Ok(handler) =>
        match handler.run(mark.event_info, dispatch_action.to_owned()) {
          Ok(_) =>
            // util::log!("finished event: {} {:?}", mark.name, mark.coord);
            mark_need_rerender()
          Err(e) => @web_sys.error_log("event handler error:" + e)
        }
      Err(msg) => @web_sys.error_log("event not handled: " + msg)
    }
  }
  let element = @node.build_dom_tree!(tree0, [], handle_event)

  // collection mounted effects
  let mut mount_changes : Ref[Array[@node.DomChange[T]]] = Ref::new([])
  @node.collect_effects_outside_in_as!(
    tree0,
    [],
    [],
    @node.RespoEffectType::Mounted,
    mount_changes,
  )
  mount_target.append_child(element)
  // util::log!("mounted changed: {:?}", mount_changes);
  @node.patch_tree!(
    tree0,
    prev_tree.val,
    mount_target,
    mount_changes.val,
    handle_event,
  )
  let to_prev_tree = prev_tree
  match interval {
    Some(v) =>
      raf_loop_slow(
        v,
        fn() -> Unit!@node.RespoCommonError {
          if drain_rerender_status() {
            let store = get_store()
            // if store == prev_store.borrow().to_owned() {
            //   // no need to update if store not changed
            //   return Ok(());
            // }

            prev_store.val = store
            let new_tree = renderer!()
            let changes : Ref[Array[@node.DomChange[T]]] = Ref::new([])
            @node.diff_tree!(new_tree, to_prev_tree.val, [], [], changes)

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

            let handler = handle_event.to_owned()
            @node.patch_tree!(
              new_tree,
              prev_tree.val,
              mount_target,
              changes.val,
              handler,
            )
            prev_tree.val = new_tree
          }
        },
      )
    None =>
      raf_loop(
        fn() -> Unit!@node.RespoCommonError {
          if drain_rerender_status() {
            let new_tree = renderer!()
            let mut changes : Ref[Array[@node.DomChange[T]]] = Ref::new([])
            @node.diff_tree!(new_tree, to_prev_tree.val, [], [], changes)
            @node.patch_tree!(
              new_tree,
              prev_tree.val,
              mount_target,
              changes.val,
              handle_event,
            )
            prev_tree.val = new_tree
          }
        },
      )
  }
}

fn request_for_target_handler[T](
  tree : @node.RespoNode[T],
  event_name : String,
  coord : Array[@node.RespoCoord]
) -> RespoListenerFn[T]!@node.RespoCommonError {
  let target_node = @node.load_coord_target_tree!(tree, coord[:])
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
