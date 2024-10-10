/// The options for custom drawer.
// #[derive(Debug, Clone, Default)]
pub struct DrawerOptions[T] {
  /// inline style for backdrop
  backdrop_style : @node.RespoStyle
  /// inline style for card
  card_style : @node.RespoStyle
  /// title of the drawer, defaults to `drawer`
  title : String?
  /// render body
  render : DrawerRenderer[T]
} derive(Default)

type DrawerRenderer[T] ((@node.DispatchFn[T]) -> Unit!@node.RespoCommonError) -> @node.RespoNode[
  T,
]!@node.RespoCommonError

fn to_string[T](self : DrawerRenderer[T]) -> String {
  "(DrawerRenderer)"
}

pub fn DrawerRenderer::default[T]() -> DrawerRenderer[T] {
  fn(_close) { @node.div([]) }
}

pub fn DrawerRenderer::new[T](
  renderer : ((@node.DispatchFn[T]) -> Unit!@node.RespoCommonError) -> @node.RespoNode[
    T,
  ]!@node.RespoCommonError
) -> DrawerRenderer[T] {
  renderer
}

fn run[T](
  self : DrawerRenderer[T],
  close : (@node.DispatchFn[T]) -> Unit!@node.RespoCommonError
) -> @node.RespoNode[T]!@node.RespoCommonError {
  let f = self._
  f!(close)
}

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
      {
        args: effect_focus_data.to_json(),
        handler: effect_focus_data.make_handler(),
      },
      {
        args: effect_drawer_fade_data.to_json(),
        handler: effect_drawer_fade_data.make_handler(),
      },
    ],
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
                    [@respo.column, @respo.ui_global, css_drawer_card],
                  ),
                ),
                style=@node.RespoStyle::new(padding=Px(0)).merge(
                  options.card_style,
                ),
                event={}..set(
                  Click,
                  fn(e, dispatch) {
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
                              inner_text=options.title.or("Drawer"),
                            ),
                            [],
                          ),
                        ],
                      ),
                      @node.space(height=8),
                      {
                        let f = options.render
                        f.run!(fn(dispatch) { close(dispatch) })
                      },
                    ],
                  ),
                ],
              ),
              comp_esc_listener(show, close),
            ],
          )
        } else {
          // .attr("data-name", "placeholder")
          @node.span([])
        },
      ],
    ),
  ).to_node()
}

struct DrawerPluginState {
  show : Bool
} derive(Default, ToJson, @json.FromJson)

/// a drawer that you can render you down card body
// #[derive(Debug, Clone)]
pub struct DrawerPlugin[T] {
  state : DrawerPluginState
  options : DrawerOptions[T]
  /// tracking content to display
  cursor : Array[String]
}

pub fn render[T : @node.RespoAction](
  self : DrawerPlugin[T]
) -> @node.RespoNode[T]!@node.RespoCommonError {
  let cursor = self.cursor.copy()
  comp_drawer!(
    self.options,
    self.state.show,
    fn(dispatch) {
      let s : DrawerPluginState = { show: false }
      let ret = dispatch.run_state?(cursor, s.to_json())
      match ret {
        Ok(_) => ()
        Err(e) => @web_sys.error_log(e.to_string())
      }
    },
  )
}

pub fn show[T : @node.RespoAction](
  self : DrawerPlugin[T],
  dispatch : @node.DispatchFn[T]
) -> Unit!@node.RespoCommonError {
  let s : DrawerPluginState = { show: true }
  dispatch.run_state!(self.cursor, s.to_json())
}

pub fn close[T : @node.RespoAction](
  self : DrawerPlugin[T],
  dispatch : @node.DispatchFn[T]
) -> Unit!@node.RespoCommonError {
  let s : DrawerPluginState = { show: false }
  dispatch.run_state!(self.cursor, s.to_json())
}

pub fn DrawerPlugin::new[T : @node.RespoAction](
  states : @respo.RespoStatesTree,
  options : DrawerOptions[T]
) -> DrawerPlugin[T] {
  let cursor = states.path()
  let state : DrawerPluginState = states.cast_branch()
  { state, options, cursor }
}
