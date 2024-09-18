// // #[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize, RespoState)]
struct MainState {
  counted : Int
} derive(Default, ToJson, @json.FromJson)

pub fn comp_counter(
  states : @respo.RespoStatesTree,
  global_counted : Int
) -> @respo_node.RespoElement[ActionOp]!@respo_node.RespoCommonError {
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

  // div().elements([
  //   div().elements([
  //     button()
  //       .class(ui_button())
  //       .inner_text("demo inc")
  //       .style(RespoStyle::default().margin(4.))
  //       .on_click(on_inc),
  //     button()
  //       .class(ui_button())
  //       .inner_text("demo dec")
  //       .style(RespoStyle::default().margin(4.))
  //       .on_click(on_dec),
  //     button()
  //       .class(ui_button())
  //       .inner_text("demo inc twice")
  //       .style(RespoStyle::default().margin(4.))
  //       .on_click(on_inc_twice),
  //   ]),
  //   div().elements([span().inner_text(format!("value is: {}", counted)).style(
  //     RespoStyle::default()
  //       .color(CssColor::Hsluv(270, 100, 40))
  //       .font_family("Menlo".to_owned())
  //       .font_size(10. + counted as f32),
  //   )]),
  //   div().elements([
  //     span().inner_text(format!("local state: {}", counted)),
  //     br(),
  //     span().inner_text(format!("global state: {}", global_counted)),
  //   ]),
  // ]),

  TODO
}
