///|
fnalias @node.(div, respo_style, span, space, button, respo_attrs, input)

///|
fnalias @respo.(
  ui_global,
  ui_center,
  ui_column,
  ui_row_parted,
  ui_fullscreen,
  ui_button
)

///| The options for alert modal.
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
  options~ : AlertOptions,
  show~ : Bool,
  on_read~ : (@node.DispatchFn[T]) -> Unit,
  on_close~ : (@node.DispatchFn[T]) -> Unit
) -> @node.RespoNode[T] {
  let effect_focus_data : EffectFocus = { show, }
  let effect_modal_fade_data : EffectModalFade = { show, }
  @node.RespoComponent::named(
    "alert-modal",
    effects=[effect_focus_data, effect_modal_fade_data],
    div(style=respo_style(position=Absolute), [
      if show {
        div(
          class_list=[ui_fullscreen, ui_center, css_backdrop],
          style=options.backdrop_style,
          on_click=fn(e, _dispatch) {
            if e is Click(original_event~, ..) {
              original_event.stop_propagation()
            }
          },
          [
            div(
              class_list=[ui_column, ui_global, css_modal_card],
              style=respo_style(line_height=32.0 |> Px).merge(
                options.card_style,
              ),
              on_click=fn(e, _dispatch) {
                if e is Click(original_event~, ..) {
                  original_event.stop_propagation()
                }
              },
              [
                div([
                  span(inner_text=options.text.or("Alert!"), []),
                  space(height=8),
                  div(class_name=ui_row_parted, [
                    span([]),
                    button(
                      inner_text=options.button_text.or("Read"),
                      class_list=[ui_button, css_button, button_name],
                      on_click=fn(_e, dispatch) {
                        on_read(dispatch)
                        on_close(dispatch)
                      },
                    ),
                  ]),
                ]),
              ],
            ),
            comp_esc_listener(show, on_close~),
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
  cursor : @node.RespoCursor[AlertPluginState]
  on_read : (@node.DispatchFn[T]) -> Unit
}

///|
pub fn render[T : @node.RespoAction](
  self : AlertPlugin[T]
) -> @node.RespoNode[T] {
  let on_read = self.on_read
  let state = self.state
  let options : AlertOptions = {
    ..self.options,
    text: match state.text {
      Some(v) => Some(v)
      None => self.options.text
    },
  }
  comp_alert_modal(
    options~,
    show=self.state.show,
    on_read=fn(dispatch) {
      let st = state
      on_read(dispatch)
      let window = @dom_ffi.window()
      // TODO dirty global variable
      window.dirty_call_fn(next_task_name)
      let ret = dispatch.set_state?(self.cursor, { show: false, text: st.text })
      match ret {
        Ok(_) => ()
        Err(e) => @dom_ffi.error_log("error: " + e.to_string())
      }
      // clean up leaked closure
      window.dirty_remove_fn(next_task_name)
    },
    on_close=fn(dispatch) {
      let st = state
      let ret = dispatch.set_state?(self.cursor, { show: false, text: st.text })
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
  dispatch.set_state!(self.cursor, { show: true, text })
}

///|
pub fn close[T : @node.RespoAction](
  self : AlertPlugin[T],
  dispatch : @node.DispatchFn[T]
) -> Unit {
  let ret = dispatch.set_state?(self.cursor, { show: false, text: self.text })
  if ret is Err(e) {
    @dom_ffi.error_log("error: " + e.to_string())
  }
}

///|
pub fn AlertPlugin::new[T : @node.RespoAction](
  states : RespoStatesTree,
  options : AlertOptions,
  on_read : (@node.DispatchFn[T]) -> Unit
) -> AlertPlugin[T] {
  let instance : AlertPlugin[T] = {
    state: states.cast_branch(),
    options,
    text: None,
    cursor: states.path(),
    on_read,
  }
  instance
}
