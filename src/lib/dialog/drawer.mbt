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
fn to_string[T](self : DrawerRenderer[T]) -> String {
  "(DrawerRenderer ..)"
}

///|
pub fn DrawerRenderer::default[T]() -> DrawerRenderer[T] {
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
  let close = on_close
  let effect_focus_data : EffectFocus = { show, }
  let effect_drawer_fade_data : EffectDrawerFade = { show, }
  @node.RespoComponent::named(
    "drawer",
    effects=[
      effect_focus_data as &@node.RespoEffect,
      effect_drawer_fade_data as &@node.RespoEffect,
    ],
    div(style=respo_style(position=Absolute), [
      if show {
        div(
          class_name=@node.str_spaced([ui_fullscreen, ui_center, css_backdrop]),
          style=options.backdrop_style,
          event={}..set(Click, fn(e, dispatch) {
            if e is Click(original_event~, ..) {
              original_event.stop_propagation()
            }
            close(dispatch)
          }),
          [
            div(
              class_name=@node.str_spaced([
                ui_column, ui_global, css_drawer_card,
              ]),
              style=respo_style(padding=Px(0)).merge(options.card_style),
              event={}..set(Click, fn(e, _dispatch) {
                if e is Click(original_event~, ..) {
                  original_event.stop_propagation()
                }
              }),
              [
                div(class_name=@respo.ui_column, [
                  div(class_name=ui_center, [
                    span(inner_text=options.title.or("Drawer"), []),
                  ]),
                  space(height=8),
                  {
                    let f = options.render
                    f.run!(fn(dispatch) { close(dispatch) })
                  },
                ]),
              ],
            ),
            comp_esc_listener(show, close),
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
  let cursor = self.cursor.copy()
  comp_drawer!(self.options, self.state.show, fn(dispatch) {
    let ret = dispatch.run_state?(cursor, DrawerPluginState::{ show: false })
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
  dispatch.run_state!(self.cursor, DrawerPluginState::{ show: true })
}

///|
pub fn DrawerPlugin::close[T : @node.RespoAction](
  self : DrawerPlugin[T],
  dispatch : @node.DispatchFn[T]
) -> Unit!@node.RespoCommonError {
  dispatch.run_state!(self.cursor, DrawerPluginState::{ show: false })
}

///|
pub fn DrawerPlugin::new[T : @node.RespoAction](
  states : @respo.RespoStatesTree,
  options : DrawerOptions[T]
) -> DrawerPlugin[T] {
  let cursor = states.path()
  let state : DrawerPluginState = states.cast_branch()
  { state, options, cursor }
}
