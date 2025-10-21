///|
using @respo {type RespoStatesTree}

///|
using @node {text_node}

///|
let next_task_name : String = "_RESPO_CONFIRM_NEXT_TASK"

///|
/// options for confirm dialog
pub(all) struct ConfirmOptions {
  /// inline style for backdrop
  backdrop_style : @css.RespoStyle
  /// inline style for card
  card_style : @css.RespoStyle
  /// message to display
  text : String?
  /// text on button
  button_text : String?
} derive(Default)

///|
let button_name : String = "dialog-button"

///|
fn[T] comp_confirm_modal(
  options : ConfirmOptions,
  show : Bool,
  on_confirm~ : (@node.DispatchFn[T]) -> Unit,
  on_close~ : (@node.DispatchFn[T]) -> Unit,
) -> @node.RespoNode[T] {

  // effect 1
  let effect_focus_data : EffectFocus = { show, }

  // effect 2
  let effect_modal_fade_data : EffectModalFade = { show, }
  @node.RespoComponent::named(
    "confirm-modal",
    div(style=respo_style(position=Absolute), [
      if show {
        div(
          class_list=[ui_fullscreen, ui_center, css_backdrop],
          style=options.backdrop_style,
          on_click=fn(e, dispatch) {
            if e is Click(original_event~, ..) {
              original_event.stop_propagation()
            }
            let _v = on_close(dispatch)

          },
          [
            div(
              class_list=[ui_column, ui_global, css_modal_card],
              style=options.card_style,
              on_click=fn(e, _dispatch) {
                if e is Click(original_event~, ..) {
                  original_event.stop_propagation()
                }
                ()
              },
              [
                div([
                  options.text.unwrap_or("Need confirmation...") |> text_node,
                  space(height=8),
                  div(class_name=ui_row_parted, [
                    span([]),
                    button(
                      inner_text=options.button_text.unwrap_or("Confirm"),
                      class_list=[ui_button, css_button, button_name],
                      on_click=fn(_e, dispatch) {
                        on_confirm(dispatch)
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
        span(
          // attrs=@node.respo_attrs(data_name="placeholder"),
          [],
        )
      },
    ]),
    effects=[effect_focus_data, effect_modal_fade_data],
  ).to_node()
}

///|
struct ConfirmPluginState {
  show : Bool
  text : String?
} derive(Default, ToJson, FromJson)

///|
/// Popup a confirmation dialog, confirm to process next task
pub(all) struct ConfirmPlugin[T] {
  state : ConfirmPluginState
  options : ConfirmOptions
  /// tracking content to display
  text : String?
  cursor : @node.RespoCursor[ConfirmPluginState]
  on_confirm : (@node.DispatchFn[T]) -> Unit
}

///|
pub fn[T : @node.RespoAction] ConfirmPlugin::render(
  self : ConfirmPlugin[T],
) -> @node.RespoNode[T] {
  let on_confirm = self.on_confirm
  comp_confirm_modal(
    self.options,
    self.state.show,
    on_confirm=fn(dispatch) {
      on_confirm(dispatch)
      let window_obj = @dom_ffi.window().to_js_object()
      // TODO dirty global variable
      let _task = window_obj.call_method_args(next_task_name, [])
      let ret = try? dispatch.set_state(self.cursor, {
          show: false,
          text: self.state.text,
        })
      match ret {
        Ok(_) => ()
        Err(e) => @dom_ffi.error_log("error: \{e}")
      }
      // clean up leaked closure
      let _ = window_obj.delete(next_task_name)

    },
    on_close=fn(dispatch) {
      let ret = try? dispatch.set_state(self.cursor, {
          show: false,
          text: self.state.text,
        })
      match ret {
        Ok(_) => ()
        Err(e) => @dom_ffi.error_log("error: \{e}")
      }
      // clean up leaked closure
      let window = @dom_ffi.window()
      let window_obj = window.to_js_object()
      let _ = window_obj.delete(next_task_name)

    },
  )
}

///|
pub fn[T : @node.RespoAction] ConfirmPlugin::show(
  self : ConfirmPlugin[T],
  dispatch : @node.DispatchFn[T],
  next_task : () -> Unit,
) -> Unit raise @node.RespoCommonError {
  let window_obj = @dom_ffi.window().to_js_object()
  window_obj.set(
    next_task_name,
    @dom_ffi.JsFnObscure::from(next_task).to_obscure(),
  )
  dispatch.set_state(self.cursor, { show: true, text: self.state.text })
}

///|
pub fn[T] ConfirmPlugin::new(
  states : RespoStatesTree,
  options : ConfirmOptions,
  on_confirm : (@node.DispatchFn[T]) -> Unit,
) -> ConfirmPlugin[T] {
  let instance : ConfirmPlugin[T] = {
    state: states.cast_branch(),
    options,
    text: None,
    cursor: states.path(),
    on_confirm,
  }
  instance
}
