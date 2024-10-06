let next_task_name : String = "_RESPO_CONFIRM_NEXT_TASK"

/// options for confirm dialog
pub struct ConfirmOptions {
  /// inline style for backdrop
  backdrop_style : @node.RespoStyle
  /// inline style for card
  card_style : @node.RespoStyle
  /// message to display
  text : String?
  /// text on button
  button_text : String?
} derive(Default)

let button_name : String = "dialog-button"

// where
//   U: Fn(DispatchFn<T>) -> Result<(), String> + 'static,
//   V: Fn(DispatchFn<T>) -> Result<(), String> + 'static,
//   T: Clone + Debug,
fn comp_confirm_modal[T, U, V](
  options : ConfirmOptions,
  show : Bool,
  on_confirm : ((T) -> Unit!@node.RespoCommonError) -> Unit,
  on_close : ((T) -> Unit!@node.RespoCommonError) -> Unit
) -> @node.RespoNode[T] {
  let confirm = on_confirm
  let close = on_close

  // effect 1
  let effect_focus_data : EffectFocus = { show, }
  let effect_focus : @node.RespoEffectBox = {
    args: effect_focus_data.to_json(),
    handler: effect_focus_data.make_handler(),
  }

  // effect 2
  let effect_modal_fade_data : EffectModalFade = { show, }
  let effect_modal_fade : @node.RespoEffectBox = {
    args: effect_modal_fade_data.to_json(),
    handler: effect_modal_fade_data.make_handler(),
  }
  @node.RespoComponent::named(
    "confirm-modal",
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
              style=options.backdrop_style,
            ),
            event={}..set(
              Click,
              fn(e, dispatch) {
                match e {
                  Click(~original_event, ..) =>
                    original_event.stop_propagation()
                  _ => ()
                }
                let _v = close(dispatch)

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
                  style=options.card_style,
                ),
                event={}..set(
                  Click,
                  fn(e, dispatch) {
                    match e {
                      Click(~original_event, ..) =>
                        original_event.stop_propagation()
                      _ => ()
                    }
                    ()
                  },
                ),
                [
                  @node.div(
                    [
                      @node.span(
                        attrs=@node.respo_attrs(
                          inner_text=options.text.or_else(
                            fn() { "Need confirmation..." },
                          ),
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
                              class_name=@respo.ui_button +
                                " " +
                                css_button +
                                " " +
                                button_name,
                              inner_text=options.button_text.or_else(
                                fn() { "Confirm" },
                              ),
                            ),
                            event={}..set(
                              Click,
                              fn(e, dispatch) {
                                confirm(dispatch)
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
              // comp_esc_listener(show, close),
            ],
          )
        } else {
          @node.span(
            // attrs=@node.respo_attrs(data_name="placeholder"),
            [],
          )
        },
      ],
    ),
    effects=[effect_focus, effect_modal_fade],
  )
  // .effect(EffectFocus { show })
  // .effect(EffectModalFade { show })
  .to_node()
}

// /// provides the interfaces to component of confirm dialog
// pub trait ConfirmPluginInterface<T, U>
// where
//   T: Debug + Clone + RespoAction,
//   U: Fn(DispatchFn<T>) -> Result<(), String>,
// {
//   /// renders UI
//   fn render(&self) -> Result<RespoNode<T>, String>
//   where
//     T: Clone + Debug;
//   /// to show dialog, second parameter is a callback when confirmed,
//   /// the callback is implemented dirty, it perform directly after confirmed
//   fn show<V>(&self, dispatch: DispatchFn<T>, next_task: V) -> Result<(), String>
//   where
//     V: Fn() -> Result<(), String> + 'static;
//   /// to close dialog
//   fn close(&self, dispatch: DispatchFn<T>) -> Result<(), String>;

//   /// creates a new instance of confirm plugin, second parameter is a callback when confirmed
//   fn new(states: RespoStatesTree, options: ConfirmOptions, on_confirm: U) -> Result<Self, String>
//   where
//     Self: std::marker::Sized;

//   fn rc(&self) -> Rc<Self>;
// }

// #[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize, RespoState)]
// struct ConfirmPluginState {
//   show: bool,
//   text: Option<String>,
// }

// /// Popup a confirmation dialog, confirm to process next task
// #[derive(Debug, Clone)]
// pub struct ConfirmPlugin<T, U>
// where
//   T: Clone + Debug,
//   U: Fn(DispatchFn<T>) -> Result<(), String> + 'static,
// {
//   state: Rc<ConfirmPluginState>,
//   options: ConfirmOptions,
//   /// tracking content to display
//   text: Option<String>,
//   cursor: Vec<Rc<str>>,
//   on_confirm: U,
//   phantom: PhantomData<T>,
// }

// impl<T, U> ConfirmPluginInterface<T, U> for ConfirmPlugin<T, U>
// where
//   T: Clone + Debug + RespoAction,
//   U: Fn(DispatchFn<T>) -> Result<(), String> + 'static + Copy,
// {
//   fn render(&self) -> Result<RespoNode<T>, String> {
//     let on_confirm = self.on_confirm;
//     let cursor = self.cursor.to_owned();
//     let state = self.state.to_owned();

//     comp_confirm_modal(
//       self.options.to_owned(),
//       state.show.to_owned(),
//       {
//         let c = cursor.to_owned();
//         let st = state.to_owned();
//         move |dispatch| {
//           on_confirm(dispatch.to_owned())?;
//           let window = web_sys::window().expect("window");
//           // TODO dirty global variable
//           let task = Reflect::get(&window, &JsValue::from_str(next_task_name));
//           if let Ok(f) = task {
//             if f.is_function() {
//               let f = f.dyn_into::<Function>().unwrap();
//               let _ = f.apply(&JsValue::NULL, &Array::new());
//             } else {
//               return Err("_NEXT_TASK is not a function".to_owned());
//             }
//           } else {
//             app::util::log!("next task is None");
//           };
//           let s = ConfirmPluginState {
//             show: false,
//             text: st.text.to_owned(),
//           };
//           dispatch.run_state(&c, s)?;
//           // clean up leaked closure
//           let window = web_sys::window().expect("window");
//           let _ = Reflect::set(&window, &JsValue::from_str(next_task_name), &JsValue::NULL);
//           Ok(())
//         }
//       },
//       {
//         let st = state.to_owned();
//         let c = cursor.to_owned();
//         move |dispatch| {
//           let s = ConfirmPluginState {
//             show: false,
//             text: st.text.to_owned(),
//           };
//           dispatch.run_state(&c, s)?;
//           // clean up leaked closure
//           let window = web_sys::window().expect("window");
//           let _ = Reflect::set(&window, &JsValue::from_str(next_task_name), &JsValue::NULL);
//           Ok(())
//         }
//       },
//     )
//   }
//   fn show<V>(&self, dispatch: DispatchFn<T>, next_task: V) -> Result<(), String>
//   where
//     V: Fn() -> Result<(), String> + 'static,
//   {
//     let s = ConfirmPluginState {
//       show: true,
//       text: self.state.text.to_owned(),
//     };
//     let task = Closure::once(next_task);
//     let window = web_sys::window().unwrap();
//     // dirty global variable to store a shared callback
//     if let Err(e) = Reflect::set(&window, &JsValue::from_str(next_task_name), task.as_ref()) {
//       app::util::error_log!("failed to store next task {:?}", e);
//     }
//     task.forget();
//     dispatch.run_state(&self.cursor, s)?;
//     Ok(())
//   }
//   fn close(&self, dispatch: DispatchFn<T>) -> Result<(), String> {
//     let s = ConfirmPluginState {
//       show: false,
//       text: self.text.to_owned(),
//     };
//     dispatch.run_state(&self.cursor, s)?;
//     Ok(())
//   }

//   fn new(states: RespoStatesTree, options: ConfirmOptions, on_confirm: U) -> Result<Self, String> {
//     let cursor = states.path();
//     let state = states.cast_branch::<ConfirmPluginState>();

//     let instance = Self {
//       state,
//       options,
//       text: None,
//       cursor,
//       on_confirm,
//       phantom: PhantomData,
//     };

//     Ok(instance)
//   }

//   // return a reference counted instance
//   fn rc(&self) -> Rc<Self> {
//     Rc::new(self.to_owned())
//   }
// }
