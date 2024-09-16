type RespoListenerFn[T] (RespoEvent, DispatchFn[T]) -> Unit

fn new_listener[T](
  f : (RespoEvent, DispatcherFn[T]) -> Unit
) -> RespoListenerFn[T] {
  RespoListenerFn(f)
}

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
  Input(~value : String, ~original_event : @web_sys.InputEvent)
  Focus(@web_sys.FocusEvent)
  Blur(@web_sys.BlurEvent)
}

struct RespoEventMark {
  coord : Array[RespoCoord]
  name : String
  event_info : RespoEvent
}
