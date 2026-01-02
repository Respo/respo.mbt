///|
/// Extended FFI bindings for additional DOM functionality
/// This file provides additional FFI functions not covered by the base dom_ffi package

///|
/// Add keyboard event listener to Document
/// This allows listening to keyboard events on the entire document
pub extern "js" fn add_keydown_listener(
  doc : @dom_ffi.Document,
  f : (@dom_ffi.KeyboardEvent) -> Unit,
) -> Unit =
  #| (doc, f) => { doc.addEventListener('keydown', f) }

///|
/// Remove keyboard event listener from Document
pub extern "js" fn remove_keydown_listener(
  doc : @dom_ffi.Document,
  f : (@dom_ffi.KeyboardEvent) -> Unit,
) -> Unit =
  #| (doc, f) => { doc.removeEventListener('keydown', f) }

///|
/// Generic add event listener for Document with callback
pub extern "js" fn add_document_event_listener(
  doc : @dom_ffi.Document,
  type_ : String,
  f : @dom_ffi.JsFnObscure,
) -> Unit =
  #| (doc, type, f) => { doc.addEventListener(type, f) }

///|
/// Generic remove event listener for Document with callback
pub extern "js" fn remove_document_event_listener(
  doc : @dom_ffi.Document,
  type_ : String,
  f : @dom_ffi.JsFnObscure,
) -> Unit =
  #| (doc, type, f) => { doc.removeEventListener(type, f) }

///|
/// Store a value in the window object for JavaScript access
pub extern "js" fn set_window_property(
  key : String,
  value : @dom_ffi.JsObscure,
) -> Unit =
  #| (key, value) => { window[key] = value }

///|
/// Get a value from the window object
pub extern "js" fn get_window_property(key : String) -> @dom_ffi.JsObscure =
  #| (key) => window[key]

///|
/// Convert a MoonBit function to JsObscure so it can be stored in window
pub extern "js" fn function_to_obscure(
  f : (String) -> Unit,
) -> @dom_ffi.JsObscure =
  #| (f) => f
