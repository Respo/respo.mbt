///|
/// Collect all global event handlers from the virtual DOM tree
/// Returns an array of handler functions with their coordinates
pub fn[T, G] collect_global_handlers(
  tree : @node.RespoNode[T, G],
  coord : @immut/vector.Vector[@node.RespoCoord],
) -> Array[
  (
    (G, @node.DispatchFn[T]) -> Unit raise @node.RespoCommonError,
    @immut/vector.Vector[@node.RespoCoord],
  ),
] {
  let handlers : Array[
    (
      (G, @node.DispatchFn[T]) -> Unit raise @node.RespoCommonError,
      @immut/vector.Vector[@node.RespoCoord],
    ),
  ] = []

  // Helper function to recursively traverse the tree
  fn collect_from_node(
    node : @node.RespoNode[T, G],
    current_coord : @immut/vector.Vector[@node.RespoCoord],
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
pub fn[T, G] dispatch_global_event(
  event : G,
  tree : @node.RespoNode[T, G],
  dispatch : @node.DispatchFn[T],
) -> Unit raise @node.RespoCommonError {
  let handlers = collect_global_handlers(tree, @immut/vector.new())

  // Call each handler with the event
  for _i, handler_info in handlers {
    let (handler, _coord) = handler_info
    handler(event, dispatch)
  }
}
