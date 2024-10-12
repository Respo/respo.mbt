pub type KeyboardEvent

pub extern "js" fn KeyboardEvent::new_with_init_dict(
  type_ : String,
  event_init_dict : KeyboardEventInit
) -> KeyboardEvent =
  #| (type_, event_init_dict) => new KeyboardEvent(type_, event_init_dict)

// key
pub extern "js" fn key(self : KeyboardEvent) -> String =
  #| (self) => self.key

// type_
pub extern "js" fn type_(self : KeyboardEvent) -> String =
  #| (self) => self.type

// key_code
pub extern "js" fn key_code(self : KeyboardEvent) -> UInt =
  #| (self) => self.keyCode

// shift_key
pub extern "js" fn shift_key(self : KeyboardEvent) -> Bool =
  #| (self) => self.shiftKey

// ctrl_key
pub extern "js" fn ctrl_key(self : KeyboardEvent) -> Bool =
  #| (self) => self.ctrlKey

// alt_key
pub extern "js" fn alt_key(self : KeyboardEvent) -> Bool =
  #| (self) => self.altKey

// meta_key
pub extern "js" fn meta_key(self : KeyboardEvent) -> Bool =
  #| (self) => self.metaKey

// repeat
pub extern "js" fn repeat(self : KeyboardEvent) -> Bool =
  #| (self) => self.repeat

pub extern "js" fn view(self : KeyboardEvent) -> Window =
  #| (self) => self.view

pub extern "js" fn code(self : KeyboardEvent) -> String =
  #| (self) => self.code

pub extern "js" fn char_code(self : KeyboardEvent) -> UInt =
  #| (self) => self.charCode

pub extern "js" fn location(self : KeyboardEvent) -> UInt =
  #| (self) => self.location

// dispatch_event
pub extern "js" fn dispatch_event(self : Node, event : KeyboardEvent) -> Bool =
  #| (self, event) => self.dispatchEvent(event)

pub extern "js" fn prevent_default(self : KeyboardEvent) -> Unit =
  #| (self) => self.preventDefault()

pub extern "js" fn stop_propagation(self : KeyboardEvent) -> Unit =
  #| (self) => self.stopPropagation()

// set_repeat
pub extern "js" fn set_repeat(self : KeyboardEvent, repeat : Bool) -> Unit =
  #| (self, repeat) => { self.repeat = repeat }

/// need to init function first before creating real event
pub type KeyboardEventInit

pub extern "js" fn KeyboardEventInit::new() -> KeyboardEventInit =
  #| () => ({})

pub extern "js" fn keyboard_event_init(
  self : Window,
  type_ : String
) -> KeyboardEventInit =
  #| (self, type) => ({})

pub extern "js" fn set_key(self : KeyboardEventInit, key : String) -> Unit =
  #| (self, key) => { self.key = key }

pub extern "js" fn set_code(self : KeyboardEventInit, code : String) -> Unit =
  #| (self, code) => { self.code = code }

pub extern "js" fn set_char_code(
  self : KeyboardEventInit,
  char_code : UInt
) -> Unit =
  #| (self, char_code) => { self.charCode = char_code }

pub extern "js" fn set_view(self : KeyboardEventInit, view : Window) -> Unit =
  #| (self, view) => { self.view = view }

pub extern "js" fn set_location(
  self : KeyboardEventInit,
  location : UInt
) -> Unit =
  #| (self, location) => { self.location = location }

pub extern "js" fn set_key_code(
  self : KeyboardEventInit,
  key_code : UInt
) -> Unit =
  #| (self, key_code) => { self.keyCode = key_code }
