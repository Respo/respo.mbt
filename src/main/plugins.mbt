///|
fn comp_plugins_demo(
  states : RespoStatesTree
) -> RespoNode[ActionOp] raise RespoCommonError {
  // respo::util::log!("re-render");

  let alert_plugin = @dialog.AlertPlugin::new(
    states.pick("info"),
    @dialog.AlertOptions::default(),
    fn(_dispatch : DispatchFn[ActionOp]) {
      @dom_ffi.log("user has read the message")
    },
  )
  let on_alert = fn(
    e : RespoEvent,
    dispatch : DispatchFn[ActionOp]
  ) -> Unit raise RespoCommonError {
    @dom_ffi.log("click " + e.to_string())

    // alert_plugin.show(dispatch, Some("a mesasge for you"))?;
    alert_plugin.show(dispatch, None)
  }
  let confirm_plugin = @dialog.ConfirmPlugin::new(
    states.pick("confirm"),
    @dialog.ConfirmOptions::default(),
    fn(_dispatch : DispatchFn[ActionOp]) { @dom_ffi.log("on confirm") },
  )
  let on_confirm = fn(
    e : RespoEvent,
    dispatch : DispatchFn[ActionOp]
  ) -> Unit raise RespoCommonError {
    @dom_ffi.log("click " + e.to_string())
    confirm_plugin.show(dispatch, () => @dom_ffi.log("do something on confirm"))
  }
  let prompt_plugin = @dialog.PromptPlugin::new(
    states.pick("prompt"),
    {
      ..@dialog.PromptOptions::default(),
      text: Some("Demo text(length 3~8)"),
      validator: Some(
        @dialog.PromptValidator::new(fn(text) {
          if text.length() <= 1 {
            Err("too short")
          } else if text.length() > 8 {
            Err("too long")
          } else {
            Ok(())
          }
        }),
      ),
      multilines: true,
    },
    fn(content, _dispatch : DispatchFn[ActionOp]) {
      @dom_ffi.log("on prompt: " + content)
    },
  )
  let on_prompt = fn(
    e : RespoEvent,
    dispatch : DispatchFn[ActionOp]
  ) -> Unit raise RespoCommonError {
    @dom_ffi.log("click " + e.to_string())
    prompt_plugin.show(dispatch, fn(content) {
      @dom_ffi.log("do something on prompt: {}" + content)
    })
  }

  // declare modal

  let modal_plugin = @dialog.ModalPlugin::new(states.pick("modal"), {
    ..@dialog.ModalOptions::default(),
    title: Some("Modal demo"),
    render: @dialog.ModalRenderer::new(fn(close_modal) {
      let handler = fn(_e : _, dispatch : _) -> Unit raise RespoCommonError {
        @dom_ffi.log("on modal handle")
        close_modal(dispatch)
      }
      div(style=respo_style(padding=8 |> Px), [
        div(["content in custom modal" |> text_node]),
        div(class_name=@respo.ui_row_parted, [
          span([]),
          button(
            inner_text="Close",
            class_name=@respo.ui_button,
            on_click=handler,
          ),
        ]),
      ])
    }),
  })
  let on_modal = fn(
    e : RespoEvent,
    dispatch : DispatchFn[ActionOp]
  ) -> Unit raise RespoCommonError {
    @dom_ffi.log("click " + e.to_string())
    modal_plugin.show(dispatch)
  }

  // declare drawer

  let drawer_plugin = @dialog.DrawerPlugin::new(states.pick("drawer"), {
    ..@dialog.DrawerOptions::default(),
    title: Some("Modal demo"),
    render: @dialog.DrawerRenderer::new(fn(close_drawer) {
      let handler = fn(
        _e : _,
        dispatch : DispatchFn[ActionOp]
      ) -> Unit raise RespoCommonError {
        @dom_ffi.log("on modal handle")
        close_drawer(dispatch)
      }
      div(style=respo_style(padding=8 |> Px), [
        div(["content in custom drawer" |> text_node]),
        div(attrs=respo_attrs(class_name=@respo.ui_row_parted), [
          span([]),
          button(
            inner_text="Close",
            class_name=@respo.ui_button,
            on_click=handler,
          ),
        ]),
      ])
    }),
  })
  let on_drawer = fn(
    e : RespoEvent,
    dispatch : DispatchFn[ActionOp]
  ) -> Unit raise RespoCommonError {
    @dom_ffi.log("click " + e.to_string())
    drawer_plugin.show(dispatch)
  }
  div([
    div([
      span(attrs=respo_attrs(inner_text="Dialog"), []),
      div([
        button(
          inner_text="Try Alert",
          class_name=@respo.ui_button,
          on_click=on_alert,
        ),
        space(width=8),
        button(
          inner_text="Try Confirm",
          class_name=@respo.ui_button,
          on_click=on_confirm,
        ),
        space(width=8),
        button(
          inner_text="Try Prompt",
          class_name=@respo.ui_button,
          on_click=on_prompt,
        ),
        space(width=8),
        button(
          inner_text="Try Custom Modal",
          class_name=@respo.ui_button_primary,
          on_click=on_modal,
        ),
        space(width=8),
        button(
          inner_text="Try Custom Drawer",
          class_name=@respo.ui_button_danger,
          on_click=on_drawer,
        ),
      ]),
    ]),
    alert_plugin.render(),
    confirm_plugin.render(),
    prompt_plugin.render(),
    modal_plugin.render(),
    drawer_plugin.render(),
  ])
}
