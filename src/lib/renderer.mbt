let need_to_rerender : Ref[Bool] = Ref::new(false)

/// check where need to trigger rerendering, also resets the status to false
fn drain_rerender_status() -> Bool {
  let ret = need_to_rerender.val
  // @dom_ffi.log("draining: " + ret.to_string())
  if ret {
    // @dom_ffi.warn_log("rerender")
    need_to_rerender.val = false
  }
  ret
}

pub fn mark_need_rerender() -> Unit {
  let ret = need_to_rerender.val
  if not(ret) {
    need_to_rerender.val = true
    // @dom_ffi.warn_log("mark need rerender")
  }
}

/// render elements
pub fn render_node[T, U](
  mount_target : @dom_ffi.Node,
  // TODO it copies the whole store, need to optimize
  get_store : () -> U,
  renderer : () -> @node.RespoNode[T]!@node.RespoCommonError,
  dispatch_action : (T) -> Unit!@node.RespoCommonError,
  _interval : Float?
) -> Unit!@node.RespoCommonError {
  let prev_store = @ref.new(get_store())
  let tree0 : @node.RespoNode[T] = renderer!()
  let prev_tree = @ref.new(tree0)
  let handle_event = fn(
    mark : @node.RespoEventMark
  ) -> Unit!@node.RespoCommonError {
    // @dom_ffi.warn_log(
    //   "start rendering: " + mark.name.to_string() + " " + mark.coord.to_string(),
    // )
    let handler = request_for_target_handler!(
      prev_tree.val,
      mark.name,
      mark.coord,
    )
    handler!(mark.event_info, dispatch_action)
    // @dom_ffi.log(
    //   "finished event: " + mark.name.to_string() + " " + mark.coord.to_string(),
    // )
    mark_need_rerender()
  }
  let element = @node.build_dom_tree!(tree0, [], handle_event)

  // collection mounted effects
  let mount_changes : Ref[Array[@node.DomChange[T]]] = Ref::new([])
  @node.collect_effects_outside_in_as!(tree0, [], [], Mounted, mount_changes)
  mount_target.append_child(element)
  // util::log!("mounted changed: {:?}", mount_changes);
  @node.patch_tree!(
    tree0,
    prev_tree.val,
    mount_target,
    mount_changes.val,
    handle_event,
  )
  @node.raf_loop(
    fn(_t : Float) -> Unit!@node.RespoCommonError {
      if drain_rerender_status() {
        prev_store.val = get_store()
        let new_tree = renderer!()
        let changes : Ref[Array[@node.DomChange[T]]] = Ref::new([])
        @node.diff_tree!(new_tree, prev_tree.val, [], [], changes)
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
  event_name : @node.RespoEventType,
  coord : Array[@node.RespoCoord]
) ->
     ((@node.RespoEvent, @node.DispatchFn[T]) -> Unit!@node.RespoCommonError)!@node.RespoCommonError {
  let target_node = @node.load_coord_target_tree!(tree, coord[:])
  match target_node {
    Component({ name, .. }) =>
      raise @node.RespoCommonError(
        "expected element, found target being a component: " + name,
      )
    Element({ name: tag_name, event, .. }) =>
      match event.get(event_name) {
        Some(v) => v
        None =>
          raise @node.RespoCommonError(
            "No event handler found for event '\{event_name}' on element '\{tag_name}', available events: TODO{event.keys()}",
          )
      }
  }
}
