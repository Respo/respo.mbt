struct PanelState {
  content : String
} derive(Default, ToJson, @json.FromJson)

// #[derive(Debug, Clone, Default, PartialEq, Eq)]
type PanelMount Unit derive(Default, Eq, ToJson, @json.FromJson)

fn PanelMount::new() -> PanelMount {
  PanelMount(())
}

impl @respo_node.RespoEffect for PanelMount with before_update(self, _el) {
  @dom_ffi.log("panel before update" + self._.to_string())
}

impl @respo_node.RespoEffect for PanelMount with updated(_self, _el) {
  @dom_ffi.log("panel updated")
}

fn comp_panel(
  states : @respo.RespoStatesTree
) -> @respo_node.RespoNode[ActionOp] {
  let cursor = states.path()
  let state : PanelState = states.cast_branch()
  let on_input = fn(
    e : @respo_node.RespoEvent,
    dispatch : @respo_node.DispatchFn[ActionOp]
  ) -> Unit!@respo_node.RespoCommonError {
    @dom_ffi.log("input event: " + e.to_string())
    // if let RespoEvent::Input { value, .. } = e {
    //   dispatch.run_state(&cursor, PanelState { content: value })?;
    // }
    match e {
      Input(value~, ..) =>
        dispatch.run!(
          StatesChange({ cursor, data: Some({ content: value }.to_json()) }),
        )
      _ => ()
    }
  }
  let on_submit = fn(
    e : @respo_node.RespoEvent,
    dispatch : @respo_node.DispatchFn[ActionOp]
  ) -> Unit!@respo_node.RespoCommonError {
    @dom_ffi.log("add button: " + e.to_string())
    dispatch.run!(AddTask(@dom_ffi.random_id(), state.content))
    dispatch.run!(
      StatesChange({ cursor, data: Some({ content: "" }.to_json()) }),
    )
  }

  // effect
  let effect_panel_mount_data : PanelMount = PanelMount::new()
  @respo_node.RespoComponent::named(
    "panel",
    effects=[effect_panel_mount_data as @respo_node.RespoEffect],
    div(
      [
        input(
          class_name=ui_input,
          placeholder="some content...",
          value=state.content,
          event={}..set(Input, on_input),
        ),
        space(width=8),
        button(
          class_name=ui_button,
          inner_text="add",
          event={}..set(Click, on_submit),
        ),
        span(inner_text="got panel state: \{state.to_json()}", []),
      ],
    ),
  )
  // .effect(PanelMount::default())
  .to_node()
}
