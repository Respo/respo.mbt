struct TaskState {
  draft : String
} derive(Hash, Eq, ToJson, @json.FromJson, Default)

struct TaskUpdateEffect {
  task : Task
} derive(Hash, Eq, Default)

// impl RespoEffect for TaskUpdateEffect {
//   fn updated(&self, _el: &web_sys::Node) -> Result<(), String> {
//     util::log!("task update effect");
//     Ok(())
//   }
// }

// #[memoize(Capacity: 40)]
pub fn comp_task(
  // _memo_caches: MemoCache<RespoNode<ActionOp>>,
  states : @respo.RespoStatesTree,
  task : Task
) -> RespoNode[ActionOp]!@respo_node.RespoCommonError {
  @web_sys.log("calling task function")
  let task_id = task.id
  let cursor = states.path()
  let state : TaskState = states.cast_branch()
  let on_toggle = fn(
    _e : @respo_node.RespoEvent,
    dispatch : DispatchFn[_]
  ) -> Unit!@respo_node.RespoCommonError {
    dispatch.run(ActionOp::ToggleTask(task_id))
  }
  let on_input = fn(
    e : @respo_node.RespoEvent,
    dispatch : DispatchFn[_]
  ) -> Unit!@respo_node.RespoCommonError {

    // if let RespoEvent::Input { value, .. } = e {
    //   dispatch.run_state(&cursor, TaskState { draft: value })?;
    // }

    match e {
      @respo_node.RespoEvent::Input(~value, ..) =>
        dispatch(
          ActionOp::StatesChange(
            { cursor, data: Some({ draft: value }.to_json()) },
          ),
        )
      _ => ()
    }
  }
  let tid = task_id
  let on_remove = fn(
    e : @respo_node.RespoEvent,
    dispatch : _
  ) -> Unit!@respo_node.RespoCommonError {
    @web_sys.log("remove button {}" + e.to_string())
    dispatch(ActionOp::RemoveTask(tid))
  }
  let on_update = fn(
    _e : @respo_node.RespoEvent,
    dispatch : _
  ) -> Unit!@respo_node.RespoCommonError {
    dispatch(ActionOp::UpdateTask(tid, state.draft))
    // dispatch.run_empty_state(&cursor)?;
    dispatch(ActionOp::StatesChange({ cursor, data: None }))
  }
  @respo_node.RespoComponent::named(
    "task",
    @respo_node.div(
      attrs=@respo_node.respo_attrs(
        class_name=@respo.ui_row_middle + " " + style_task_container,
      ),
      [
        @respo_node.div(
          attrs=@respo_node.respo_attrs(
            class_name=style_done_button,
            style=if task.done {
              @respo_node.RespoStyle::new(background_color=Blue)
            } else {
              @respo_node.RespoStyle::new()
            },
          ),
          event={ "cilck": on_toggle },
          [],
        ),
        @respo_node.div(
          attrs=@respo_node.respo_attrs(inner_text=task.content),
          [],
        ),
        @respo_node.span(
          attrs=@respo_node.respo_attrs(
            class_name=@respo.ui_center + " " + style_remove_button,
          ),
          event={ "click": on_remove },
          [],
        ),
        @respo_node.div(
          attrs=@respo_node.respo_attrs(
            style=@respo_node.RespoStyle::new(margin_left=20),
          ),
          [],
        ),
        @respo_node.input(
          attrs=@respo_node.respo_attrs(
            class_name=@respo.ui_input,
            value=state.draft,
            placeholder="something to update...",
          ),
          event={ "input": on_input },
        ),
        @respo_node.space(width=8),
        @respo_node.button(
          attrs=@respo_node.respo_attrs(
            class_name=@respo.ui_button,
            inner_text="Update",
          ),
          event={ "click": on_update },
        ),
      ],
    ),
  )
  // .effect(TaskUpdateEffect { task: task.to_owned() })
}

// static_styles!(
//   style_task_container,
//   ("&", RespoStyle::default().margin(4.).background_color(CssColor::Hsl(200, 90, 96)))
// );

// static_styles!(
//   style_done_button,
//   (
//     "&",
//     RespoStyle::default()
//       .width(CssSize::Px(24.0))
//       .height(CssSize::Px(24.0))
//       .margin(4.)
//       .cursor("pointer".to_owned())
//       .background_color(CssColor::Hsl(20, 90, 70)),
//   )
// );

// static_styles!(
//   style_remove_button,
//   (
//     "&",
//     RespoStyle::default()
//       .width(CssSize::Px(16.0))
//       .height(CssSize::Px(16.0))
//       .margin(4.)
//       .cursor("pointer".to_owned())
//       .margin4(0.0, 0.0, 0.0, 16.0)
//       .color(CssColor::Hsl(0, 90, 90)),
//   ),
//   ("$0:hover", RespoStyle::default().color(CssColor::Hsl(0, 90, 80))),
// );
