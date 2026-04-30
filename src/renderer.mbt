///|
let need_to_rerender : Ref[Bool] = Ref::new(false)

///|
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

///|
/// Signal that the store has changed and a re-render should be scheduled.
///
/// Call this after assigning `app.store.val = new_store` to trigger the next
/// animation-frame render cycle.
pub fn mark_need_rerender() -> Unit {
  let ret = need_to_rerender.val
  if !ret {
    need_to_rerender.val = true
    // @dom_ffi.warn_log("mark need rerender")
  }
}

///|
/// Mount and start the render loop for a Respo application.
///
/// ## Immutability contract
///
/// `store` **must** hold an immutable value type (no `mut` struct fields).
/// The render loop uses two optimizations to avoid unnecessary work:
///
/// 1. **Physical equality** (`physical_equal`): if `store.val` is the exact
///    same heap object as in the previous frame, the render is skipped entirely.
/// 2. **Logical equality** (`==`): if `store.val != prev_store` but they compare
///    equal, the render is also skipped.
///
/// ⚠️ **`mut` field pitfall**: if your `Store` struct has `mut` fields and
/// `update()` mutates them in place, then `{ ..store.val }` only creates a
/// shallow copy — but `prev_store` already sees the mutated values through the
/// shared struct reference. Both checks then return `true` and the DOM is never
/// updated.
///
/// ✅ **Correct pattern**: `update()` must return a brand-new `Store` value.
///
/// ```moonbit
/// // WRONG — mut field + in-place mutation
/// struct Store { mut count : Int } derive(Eq)
/// fn Store::update(self : Store, op : Op) -> Op? {
///   self.count += 1  // mutates in place — prev_store sees this too!
///   None
/// }
///
/// // CORRECT — no mut, update returns new store
/// struct Store { count : Int } derive(Eq)
/// fn Store::update(self : Store, op : Op) -> (Store, Op?) {
///   ({ ..self, count: self.count + 1 }, None)
/// }
/// // caller:
/// let (new_store, maybe_op) = app.store.val.update(op)
/// app.store.val = new_store
/// ```
pub fn[T, U : Eq, G] render_node(
  mount_target : @dom_ffi.Node,
  // TODO it copies the whole store, need to optimize
  store : Ref[U],
  renderer : () -> @node.RespoNode[T, G] raise @node.RespoCommonError,
  dispatch_action : (T) -> Unit raise @node.RespoCommonError,
  _interval : Float?,
) -> Unit raise @node.RespoCommonError {
  let prev_store = @ref.new(store.val)
  let tree0 : @node.RespoNode[T, G] = renderer()
  let prev_tree = @ref.new(tree0)
  let handle_event = fn(
    mark : @node.RespoEventMark,
  ) -> Unit raise @node.RespoCommonError {
    // @dom_ffi.warn_log(
    //   "start rendering: " + mark.name.to_string() + " " + mark.coord.to_string(),
    // )
    let handler = request_for_target_handler(
      prev_tree.val,
      mark.name,
      mark.coord,
    )
    handler(mark.event_info, dispatch_action)
    // @dom_ffi.log(
    //   "finished event: " + mark.name.to_string() + " " + mark.coord.to_string(),
    // )
    mark_need_rerender()
  }
  let element = @node.build_dom_tree(tree0, @immut/vector.new(), handle_event)

  // collection mounted effects
  let mount_changes : Ref[Array[@node.DomChange[T, G]]] = Ref::new([])
  @node.collect_effects_outside_in_as(
    tree0,
    @immut/vector.new(),
    @immut/vector.new(),
    Mounted,
    mount_changes,
  )
  mount_target.append_child(element)
  // println("mounted changed: \{mount_changes.val}")
  @node.patch_tree(
    tree0,
    prev_tree.val,
    mount_target,
    mount_changes.val,
    handle_event,
  )
  @node.raf_loop(fn(_t : Float) -> Unit raise @node.RespoCommonError {
    if drain_rerender_status() {
      // Skip re-render if store hasn't changed (immutable data optimization).
      // physical_equal is O(1); == may walk the whole structure.
      // Both checks are only reliable when Store has no `mut` fields — see
      // render_node doc comment for the full explanation.
      if physical_equal(store.val, prev_store.val) {
        debug_render("skipped - store reference unchanged")
        return
      }
      // Skip re-render if store changed but logically equal.
      // If this fires unexpectedly after a state change, check that your Store
      // has no `mut` fields and that update() returns a new value.
      if store.val == prev_store.val {
        debug_render("skipped - store logically equal")
        return
      }
      prev_store.val = store.val
      debug_render("starting render cycle")
      let new_tree = renderer()
      let changes : Ref[Array[@node.DomChange[T, G]]] = Ref::new([])
      @node.diff_tree(
        new_tree,
        prev_tree.val,
        @immut/vector.new(),
        @immut/vector.new(),
        changes,
      )
      debug_render("\{changes.val.length()} DOM changes")
      @node.patch_tree(
        new_tree,
        prev_tree.val,
        mount_target,
        changes.val,
        handle_event,
      )
      prev_tree.val = new_tree
    }
  })
}

///|
fn[T, G] request_for_target_handler(
  tree : @node.RespoNode[T, G],
  event_name : @node.RespoEventType,
  coord : @immut/vector.Vector[@node.RespoCoord],
) -> ((@node.RespoEvent, @node.DispatchFn[T]) -> Unit raise @node.RespoCommonError) raise @node.RespoCommonError {
  let target_node = @node.load_coord_target_tree(tree, coord.to_array())
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
