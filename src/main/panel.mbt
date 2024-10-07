struct PanelState {
  content : String
} derive(Default, ToJson, @json.FromJson)

// #[derive(Debug, Clone, Default, PartialEq, Eq)]
struct PanelMount {}

// impl RespoEffect for PanelMount {
//   fn updated(&self, _el: &web_sys::Node) -> Result<(), String> {
//     respo::util::log!("panel updated");
//     Ok(())
//   }

//   fn mounted(&self, _el: &web_sys::Node) -> Result<(), String> {
//     respo::util::log!("panel mounted");
//     Ok(())
//   }
// }

fn comp_panel(
  states : @respo.RespoStatesTree
) -> @respo_node.RespoNode[ActionOp] {
  let cursor = states.path()
  let state : PanelState = states.cast_branch()
  let on_input = fn(
    e : @respo_node.RespoEvent,
    dispatch : @respo_node.DispatchFn[ActionOp]
  ) -> Unit!@respo_node.RespoCommonError {
    @web_sys.log("input event: " + e.to_string())
    // if let RespoEvent::Input { value, .. } = e {
    //   dispatch.run_state(&cursor, PanelState { content: value })?;
    // }
    match e {
      @respo_node.RespoEvent::Input(~value, ..) =>
        dispatch.run!(
          ActionOp::StatesChange(
            { cursor, data: Some({ content: value }.to_json()) },
          ),
        )
      _ => ()
    }
  }
  let on_submit = fn(
    e : @respo_node.RespoEvent,
    dispatch : @respo_node.DispatchFn[ActionOp]
  ) -> Unit!@respo_node.RespoCommonError {
    @web_sys.log("add button: " + e.to_string())
    dispatch.run!(ActionOp::AddTask(@web_sys.random_id(), state.content))
    dispatch.run!(
      ActionOp::StatesChange({ cursor, data: Some({ content: "" }.to_json()) }),
    )
  }
  @respo_node.RespoComponent::named(
    "panel",
    @respo_node.div(
      [
        @respo_node.input(
          attrs=@respo_node.respo_attrs(
            class_name=@respo.ui_input,
            placeholder="some content...",
            value=state.content,
          ),
          event={}..set(Input, on_input),
        ),
        @respo_node.space(width=8),
        @respo_node.button(
          attrs=@respo_node.respo_attrs(
            class_name=@respo.ui_button,
            inner_text="add",
          ),
          event={}..set(Click, on_submit),
        ),
        @respo_node.span(
          attrs=@respo_node.respo_attrs(
            inner_text="got panel state: \{state.to_json()}",
          ),
          [],
        ),
      ],
    ),
  )
  // .effect(PanelMount::default())
  .to_node()
}
