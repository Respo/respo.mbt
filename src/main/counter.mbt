///|
typealias @respo_node.(RespoNode, RespoEvent, DispatchFn, RespoCommonError)

///|
fnalias @respo_node.(
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
fnalias @css.respo_style

///|
struct MainState {
  counted : Int
} derive(Default, ToJson, FromJson)

///|
fn comp_counter(
  states : RespoStatesTree,
  global_counted : Int,
) -> RespoNode[ActionOp] {
  let ((state : MainState), cursor) = states.local_pair()
  let counted = state.counted
  div(
    attrs={
      let t = respo_attrs()
      t.set("data-comp", "counter")
      t
    },
    [
      div([
        button(
          inner_text="demo inc",
          class_name=@respo.ui_button,
          style=respo_style(margin=4 |> Px),
          on_click=fn(e, dispatch) {
            @dom_ffi.warn_log("inc click: \{e}")
            if e is Click(original_event~, ..) {
              original_event.prevent_default()
            }
            dispatch.run(Increment)
            dispatch.set_state(cursor, { counted: state.counted + 1 })
          },
        ),
        button(
          inner_text="demo dec",
          class_name=@respo.ui_button,
          style=respo_style(margin=4 |> Px),
          on_click=fn(e, dispatch) {
            @dom_ffi.warn_log("dec click: \{e}")
            dispatch.run(Decrement)
            dispatch.set_state(cursor, { counted: state.counted - 1 })
          },
        ),
        button(
          inner_text="demo inc twice",
          class_name=@respo.ui_button,
          style=respo_style(margin=4 |> Px),
          on_click=fn(e, dispatch) {
            @dom_ffi.warn_log("twice click: \{e}")
            dispatch.run(IncTwice)
            dispatch.set_state(cursor, { counted: state.counted + 2 })
          },
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
    ],
  )
}
