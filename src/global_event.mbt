///|
/// Collect all global event handlers from the virtual DOM tree
/// Returns an array of handler functions with their coordinates
pub fn[T, G] collect_global_handlers(
  tree : @node.RespoNode[T, G],
  coord : @immut/array.T[@node.RespoCoord],
) -> Array[
  (
    (G, @node.DispatchFn[T]) -> Unit raise @node.RespoCommonError,
    @immut/array.T[@node.RespoCoord],
  ),
] {
  let handlers : Array[
    (
      (G, @node.DispatchFn[T]) -> Unit raise @node.RespoCommonError,
      @immut/array.T[@node.RespoCoord],
    ),
  ] = []

  // Helper function to recursively traverse the tree
  fn collect_from_node(
    node : @node.RespoNode[T, G],
    current_coord : @immut/array.T[@node.RespoCoord],
  ) -> Unit {
    match node {
      @node.Component(component) => {
        // If this component has a listener, add it
        match component.listeners {
          Some(listener) => handlers.push((listener, current_coord))
          None => ()
        }
        // Recursively collect from the component's tree
        collect_from_node(component.tree, current_coord)
      }
      @node.Element(element) =>
        // Recursively collect from all children
        for child in element.children {
          let child_coord = current_coord.push(@node.Key(child.0))
          collect_from_node(child.1, child_coord)
        }
    }
  }

  collect_from_node(tree, coord)
  handlers
}

///|
/// Dispatch a global event to all registered handlers in the tree
pub fn[T, G : Show] dispatch_global_event(
  event : G,
  tree : @node.RespoNode[T, G],
  dispatch : @node.DispatchFn[T],
) -> Unit raise @node.RespoCommonError {
  @dom_ffi.log("[dispatch_global_event] Starting event dispatch: \{event}")
  let handlers = collect_global_handlers(tree, @immut/array.new())
  @dom_ffi.log("[dispatch_global_event] Found \{handlers.length()} handlers")

  // Call each handler with the event
  for i, handler_info in handlers {
    let (handler, _coord) = handler_info
    @dom_ffi.log("[dispatch_global_event] Calling handler #\{i}")
    handler(event, dispatch)
  }
  @dom_ffi.log("[dispatch_global_event] Event dispatch complete")
}
