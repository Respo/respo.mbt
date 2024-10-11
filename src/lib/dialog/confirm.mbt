let next_task_name : String = "_RESPO_CONFIRM_NEXT_TASK"

/// options for confirm dialog
pub struct ConfirmOptions {
  /// inline style for backdrop
  backdrop_style : @node.RespoStyle
  /// inline style for card
  card_style : @node.RespoStyle
  /// message to display
  text : String?
  /// text on button
  button_text : String?
} derive(Default)

let button_name : String = "dialog-button"

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
  let effect_focus : @node.RespoEffectBox = {
    args: effect_focus_data.to_json(),
    handler: effect_focus_data.make_handler(),
  }

  // effect 2
  let effect_modal_fade_data : EffectModalFade = { show, }
  let effect_modal_fade : @node.RespoEffectBox = {
    args: effect_modal_fade_data.to_json(),
    handler: effect_modal_fade_data.make_handler(),
  }
  @node.RespoComponent::named(
    "confirm-modal",
    @node.div(
      style=@node.RespoStyle::new(position=Absolute),
      [
        if show {
          @node.div(
            attrs=@node.respo_attrs(
              class_name=@node.str_spaced(
                [@respo.ui_fullscreen, @respo.ui_center, css_backdrop],
              ),
            ),
            style=options.backdrop_style,
            event={}..set(
              Click,
              fn(e, dispatch) {
                match e {
                  Click(~original_event, ..) =>
                    original_event.stop_propagation()
                  _ => ()
                }
                let _v = close(dispatch)

              },
            ),
            [
              @node.div(
                attrs=@node.respo_attrs(
                  class_name=@node.str_spaced(
                    [@respo.column, @respo.ui_global, css_modal_card],
                  ),
                ),
                style=options.card_style,
                event={}..set(
                  Click,
                  fn(e, _dispatch) {
                    match e {
                      Click(~original_event, ..) =>
                        original_event.stop_propagation()
                      _ => ()
                    }
                    ()
                  },
                ),
                [
                  @node.div(
                    [
                      @node.span(
                        attrs=@node.respo_attrs(
                          inner_text=options.text.or("Need confirmation..."),
                        ),
                        [],
                      ),
                      @node.space(height=8),
                      @node.div(
                        attrs=@node.respo_attrs(class_name=@respo.ui_row_parted),
                        [
                          @node.span([]),
                          @node.button(
                            attrs=@node.respo_attrs(
                              class_name=@node.str_spaced(
                                [@respo.ui_button, css_button, button_name],
                              ),
                              inner_text=options.button_text.or("Confirm"),
                            ),
                            event={}..set(
                              Click,
                              fn(_e, dispatch) {
                                confirm(dispatch)
                                close(dispatch)
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              comp_esc_listener(show, close),
            ],
          )
        } else {
          @node.span(
            // attrs=@node.respo_attrs(data_name="placeholder"),
            [],
          )
        },
      ],
    ),
    effects=[effect_focus, effect_modal_fade],
  ).to_node()
}

struct ConfirmPluginState {
  show : Bool
  text : String?
} derive(Default, ToJson, @json.FromJson)

/// Popup a confirmation dialog, confirm to process next task
pub struct ConfirmPlugin[T] {
  state : ConfirmPluginState
  options : ConfirmOptions
  /// tracking content to display
  text : String?
  cursor : Array[String]
  on_confirm : (@node.DispatchFn[T]) -> Unit
}

pub fn render[T : @node.RespoAction](
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
      let window = @web_sys.window()
      // TODO dirty global variable
      let _task = window.dirty_call_fn(next_task_name)
      let s : ConfirmPluginState = { show: false, text: st.text }
      let ret = dispatch.run_state?(c, s.to_json())
      match ret {
        Ok(_) => ()
        Err(e) => @web_sys.error_log("error: " + e.to_string())
      }
      // clean up leaked closure
      window.dirty_remove_fn(next_task_name)
    },
    fn(dispatch) {
      let st = state
      let c = cursor.copy()
      let s : ConfirmPluginState = { show: false, text: st.text }
      let ret = dispatch.run_state?(c, s.to_json())
      match ret {
        Ok(_) => ()
        Err(e) => @web_sys.error_log("error: " + e.to_string())
      }
      // clean up leaked closure
      let window = @web_sys.window()
      window.dirty_remove_fn(next_task_name)
    },
  )
}

pub fn show[T : @node.RespoAction](
  self : ConfirmPlugin[T],
  dispatch : @node.DispatchFn[T],
  next_task : () -> Unit
) -> Unit!@node.RespoCommonError {
  let s : ConfirmPluginState = { show: true, text: self.state.text }
  let window = @web_sys.window()
  window.dirty_set_fn(next_task_name, next_task)
  dispatch.run_state!(self.cursor, s.to_json())
}

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
