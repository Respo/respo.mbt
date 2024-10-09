let next_prompt_task_name : String = "_RESPO_PROMPT_NEXT_TASK"

/// options for prompt dialog
// #[derive(Debug, Clone, Default)]
pub struct PromptOptions {
  /// inline style for backdrop
  backdrop_style : @node.RespoStyle
  /// inline style for card
  card_style : @node.RespoStyle
  /// hint to display, defaults `input message`
  text : String?
  /// text on button
  button_text : String?
  /// initial value of input
  initial_value : String?
  /// textarea or input
  multilines : Bool
  /// inline style for input bix
  input_style : @node.RespoStyle
  /// a validation function to check input
  validator : PromptValidator?
}

// /// wraps validator function
// #[allow(clippy::type_complexity)]
// #[derive(Clone)]
pub type PromptValidator (String) -> Result[Unit, String]

pub fn to_string(self : PromptValidator) -> String {
  "(PromptValidator)"
}

impl Show for PromptValidator with output(self, logger) {
  logger.write_string(self.to_string())
}

fn PromptValidator::new(
  f : (String) -> Result[Unit, String]
) -> PromptValidator {
  f
}

fn PromptValidator::run(
  self : PromptValidator,
  value : String
) -> Result[Unit, String] {
  let f = self._
  f(value)
}

// #[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize, RespoState)]
struct InputState {
  draft : String
  error : String?
} derive(Default, ToJson, @json.FromJson)

fn comp_prompt_modal[T : @node.RespoAction](
  states : @respo.RespoStatesTree,
  options : PromptOptions,
  show : Bool,
  on_submit : (String, @node.DispatchFn[T]) -> Unit!@node.RespoCommonError,
  on_close : (@node.DispatchFn[T]) -> Unit
) -> @node.RespoNode[T] {
  let cursor = states.path()
  // TODO need compare with old
  let mut state : InputState = states.cast_branch()
  state = match options.initial_value {
    Some(text) => { draft: text.to_string(), error: None }
    None => { draft: "".to_string(), error: None }
  }

  // respo::util::log!("State: {:?}", state);

  let submit = on_submit
  let close = on_close
  let on_text_input = fn(
    e : @node.RespoEvent,
    dispatch : @node.DispatchFn[T]
  ) -> Unit!@node.RespoCommonError {
    // if let RespoEvent::Input { value, .. } = e {
    //   dispatch.run_state(&cursor, InputState { draft: value, error: None })?;
    // }
    match e {
      Input(~value, ..) => {
        let s : InputState = { draft: value, error: None }
        dispatch.run_state!(cursor, s.to_json())
      }
      _ => ()
    }
  }
  let check_submit = fn(
    text : String,
    dispatch : @node.DispatchFn[T]
  ) -> Unit!@node.RespoCommonError {
    @web_sys.log("validator: " + options.validator.to_string())
    match options.validator {
      Some(validator) => {
        let result = validator.run(text)
        match result {
          Ok(_) => {
            submit!(text, dispatch)
            close(dispatch)
            dispatch.run_empty_state!(cursor)
          }
          Err(message) =>
            dispatch.run_state!(
              cursor,
              { draft: text, error: Some(message) }.to_json(),
            )
        }
      }
      None => {
        submit!(text, dispatch)
        close(dispatch)
        dispatch.run_empty_state!(cursor)
      }
    }
  }
  let input_el : @node.RespoNode[T] = if options.multilines {
    @node.textarea(attrs=@node.respo_attrs(class_name=@respo.ui_textarea))
  } else {
    @node.input(attrs=@node.respo_attrs(class_name=@respo.ui_input))
  }
  // let effect_focus_data : EffectFocus = { show, }
  let effect_modal_fade_data : EffectModalFade = { show, }
  @node.RespoComponent::named(
    "prompt-modal",
    effects=[
      // {
      //   args: effect_focus_data.to_json(),
      //   handler: effect_focus_data.make_handler(),
      // },
      {
        args: effect_modal_fade_data.to_json(),
        handler: effect_modal_fade_data.make_handler(),
      },
    ],
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
                close(dispatch)
                dispatch.run_empty_state!(cursor)
              },
            ),
            [
              @node.div(
                attrs=@node.respo_attrs(
                  class_name=@node.str_spaced(
                    [@respo.column, @respo.ui_global, css_modal_card],
                  ),
                ),
                style=@node.RespoStyle::new(line_height=Px(32.0))
                  .merge(options.card_style)
                  .merge(options.input_style),
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
                          inner_text=options.text.or_else(
                            fn() { "Input your text:" },
                          ),
                        ),
                        [],
                      ),
                      @node.space(height=8),
                      @node.div(
                        [
                          @node.input(
                            attrs=@node.respo_attrs(
                              value=state.draft,
                              placeholder="Content...",
                              class_name=@respo.ui_input,
                            ),
                            style=@node.RespoStyle::new(width=Percent(100)),
                            event={}..set(Input, on_text_input),
                          ),
                          match state.error {
                            Some(message) =>
                              @node.div(
                                attrs=@node.respo_attrs(
                                  class_name=css_error,
                                  inner_text=message,
                                ),
                                [],
                              )
                            None => @node.span([])
                          },
                          @node.space(height=8),
                          @node.div(
                            attrs=@node.respo_attrs(
                              class_name=@respo.ui_row_parted,
                            ),
                            [
                              @node.span([]),
                              @node.button(
                                attrs=@node.respo_attrs(
                                  class_name=@node.str_spaced(
                                    [@respo.ui_button, css_button, button_name],
                                  ),
                                  inner_text=options.button_text.or_else(
                                    fn() { "Submit" },
                                  ),
                                ),
                                event={}..set(
                                  Click,
                                  fn(e, dispatch) {
                                    check_submit!(state.draft, dispatch)
                                  },
                                ),
                              ),
                            ],
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
          // .attr("data-name", "placeholder")
          @node.span([])
        },
      ],
    ),
  ).to_node()
}

struct PromptPluginState {
  show : Bool
  text : String?
} derive(Default, ToJson, @json.FromJson)

/// a dialog for prompt, request for some input, and submit
// #[derive(Debug, Clone)]
pub struct PromptPlugin[T] {
  states : @respo.RespoStatesTree
  state : PromptPluginState
  options : PromptOptions
  /// tracking content to display
  text : String?
  cursor : Array[String]
  on_submit : (String, @node.DispatchFn[T]) -> Unit!@node.RespoCommonError
}

fn render[T : @node.RespoAction](self : PromptPlugin[T]) -> @node.RespoNode[T] {
  let on_submit = self.on_submit
  let cursor = self.cursor.copy()
  let state = self.state
  comp_prompt_modal(
    self.states.pick("plugin"),
    self.options,
    self.state.show,
    {
      let cursor = cursor.copy()
      fn(content, dispatch) {
        on_submit!(content, dispatch)
        let window = @web_sys.window()
        let task = window.dirty_call_fn_1(next_prompt_task_name, content)
        let s : PromptPluginState = { show: false, text: state.text }
        dispatch.run_state!(cursor, s.to_json())
        // clean up leaked closure
        window.dirty_remove_fn(next_prompt_task_name)
      }
    },
    fn(dispatch) -> Unit {
      let s : PromptPluginState = { show: false, text: state.text }
      let ret = dispatch.run_state?(cursor, s.to_json())
      match ret {
        Ok(_) => ()
        Err(e) => @web_sys.error_log("error: " + e.to_string())
      }
      // clean up leaked closure
      let window = @web_sys.window()
      window.dirty_remove_fn(next_prompt_task_name)
    },
  )
}

fn show[T : @node.RespoAction](
  self : PromptPlugin[T],
  dispatch : @node.DispatchFn[T],
  next_task : (String) -> Unit
) -> Unit!@node.RespoCommonError {
  let s : PromptPluginState = { show: true, text: self.state.text }
  let window = @web_sys.window()
  window.dirty_set_fn_1(next_prompt_task_name, next_task)
  dispatch.run_state!(self.cursor, s.to_json())
}

fn close[T : @node.RespoAction](
  self : PromptPlugin[T],
  dispatch : @node.DispatchFn[T]
) -> Unit!@node.RespoCommonError {
  let s : PromptPluginState = { show: false, text: self.text }
  dispatch.run_state!(self.cursor, s.to_json())
}

fn PromptPlugin::new[T : @node.RespoAction](
  states : @respo.RespoStatesTree,
  options : PromptOptions,
  on_submit : (String, @node.DispatchFn[T]) -> Unit!@node.RespoCommonError
) -> PromptPlugin[T] {
  let cursor = states.path()
  let state : PromptPluginState = states.cast_branch()
  { states, state, options, text: None, cursor, on_submit }
}

let css_error : String = @node.declare_static_style(
  [("&", @node.RespoStyle::new(color=Red))],
)
