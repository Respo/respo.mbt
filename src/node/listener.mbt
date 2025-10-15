///|
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

///|
pub impl Show for RespoEvent with output(self, logger) {
  let ret = match self {
    Click(..) => "(Click)".to_string()
    Keyboard(..) => "(Keyboard)".to_string()
    Input(..) => "(Input)".to_string()
    Focus(_) => "(Focus)".to_string()
    Blur(_) => "(Blur)".to_string()
  }
  logger.write_string(ret)
}

///|
pub(all) struct RespoEventMark {
  coord : @immut/array.T[RespoCoord]
  name : RespoEventType
  event_info : RespoEvent
}

///|
pub(all) enum RespoEventType {
  Click
  DblClick
  Change
  Keydown
  Keyup
  Keypress
  Input
  Focus
  Blur
} derive(Eq, Hash)

///|
pub impl Show for RespoEventType with output(self, logger) {
  let ret = match self {
    Click => "Click".to_string()
    DblClick => "DblClick".to_string()
    Change => "Change".to_string()
    Keydown => "Keydown".to_string()
    Keyup => "Keyup".to_string()
    Keypress => "Keypress".to_string()
    Input => "Input".to_string()
    Focus => "Focus".to_string()
    Blur => "Blur".to_string()
  }
  logger.write_string(ret)
}

///|
pub fn RespoEventType::to_cirru(self : RespoEventType) -> Cirru {
  match self {
    Click => Leaf("::click")
    DblClick => Leaf("::dbl-click")
    Change => Leaf("::change")
    Keydown => Leaf("::keydown")
    Keyup => Leaf("::keyup")
    Keypress => Leaf("::keypress")
    Input => Leaf("::input")
    Focus => Leaf("::focus")
    Blur => Leaf("::blur")
  }
}
