// // #[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize, RespoState)]
struct MainState {
  counted : Int
} derive(Default, ToJson, @json.FromJson)

pub fn comp_counter(
  states : @respo.RespoStatesTree,
  global_counted : Int
) -> @respo_node.RespoNode[ActionOp]!@respo_node.RespoCommonError {
  let cursor = states.path()
  let state : MainState = states.cast_branch()
  let counted = state.counted
  let on_inc = fn(
    e : @respo_node.RespoEvent,
    dispatch : (ActionOp) -> Unit!@respo_node.RespoCommonError
  ) -> Unit!@respo_node.RespoCommonError {
    @web_sys.warn_log("click {:?}" + e.to_string())
    match e {
      @respo_node.RespoEvent::Click(~original_event, ..) =>
        // original_event.prevent_default();
        ()
      _ => ()
    }
    dispatch!(ActionOp::Increment)
    let next_state : MainState = { counted: state.counted + 1 }
    let c : @respo.RespoUpdateState = {
      cursor,
      data: Some(next_state.to_json()),
    }
    dispatch!(ActionOp::StatesChange(c))
  }
  let on_dec = fn(
    e : @respo_node.RespoEvent,
    dispatch : (ActionOp) -> Unit!@respo_node.RespoCommonError
  ) -> Unit!@respo_node.RespoCommonError {
    @web_sys.warn_log("click {:?}" + e.to_string())
    dispatch!(ActionOp::Decrement)
    let next_state : MainState = { counted: state.counted - 1 }
    let c : @respo.RespoUpdateState = {
      cursor,
      data: Some(next_state.to_json()),
    }
    dispatch!(ActionOp::StatesChange(c))
  }
  let on_inc_twice = fn(
    e : @respo_node.RespoEvent,
    dispatch : (ActionOp) -> Unit!@respo_node.RespoCommonError
  ) -> Unit!@respo_node.RespoCommonError {
    @web_sys.warn_log("click {:?}" + e.to_string())
    dispatch!(ActionOp::IncTwice)
    let next_state : MainState = { counted: state.counted + 2 }
    let c : @respo.RespoUpdateState = {
      cursor,
      data: Some(next_state.to_json()),
    }
    dispatch!(ActionOp::StatesChange(c))
  }
  let a : Map[String, String] = {}
  @respo_node.div(
    [
      @respo_node.div(
        [
          @respo_node.button(
            attrs=@respo_node.respo_attrs(
              inner_text="demo inc",
              class_name=ui_button(),
            ),
            style=@respo_node.RespoStyle::new(margin="4"),
            event={ "click": on_inc },
            [],
          ),
          @respo_node.button(
            attrs=@respo_node.respo_attrs(
              inner_text="demo dec",
              class_name=ui_button(),
            ),
            style=@respo_node.RespoStyle::new(margin="4"),
            event={ "click": on_dec },
            [],
          ),
          @respo_node.button(
            attrs=@respo_node.respo_attrs(
              inner_text="demo inc twice",
              class_name=ui_button(),
            ),
            style=@respo_node.RespoStyle::new(margin="4"),
            event={ "click": on_inc_twice },
            [],
          ),
        ],
      ),
      @respo_node.div(
        [
          @respo_node.span(
            attrs=@respo_node.respo_attrs(
              inner_text="value is: " + counted.to_string(),
            ),
            style=@respo_node.RespoStyle::new(
              color="hsluv(270, 100, 40)",
              font_family="Menlo",
              font_size="10.0" + counted.to_string() + "px",
            ),
            [],
          ),
        ],
      ),
      @respo_node.div(
        [
          @respo_node.span(
            attrs=@respo_node.respo_attrs(inner_text="local state: \{counted}"),
            [],
          ),
          @respo_node.br(),
          @respo_node.span(
            attrs=@respo_node.respo_attrs(
              inner_text="global state: " + global_counted.to_string(),
            ),
            [],
          ),
        ],
      ),
    ],
  )
}

fn ui_button() -> String {
  "TODO ui-button style"
}
