///| The options for custom drawer.
// #[derive(Debug, Clone, Default)]
pub(all) struct DrawerOptions[T] {
  /// inline style for backdrop
  backdrop_style : @node.RespoStyle
  /// inline style for card
  card_style : @node.RespoStyle
  /// title of the drawer, defaults to `drawer`
  title : String?
  /// render body
  render : DrawerRenderer[T]
} derive(Default)

///|
type DrawerRenderer[T] ((@node.DispatchFn[T]) -> Unit!@node.RespoCommonError) -> @node.RespoNode[
  T,
]!@node.RespoCommonError

///|
impl[T] Show for DrawerRenderer[T] with output(self, logger) {
  logger.write_string("(DrawerRenderer \{self})")
}

///|
pub impl[T] Default for DrawerRenderer[T] with default() -> DrawerRenderer[T] {
  fn(_close) { div([]) }
}

///|
pub fn DrawerRenderer::new[T](
  renderer : ((@node.DispatchFn[T]) -> Unit!@node.RespoCommonError) -> @node.RespoNode[
    T,
  ]!@node.RespoCommonError
) -> DrawerRenderer[T] {
  renderer
}

///|
fn run[T](
  self : DrawerRenderer[T],
  close : (@node.DispatchFn[T]) -> Unit!@node.RespoCommonError
) -> @node.RespoNode[T]!@node.RespoCommonError {
  let f = self._
  f!(close)
}

///|
fn comp_drawer[T](
  options : DrawerOptions[T],
  show : Bool,
  on_close : (@node.DispatchFn[T]) -> Unit
) -> @node.RespoNode[T]!@node.RespoCommonError {
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
          event={}..set(Click, fn(e, dispatch) {
            if e is Click(original_event~, ..) {
              original_event.stop_propagation()
            }
            on_close(dispatch)
          }),
          [
            div(
              class_list=[ui_column, ui_global, css_drawer_card],
              style=respo_style(padding=0 |> Px).merge(options.card_style),
              event={}..set(Click, fn(e, _dispatch) {
                if e is Click(original_event~, ..) {
                  original_event.stop_propagation()
                }
              }),
              [
                div(class_name=ui_column, [
                  div(class_name=ui_center, [
                    options.title.or("Drawer") |> text_node,
                  ]),
                  space(height=8),
                  options.render.run!(fn(dispatch) { on_close(dispatch) }),
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

///|
struct DrawerPluginState {
  show : Bool
} derive(Default, ToJson, @json.FromJson)

///| a drawer that you can render you down card body
// #[derive(Debug, Clone)]
pub(all) struct DrawerPlugin[T] {
  state : DrawerPluginState
  options : DrawerOptions[T]
  /// tracking content to display
  cursor : Array[String]
}

///|
pub fn DrawerPlugin::render[T : @node.RespoAction](
  self : DrawerPlugin[T]
) -> @node.RespoNode[T]!@node.RespoCommonError {
  comp_drawer!(self.options, self.state.show, fn(dispatch) {
    let ret = dispatch.set_state?(self.cursor, DrawerPluginState::{
      show: false,
    })
    match ret {
      Ok(_) => ()
      Err(e) => @dom_ffi.error_log(e.to_string())
    }
  })
}

///|
pub fn DrawerPlugin::show[T : @node.RespoAction](
  self : DrawerPlugin[T],
  dispatch : @node.DispatchFn[T]
) -> Unit!@node.RespoCommonError {
  dispatch.set_state!(self.cursor, DrawerPluginState::{ show: true })
}

///|
pub fn DrawerPlugin::close[T : @node.RespoAction](
  self : DrawerPlugin[T],
  dispatch : @node.DispatchFn[T]
) -> Unit!@node.RespoCommonError {
  dispatch.set_state!(self.cursor, DrawerPluginState::{ show: false })
}

///|
pub fn DrawerPlugin::new[T : @node.RespoAction](
  states : RespoStatesTree,
  options : DrawerOptions[T]
) -> DrawerPlugin[T] {
  let cursor = states.path()
  { state: states.cast_branch(), options, cursor }
}
