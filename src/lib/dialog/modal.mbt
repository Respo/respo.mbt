/// The options for custom modal.
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

/// tmp fix since syntax error
typealias Dispatcher[T] = (@node.DispatchFn[T]) -> Unit!@node.RespoCommonError

pub(all) type ModalRenderer[T] (Dispatcher[T]) -> @node.RespoNode[T]!@node.RespoCommonError

pub fn ModalRenderer::default[T]() -> ModalRenderer[T] {
  fn(_close) { div([]) }
}

pub fn ModalRenderer::new[T](
  renderer : ((@node.DispatchFn[T]) -> Unit!@node.RespoCommonError) -> @node.RespoNode[
    T,
  ]!@node.RespoCommonError
) -> ModalRenderer[T] {
  renderer
}

fn run[T](
  self : ModalRenderer[T],
  close : (@node.DispatchFn[T]) -> Unit!@node.RespoCommonError
) -> Unit!@node.RespoCommonError {
  let f = self._
  let _r = f!(close)

}

fn comp_modal[T](
  options : ModalOptions[T],
  show : Bool,
  on_close : (@node.DispatchFn[T]) -> Unit
) -> @node.RespoNode[T]!@node.RespoCommonError {
  let close = on_close

  // let effect_focus_data : EffectFocus = { show, }
  let effect_modal_fade_data : EffectModalFade = { show, }
  @node.RespoComponent::named(
    "modal",
    effects=[effect_modal_fade_data as @node.RespoEffect],
    div(
      style=respo_style(position=Absolute),
      [
        if show {
          div(
            class_name=str_spaced(
              [@respo.ui_fullscreen, @respo.ui_center, css_backdrop],
            ),
            style=options.backdrop_style,
            event={}..set(
              Click,
              fn(e, dispatch) {
                match e {
                  Click(original_event~, ..) =>
                    original_event.stop_propagation()
                  _ => ()
                }
                close(dispatch)
              },
            ),
            [
              div(
                class_name=str_spaced([ui_column, ui_global, css_modal_card]),
                style=respo_style(padding=Px(0), line_height=Px(32.0)).merge(
                  options.card_style,
                ),
                event={}..set(
                  Click,
                  fn(e, _dispatch) {
                    match e {
                      Click(original_event~, ..) =>
                        original_event.stop_propagation()
                      _ => ()
                    }
                  },
                ),
                [
                  div(
                    class_name=ui_column,
                    [
                      div(
                        class_name=ui_center,
                        [span(inner_text=options.title.or("Modal"), [])],
                      ),
                      @node.space(height=8),
                      {
                        let f = options.render._
                        f!(fn(dispatch) { close(dispatch) })
                      },
                    ],
                  ),
                ],
              ),
              comp_esc_listener(show, close),
            ],
          )
        } else {
          span(attrs=respo_attrs()..set("data-name", "placeholder"), [])
        },
      ],
    ),
  ).to_node()
}

// #[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize, RespoState)]
struct ModalPluginState {
  show : Bool
} derive(Default, ToJson, @json.FromJson)

/// a modal that you can render you down card body
// #[derive(Debug, Clone)]
pub(all) struct ModalPlugin[T] {
  // where
  //   T: Clone + Debug,
  state : ModalPluginState
  options : ModalOptions[T]
  /// tracking content to display
  cursor : Array[String]
}

pub fn render[T : @node.RespoAction](
  self : ModalPlugin[T]
) -> @node.RespoNode[T]!@node.RespoCommonError {
  let cursor = self.cursor
  comp_modal!(
    self.options,
    self.state.show,
    fn(dispatch) {
      let s : ModalPluginState = { show: false }
      match dispatch.run_state?(cursor, s) {
        Ok(_) => ()
        Err(e) => @dom_ffi.error_log(e.to_string())
      }
    },
  )
}

pub fn show[T : @node.RespoAction](
  self : ModalPlugin[T],
  dispatch : @node.DispatchFn[T]
) -> Unit!@node.RespoCommonError {
  dispatch.run_state!(self.cursor, ModalPluginState::{ show: true })
}

pub fn close[T : @node.RespoAction](
  self : ModalPlugin[T],
  dispatch : @node.DispatchFn[T]
) -> Unit!@node.RespoCommonError {
  dispatch.run_state!(self.cursor, ModalPluginState::{ show: false })
}

pub fn ModalPlugin::new[T : @node.RespoAction](
  states : @respo.RespoStatesTree,
  options : ModalOptions[T]
) -> ModalPlugin[T] {
  let cursor = states.path()
  let state : ModalPluginState = states.cast_branch()
  { state, options, cursor }
}
