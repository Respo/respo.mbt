type RespoListenerFn[T] (RespoEvent, DispatchFn[T]) -> Unit

fn new_listener[T](
  f : (RespoEvent, DispatcherFn[T]) -> Unit
) -> RespoListenerFn[T] {
  RespoListenerFn(f)
}

// pub enum RespoEvent {
//   Click {
//     client_x: f64,
//     client_y: f64,
//     original_event: MouseEvent,
//   },
//   Keyboard {
//     key: String,
//     key_code: u32,
//     shift_key: bool,
//     ctrl_key: bool,
//     alt_key: bool,
//     meta_key: bool,
//     repeat: bool,
//     original_event: KeyboardEvent,
//   },
//   Input {
//     value: String,
//     original_event: InputEvent,
//   },
//   Focus(FocusEvent),
//   Blur(FocusEvent),
// }

enum RespoEvent {
  Click(~client_x : Double, ~client_y : Double)
  Keyboard(
    ~key : String,
    ~key_code : UInt,
    ~shift_key : Bool,
    ~ctrl_key : Bool,
    ~alt_key : Bool,
    ~meta_key : Bool,
    ~repeat : Bool
  )
  Input(~value : String, ~original_event : InputEvent)
  Focus(FocusEvent)
  Blur(BlurEvent)
}
