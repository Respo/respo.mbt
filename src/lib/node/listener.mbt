pub enum RespoEvent {
  Click(
    ~client_x : Float,
    ~client_y : Float,
    ~original_event : @web_sys.MouseEvent
  )
  Keyboard(
    ~key : String,
    ~key_code : UInt,
    ~shift_key : Bool,
    ~ctrl_key : Bool,
    ~alt_key : Bool,
    ~meta_key : Bool,
    ~repeat : Bool,
    ~original_event : @web_sys.KeyboardEvent
  )
  Input(~value : String, ~original_event : @web_sys.InputEvent)
  Focus(@web_sys.FocusEvent)
  Blur(@web_sys.BlurEvent)
}

pub fn to_string(self : RespoEvent) -> String {
  match self {
    Click(..) => "(Click)".to_string()
    Keyboard(..) => "(Keyboard)".to_string()
    Input(..) => "(Input)".to_string()
    Focus(_) => "(Focus)".to_string()
    Blur(_) => "(Blur)".to_string()
  }
}

pub struct RespoEventMark {
  coord : Array[RespoCoord]
  name : String
  event_info : RespoEvent
}
