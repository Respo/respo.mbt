///|
let next_prompt_task_name : String = "_RESPO_PROMPT_NEXT_TASK"

///| options for prompt dialog
// #[derive(Debug, Clone, Default)]
pub(all) struct PromptOptions {
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
///|
pub(all) type PromptValidator (String) -> Result[Unit, String]

///|
pub fn PromptValidator::to_string(self : PromptValidator) -> String {
  "(PromptValidator \{self})"
}

///|
impl Show for PromptValidator with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub fn PromptValidator::new(
  f : (String) -> Result[Unit, String]
) -> PromptValidator {
  f
}

///|
fn PromptValidator::run(
  self : PromptValidator,
  value : String
) -> Result[Unit, String] {
  let f = self._
  f(value)
}

// #[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize, RespoState)]
///|
priv struct InputState {
  draft : String
  error : String?
} derive(Default, ToJson, @json.FromJson)

///|
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
  if options.initial_value is Some(text) {
    state = { draft: text.to_string(), error: None }
  }
  // @dom_ffi.log("Prompt state: " + state.to_json().stringify(indent=2))
  let submit = on_submit
  let close = on_close
  // @dom_ffi.warn_log(
  //   "recreate prompt modal with states: " +
  //   states.data.to_json().stringify(indent=2),
  // )
  let on_text_input = fn(
    e : @node.RespoEvent,
    dispatch : @node.DispatchFn[T]
  ) -> Unit!@node.RespoCommonError {
    if e is Input(value~, ..) {
      // @dom_ffi.log("input value: " + value.escape())
      // @dom_ffi.log("input state: " + s.to_json().stringify(indent=2))
      dispatch.run_state!(cursor, InputState::{ draft: value, error: None })
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
            dispatch.run_state!(cursor, InputState::{
              draft: text,
              error: Some(message),
            })
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
      effect_modal_fade_data as &@node.RespoEffect,
    ],
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
            close(dispatch)
            dispatch.run_empty_state!(cursor)
          }),
          [
            div(
              class_name=@node.str_spaced([
                @respo.ui_column, @respo.ui_global, css_modal_card,
              ]),
              style=respo_style(line_height=Px(32.0))
                .merge(options.card_style)
                .merge(options.input_style),
              event={}..set(Click, fn(e, _dispatch) {
                if e is Click(original_event~, ..) {
                  original_event.stop_propagation()
                }
              }),
              [
                div([
                  span(inner_text=options.text.or("Input your text:"), []),
                  space(height=8),
                  div([
                    if options.multilines {
                      input(
                        value=state.draft,
                        placeholder="Content...",
                        class_name=ui_textarea,
                        style=respo_style(width=Percent(100)),
                        event={}..set(Input, on_text_input),
                      )
                    } else {
                      input(
                        value=state.draft,
                        placeholder="Content...",
                        class_name=@respo.ui_input,
                        style=respo_style(width=Percent(100)),
                        event={}..set(Input, on_text_input),
                      )
                    },
                    match state.error {
                      Some(message) =>
                        div(
                          class_name=css_error,
                          attrs=respo_attrs(inner_text=message),
                          [],
                        )
                      None => span([])
                    },
                    space(height=8),
                    div(class_name=ui_row_parted, [
                      span([]),
                      button(
                        inner_text=options.button_text.or("Submit"),
                        class_name=str_spaced([
                          ui_button, css_button, button_name,
                        ]),
                        event={}..set(Click, fn(_e, dispatch) {
                          check_submit!(state.draft, dispatch)
                        }),
                      ),
                    ]),
                  ]),
                ]),
              ],
            ),
            comp_esc_listener(show, close),
          ],
        )
      } else {
        span(attrs=@node.respo_attrs()..set("data-name", "placeholder"), [])
      },
    ]),
  ).to_node()
}

///|
struct PromptPluginState {
  show : Bool
  text : String?
} derive(Default, ToJson, @json.FromJson)

///| a dialog for prompt, request for some input, and submit
// #[derive(Debug, Clone)]
pub(all) struct PromptPlugin[T] {
  states : @respo.RespoStatesTree
  state : PromptPluginState
  options : PromptOptions
  /// tracking content to display
  text : String?
  cursor : Array[String]
  on_submit : (String, @node.DispatchFn[T]) -> Unit!@node.RespoCommonError
}

///|
pub fn PromptPlugin::render[T : @node.RespoAction](
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
        dispatch.run_state!(cursor, PromptPluginState::{
          show: false,
          text: state.text,
        })
        // clean up leaked closure
        window.dirty_remove_fn(next_prompt_task_name)
      }
    },
    fn(dispatch) -> Unit {
      let s : PromptPluginState = { show: false, text: state.text }
      let ret = dispatch.run_state?(cursor, s)
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

///|
pub fn PromptPlugin::show[T : @node.RespoAction](
  self : PromptPlugin[T],
  dispatch : @node.DispatchFn[T],
  next_task : (String) -> Unit
) -> Unit!@node.RespoCommonError {
  let window = @dom_ffi.window()
  window.dirty_set_fn_1(next_prompt_task_name, next_task)
  dispatch.run_state!(self.cursor, PromptPluginState::{
    show: true,
    text: self.state.text,
  })
}

///|
pub fn PromptPlugin::close[T : @node.RespoAction](
  self : PromptPlugin[T],
  dispatch : @node.DispatchFn[T]
) -> Unit!@node.RespoCommonError {
  dispatch.run_state!(self.cursor, PromptPluginState::{
    show: false,
    text: self.text,
  })
}

///|
pub fn PromptPlugin::new[T : @node.RespoAction](
  states : @respo.RespoStatesTree,
  options : PromptOptions,
  on_submit : (String, @node.DispatchFn[T]) -> Unit!@node.RespoCommonError
) -> PromptPlugin[T] {
  let cursor = states.path()
  let state : PromptPluginState = states.cast_branch()
  { states, state, options, text: None, cursor, on_submit }
}

///|
let css_error : String = declare_static_style([("&", respo_style(color=Red))])
