pub fn comp_plugins_demo(
  states : @respo.RespoStatesTree
) -> @respo_node.RespoNode[ActionOp]!@respo_node.RespoCommonError {
  // respo::util::log!("re-render");

  let alert_plugin = @dialog.AlertPlugin::new(
    states.pick("info"),
    // AlertOptions {
    //   // card_style: RespoStyle::default().background_color(CssColor::Blue),
    //   ..
    // },
    @dialog.AlertOptions::default(),
    fn(_dispatch : @respo_node.DispatchFn[ActionOp]) {
      @web_sys.log("user has read the message")
    },
  )
  let on_alert = fn(
    e : @respo_node.RespoEvent,
    dispatch : @respo_node.DispatchFn[ActionOp]
  ) -> Unit!@respo_node.RespoCommonError {
    @web_sys.log("click " + e.to_string())

    // alert_plugin.show(dispatch, Some("a mesasge for you".to_owned()))?;
    alert_plugin.show!(dispatch, None)
  }
  let confirm_plugin = @dialog.ConfirmPlugin::new(
    states.pick("confirm"),
    @dialog.ConfirmOptions::default(),
    fn(_dispatch : @respo_node.DispatchFn[ActionOp]) {
      @web_sys.log("on confirm")
    },
  )
  let on_confirm = fn(
    e : @respo_node.RespoEvent,
    dispatch : @respo_node.DispatchFn[ActionOp]
  ) -> Unit!@respo_node.RespoCommonError {
    @web_sys.log("click " + e.to_string())
    confirm_plugin.show!(
      dispatch,
      fn() { @web_sys.log("do something on confirm") },
    )
  }
  let prompt_plugin = @dialog.PromptPlugin::new(
    states.pick("prompt"),
    {
      ..@dialog.PromptOptions::default(),
      text: Some("Demo text(length 3~8)"),
      validator: Some(
        @dialog.PromptValidator::new(
          fn(text) {
            if text.length() <= 1 {
              Err("too short")
            } else if text.length() > 8 {
              Err("too long")
            } else {
              Ok(())
            }
          },
        ),
      ),
      multilines: true,
    },
    fn(content, _dispatch : @respo_node.DispatchFn[ActionOp]) {
      @web_sys.log("on prompt: " + content)
    },
  )
  let on_prompt = fn(
    e : @respo_node.RespoEvent,
    dispatch : @respo_node.DispatchFn[ActionOp]
  ) -> Unit!@respo_node.RespoCommonError {
    @web_sys.log("click " + e.to_string())
    prompt_plugin.show!(
      dispatch,
      fn(content) { @web_sys.log("do something on prompt: {}" + content) },
    )
  }

  // declare modal

  let modal_plugin = @dialog.ModalPlugin::new(
    states.pick("modal"),
    {
      ..@dialog.ModalOptions::default(),
      title: Some("Modal demo"),
      render: @dialog.ModalRenderer::new(
        fn(close_modal) {
          let handler = fn(
            _e : _,
            dispatch : _
          ) -> Unit!@respo_node.RespoCommonError {
            @web_sys.log("on modal handle")
            close_modal!(dispatch)
          }
          @respo_node.div(
            style=@respo_node.RespoStyle::new(padding=Px(8)),
            [
              @respo_node.div(
                [
                  @respo_node.span(
                    attrs=@respo_node.respo_attrs(
                      inner_text="content in custom modal",
                    ),
                    [],
                  ),
                ],
              ),
              @respo_node.div(
                attrs=@respo_node.respo_attrs(class_name=@respo.ui_row_parted),
                [
                  @respo_node.span([]),
                  @respo_node.button(
                    attrs=@respo_node.respo_attrs(
                      class_name=@respo.ui_button,
                      inner_text="close",
                    ),
                    event={}..set(Click, handler),
                  ),
                ],
              ),
            ],
          )
        },
      ),
    },
  )
  let on_modal = fn(
    e : @respo_node.RespoEvent,
    dispatch : @respo_node.DispatchFn[ActionOp]
  ) -> Unit!@respo_node.RespoCommonError {
    @web_sys.log("click " + e.to_string())
    modal_plugin.show!(dispatch)
  }

  // declare drawer

  let drawer_plugin = @dialog.DrawerPlugin::new(
    states.pick("drawer"),
    {
      ..@dialog.DrawerOptions::default(),
      title: Some("Modal demo"),
      render: @dialog.DrawerRenderer::new(
        fn(close_drawer) {
          let handler = fn(
            _e : _,
            dispatch : @respo_node.DispatchFn[ActionOp]
          ) -> Unit!@respo_node.RespoCommonError {
            @web_sys.log("on modal handle")
            close_drawer!(dispatch)
          }
          @respo_node.div(
            style=@respo_node.RespoStyle::new(padding=Px(8)),
            [
              @respo_node.div(
                [
                  @respo_node.span(
                    attrs=@respo_node.respo_attrs(
                      inner_text="content in custom drawer",
                    ),
                    [],
                  ),
                ],
              ),
              @respo_node.div(
                attrs=@respo_node.respo_attrs(class_name=@respo.ui_row_parted),
                [
                  @respo_node.span([]),
                  @respo_node.button(
                    attrs=@respo_node.respo_attrs(
                      class_name=@respo.ui_button,
                      inner_text="close",
                    ),
                    event={}..set(Click, handler),
                  ),
                ],
              ),
            ],
          )
        },
      ),
    },
  )
  let on_drawer = fn(
    e : @respo_node.RespoEvent,
    dispatch : @respo_node.DispatchFn[ActionOp]
  ) -> Unit!@respo_node.RespoCommonError {
    @web_sys.log("click " + e.to_string())
    drawer_plugin.show!(dispatch)
  }
  @respo_node.div(
    [
      @respo_node.div(
        [
          @respo_node.span(
            attrs=@respo_node.respo_attrs(inner_text="Dialog"),
            [],
          ),
          @respo_node.div(
            [
              @respo_node.button(
                attrs=@respo_node.respo_attrs(
                  class_name=@respo.ui_button,
                  inner_text="Try Alert",
                ),
                event={}..set(Click, on_alert),
              ),
              @respo_node.space(width=8),
              @respo_node.button(
                attrs=@respo_node.respo_attrs(
                  class_name=@respo.ui_button,
                  inner_text="Try Confirm",
                ),
                event={}..set(Click, on_confirm),
              ),
              @respo_node.space(width=8),
              @respo_node.button(
                attrs=@respo_node.respo_attrs(
                  class_name=@respo.ui_button,
                  inner_text="Try Prompt",
                ),
                event={}..set(Click, on_prompt),
              ),
              @respo_node.space(width=8),
              @respo_node.button(
                attrs=@respo_node.respo_attrs(
                  class_name=@respo.ui_button_primary,
                  inner_text="Try Custom Modal",
                ),
                event={}..set(Click, on_modal),
              ),
              @respo_node.space(width=8),
              @respo_node.button(
                attrs=@respo_node.respo_attrs(
                  class_name=@respo.ui_button_danger,
                  inner_text="Try Custom Drawer",
                ),
                event={}..set(Click, on_drawer),
              ),
            ],
          ),
        ],
      ),
      alert_plugin.render(),
      confirm_plugin.render(),
      prompt_plugin.render(),
      modal_plugin.render!(),
      drawer_plugin.render!(),
    ],
  )
}
