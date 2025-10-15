///|
/// The options for custom drawer.
// #[derive(Debug, Clone, Default)]
pub(all) struct DrawerOptions[T] {
  /// inline style for backdrop
  backdrop_style : @css.RespoStyle
  /// inline style for card
  card_style : @css.RespoStyle
  /// title of the drawer, defaults to `drawer`
  title : String?
  /// render body
  render : DrawerRenderer[T]
} derive(Default)

///|
struct DrawerRenderer[T](
  ((@node.DispatchFn[T]) -> Unit raise @node.RespoCommonError) -> @node.RespoNode[
    T,
  ] raise @node.RespoCommonError
)

///|
impl[T] Show for DrawerRenderer[T] with output(self, logger) {
  logger.write_string("(DrawerRenderer \{self})")
}

///|
pub impl[T] Default for DrawerRenderer[T] with default() -> DrawerRenderer[T] {
  fn(_close) { div([]) }
}

///|
pub fn[T] DrawerRenderer::new(
  renderer : ((@node.DispatchFn[T]) -> Unit raise @node.RespoCommonError) -> @node.RespoNode[
    T,
  ] raise @node.RespoCommonError,
) -> DrawerRenderer[T] {
  renderer
}

///|
fn[T] run(
  self : DrawerRenderer[T],
  close : (@node.DispatchFn[T]) -> Unit raise @node.RespoCommonError,
) -> @node.RespoNode[T] raise @node.RespoCommonError {
  let f = self.inner()
  f(close)
}

///|
fn[T] comp_drawer(
  options~ : DrawerOptions[T],
  show~ : Bool,
  on_close~ : (@node.DispatchFn[T]) -> Unit,
) -> @node.RespoNode[T] raise @node.RespoCommonError {
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
pub(all) struct DrawerPlugin[T] {
  state : DrawerPluginState
  options : DrawerOptions[T]
  /// tracking content to display
  cursor : @node.RespoCursor[DrawerPluginState]
}

///|
pub fn[T : @node.RespoAction] DrawerPlugin::render(
  self : DrawerPlugin[T],
) -> @node.RespoNode[T] raise @node.RespoCommonError {
  comp_drawer(options=self.options, show=self.state.show, on_close=fn(
    dispatch,
  ) {
    let ret = try? dispatch.set_state(self.cursor, { show: false })
    match ret {
      Ok(_) => ()
      Err(e) => @dom_ffi.error_log(e.to_string())
    }
  })
}

///|
pub fn[T : @node.RespoAction] DrawerPlugin::show(
  self : DrawerPlugin[T],
  dispatch : @node.DispatchFn[T],
) -> Unit raise @node.RespoCommonError {
  dispatch.set_state(self.cursor, { show: true })
}

///|
pub fn[T : @node.RespoAction] DrawerPlugin::close(
  self : DrawerPlugin[T],
  dispatch : @node.DispatchFn[T],
) -> Unit raise @node.RespoCommonError {
  dispatch.set_state(self.cursor, { show: false })
}

///|
pub fn[T] DrawerPlugin::new(
  states : RespoStatesTree,
  options : DrawerOptions[T],
) -> DrawerPlugin[T] {
  let cursor = states.path()
  { state: states.cast_branch(), options, cursor }
}
