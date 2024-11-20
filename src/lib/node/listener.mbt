/// wraps some basic event types
pub(all) enum RespoEvent {
  Click(
    client_x~ : Float,
    client_y~ : Float,
    original_event~ : @dom_ffi.MouseEvent
  )
  Keyboard(
    key~ : String,
    key_code~ : UInt,
    shift_key~ : Bool,
    ctrl_key~ : Bool,
    alt_key~ : Bool,
    meta_key~ : Bool,
    repeat~ : Bool,
    original_event~ : @dom_ffi.KeyboardEvent
  )
  Input(value~ : String, original_event~ : @dom_ffi.InputEvent)
  Focus(@dom_ffi.FocusEvent)
  Blur(@dom_ffi.BlurEvent)
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

pub(all) struct RespoEventMark {
  coord : Array[RespoCoord]
  name : RespoEventType
  event_info : RespoEvent
}

pub(all) enum RespoEventType {
  Click
  DblClick
  Changle
  Keydown
  Keyup
  Keypress
  Input
  Focus
  Blur
} derive(Eq, Hash)

pub fn RespoEventType::to_string(self : RespoEventType) -> String {
  match self {
    Click => "Click".to_string()
    DblClick => "DblClick".to_string()
    Changle => "Changle".to_string()
    Keydown => "Keydown".to_string()
    Keyup => "Keyup".to_string()
    Keypress => "Keypress".to_string()
    Input => "Input".to_string()
    Focus => "Focus".to_string()
    Blur => "Blur".to_string()
  }
}

impl Show for RespoEventType with output(self, logger) {
  logger.write_string(RespoEventType::to_string(self))
}

pub fn to_cirru(self : RespoEventType) -> @cirru.Cirru {
  match self {
    Click => Leaf("::click")
    DblClick => Leaf("::dbl-click")
    Changle => Leaf("::changle")
    Keydown => Leaf("::keydown")
    Keyup => Leaf("::keyup")
    Keypress => Leaf("::keypress")
    Input => Leaf("::input")
    Focus => Leaf("::focus")
    Blur => Leaf("::blur")
  }
}
