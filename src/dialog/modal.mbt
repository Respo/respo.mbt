///|
/// The options for custom modal.
// #[derive(Debug, Clone, Default)]
pub(all) struct ModalOptions[T, G] {
  /// inline style for backdrop
  backdrop_style : @css.RespoStyle
  /// inline style for card
  card_style : @css.RespoStyle
  /// title of the modal, defaults to `Modal`
  title : String?
  /// render body
  render : ModalRenderer[T, G]
} derive(Default)

///| tmp fix since syntax error

///|
pub(all) struct ModalRenderer[T, G](
  ((@node.DispatchFn[T]) -> Unit raise @node.RespoCommonError) -> @node.RespoNode[
    T,
    G,
  ] raise @node.RespoCommonError
)

///|
pub impl[T, G] Default for ModalRenderer[T, G] with default() -> ModalRenderer[
  T,
  G,
] {
  fn(_close) { div([]) }
}

///|
pub fn[T, G] ModalRenderer::new(
  renderer : ((@node.DispatchFn[T]) -> Unit raise @node.RespoCommonError) -> @node.RespoNode[
    T,
    G,
  ] raise @node.RespoCommonError,
) -> ModalRenderer[T, G] {
  renderer
}

///|
fn[T, G] comp_modal(
  options : ModalOptions[T, G],
  show : Bool,
  on_close : (@node.DispatchFn[T]) -> Unit,
) -> @node.RespoNode[T, G] raise @node.RespoCommonError {
  // let effect_focus_data : EffectFocus = { show, }
  let effect_modal_fade_data : EffectModalFade = { show, }
  @node.RespoComponent::named(
    "modal",
    effects=[effect_modal_fade_data],
    div(style=respo_style(position=Absolute), [
      if show {
        div(
          class_list=[ui_fullscreen, ui_center, css_backdrop],
          // class_list=[ui_fullscreen, ui_center, css_backdrop],
          style=options.backdrop_style,
          on_click=fn(e, dispatch) {
            if e is Click(original_event~, ..) {
              original_event.stop_propagation()
            }
            on_close(dispatch)
          },
          [
            div(
              class_list=[ui_column, ui_global, css_modal_card],
              style=respo_style(padding=0 |> Px, line_height=32.0 |> Px).merge(
                options.card_style,
              ),
              on_click=fn(e, _dispatch) {
                if e is Click(original_event~, ..) {
                  original_event.stop_propagation()
                }
              },
              [
                div(class_name=ui_column, [
                  div(class_name=ui_center, [
                    options.title.unwrap_or("Modal") |> text_node,
                  ]),
                  @node.space(height=8),
                  {
                    let f = options.render.0
                    f(fn(dispatch) { on_close(dispatch) })
                  },
                ]),
              ],
            ),
            comp_esc_listener(show, on_close~),
          ],
        )
      } else {
        span(
          attrs={
            let t = respo_attrs()
            t.set("data-name", "placeholder")
            t
          },
          [],
        )
      },
    ]),
  ).to_node()
}

// #[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize, RespoState)]

///|
struct ModalPluginState {
  show : Bool
} derive(Default, ToJson, FromJson)

///|
/// a modal that you can render you down card body
// #[derive(Debug, Clone)]
pub(all) struct ModalPlugin[T, G] {
  // where
  //   T: Clone + Debug,
  state : ModalPluginState
  options : ModalOptions[T, G]
  /// tracking content to display
  cursor : @node.RespoCursor[ModalPluginState]
}

///|
pub fn[T : @node.RespoAction, G] ModalPlugin::render(
  self : ModalPlugin[T, G],
) -> @node.RespoNode[T, G] raise @node.RespoCommonError {
  comp_modal(self.options, self.state.show, dispatch => {
    dispatch.set_state(self.cursor, { show: false }) catch {
      e => @dom_ffi.error_log(e.to_string())
    }
  })
}

///|
pub fn[T : @node.RespoAction, G] ModalPlugin::show(
  self : ModalPlugin[T, G],
  dispatch : @node.DispatchFn[T],
) -> Unit raise @node.RespoCommonError {
  dispatch.set_state(self.cursor, { show: true })
}

///|
pub fn[T : @node.RespoAction, G] ModalPlugin::close(
  self : ModalPlugin[T, G],
  dispatch : @node.DispatchFn[T],
) -> Unit raise @node.RespoCommonError {
  dispatch.set_state(self.cursor, { show: false })
}

///|
pub fn[T, G] ModalPlugin::new(
  states : RespoStatesTree,
  options : ModalOptions[T, G],
) -> ModalPlugin[T, G] {
  { state: states.cast_branch(), options, cursor: states.path() }
}
