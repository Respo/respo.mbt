///|
struct TaskState {
  draft : String
} derive(Hash, Eq, ToJson, @json.FromJson, Default)

///|
struct TaskUpdateEffect {
  task : Task
} derive(Hash, Eq, Default, ToJson, @json.FromJson)

///|
impl @respo_node.RespoEffect for TaskUpdateEffect with updated(_self, _el) {
  @dom_ffi.log("task updated")
}

// #[memoize(Capacity: 40)]

///|
fn comp_task(
  // _memo_caches: MemoCache<RespoNode<ActionOp>>,
  states : @respo.RespoStatesTree,
  task : Task
) -> @respo_node.RespoNode[ActionOp] {
  @dom_ffi.log("calling task function")
  let task_id = task.id
  let cursor = states.path()
  let state : TaskState = states.cast_branch()
  let on_toggle = fn(
    _e : @respo_node.RespoEvent,
    dispatch : @respo_node.DispatchFn[ActionOp]
  ) -> Unit!@respo_node.RespoCommonError {
    @dom_ffi.log("TOGGLE TASK \{task_id}")
    dispatch.run!(ToggleTask(task_id))
  }
  let on_input = fn(
    e : @respo_node.RespoEvent,
    dispatch : @respo_node.DispatchFn[ActionOp]
  ) -> Unit!@respo_node.RespoCommonError {
    if e is Input(value~, ..) {
      dispatch.run!(
        StatesChange({ cursor, data: Some({ draft: value }.to_json()) }),
      )
    }
  }
  let tid = task_id
  let on_remove = fn(
    e : @respo_node.RespoEvent,
    dispatch : @respo_node.DispatchFn[ActionOp]
  ) -> Unit!@respo_node.RespoCommonError {
    @dom_ffi.log("remove button {}" + e.to_string())
    dispatch.run!(RemoveTask(tid))
  }
  let on_update = fn(
    _e : @respo_node.RespoEvent,
    dispatch : @respo_node.DispatchFn[ActionOp]
  ) -> Unit!@respo_node.RespoCommonError {
    dispatch.run!(UpdateTask(tid, state.draft))
    // dispatch.run_empty_state(&cursor)?;
    dispatch.run!(StatesChange({ cursor, data: None }))
  }

  // define effect
  let effect_state : TaskUpdateEffect = { task, }

  // return component
  @respo_node.RespoComponent::named(
    "task",
    effects=[effect_state as &@respo_node.RespoEffect],
    div(class_name=str_spaced([ui_row_middle, style_task_container]), [
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
      div(attrs=@respo_node.respo_attrs(inner_text=task.content), []),
      span(
        class_name=str_spaced([ui_center, style_remove_button]),
        event={}..set(Click, on_remove),
        [],
      ),
      div(style=respo_style(margin_left=Px(20)), []),
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
let style_task_container : String = declare_static_style([
  ("&", respo_style(margin=Px(4), background_color=Hsl(200, 90, 96))),
])

///|
let style_done_button : String = declare_static_style([
  (
    "&",
    respo_style(
      width=Px(24),
      height=Px(24),
      margin=Px(4),
      cursor=Pointer,
      background_color=Hsl(20, 90, 70),
    ),
  ),
])

///|
let style_remove_button : String = declare_static_style([
  (
    "&",
    respo_style(
      width=Px(16),
      height=Px(16),
      margin=Px(4),
      cursor=Pointer,
      margin_left=Px(16),
      color=Hsl(0, 90, 90),
    ),
  ),
  ("$0:hover", respo_style(color=Hsl(0, 90, 80))),
])
