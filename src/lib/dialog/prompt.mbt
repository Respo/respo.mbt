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
} derive(Default)

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

pub fn PromptValidator::new(
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
  // @dom_ffi.log("Prompt states tree: " + states.to_json().stringify(indent=2))
  // @dom_ffi.log("Cast state: " + state.to_json().stringify(indent=2))
  match options.initial_value {
    Some(text) => state = { draft: text.to_string(), error: None }
    None => ()
  }
  // @dom_ffi.log("Prompt state: " + state.to_json().stringify(indent=2))
  let submit = on_submit
  let close = on_close
  @dom_ffi.warn_log(
    "recreate prompt modal with states: " +
    states.data.to_json().stringify(indent=2),
  )
  let on_text_input = fn(
    e : @node.RespoEvent,
    dispatch : @node.DispatchFn[T]
  ) -> Unit!@node.RespoCommonError {
    // if let RespoEvent::Input { value, .. } = e {
    //   dispatch.run_state(&cursor, InputState { draft: value, error: None })?;
    // }
    match e {
      Input(~value, ..) => {
        // @dom_ffi.log("input value: " + value.escape())
        let s : InputState = { draft: value, error: None }
        // @dom_ffi.log("input state: " + s.to_json().stringify(indent=2))
        dispatch.run_state!(cursor, s.to_json())
      }
      _ => ()
    }
  }
  let check_submit = fn(
    text : String,
    dispatch : @node.DispatchFn[T]
  ) -> Unit!@node.RespoCommonError {
    @dom_ffi.log("Event states tree: " + states.to_json().stringify(indent=2))
    match options.validator {
      Some(validator) => {
        let result = validator.run(text)
        @dom_ffi.log(
          "validator result: " + result.to_string() + " of " + text.escape(),
        )
        // @dom_ffi.debugger()
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

  // let effect_focus_data : EffectFocus = { show, }
  let effect_modal_fade_data : EffectModalFade = { show, }
  @node.RespoComponent::named(
    "prompt-modal",
    effects=[
      // (effect_focus_data as @node.RespoEffect).turn_effect(),
      (effect_modal_fade_data as @node.RespoEffect).turn_effect(),
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
                  fn(e, _dispatch) {
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
                          inner_text=options.text.or("Input your text:"),
                        ),
                        [],
                      ),
                      @node.space(height=8),
                      @node.div(
                        [
                          if options.multilines {
                            @node.input(
                              attrs=@node.respo_attrs(
                                value=state.draft,
                                placeholder="Content...",
                                class_name=@respo.ui_textarea,
                              ),
                              style=@node.RespoStyle::new(width=Percent(100)),
                              event={}..set(Input, on_text_input),
                            )
                          } else {
                            @node.input(
                              attrs=@node.respo_attrs(
                                value=state.draft,
                                placeholder="Content...",
                                class_name=@respo.ui_input,
                              ),
                              style=@node.RespoStyle::new(width=Percent(100)),
                              event={}..set(Input, on_text_input),
                            )
                          },
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
                                  inner_text=options.button_text.or("Submit"),
                                ),
                                event={}..set(
                                  Click,
                                  fn(_e, dispatch) {
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
          @node.span(
            attrs=@node.respo_attrs()..set("data-name", "placeholder"),
            [],
          )
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

pub fn render[T : @node.RespoAction](
  self : PromptPlugin[T]
) -> @node.RespoNode[T] {
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
        let window = @dom_ffi.window()
        let _task = window.dirty_call_fn_1(next_prompt_task_name, content)
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
        Err(e) => @dom_ffi.error_log("error: " + e.to_string())
      }
      // clean up leaked closure
      let window = @dom_ffi.window()
      window.dirty_remove_fn(next_prompt_task_name)
    },
  )
}

pub fn show[T : @node.RespoAction](
  self : PromptPlugin[T],
  dispatch : @node.DispatchFn[T],
  next_task : (String) -> Unit
) -> Unit!@node.RespoCommonError {
  let s : PromptPluginState = { show: true, text: self.state.text }
  let window = @dom_ffi.window()
  window.dirty_set_fn_1(next_prompt_task_name, next_task)
  dispatch.run_state!(self.cursor, s.to_json())
}

pub fn close[T : @node.RespoAction](
  self : PromptPlugin[T],
  dispatch : @node.DispatchFn[T]
) -> Unit!@node.RespoCommonError {
  let s : PromptPluginState = { show: false, text: self.text }
  dispatch.run_state!(self.cursor, s.to_json())
}

pub fn PromptPlugin::new[T : @node.RespoAction](
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
