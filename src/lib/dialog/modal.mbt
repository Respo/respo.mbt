/// The options for custom modal.
// #[derive(Debug, Clone, Default)]
pub struct ModalOptions[T] {
  /// inline style for backdrop
  backdrop_style : @node.RespoStyle
  /// inline style for card
  card_style : @node.RespoStyle
  /// title of the modal, defaults to `Modal`
  title : String?
  /// render body
  render : ModalRenderer[T]
} derive(Default)

pub type ModalRenderer[T] ((@node.DispatchFn[T]) -> Unit!@node.RespoCommonError) -> @node.RespoNode[
  T,
]!@node.RespoCommonError

pub fn ModalRenderer::default[T]() -> ModalRenderer[T] {
  fn(_close) { @node.div([]) }
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
    effects=[(effect_modal_fade_data as @node.RespoEffect).turn_effect()],
    @node.div(
      style=@node.RespoStyle::new(position=Absolute),
      [
        if show {
          @node.div(
            attrs=@node.respo_attrs(
              class_name=@node.str_spaced(
                [@respo.ui_fullscreen, @respo.ui_center, css_backdrop],
              ),
            ),
            style=options.backdrop_style,
            event={}..set(
              Click,
              fn(e, dispatch) {
                match e {
                  Click(~original_event, ..) =>
                    original_event.stop_propagation()
                  _ => ()
                }
                close(dispatch)
              },
            ),
            [
              @node.div(
                attrs=@node.respo_attrs(
                  class_name=@node.str_spaced(
                    [@respo.column, @respo.ui_global, css_modal_card],
                  ),
                ),
                style=@node.RespoStyle::new(padding=Px(0), line_height=Px(32.0)).merge(
                  options.card_style,
                ),
                event={}..set(
                  Click,
                  fn(e, _dispatch) {
                    match e {
                      Click(~original_event, ..) =>
                        original_event.stop_propagation()
                      _ => ()
                    }
                  },
                ),
                [
                  @node.div(
                    attrs=@node.respo_attrs(class_name=@respo.column),
                    [
                      @node.div(
                        attrs=@node.respo_attrs(class_name=@respo.ui_center),
                        [
                          @node.span(
                            attrs=@node.respo_attrs(
                              inner_text=options.title.or("Modal"),
                            ),
                            [],
                          ),
                        ],
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
          @node.span(
            attrs=@node.respo_attrs()..set("data-name", "placeholder"),
            [],
          )
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
pub struct ModalPlugin[T] {
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
      match dispatch.run_state?(cursor, s.to_json()) {
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
  let s : ModalPluginState = { show: true }
  dispatch.run_state!(self.cursor, s.to_json())
}

pub fn close[T : @node.RespoAction](
  self : ModalPlugin[T],
  dispatch : @node.DispatchFn[T]
) -> Unit!@node.RespoCommonError {
  let s : ModalPluginState = { show: false }
  dispatch.run_state!(self.cursor, s.to_json())
}

pub fn ModalPlugin::new[T : @node.RespoAction](
  states : @respo.RespoStatesTree,
  options : ModalOptions[T]
) -> ModalPlugin[T] {
  let cursor = states.path()
  let state : ModalPluginState = states.cast_branch()
  { state, options, cursor }
}
