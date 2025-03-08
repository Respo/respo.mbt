///| The options for alert modal.
// #[derive(Debug, Clone, Default)]
pub(all) struct AlertOptions {
  /// inline style for backdrop
  mut backdrop_style : @node.RespoStyle
  /// inline style for card
  card_style : @node.RespoStyle
  /// message of the alert modal, defaults to `Alert!`
  mut text : String?
  /// text on button
  button_text : String?
} derive(Default)

///|
fn comp_alert_modal[T](
  options : AlertOptions,
  show : Bool,
  on_read : (@node.DispatchFn[T]) -> Unit,
  on_close : (@node.DispatchFn[T]) -> Unit
) -> @node.RespoNode[T] {
  let read = on_read
  let close = on_close
  let effect_focus_data : EffectFocus = { show, }
  let effect_modal_fade_data : EffectModalFade = { show, }
  @node.RespoComponent::named(
    "alert-modal",
    effects=[
      effect_focus_data as &@node.RespoEffect,
      effect_modal_fade_data as &@node.RespoEffect,
    ],
    div(style=respo_style(position=Absolute), [
      if show {
        div(
          class_name=@node.str_spaced([
            @respo.ui_fullscreen, @respo.ui_center, css_backdrop,
          ]),
          style=options.backdrop_style,
          event={}..set(Click, fn(e, _dispatch) {
            if e is Click(original_event~, ..) {
              original_event.stop_propagation()
            }
          }),
          [
            div(
              class_name=@node.str_spaced([
                @respo.ui_column, ui_global, css_modal_card,
              ]),
              style=respo_style(line_height=Px(32.0)).merge(options.card_style),
              event={}..set(Click, fn(e, _dispatch) {
                if e is Click(original_event~, ..) {
                  original_event.stop_propagation()
                }
              }),
              [
                div([
                  span(inner_text=options.text.or("Alert!"), []),
                  space(height=8),
                  div(class_name=@respo.ui_row_parted, [
                    span([]),
                    button(
                      inner_text=options.button_text.or("Read"),
                      class_name=str_spaced([ui_button, css_button, button_name]),
                      event={}..set(Click, fn(_e, dispatch) {
                        read(dispatch)
                        close(dispatch)
                      }),
                    ),
                  ]),
                ]),
              ],
            ),
            comp_esc_listener(show, close),
          ],
        )
      } else {
        span(attrs=respo_attrs()..set("data-name", "placeholder"), [])
      },
    ]),
  ).to_node()
}

// #[derive(Debug, Clone, Default, PartialEq, Eq, Deserialize, Serialize, RespoState)]
///|
struct AlertPluginState {
  show : Bool
  text : String?
} derive(Default, ToJson, @json.FromJson)

///| abstraction for Alert modal, new with `AlertOption`,
/// just displaying a message, you read it, you close it
pub(all) struct AlertPlugin[T] {
  state : AlertPluginState
  options : AlertOptions
  /// tracking content to display
  text : String?
  cursor : Array[String]
  on_read : (@node.DispatchFn[T]) -> Unit
}

///|
pub fn render[T : @node.RespoAction](
  self : AlertPlugin[T]
) -> @node.RespoNode[T] {
  let on_read = self.on_read
  let cursor = self.cursor.copy()
  let state = self.state
  let options : AlertOptions = {
    ..self.options,
    text: match state.text {
      Some(v) => Some(v)
      None => self.options.text
    },
  }
  comp_alert_modal(
    options,
    self.state.show,
    fn(dispatch) {
      let c = cursor.copy()
      let st = state
      on_read(dispatch)
      let window = @dom_ffi.window()
      // TODO dirty global variable
      window.dirty_call_fn(next_task_name)
      let ret = dispatch.run_state?(c, AlertPluginState::{
        show: false,
        text: st.text,
      })
      match ret {
        Ok(_) => ()
        Err(e) => @dom_ffi.error_log("error: " + e.to_string())
      }
      // clean up leaked closure
      window.dirty_remove_fn(next_task_name)
    },
    fn(dispatch) {
      let st = state
      let c = cursor.copy()
      let ret = dispatch.run_state?(c, AlertPluginState::{
        show: false,
        text: st.text,
      })
      match ret {
        Ok(_) => ()
        Err(e) => @dom_ffi.error_log("error: " + e.to_string())
      }
      // clean up leaked closure
      let window = @dom_ffi.window()
      window.dirty_remove_fn(next_task_name)
    },
  )
}

///|
pub fn show[T : @node.RespoAction](
  self : AlertPlugin[T],
  dispatch : @node.DispatchFn[T],
  text : String?
) -> Unit!@node.RespoCommonError {
  dispatch.run_state!(self.cursor, AlertPluginState::{ show: true, text })
}

///|
pub fn close[T : @node.RespoAction](
  self : AlertPlugin[T],
  dispatch : @node.DispatchFn[T]
) -> Unit {
  let ret = dispatch.run_state?(self.cursor, AlertPluginState::{
    show: false,
    text: self.text,
  })
  match ret {
    Ok(_) => ()
    Err(e) => @dom_ffi.error_log("error: " + e.to_string())
  }
}

///|
pub fn AlertPlugin::new[T : @node.RespoAction](
  states : @respo.RespoStatesTree,
  options : AlertOptions,
  on_read : (@node.DispatchFn[T]) -> Unit
) -> AlertPlugin[T] {
  let cursor = states.path()
  let state : AlertPluginState = states.cast_branch()
  let instance : AlertPlugin[T] = {
    state,
    options,
    text: None,
    cursor,
    on_read,
  }
  instance
}
