// // #[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize, RespoState)]
///|
struct MainState {
  counted : Int
} derive(Default, ToJson, @json.FromJson)

///|
fn comp_counter(
  states : @respo.RespoStatesTree,
  global_counted : Int
) -> @respo_node.RespoNode[ActionOp] {
  let cursor = states.path()
  let state : MainState = states.cast_branch()
  let counted = state.counted
  let on_inc = fn(
    e : @respo_node.RespoEvent,
    dispatch : @respo_node.DispatchFn[ActionOp]
  ) -> Unit!@respo_node.RespoCommonError {
    @dom_ffi.warn_log("inc click: " + e.to_string())
    match e {
      Click(original_event~, ..) => original_event.prevent_default()
      _ => ()
    }
    dispatch.run!(Increment)
    dispatch.run_state!(cursor, MainState::{ counted: state.counted + 1 })
  }
  let on_dec = fn(
    e : @respo_node.RespoEvent,
    dispatch : @respo_node.DispatchFn[ActionOp]
  ) -> Unit!@respo_node.RespoCommonError {
    @dom_ffi.warn_log("dec click: " + e.to_string())
    dispatch.run!(Decrement)
    dispatch.run_state!(cursor, MainState::{ counted: state.counted - 1 })
  }
  let on_inc_twice = fn(
    e : @respo_node.RespoEvent,
    dispatch : @respo_node.DispatchFn[ActionOp]
  ) -> Unit!@respo_node.RespoCommonError {
    @dom_ffi.warn_log("twice click: " + e.to_string())
    dispatch.run!(IncTwice)
    dispatch.run_state!(cursor, MainState::{ counted: state.counted + 2 })
  }
  @respo_node.div(
    attrs=@respo_node.respo_attrs()..set("data-comp", "counter"),
    [
      @respo_node.div([
        @respo_node.button(
          inner_text="demo inc",
          class_name=@respo.ui_button,
          style=respo_style(margin=Px(4)),
          event={}..set(Click, on_inc),
        ),
        @respo_node.button(
          inner_text="demo dec",
          class_name=@respo.ui_button,
          style=respo_style(margin=Px(4)),
          event={}..set(Click, on_dec),
        ),
        @respo_node.button(
          inner_text="demo inc twice",
          class_name=@respo.ui_button,
          style=respo_style(margin=Px(4)),
          event={}..set(Click, on_inc_twice),
        ),
      ]),
      @respo_node.div([
        @respo_node.text_node(
          "value is: " + counted.to_string(),
          style=respo_style(
            color=Hsluv(270, 100, 40),
            font_family="Menlo",
            font_size=counted.reinterpret_as_uint() + 10,
          ),
        ),
      ]),
      @respo_node.div([
        text_node("local state: \{counted}"),
        @respo_node.br(),
        text_node("global state: " + global_counted.to_string()),
      ]),
    ],
  )
}
