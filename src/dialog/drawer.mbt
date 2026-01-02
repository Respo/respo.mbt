///|
/// The options for custom drawer.
// #[derive(Debug, Clone, Default)]
pub(all) struct DrawerOptions[T, G] {
  /// inline style for backdrop
  backdrop_style : @css.RespoStyle
  /// inline style for card
  card_style : @css.RespoStyle
  /// title of the drawer, defaults to `drawer`
  title : String?
  /// render body
  render : DrawerRenderer[T, G]
} derive(Default)

///|
struct DrawerRenderer[T, G](
  ((@node.DispatchFn[T]) -> Unit raise @node.RespoCommonError) -> @node.RespoNode[
    T,
    G,
  ] raise @node.RespoCommonError
)

///|
impl[T, G] Show for DrawerRenderer[T, G] with output(self, logger) {
  logger.write_string("(DrawerRenderer \{self})")
}

///|
pub impl[T, G] Default for DrawerRenderer[T, G] with default() -> DrawerRenderer[
  T,
  G,
] {
  fn(_close) { div([]) }
}

///|
pub fn[T, G] DrawerRenderer::new(
  renderer : ((@node.DispatchFn[T]) -> Unit raise @node.RespoCommonError) -> @node.RespoNode[
    T,
    G,
  ] raise @node.RespoCommonError,
) -> DrawerRenderer[T, G] {
  renderer
}

///|
fn[T, G] DrawerRenderer::run(
  self : DrawerRenderer[T, G],
  close : (@node.DispatchFn[T]) -> Unit raise @node.RespoCommonError,
) -> @node.RespoNode[T, G] raise @node.RespoCommonError {
  let f = self.0
  f(close)
}

///|
fn[T, G] comp_drawer(
  options~ : DrawerOptions[T, G],
  show~ : Bool,
  on_close~ : (@node.DispatchFn[T]) -> Unit,
) -> @node.RespoNode[T, G] raise @node.RespoCommonError {
  let effect_focus_data : EffectFocus = { show, }
  let effect_drawer_fade_data : EffectDrawerFade = { show, }
  @node.RespoComponent::named(
    "drawer",
    effects=[effect_focus_data, effect_drawer_fade_data],
    div(style=respo_style(position=Absolute), [
      if show {
        div(
          class_list=[ui_fullscreen, ui_center, css_backdrop],
          style=options.backdrop_style,
          on_click=fn(e, dispatch) {
            if e is Click(original_event~, ..) {
              original_event.stop_propagation()
            }
            on_close(dispatch)
          },
          [
            div(
              class_list=[ui_column, ui_global, css_drawer_card],
              style=respo_style(padding=0 |> Px).merge(options.card_style),
              on_click=fn(e, _dispatch) {
                if e is Click(original_event~, ..) {
                  original_event.stop_propagation()
                }
              },
              [
                div(class_name=ui_column, [
                  div(class_name=ui_center, [
                    options.title.unwrap_or("Drawer") |> text_node,
                  ]),
                  space(height=8),
                  options.render.run(fn(dispatch) { on_close(dispatch) }),
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

///|
struct DrawerPluginState {
  show : Bool
} derive(Default, ToJson, FromJson)

///|
/// a drawer that you can render you down card body
// #[derive(Debug, Clone)]
pub(all) struct DrawerPlugin[T, G] {
  state : DrawerPluginState
  options : DrawerOptions[T, G]
  /// tracking content to display
  cursor : @node.RespoCursor[DrawerPluginState]
}

///|
pub fn[T : @node.RespoAction, G] DrawerPlugin::render(
  self : DrawerPlugin[T, G],
) -> @node.RespoNode[T, G] raise @node.RespoCommonError {
  comp_drawer(options=self.options, show=self.state.show, on_close=fn(
    dispatch,
  ) {
    dispatch.set_state(self.cursor, { show: false }) catch {
      e => @dom_ffi.error_log(e.to_string())
    }
  })
}

///|
pub fn[T : @node.RespoAction, G] DrawerPlugin::show(
  self : DrawerPlugin[T, G],
  dispatch : @node.DispatchFn[T],
) -> Unit raise @node.RespoCommonError {
  dispatch.set_state(self.cursor, { show: true })
}

///|
pub fn[T : @node.RespoAction, G] DrawerPlugin::close(
  self : DrawerPlugin[T, G],
  dispatch : @node.DispatchFn[T],
) -> Unit raise @node.RespoCommonError {
  dispatch.set_state(self.cursor, { show: false })
}

///|
pub fn[T, G] DrawerPlugin::new(
  states : RespoStatesTree,
  options : DrawerOptions[T, G],
) -> DrawerPlugin[T, G] {
  let cursor = states.path()
  { state: states.cast_branch(), options, cursor }
}
