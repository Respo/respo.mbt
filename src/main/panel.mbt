///|
using @respo {type RespoStatesTree}

///|
using @respo_node {type RespoComponent, trait RespoEffect}

///|
struct PanelState {
  content : String
} derive(Default, ToJson, FromJson)

// #[derive(Debug, Clone, Default, PartialEq, Eq)]

///|
struct PanelMount {} derive(Default, Eq, ToJson, FromJson)

///|
impl RespoEffect for PanelMount with before_update(_self, _el) {
  @dom_ffi.log("panel before update")
}

///|
impl RespoEffect for PanelMount with updated(_self, _el) {
  @dom_ffi.log("panel updated")
}

///|
extern "js" fn random_id() -> String =
  #| () => Math.random().toString(36).slice(2)

///|
fn comp_panel(states : RespoStatesTree) -> RespoNode[ActionOp] {
  let ((state : PanelState), cursor) = states.local_pair()
  let on_input = fn(
    e : RespoEvent,
    dispatch : DispatchFn[ActionOp],
  ) -> Unit raise RespoCommonError {
    @dom_ffi.log("input event: " + e.to_string())
    if e is Input(value~, ..) {
      println("input value: " + value)
      dispatch.set_state(cursor, { content: value })
    } else {
      @dom_ffi.warn_log("not input event: " + e.to_string())
    }
  }
  let on_submit = fn(
    e : RespoEvent,
    dispatch : DispatchFn[ActionOp],
  ) -> Unit raise RespoCommonError {
    @dom_ffi.log("add button: \{e}, \{state.content}")
    dispatch.run(AddTask(random_id(), state.content))
    dispatch.set_state(cursor, { content: "" })
  }

  // effect
  let effect_panel_mount_data = PanelMount::default()
  RespoComponent::named(
    "panel",
    effects=[effect_panel_mount_data],
    div([
      input(
        class_name=@respo.ui_input,
        placeholder="some content...",
        value=state.content,
        on_input~,
      ),
      space(width=8),
      button(class_name=@respo.ui_button, inner_text="add", on_click=on_submit),
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
