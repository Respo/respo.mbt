///|
typealias @respo_node.RespoIndexKey

///|
struct TodolistState {
  hide_done : Bool
} derive(Default, Eq, ToJson, @json.FromJson)

///|
fn comp_todolist(
  states : RespoStatesTree,
  tasks : Array[Task]
) -> RespoNode[ActionOp] {
  let ((state : TodolistState), cursor) = states.local_pair()
  let children : Array[(RespoIndexKey, RespoNode[ActionOp])] = []
  for task in tasks {
    if state.hide_done && task.done {
      continue
    }
    children.push(
      (RespoIndexKey(task.id), comp_task(states.pick(task.id), task)),
    )
  }

  // @dom_ffi.log(tasks.to_string())

  let on_hide = fn(
    e : RespoEvent,
    dispatch : DispatchFn[ActionOp]
  ) -> Unit!RespoCommonError {
    @dom_ffi.log("click: " + e.to_string())
    dispatch.set_state!(cursor, { hide_done: not(state.hide_done) })
  }
  div([
    div([
      "tasks size: \{tasks.length()} ... \{state.hide_done.to_string()}"
      |> text_node,
      button(inner_text="hide done", class_name=ui_button, on_click=on_hide),
    ]),
    @respo_node.div_listed(children),
  ])
}
