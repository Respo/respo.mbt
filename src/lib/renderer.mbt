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
  dispatch_action : (T) -> Unit!@node.RespoCommonError,
  _interval : Float?
) -> Unit!@node.RespoCommonError {
  let _prev_store = @ref.new(get_store())
  let tree0 : @node.RespoNode[T] = renderer!()
  let prev_tree = @ref.new(tree0)
  let to_prev_tree = prev_tree
  let handle_event = fn(
    mark : @node.RespoEventMark
  ) -> Unit!@node.RespoCommonError {
    let handler = request_for_target_handler!(
      to_prev_tree.val,
      mark.name,
      mark.coord,
    )
    handler(mark.event_info, dispatch_action)
    // util::log!("finished event: {} {:?}", mark.name, mark.coord);
    // mark_need_rerender()
  }
  let element = @node.build_dom_tree!(tree0, [], handle_event)

  // collection mounted effects
  let mount_changes : Ref[Array[@node.DomChange[T]]] = Ref::new([])
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
  @node.raf_loop(
    fn(_t : Float) -> Unit!@node.RespoCommonError {
      if drain_rerender_status() {
        let new_tree = renderer!()
        let changes : Ref[Array[@node.DomChange[T]]] = Ref::new([])
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

fn request_for_target_handler[T](
  tree : @node.RespoNode[T],
  event_name : String,
  coord : Array[@node.RespoCoord]
) ->
     ((@node.RespoEvent, (T) -> Unit!@node.RespoCommonError) -> Unit)!@node.RespoCommonError {
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
            "No event handler found for event '\{event_name}' on element '\{tag_name}', available events: TODO{event.keys()}",
          )
      }
    @node.RespoNode::Referenced(cell) =>
      request_for_target_handler!(cell, event_name, coord)
  }
}
