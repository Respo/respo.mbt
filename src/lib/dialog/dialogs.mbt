///|
struct EffectFocus {
  show : Bool
} derive(Eq, ToJson, @json.FromJson)

///|
impl @node.RespoEffect for EffectFocus with updated(self, el) -> Unit {
  let show : Bool = self.show
  if show {
    focus_element(el, button_name)
  }
}

///|
fn focus_element(el : @dom_ffi.Node, name : String) -> Unit {
  let element = el.reinterpret_as_element().query_selector("." + name) // TODO need to handle None in FFI
  element.focus()
  // app::util::warn_log!("Attempted to focus on element '{}', but it was not found in the DOM.", name);
}

///|
struct EffectModalFade {
  show : Bool
} derive(Eq, ToJson, @json.FromJson)

///|
impl @node.RespoEffect for EffectModalFade with before_update(self, el) {
  let show = self.show
  if not(show) {
    let target = el.first_child()
    let cloned = target.clone_node(deep=true)
    let document = el.owner_document()
    document.body().append_child(cloned)
    let window = @dom_ffi.window()
    let immediate_call = fn() {
      let style = cloned.style()
      style.set_property("opacity", "0")
      let card = cloned.first_child()
      let card_style = card.style()
      card_style.set_property("transition-duration", "240ms")
      card_style.set_property("transform", "scale(0.94) translate(0px,-20px)")
    }
    window.set_timeout(immediate_call, 10)
    let delay_call = fn() { cloned.remove() }
    window.set_timeout(delay_call, 250)

    // else
    // app::util::warn_log!("content not found")

  }
}

///|
impl @node.RespoEffect for EffectModalFade with updated(self, el) {
  let show : Bool = self.show
  if show {
    let target = el.first_child()
    let style = target.style()
    let card_style = target.first_child().style()
    style.set_property("opacity", "0")
    card_style.set_property("transform", "scale(0.94) translate(0px,-12px)")
    let call = fn() {
      style.set_property("transition-duration", "240ms")
      card_style.set_property("transition-duration", "240ms")
      style.set_property("opacity", "1")
      card_style.set_property("transform", "scale(1) translate(0px,0px)")
    }
    let window = @dom_ffi.window()
    window.set_timeout(call, 10)
  }
}

///|
struct EffectDrawerFade {
  show : Bool
} derive(Eq, ToJson, @json.FromJson)

///|
impl @node.RespoEffect for EffectDrawerFade with before_update(self, el) {
  let show = self.show
  if not(show) {
    let target = el.first_child()
    let d = target.clone_node(deep=true)
    let cloned = d // outlive
    let document = el.owner_document()
    document.body().append_child(cloned)
    let window = @dom_ffi.window()
    let immediate_call = fn() {
      let style = cloned.style()
      style.set_property("opacity", "0")
      let card = cloned.first_child()
      let card_style = card.style()
      card_style.set_property("transition-duration", "240ms")
      card_style.set_property("transform", "translate(100%,0px)")
    }
    window.set_timeout(immediate_call, 10)
    let delay_call = fn() { cloned.remove() }
    window.set_timeout(delay_call, 250)

    // else
    // app::util::warn_log!("content not found")
  }
}

///|
impl @node.RespoEffect for EffectDrawerFade with updated(self, el) {
  let show = self.show
  if show {
    let target = el.first_child()
    let style = target.style()
    let card_style = target.first_child().style()
    style.set_property("opacity", "0")
    card_style.set_property("transform", "translate(100%, 0px)")
    let call = fn() {
      style.set_property("transition-duration", "240ms")
      card_style.set_property("transition-duration", "240ms")
      style.set_property("opacity", "1")
      card_style.set_property("transform", "translate(0px,0px)")
    }
    let window = @dom_ffi.window()
    window.set_timeout(call, 10)
  }
}

///|
type EffectModalClose Unit derive(Eq, ToJson, @json.FromJson)

///|
impl @node.RespoEffect for EffectModalClose with mounted(_self, el) {
  let window = @dom_ffi.window()
  let listener = fn(event : @dom_ffi.KeyboardEvent) {
    let init_dict = @dom_ffi.KeyboardEventInit::new()
    // init_dict.set_key(event.key())
    init_dict.set_code(event.code())
    init_dict.set_char_code(event.char_code())
    init_dict.set_view(event.view())
    init_dict.set_location(event.location())
    init_dict.set_key_code(event.key_code())
    let new_event = @dom_ffi.KeyboardEvent::new_with_init_dict(
      "keydown", init_dict,
    )
    let _ = el.dispatch_event(new_event)
    return false
  }
  window.add_event_listener_with_callback("keydown", listener)
  let _ = el
    .reinterpret_as_element()
    .dirty_set_attribute_fn(temp_listener, listener)

}

///|
impl @node.RespoEffect for EffectModalClose with before_unmount(_self, el) {
  let el = el.reinterpret_as_element()
  let listener = el.dirty_get_attribute_fn(temp_listener) // dirty
  let window = @dom_ffi.window()
  window.remove_event_listener_with_callback("keydown", listener)
  let _ = el.dirty_remove_attribute_fn(temp_listener)

}

///| put listener on the element, directly on the element
let temp_listener : String = "temp_listener"

///| handle global keydown event
pub fn comp_esc_listener[T](
  _show : Bool,
  on_close : (@node.DispatchFn[T]) -> Unit
) -> @node.RespoNode[T] {
  let effect_modal_close_data = EffectModalClose(())
  @node.RespoComponent::named(
    "esc-listener",
    effects=[effect_modal_close_data as &@node.RespoEffect],
    input(
      value="",
      style=respo_style(display=None),
      event={}..set(Keydown, fn(e, dispatch) {
        if e is Keyboard(key~, ..) && key == "Escape" {
          on_close(dispatch)
        }
      }),
    ),
  ).to_node()
}

///|
let css_backdrop : String = declare_static_style([
  (
    "&",
    respo_style(
      background_color=Hsla(0, 30, 10, 0.6),
      position=Fixed,
      z_index=999,
    ),
  ),
])

///|
let css_modal_card : String = declare_static_style([
  (
    "&",
    respo_style(
      background_color=Hsl(0, 0, 100),
      max_width=Px(600),
      width=Percent(100),
      max_height=Vh(80),
      overflow=Auto,
      border_radius=3.0,
      color=Hsl(0, 0, 0),
      margin=Auto,
      padding=Px(16),
    ),
  ),
])

///|
let css_drawer_card : String = declare_static_style([
  (
    "&",
    respo_style(
      background_color=Hsl(0, 0, 100),
      max_width=Vw(50),
      width=Px(400),
      height=Vh(100),
      overflow=Auto,
      color=Hsl(0, 0, 0),
      top=Px(0),
      right=Px(0),
      bottom=Px(0),
      position=Absolute,
      box_shadow="-2 0 12px 0 hsla(0, 0, 0, 0.2)",
      transform_property=["transform", "opacity"],
    ),
  ),
])

///|
let css_button : String = declare_static_style([
  (
    "&",
    respo_style(
      border_radius=4.0,
      background_color=White,
      border_color=Hsl(0, 0, 0),
    ),
  ),
])
