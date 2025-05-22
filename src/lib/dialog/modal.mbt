///| The options for custom modal.
// #[derive(Debug, Clone, Default)]
pub(all) struct ModalOptions[T] {
  /// inline style for backdrop
  backdrop_style : @node.RespoStyle
  /// inline style for card
  card_style : @node.RespoStyle
  /// title of the modal, defaults to `Modal`
  title : String?
  /// render body
  render : ModalRenderer[T]
} derive(Default)

///| tmp fix since syntax error
typealias Dispatcher[T] = (@node.DispatchFn[T]) -> Unit!@node.RespoCommonError

///|
pub(all) type ModalRenderer[T] (Dispatcher[T]) -> @node.RespoNode[T]!@node.RespoCommonError

///|
pub impl[T] Default for ModalRenderer[T] with default() -> ModalRenderer[T] {
  fn(_close) { div([]) }
}

///|
pub fn ModalRenderer::new[T](
  renderer : ((@node.DispatchFn[T]) -> Unit!@node.RespoCommonError) -> @node.RespoNode[
    T,
  ]!@node.RespoCommonError
) -> ModalRenderer[T] {
  renderer
}

///|
fn ModalRenderer::run[T](
  self : ModalRenderer[T],
  close : (@node.DispatchFn[T]) -> Unit!@node.RespoCommonError
) -> Unit!@node.RespoCommonError {
  let f = self._
  let _r = f!(close)

}

///|
fn comp_modal[T](
  options : ModalOptions[T],
  show : Bool,
  on_close : (@node.DispatchFn[T]) -> Unit
) -> @node.RespoNode[T]!@node.RespoCommonError {
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
                    options.title.or("Modal") |> text_node,
                  ]),
                  @node.space(height=8),
                  {
                    let f = options.render._
                    f!(fn(dispatch) { on_close(dispatch) })
                  },
                ]),
              ],
            ),
            comp_esc_listener(show, on_close),
          ],
        )
      } else {
        span(attrs=respo_attrs()..set("data-name", "placeholder"), [])
      },
    ]),
  ).to_node()
}

// #[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize, RespoState)]
///|
struct ModalPluginState {
  show : Bool
} derive(Default, ToJson, @json.FromJson)

///| a modal that you can render you down card body
// #[derive(Debug, Clone)]
pub(all) struct ModalPlugin[T] {
  // where
  //   T: Clone + Debug,
  state : ModalPluginState
  options : ModalOptions[T]
  /// tracking content to display
  cursor : @node.RespoCursor[ModalPluginState]
}

///|
pub fn ModalPlugin::render[T : @node.RespoAction](
  self : ModalPlugin[T]
) -> @node.RespoNode[T]!@node.RespoCommonError {
  comp_modal!(self.options, self.state.show, fn(dispatch) {
    match dispatch.set_state?(self.cursor, { show: false }) {
      Ok(_) => ()
      Err(e) => @dom_ffi.error_log(e.to_string())
    }
  })
}

///|
pub fn ModalPlugin::show[T : @node.RespoAction](
  self : ModalPlugin[T],
  dispatch : @node.DispatchFn[T]
) -> Unit!@node.RespoCommonError {
  dispatch.set_state!(self.cursor, { show: true })
}

///|
pub fn ModalPlugin::close[T : @node.RespoAction](
  self : ModalPlugin[T],
  dispatch : @node.DispatchFn[T]
) -> Unit!@node.RespoCommonError {
  dispatch.set_state!(self.cursor, { show: false })
}

///|
pub fn ModalPlugin::new[T : @node.RespoAction](
  states : RespoStatesTree,
  options : ModalOptions[T]
) -> ModalPlugin[T] {
  { state: states.cast_branch(), options, cursor: states.path() }
}
