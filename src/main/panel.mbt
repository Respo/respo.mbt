///|
fnalias @respo.(ui_input, ui_center, ui_row_middle)

///|
typealias @respo.RespoStatesTree

///|
typealias @respo_node.RespoComponent

///|
traitalias @respo_node.RespoEffect

///|
struct PanelState {
  content : String
} derive(Default, ToJson, @json.FromJson)

// #[derive(Debug, Clone, Default, PartialEq, Eq)]
///|
type PanelMount Unit derive(Default, Eq, ToJson, @json.FromJson)

///|
fn PanelMount::new() -> PanelMount {
  PanelMount(())
}

///|
impl RespoEffect for PanelMount with before_update(self, _el) {
  @dom_ffi.log("panel before update" + self._.to_string())
}

///|
impl RespoEffect for PanelMount with updated(_self, _el) {
  @dom_ffi.log("panel updated")
}

///|
fn comp_panel(states : RespoStatesTree) -> RespoNode[ActionOp] {
  let cursor = states.path()
  let state = (states.cast_branch() : PanelState)
  let on_input = fn(
    e : RespoEvent,
    dispatch : DispatchFn[ActionOp]
  ) -> Unit!RespoCommonError {
    @dom_ffi.log("input event: " + e.to_string())
    if e is Input(value~, ..) {
      dispatch.set_state!(cursor, { content: value })
    }
  }
  let on_submit = fn(
    e : RespoEvent,
    dispatch : DispatchFn[ActionOp]
  ) -> Unit!RespoCommonError {
    @dom_ffi.log("add button: \{e}")
    dispatch.run!(AddTask(@dom_ffi.random_id(), state.content))
    dispatch.set_state!(cursor, { content: "" })
  }

  // effect
  let effect_panel_mount_data = PanelMount::new()
  RespoComponent::named(
    "panel",
    effects=[effect_panel_mount_data],
    div([
      input(
        class_name=ui_input,
        placeholder="some content...",
        value=state.content,
        on_input~,
      ),
      space(width=8),
      button(class_name=ui_button, inner_text="add", on_click=on_submit),
      "got panel state: \{state.to_json()}" |> text_node,
    ]),
  )
  // .effect(PanelMount::default())
  .to_node()
}

///|
let memo_comp_panel : (RespoStatesTree) -> RespoNode[ActionOp] = @respo.memo_once1(
  comp_panel,
)
