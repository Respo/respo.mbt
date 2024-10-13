struct PanelState {
  content : String
} derive(Default, ToJson, @json.FromJson)

// #[derive(Debug, Clone, Default, PartialEq, Eq)]
type PanelMount Unit derive(Default, Eq, ToJson, @json.FromJson)

fn PanelMount::new() -> PanelMount {
  PanelMount(())
}

fn PanelMount::make_handler(
  self : PanelMount
) -> (@respo_node.RespoEffectType, @dom_ffi.Node) -> Unit {
  fn(effect_type : @respo_node.RespoEffectType, _el : @dom_ffi.Node) -> Unit {
    if effect_type == @respo_node.RespoEffectType::BeforeUpdate {
      @dom_ffi.log("panel before update" + self._.to_string())
    } else if effect_type == @respo_node.RespoEffectType::Updated {
      @dom_ffi.log("panel updated")
    }
  }
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
    @dom_ffi.log("add button: " + e.to_string())
    dispatch.run!(ActionOp::AddTask(@dom_ffi.random_id(), state.content))
    dispatch.run!(
      ActionOp::StatesChange({ cursor, data: Some({ content: "" }.to_json()) }),
    )
  }

  // effect
  let effect_panel_mount_data : PanelMount = PanelMount::new()
  @respo_node.RespoComponent::named(
    "panel",
    effects=[
      {
        args: effect_panel_mount_data.to_json(),
        handler: effect_panel_mount_data.make_handler(),
      },
    ],
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
