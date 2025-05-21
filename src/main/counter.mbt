///|
typealias @respo_node.(RespoNode, RespoEvent, DispatchFn, RespoCommonError)

///|
fnalias @respo_node.(
  respo_style,
  text_node,
  div,
  input,
  button,
  space,
  static_style,
  span,
  respo_attrs
)

///|
struct MainState {
  counted : Int
} derive(Default, ToJson, @json.FromJson)

///|
fn comp_counter(
  states : RespoStatesTree,
  global_counted : Int
) -> RespoNode[ActionOp] {
  let cursor = (states.path() : @respo_node.RespoCursor[MainState])
  let state = (states.cast_branch() : MainState)
  let counted = state.counted
  let on_inc = fn(
    e : RespoEvent,
    dispatch : DispatchFn[ActionOp]
  ) -> Unit!RespoCommonError {
    @dom_ffi.warn_log("inc click: " + e.to_string())
    if e is Click(original_event~, ..) {
      original_event.prevent_default()
    }
    dispatch.run!(Increment)
    dispatch.set_state!(cursor, { counted: state.counted + 1 })
  }
  let on_dec = fn(
    e : RespoEvent,
    dispatch : DispatchFn[ActionOp]
  ) -> Unit!RespoCommonError {
    @dom_ffi.warn_log("dec click: " + e.to_string())
    dispatch.run!(Decrement)
    dispatch.set_state!(cursor, { counted: state.counted - 1 })
  }
  let on_inc_twice = fn(
    e : RespoEvent,
    dispatch : DispatchFn[ActionOp]
  ) -> Unit!RespoCommonError {
    @dom_ffi.warn_log("twice click: " + e.to_string())
    dispatch.run!(IncTwice)
    dispatch.set_state!(cursor, { counted: state.counted + 2 })
  }
  div(attrs=respo_attrs()..set("data-comp", "counter"), [
    div([
      button(
        inner_text="demo inc",
        class_name=ui_button,
        style=respo_style(margin=4 |> Px),
        event={}..set(Click, on_inc),
      ),
      button(
        inner_text="demo dec",
        class_name=ui_button,
        style=respo_style(margin=4 |> Px),
        event={}..set(Click, on_dec),
      ),
      button(
        inner_text="demo inc twice",
        class_name=ui_button,
        style=respo_style(margin=4 |> Px),
        event={}..set(Click, on_inc_twice),
      ),
    ]),
    div([
      text_node(
        "value is: \{counted}",
        style=respo_style(
          color=Hsluv(270, 100, 40),
          font_family="Menlo",
          font_size=counted.reinterpret_as_uint() + 10,
        ),
      ),
    ]),
    div([
      "local state: \{counted}" |> text_node,
      @respo_node.br(),
      "global state: \{global_counted}" |> text_node,
    ]),
  ])
}
