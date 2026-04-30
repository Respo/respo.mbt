///|
/// Wraps basic DOM event types with commonly-used properties extracted.
/// This provides a unified interface for handling different event types in Respo applications.
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
  Drag(
    client_x~ : Float,
    client_y~ : Float,
    data_transfer~ : @dom_ffi.DataTransfer,
    original_event~ : @dom_ffi.DragEvent
  )
}

///|
pub impl Show for RespoEvent with output(self, logger) {
  let ret = match self {
    Click(..) => "(Click)".to_string()
    Keyboard(..) => "(Keyboard)".to_string()
    Input(..) => "(Input)".to_string()
    Focus(_) => "(Focus)".to_string()
    Blur(_) => "(Blur)".to_string()
    Drag(..) => "(Drag)".to_string()
  }
  logger.write_string(ret)
}

///|
/// Represents an event mark with its location in the virtual DOM tree.
/// Contains the coordinate path to the element, the event type, and the event data.
pub(all) struct RespoEventMark {
  coord : @immut/vector.Vector[RespoCoord]
  name : RespoEventType
  event_info : RespoEvent
}

///|
/// Defines the types of DOM events that can be handled in Respo.
/// Each variant corresponds to a specific browser event type.
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
  DragStart
  DragEnd
  DragOver
  DragEnter
  DragLeave
  Drop
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
    DragStart => "DragStart".to_string()
    DragEnd => "DragEnd".to_string()
    DragOver => "DragOver".to_string()
    DragEnter => "DragEnter".to_string()
    DragLeave => "DragLeave".to_string()
    Drop => "Drop".to_string()
  }
  logger.write_string(ret)
}

///|
/// Converts a RespoEventType to its Cirru representation.
/// Returns a Cirru leaf node with the event type name prefixed with `::`.
pub fn RespoEventType::to_cirru(self : RespoEventType) -> Cirru {
  match self {
    Click => Leaf(":click")
    DblClick => Leaf(":dbl-click")
    Change => Leaf(":change")
    Keydown => Leaf(":keydown")
    Keyup => Leaf(":keyup")
    Keypress => Leaf(":keypress")
    Input => Leaf(":input")
    Focus => Leaf(":focus")
    Blur => Leaf(":blur")
    DragStart => Leaf(":drag-start")
    DragEnd => Leaf(":drag-end")
    DragOver => Leaf(":drag-over")
    DragEnter => Leaf(":drag-enter")
    DragLeave => Leaf(":drag-leave")
    Drop => Leaf(":drop")
  }
}
