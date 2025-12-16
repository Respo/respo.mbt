///|
/// Global debug mode flag
let respo_debug_mode : Ref[Bool] = Ref::new(false)

///|
/// Enable or disable debug mode for Respo framework
/// When enabled, logs state changes, events, and render cycles
pub fn set_debug_mode(enabled : Bool) -> Unit {
  respo_debug_mode.val = enabled
  if enabled {
    @dom_ffi.log("[Respo] Debug mode enabled")
  }
}

///|
/// Check if debug mode is enabled
pub fn is_debug_mode() -> Bool {
  respo_debug_mode.val
}

///|
/// Log a debug message (only when debug mode is enabled)
pub fn debug_log(message : String) -> Unit {
  if respo_debug_mode.val {
    @dom_ffi.log("[Respo Debug] " + message)
  }
}

///|
/// Log a state change (only when debug mode is enabled)
pub fn[T : Show] debug_state_change(
  label : String,
  old_state : T,
  new_state : T,
) -> Unit {
  if respo_debug_mode.val {
    @dom_ffi.log(
      "[Respo Debug] State change (\{label}): \{old_state} -> \{new_state}",
    )
  }
}

///|
/// Log an event (only when debug mode is enabled)
pub fn debug_event(event_type : String, details : String) -> Unit {
  if respo_debug_mode.val {
    @dom_ffi.log("[Respo Debug] Event (\{event_type}): \{details}")
  }
}

///|
/// Log a render cycle (only when debug mode is enabled)
pub fn debug_render(message : String) -> Unit {
  if respo_debug_mode.val {
    @dom_ffi.log("[Respo Debug] Render: \{message}")
  }
}

///|
/// Log store update (only when debug mode is enabled)
pub fn[T : Show] debug_store_update(action : T) -> Unit {
  if respo_debug_mode.val {
    @dom_ffi.log("[Respo Debug] Store update: \{action}")
  }
}
