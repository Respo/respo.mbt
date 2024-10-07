/// The options for alert modal.
// #[derive(Debug, Clone, Default)]
pub struct AlertOptions {
  /// inline style for backdrop
  backdrop_style : @node.RespoStyle
  /// inline style for card
  card_style : @node.RespoStyle
  /// message of the alert modal, defaults to `Alert!`
  text : String?
  /// text on button
  button_text : String?
}

fn comp_alert_modal[T](
  options : AlertOptions,
  show : Bool,
  on_read : (@node.DispatchFn[T]) -> Unit,
  on_close : (@node.DispatchFn[T]) -> Unit
) -> @node.RespoNode[T] {
  let read = on_read
  let close = on_close
  @node.RespoComponent::named(
    "alert-modal",
    @node.div(
      attrs=@node.respo_attrs(style=@node.RespoStyle::new(position=Absolute)),
      [
        if show {
          @node.div(
            attrs=@node.respo_attrs(
              class_name=@respo.ui_fullscreen +
                " " +
                @respo.ui_center +
                " " +
                css_backdrop,
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
              },
            ),
            [
              @node.div(
                attrs=@node.respo_attrs(
                  class_name=@respo.column +
                    " " +
                    @respo.ui_global +
                    " " +
                    css_modal_card,
                ),
                style=@node.RespoStyle::new(line_height=Px(32.0)).merge(
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
                    [
                      @node.span(
                        attrs=@node.respo_attrs(
                          inner_text=options.text.or_else(fn() { "Alert!" }),
                        ),
                        [],
                      ),
                      @node.space(height=8),
                      @node.div(
                        attrs=@node.respo_attrs(class_name=@respo.ui_row_parted),
                        [
                          @node.span([]),
                          @node.button(
                            attrs=@node.respo_attrs(
                              inner_text=options.button_text.or_else(
                                fn() { "Read" },
                              ),
                            ),
                            event={}..set(
                              Click,
                              fn(e, dispatch) {
                                read(dispatch)
                                close(dispatch)
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              comp_esc_listener(show, close),
            ],
          )
        } else {
          // attr("data-name", "placeholder")
          @node.span([])
        },
      ],
    ),
  )
  // .effect(EffectFocus { show })
  // .effect(EffectModalFade { show })
  .to_node()
}

// /// provides the interfaces to component of alert dialog
// pub trait AlertPluginInterface<T, U>
// where
//   T: Debug + Clone + RespoAction,
//   U: Fn(DispatchFn<T>) -> Result<(), String>,
// {
//   /// renders virtual dom for alert modal
//   fn render(&self) -> Result<RespoNode<T>, String>
//   where
//     T: Clone + Debug;
//   /// to show alert, second parameter is a message that could overwrite the default message
//   fn show(&self, dispatch: DispatchFn<T>, text: Option<String>) -> Result<(), String>;
//   /// to close alert
//   fn close(&self, dispatch: DispatchFn<T>) -> Result<(), String>;

//   /// show alert with options, `on_read` is the callback function when read button is clicked
//   fn new(states: RespoStatesTree, options: AlertOptions, on_read: U) -> Result<Self, String>
//   where
//     Self: std::marker::Sized;

//   /// return referencial counted alert plugin
//   fn share_with_ref(&self) -> Rc<Self>;
// }

// #[derive(Debug, Clone, Default, PartialEq, Eq, Deserialize, Serialize, RespoState)]
// struct AlertPluginState {
//   show: bool,
//   text: Option<String>,
// }

// /// abstraction for Alert modal, new with `AlertOption`,
// /// just displaying a message, you read it, you close it
// #[derive(Debug, Clone)]
// pub struct AlertPlugin<T, U>
// where
//   T: Clone + Debug,
//   U: Fn(DispatchFn<T>) -> Result<(), String> + 'static,
// {
//   state: Rc<AlertPluginState>,
//   options: AlertOptions,
//   /// tracking content to display
//   text: Option<String>,
//   cursor: Vec<Rc<str>>,
//   on_read: U,
//   phantom: PhantomData<T>,
// }

// impl<T, U> AlertPluginInterface<T, U> for AlertPlugin<T, U>
// where
//   T: Clone + Debug + RespoAction,
//   U: Fn(DispatchFn<T>) -> Result<(), String> + 'static + Copy,
// {
//   fn render(&self) -> Result<RespoNode<T>, String> {
//     let on_read = self.on_read;
//     let cursor = &self.cursor;
//     let state = &self.state;

//     let mut options = self.options.to_owned();
//     options.text = {
//       let state = state.to_owned();
//       state.text.as_deref().or(options.text.as_deref()).map(ToOwned::to_owned)
//     };

//     comp_alert_modal(
//       options,
//       self.state.show,
//       {
//         let cursor = cursor.to_owned();
//         let state = state.to_owned();
//         move |dispatch| {
//           on_read(dispatch.to_owned())?;
//           let s = AlertPluginState {
//             show: false,
//             text: state.text.to_owned(),
//           };
//           dispatch.run_state(&cursor, s)?;
//           Ok(())
//         }
//       },
//       {
//         let cursor = cursor.to_owned();
//         let state = state.to_owned();
//         move |dispatch| {
//           let s = AlertPluginState {
//             show: false,
//             text: state.text.to_owned(),
//           };
//           dispatch.run_state(&cursor, s)?;
//           Ok(())
//         }
//       },
//     )
//   }
//   fn show(&self, dispatch: DispatchFn<T>, text: Option<String>) -> Result<(), String> {
//     let s = AlertPluginState { show: true, text };
//     dispatch.run_state(&self.cursor, s)?;
//     Ok(())
//   }
//   fn close(&self, dispatch: DispatchFn<T>) -> Result<(), String> {
//     let s = AlertPluginState {
//       show: false,
//       text: self.text.to_owned(),
//     };
//     dispatch.run_state(&self.cursor, s)?;
//     Ok(())
//   }

//   fn new(states: RespoStatesTree, options: AlertOptions, on_read: U) -> Result<Self, String> {
//     let cursor = states.path();
//     let state = states.cast_branch::<AlertPluginState>();

//     let instance = Self {
//       state,
//       options,
//       text: None,
//       cursor,
//       on_read,
//       phantom: PhantomData,
//     };

//     Ok(instance)
//   }

//   fn share_with_ref(&self) -> Rc<Self> {
//     Rc::new(self.to_owned())
//   }
// }
