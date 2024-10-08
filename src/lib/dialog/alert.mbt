/// The options for alert modal.
// #[derive(Debug, Clone, Default)]
pub struct AlertOptions {
  /// inline style for backdrop
  mut backdrop_style : @node.RespoStyle
  /// inline style for card
  card_style : @node.RespoStyle
  /// message of the alert modal, defaults to `Alert!`
  mut text : String?
  /// text on button
  button_text : String?
}

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
      {
        args: effect_focus_data.to_json(),
        handler: effect_focus_data.make_handler(),
      },
      {
        args: effect_modal_fade_data.to_json(),
        handler: effect_modal_fade_data.make_handler(),
      },
    ],
    @node.div(
      attrs=@node.respo_attrs(style=@node.RespoStyle::new(position=Absolute)),
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
              },
            ),
            [
              @node.div(
                attrs=@node.respo_attrs(
                  class_name=@node.str_spaced(
                    [@respo.column, @respo.ui_global, css_modal_card],
                  ),
                ),
                style=@node.RespoStyle::new(line_height=Px(32.0)).merge(
                  options.card_style,
                ),
                event={}..set(
                  Click,
                  fn(e, dispatch) {
                    match e {
                      Click(~original_event, ..) =>
                        original_event.stop_propagation()
                      _ => ()
                    }
                  },
                ),
                [
                  @node.div(
                    [
                      @node.span(
                        attrs=@node.respo_attrs(
                          inner_text=options.text.or_else(fn() { "Alert!" }),
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
                              inner_text=options.button_text.or_else(
                                fn() { "Read" },
                              ),
                            ),
                            event={}..set(
                              Click,
                              fn(e, dispatch) {
                                read(dispatch)
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
          // attr("data-name", "placeholder")
          @node.span([])
        },
      ],
    ),
  ).to_node()
}

// #[derive(Debug, Clone, Default, PartialEq, Eq, Deserialize, Serialize, RespoState)]
struct AlertPluginState {
  show : Bool
  text : String?
} derive(Default, ToJson, @json.FromJson)

/// abstraction for Alert modal, new with `AlertOption`,
/// just displaying a message, you read it, you close it
pub struct AlertPlugin[T] {
  state : AlertPluginState
  options : AlertOptions
  /// tracking content to display
  text : String?
  cursor : Array[String]
  on_read : (@node.DispatchFn[T]) -> Unit
}

pub fn render[T : @node.RespoAction](
  self : AlertPlugin[T]
) -> @node.RespoNode[T] {
  let on_read = self.on_read
  let cursor = self.cursor.copy()
  let state = self.state
  let options = self.options
  options.text = {
    let state = state
    state.text.map_or(Some(""), fn(s) { options.text })
  }
  comp_alert_modal(
    options,
    self.state.show,
    fn(dispatch) {
      let c = cursor.copy()
      let st = state
      on_read(dispatch)
      let window = @web_sys.window()
      // TODO dirty global variable
      window.dirty_call_fn(next_task_name)
      let s : AlertPluginState = { show: false, text: st.text }
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
      let s : AlertPluginState = { show: false, text: st.text }
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
  self : AlertPlugin[T],
  dispatch : @node.DispatchFn[T],
  text : String?
) -> Unit {
  let s : AlertPluginState = { show: true, text }
  let ret = dispatch.run_state?(self.cursor, s.to_json())
  match ret {
    Ok(_) => ()
    Err(e) => @web_sys.error_log("error: " + e.to_string())
  }
}

pub fn close[T : @node.RespoAction](
  self : AlertPlugin[T],
  dispatch : @node.DispatchFn[T]
) -> Unit {
  let s : AlertPluginState = { show: false, text: self.text }
  let ret = dispatch.run_state?(self.cursor, s.to_json())
  match ret {
    Ok(_) => ()
    Err(e) => @web_sys.error_log("error: " + e.to_string())
  }
}

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
