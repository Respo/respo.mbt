///|
struct TaskState {
  draft : String
} derive(Hash, Eq, ToJson, @json.FromJson, Default)

///|
struct TaskUpdateEffect {
  task : Task
} derive(Hash, Eq, Default, ToJson, @json.FromJson)

///|
impl RespoEffect for TaskUpdateEffect with updated(_self, _el) {
  @dom_ffi.log("task updated")
}

// #[memoize(Capacity: 40)]

///|
fn comp_task(
  // _memo_caches: MemoCache<RespoNode<ActionOp>>,
  states : RespoStatesTree,
  task : Task
) -> RespoNode[ActionOp] {
  @dom_ffi.log("calling task function")
  let task_id = task.id
  let cursor = states.path()
  let state = (states.cast_branch() : TaskState)
  let on_toggle = fn(
    _e : RespoEvent,
    dispatch : DispatchFn[ActionOp]
  ) -> Unit!RespoCommonError {
    @dom_ffi.log("TOGGLE TASK \{task_id}")
    dispatch.run!(ToggleTask(task_id))
  }
  let on_input = fn(
    e : RespoEvent,
    dispatch : DispatchFn[ActionOp]
  ) -> Unit!RespoCommonError {
    if e is Input(value~, ..) {
      dispatch.set_state!(cursor, TaskState::{ draft: value })
    }
  }
  let tid = task_id
  let on_remove = fn(
    e : RespoEvent,
    dispatch : DispatchFn[ActionOp]
  ) -> Unit!RespoCommonError {
    @dom_ffi.log("remove button {}" + e.to_string())
    dispatch.run!(RemoveTask(tid))
  }
  let on_update = fn(
    _e : RespoEvent,
    dispatch : DispatchFn[ActionOp]
  ) -> Unit!RespoCommonError {
    dispatch.run!(UpdateTask(tid, state.draft))
    // dispatch.run_empty_state(&cursor)?;
    dispatch.empty_state!(cursor)
  }

  // define effect
  let effect_state : TaskUpdateEffect = { task, }

  // return component
  RespoComponent::named(
    "task",
    effects=[effect_state],
    div(class_list=[ui_row_middle, style_task_container], [
      div(
        class_name=style_done_button,
        style=if task.done {
          respo_style(background_color=Blue)
        } else {
          respo_style()
        },
        event={}..set(Click, on_toggle),
        [],
      ),
      div(attrs=respo_attrs(inner_text=task.content), []),
      span(
        class_list=[ui_center, style_remove_button],
        event={}..set(Click, on_remove),
        [],
      ),
      div(style=respo_style(margin_left=20 |> Px), []),
      input(
        class_name=ui_input,
        value=state.draft,
        placeholder="something to update...",
        event={}..set(Input, on_input),
      ),
      space(width=8),
      button(
        inner_text="Update",
        class_name=ui_button,
        event={}..set(Click, on_update),
      ),
    ]),
  ).to_node()
}

///|
let style_task_container : String = static_style([
  ("&", respo_style(margin=4 |> Px, background_color=Hsl(200, 90, 96))),
])

///|
let style_done_button : String = static_style([
  (
    "&",
    respo_style(
      width=24 |> Px,
      height=24 |> Px,
      margin=4 |> Px,
      cursor=Pointer,
      background_color=Hsl(20, 90, 70),
    ),
  ),
])

///|
let style_remove_button : String = static_style([
  (
    "&",
    respo_style(
      width=16 |> Px,
      height=16 |> Px,
      margin=4 |> Px,
      cursor=Pointer,
      margin_left=16 |> Px,
      color=Hsl(0, 90, 90),
    ),
  ),
  ("$0:hover", respo_style(color=Hsl(0, 90, 80))),
])
