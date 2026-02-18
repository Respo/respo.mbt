///|
/// State for shortcut demo component
struct ShortcutDemoState {
  message : String
  triggered : Bool
} derive(Default, ToJson, FromJson)

///|
/// Component that demonstrates global keyboard shortcut listening
/// Press Ctrl+K or Cmd+K to trigger the demo
fn comp_shortcut_demo(
  states : RespoStatesTree,
) -> RespoNode[ActionOp, GlobalEvent] {
  let ((state : ShortcutDemoState), cursor) = states.local_pair()
  let tree = div(class_name=style_shortcut_container, [
    div(class_name=style_shortcut_title, ["Global Shortcut Demo" |> text_node]),
    div(
      class_name=if state.triggered {
        style_shortcut_message_active
      } else {
        style_shortcut_message_inactive
      },
      [
        if state.message == "" {
          "Press Ctrl+K (or Cmd+K on Mac) to trigger..." |> text_node
        } else {
          state.message |> text_node
        },
      ],
    ),
    div(class_name=style_shortcut_hint, [
      "This component listens to global KeyPress events. Try pressing 'k' or 'K' key."
      |> text_node,
    ]),
  ])

  // Wrap in a component with global event listener
  @respo_node.RespoComponent::named(
    "shortcut-demo",
    tree,
    listeners=Some(fn(event : GlobalEvent, dispatch : DispatchFn[ActionOp]) {
      @dom_ffi.log("[shortcut-demo] Received global event: \{event}")
      // Listen to global keyboard events
      match event {
        KeyPress(key) => {
          @dom_ffi.log("[shortcut-demo] KeyPress received: \{key}")
          if key == "k" || key == "K" {
            @dom_ffi.log("[shortcut-demo] Triggering shortcut for key: \{key}")
            // Update local state to show triggered message
            dispatch.set_state(cursor, {
              message: "🎉 Shortcut triggered! Key: \{key}",
              triggered: true,
            }) catch {
              e =>
                @dom_ffi.error_log(
                  "[shortcut-demo] Failed to update state: \{e}",
                )
            }

            // Reset state after 1 second
            let _ = @dom_ffi.set_timeout(
              fn() {
                @dom_ffi.log("[shortcut-demo] Resetting state after timeout")
                dispatch.set_state(cursor, { message: "", triggered: false }) catch {
                  e =>
                    @dom_ffi.error_log(
                      "[shortcut-demo] Failed to reset state: \{e}",
                    )
                }
              },
              1000,
            )
          } else {
            @dom_ffi.log("[shortcut-demo] Ignoring key: \{key}")
          }
        }
        _ => @dom_ffi.log("[shortcut-demo] Ignoring non-KeyPress event")
      }
    }),
  ).to_node()
}

///|
let style_shortcut_container : String = static_style([
  (
    "&",
    respo_style(
      padding=16 |> Px,
      border_width=1 |> Px,
      border_color=Hsl(0, 0, 80),
      border_radius=8,
      background_color=Hsl(210, 100, 98),
    ),
  ),
])

///|
let style_shortcut_title : String = static_style([
  ("&", respo_style(font_size=18, font_weight="600", margin_bottom=12 |> Px)),
])

///|
let style_shortcut_message_active : String = static_style([
  (
    "&",
    respo_style(
      color=Hsl(120, 60, 40),
      font_size=16,
      padding=8 |> Px,
      background_color=Hsl(120, 80, 95),
      border_radius=4,
    ),
  ),
])

///|
let style_shortcut_message_inactive : String = static_style([
  (
    "&",
    respo_style(
      color=Hsl(0, 0, 40),
      font_size=16,
      padding=8 |> Px,
      background_color=Hsl(0, 0, 95),
      border_radius=4,
    ),
  ),
])

///|
let style_shortcut_hint : String = static_style([
  ("&", respo_style(margin_top=8 |> Px, font_size=12, color=Hsl(0, 0, 60))),
])
