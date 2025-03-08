///|
let next_task_name : String = "_RESPO_CONFIRM_NEXT_TASK"

///| options for confirm dialog
pub(all) struct ConfirmOptions {
  /// inline style for backdrop
  backdrop_style : @node.RespoStyle
  /// inline style for card
  card_style : @node.RespoStyle
  /// message to display
  text : String?
  /// text on button
  button_text : String?
} derive(Default)

///|
let button_name : String = "dialog-button"

///|
fn comp_confirm_modal[T](
  options : ConfirmOptions,
  show : Bool,
  on_confirm : (@node.DispatchFn[T]) -> Unit,
  on_close : (@node.DispatchFn[T]) -> Unit
) -> @node.RespoNode[T] {
  let confirm = on_confirm
  let close = on_close

  // effect 1
  let effect_focus_data : EffectFocus = { show, }

  // effect 2
  let effect_modal_fade_data : EffectModalFade = { show, }
  @node.RespoComponent::named(
    "confirm-modal",
    div(style=respo_style(position=Absolute), [
      if show {
        div(
          class_name=@node.str_spaced([
            @respo.ui_fullscreen, @respo.ui_center, css_backdrop,
          ]),
          style=options.backdrop_style,
          event={}..set(Click, fn(e, dispatch) {
            if e is Click(original_event~, ..) {
              original_event.stop_propagation()
            }
            let _v = close(dispatch)

          }),
          [
            div(
              class_name=@node.str_spaced([
                @respo.ui_column, @respo.ui_global, css_modal_card,
              ]),
              style=options.card_style,
              event={}..set(Click, fn(e, _dispatch) {
                if e is Click(original_event~, ..) {
                  original_event.stop_propagation()
                }
                ()
              }),
              [
                div([
                  span(inner_text=options.text.or("Need confirmation..."), []),
                  space(height=8),
                  div(class_name=@respo.ui_row_parted, [
                    span([]),
                    button(
                      inner_text=options.button_text.or("Confirm"),
                      class_name=str_spaced([
                        @respo.ui_button, css_button, button_name,
                      ]),
                      event={}..set(Click, fn(_e, dispatch) {
                        confirm(dispatch)
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
        span(
          // attrs=@node.respo_attrs(data_name="placeholder"),
          [],
        )
      },
    ]),
    effects=[
      effect_focus_data as &@node.RespoEffect,
      effect_modal_fade_data as &@node.RespoEffect,
    ],
  ).to_node()
}

///|
struct ConfirmPluginState {
  show : Bool
  text : String?
} derive(Default, ToJson, @json.FromJson)

///| Popup a confirmation dialog, confirm to process next task
pub(all) struct ConfirmPlugin[T] {
  state : ConfirmPluginState
  options : ConfirmOptions
  /// tracking content to display
  text : String?
  cursor : Array[String]
  on_confirm : (@node.DispatchFn[T]) -> Unit
}

///|
pub fn ConfirmPlugin::render[T : @node.RespoAction](
  self : ConfirmPlugin[T]
) -> @node.RespoNode[T] {
  let on_confirm = self.on_confirm
  let cursor = self.cursor.copy()
  let state = self.state
  comp_confirm_modal(
    self.options,
    state.show,
    fn(dispatch) {
      let c = cursor.copy()
      let st = state
      on_confirm(dispatch)
      let window = @dom_ffi.window()
      // TODO dirty global variable
      let _task = window.dirty_call_fn(next_task_name)
      let ret = dispatch.run_state?(c, ConfirmPluginState::{
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
      let s : ConfirmPluginState = { show: false, text: st.text }
      let ret = dispatch.run_state?(c, s)
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
pub fn ConfirmPlugin::show[T : @node.RespoAction](
  self : ConfirmPlugin[T],
  dispatch : @node.DispatchFn[T],
  next_task : () -> Unit
) -> Unit!@node.RespoCommonError {
  let s : ConfirmPluginState = { show: true, text: self.state.text }
  let window = @dom_ffi.window()
  window.dirty_set_fn(next_task_name, next_task)
  dispatch.run_state!(self.cursor, s)
}

///|
pub fn ConfirmPlugin::new[T](
  states : @respo.RespoStatesTree,
  options : ConfirmOptions,
  on_confirm : (@node.DispatchFn[T]) -> Unit
) -> ConfirmPlugin[T] {
  let cursor = states.path()
  let state : ConfirmPluginState = states.cast_branch()
  let instance : ConfirmPlugin[T] = {
    state,
    options,
    text: None,
    cursor,
    on_confirm,
  }
  instance
}
