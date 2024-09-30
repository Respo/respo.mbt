struct TodolistState {
  hide_done : Bool
} derive(Default, Eq, ToJson, @json.FromJson)

pub fn comp_todolist(
  states : @respo.RespoStatesTree,
  tasks : Array[Task]
) -> @respo_node.RespoNode[ActionOp] {
  let cursor = states.path()
  let state : TodolistState = states.cast_branch()
  let children : Array[
    (@respo_node.RespoIndexKey, @respo_node.RespoNode[ActionOp]),
  ] = []
  for task in tasks {
    if state.hide_done && task.done {
      continue
    }
    children.push(
      (
        @respo_node.RespoIndexKey(task.id),
        comp_task(states.pick(task.id), task),
      ),
    )
  }

  // util::log!("{:?}", &tasks);

  let on_hide = fn(
    e : @respo_node.RespoEvent,
    dispatch : (ActionOp) -> Unit!@respo_node.RespoCommonError
  ) -> Unit!@respo_node.RespoCommonError {
    @web_sys.log("click: " + e.to_string())
    dispatch!(
      StatesChange(
        { cursor, data: Some({ hide_done: not(state.hide_done) }.to_json()) },
      ),
    )
  }
  @respo_node.div(
    [
      @respo_node.div(
        [
          @respo_node.span(
            attrs=@respo_node.respo_attrs(
              inner_text="tasks size: \{tasks.length()} ... \{state.hide_done.to_string()}",
            ),
            [],
          ),
          @respo_node.button(
            attrs=@respo_node.respo_attrs(
              class_name=@respo.ui_button,
              inner_text="hide done",
            ),
            event={ "click": on_hide },
          ),
        ],
      ),
      @respo_node.div_listed(children),
    ],
  )
}
