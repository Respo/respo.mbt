///|
typealias @respo_node.RespoIndexKey

///|
struct TodolistState {
  hide_done : Bool
} derive(Default, Eq, ToJson, @json.FromJson)

///|
fn comp_todolist(
  states : @respo.RespoStatesTree,
  tasks : Array[Task]
) -> RespoNode[ActionOp] {
  let cursor = states.path()
  let state : TodolistState = states.cast_branch()
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
    dispatch.run!(
      StatesChange({
        cursor,
        data: Some({ hide_done: not(state.hide_done) }.to_json()),
      }),
    )
  }
  div([
    div([
      span(
        inner_text="tasks size: \{tasks.length()} ... \{state.hide_done.to_string()}",
        [],
      ),
      button(
        inner_text="hide done",
        class_name=@respo.ui_button,
        event={}..set(Click, on_hide),
      ),
    ]),
    @respo_node.div_listed(children),
  ])
}
