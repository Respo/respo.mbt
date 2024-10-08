/// DOM Node type
pub type Node

pub extern "js" fn child_nodes(self : Node) -> Array[Node] =
  #| (self) => self.childNodes

// children
pub extern "js" fn children(self : Node) -> Array[Node] =
  #| (self) => self.children

pub extern "js" fn reinterpret_as_element(self : Node) -> Element =
  #| (self) => self

// reinterpret_as_node
pub extern "js" fn reinterpret_as_node(self : Element) -> Node =
  #| (self) => self

// first_child
pub extern "js" fn first_child(self : Node) -> Node =
  #| (self) => self.firstChild

pub type Element

pub extern "js" fn set_inner_html(self : Element, html : String) -> Unit =
  #| (self, html) => { self.innerHTML = html }

pub extern "js" fn set_inner_text(self : Element, text : String) -> Unit =
  #| (self, text) => { self.innerText = text }

pub extern "js" fn set_html_for(self : Element, html : String) -> Unit =
  #| (self, html) => { self.htmlFor = html }

pub extern "js" fn tag_name(self : Element) -> String =
  #| (self) => self.tagName

pub extern "js" fn set_attribute(
  self : Element,
  name : String,
  value : String
) -> Unit =
  #| (self, name, value) => { self.setAttribute(name, value) }

// remove_attribute
pub extern "js" fn remove_attribute(self : Element, name : String) -> Unit =
  #| (self, name) => { self.removeAttribute(name) }

// dirty_get_attribute_fn
pub extern "js" fn dirty_get_attribute_fn(
  self : Element,
  name : String
) -> () -> Bool =
  #| (self, name) => self[name]

// dirty_set_attribute_fn
pub extern "js" fn dirty_set_attribute_fn(
  self : Element,
  name : String,
  f : (KeyboardEvent) -> Bool
) =
  #| (self, name, f) => self[name] = f

// dirty_remove_attribute_fn
pub extern "js" fn dirty_remove_attribute_fn(self : Element, name : String) =
  #| (self, name) => delete self[name]

pub extern "js" fn append_child(self : Element, child : Node) -> Unit =
  #| (self, child) => { self.appendChild(child) }

// set_onkeypress on input
pub extern "js" fn set_onkeypress(
  self : HtmlInputElement,
  f : ((KeyboardEvent) -> Unit)?
) -> Unit =
  #| (self, f) => { self.onkeypress = f }

// set_onkeypress on textarea
pub extern "js" fn set_onkeypress(
  self : HtmlTextAreaElement,
  f : ((KeyboardEvent) -> Unit)?
) -> Unit =
  #| (self, f) => { self.onkeypress = f }

// set_onkeydown on input
pub extern "js" fn set_onkeydown(
  self : HtmlInputElement,
  f : ((KeyboardEvent) -> Unit)?
) -> Unit =
  #| (self, f) => { self.onkeydown = f }

// set_onkeydown on textarea
pub extern "js" fn set_onkeydown(
  self : HtmlTextAreaElement,
  f : ((KeyboardEvent) -> Unit)?
) -> Unit =
  #| (self, f) => { self.onkeydown = f }

// set_onkeyup on input
pub extern "js" fn set_onkeyup(
  self : HtmlInputElement,
  f : ((KeyboardEvent) -> Unit)?
) -> Unit =
  #| (self, f) => { self.onkeyup = f }

// set_onkeyup on textarea
pub extern "js" fn set_onkeyup(
  self : HtmlTextAreaElement,
  f : ((KeyboardEvent) -> Unit)?
) -> Unit =
  #| (self, f) =>  { self.onkeyup = f }

// style
pub type CSSStyleDeclaration

pub extern "js" fn style(self : Node) -> CSSStyleDeclaration =
  #| (self) => self.style

pub extern "js" fn clone_node(self : Node, ~deep : Bool = false) -> Node =
  #| (self, deep) => self.cloneNode(deep)

pub extern "js" fn owner_document(self : Node) -> Document =
  #| (self) => self.ownerDocument

pub type HtmlInputElement

pub extern "js" fn reinterpret_as_html_input_element(
  self : Element
) -> HtmlInputElement =
  #| (self) => self

pub type HtmlTextAreaElement

// set_onblur
pub extern "js" fn set_onblur(
  self : HtmlInputElement,
  f : ((BlurEvent) -> Unit)?
) -> Unit =
  #| (self, f) => { self.onblur = f }

// set_onfocus on input
pub extern "js" fn set_onfocus(
  self : HtmlInputElement,
  f : ((FocusEvent) -> Unit)?
) -> Unit =
  #| (self, f) => { self.onfocus = f }

// set_onblur on textarea
pub extern "js" fn set_onblur(
  self : HtmlTextAreaElement,
  f : ((BlurEvent) -> Unit)?
) -> Unit =
  #| (self, f) => { self.onblur = f }

// set_onfocus on textarea
pub extern "js" fn set_onfocus(
  self : HtmlTextAreaElement,
  f : ((FocusEvent) -> Unit)?
) -> Unit =
  #| (self, f) => { self.onfocus = f }

// set_onchange on input
pub extern "js" fn set_onchange(
  self : HtmlInputElement,
  f : ((InputEvent) -> Unit)?
) -> Unit =
  #| (self, f) => { self.onchange = f }

// set_onchange on textarea
pub extern "js" fn set_onchange(
  self : HtmlTextAreaElement,
  f : ((InputEvent) -> Unit)?
) -> Unit =
  #| (self, f) => { self.onchange = f }

// set_oninput on input
pub extern "js" fn set_oninput(
  self : HtmlInputElement,
  f : (InputEvent) -> Unit
) -> Unit =
  #| (self, f) => { self.oninput = f }

pub extern "js" fn unset_oninput(self : HtmlInputElement) -> Unit =
  #| (self) => { self.oninput = null }

// set_oninput on textarea
pub extern "js" fn set_oninput(
  self : HtmlTextAreaElement,
  f : ((InputEvent) -> Unit)?
) -> Unit =
  #| (self, f) => { self.oninput = f }

pub extern "js" fn value(self : HtmlInputElement) -> String =
  #| (self) => self.value

pub extern "js" fn set_value(self : HtmlInputElement, value : String) -> Unit =
  #| (self, value) => { self.value = value }

pub extern "js" fn value(self : HtmlTextAreaElement) -> String =
  #| (self) => self.value

pub extern "js" fn set_value(
  self : HtmlTextAreaElement,
  value : String
) -> Unit =
  #| (self, value) => { self.value = value }

// parent_element
pub extern "js" fn parent_element(self : Node) -> Element =
  #| (self) => self.parentElement

// insert_before
pub extern "js" fn insert_before(
  self : Element,
  new_child : Node,
  reference_child : Node?
) -> Unit =
  #| (self, new_child, reference_child) => { self.insertBefore(new_child, reference_child) }

pub extern "js" fn reinterpret_as_html_textarea_element(
  self : Element
) -> HtmlTextAreaElement =
  #| (self) => self

// remove
pub extern "js" fn remove(self : Node) -> Unit =
  #| (self) => { self.remove() }

// remove_child from Node
pub extern "js" fn remove_child(self : Node, child : Node) -> Unit =
  #| (self, child) => { self.removeChild(child) }

// set_property
pub extern "js" fn set_property(
  self : CSSStyleDeclaration,
  name : String,
  value : String
) -> Unit =
  #| (self, name, value) => { self[name] = value }

// remove_property
pub extern "js" fn remove_property(
  self : CSSStyleDeclaration,
  name : String
) -> Unit =
  #| (self, name) => { delete self[name] }

pub type InputEvent

pub type FocusEvent

pub type BlurEvent

pub type MouseEvent

pub extern "js" fn stop_propagation(self : MouseEvent) -> Unit =
  #| (self) => self.stopPropagation()

// client_x
pub extern "js" fn client_x(self : MouseEvent) -> Float =
  #| (self) => self.clientX

// client_y
pub extern "js" fn client_y(self : MouseEvent) -> Float =
  #| (self) => self.clientY

pub extern "js" fn log(msg : String) -> Unit =
  #| (msg) => { console.log(msg) }

pub extern "js" fn warn_log(msg : String) -> Unit =
  #| (msg) => { console.warn(msg) }

pub extern "js" fn error_log(msg : String) -> Unit =
  #| (msg) => { console.error(msg) }

pub extern "js" fn debugger() -> Unit =
  #| () => { debugger }

// set_onclick
pub extern "js" fn set_onclick(
  self : Element,
  f : (MouseEvent) -> Unit
) -> Unit =
  #| (self, f) => { self.onclick = f }

pub extern "js" fn unset_onclick(self : Element) -> Unit =
  #| (self) => { self.onclick = null }

// set_ondblclick
pub extern "js" fn set_ondblclick(
  self : Element,
  f : (MouseEvent) -> Unit
) -> Unit =
  #| (self, f) => { self.ondblclick = f }

pub extern "js" fn unset_ondblclick(self : Element) -> Unit =
  #| (self) => { self.ondbclick = null }

pub type KeyboardEvent

// init_dict.set_key(event.key())
// init_dict.set_code(event.code())
// init_dict.set_char_code(event.char_code())
// init_dict.set_view(event.view())
// init_dict.set_location(event.location())
// init_dict.set_key_code(event.key_code())

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

pub extern "js" fn set_code(self : KeyboardEvent, code : String) -> Unit =
  #| (self, code) => { self.code = code }

pub extern "js" fn set_key(self : KeyboardEvent, key : String) -> Unit =
  #| (self, key) => { self.key = key }

pub extern "js" fn set_char_code(
  self : KeyboardEvent,
  char_code : UInt
) -> Unit =
  #| (self, char_code) => { self.charCode = char_code }

// set_key_code
pub extern "js" fn set_key_code(self : KeyboardEvent, key_code : UInt) -> Unit =
  #| (self, key_code) => { self.keyCode = key_code }

// set_location
pub extern "js" fn set_location(self : KeyboardEvent, location : UInt) -> Unit =
  #| (self, location) => { self.location = location }

// set_view
pub extern "js" fn set_view(self : KeyboardEvent, view : Window) -> Unit =
  #| (self, view) => { self.view = view }

// set_repeat
pub extern "js" fn set_repeat(self : KeyboardEvent, repeat : Bool) -> Unit =
  #| (self, repeat) => { self.repeat = repeat }

/// window
pub type Window

pub extern "js" fn window() -> Window =
  #| () => window

// add_event_listener_with_callback
pub extern "js" fn add_event_listener_with_callback(
  self : Window,
  type_ : String,
  f : (KeyboardEvent) -> Bool // TODO
) -> Unit =
  #| (self, type, f) => { self.addEventListener(type, f) }

// remove_event_listener_with_callback
pub extern "js" fn remove_event_listener_with_callback(
  self : Window,
  type_ : String,
  f : () -> Bool // TODO
) -> Unit =
  #| (self, type, f) => { self.removeEventListener(type, f) }

pub extern "js" fn set_timeout(
  self : Window,
  f : () -> Unit,
  ms : UInt
) -> Unit =
  #| (self, f, ms) => { self.setTimeout(f, ms) }

// dirty_get_fn
pub extern "js" fn dirty_get_fn(self : Window, name : String) -> () -> Unit =
  #| (self, name) => self[name]

// dirty_set_fn
pub extern "js" fn dirty_set_fn(self : Window, name : String, f : () -> Unit) =
  #| (self, name, f) => { self[name] = f }

// dirty_call_fn
pub extern "js" fn dirty_call_fn(self : Window, name : String) -> Unit =
  #| (self, name) => self[name].?()

// dirty_remove_fn
pub extern "js" fn dirty_remove_fn(self : Window, name : String) -> Unit =
  #| (self, name) => delete self[name]

// dirty_get_fn_1
pub extern "js" fn dirty_get_fn_1(
  self : Window,
  name : String
) -> (String) -> Unit =
  #| (self, name) => self[name]

// dirty_set_fn_1
pub extern "js" fn dirty_set_fn_1(
  self : Window,
  name : String,
  f : (String) -> Unit
) =
  #| (self, name, f) => { self[name] = f }

// dirty_call_fn_1
pub extern "js" fn dirty_call_fn_1(
  self : Window,
  name : String,
  v1 : String
) -> Unit =
  #| (self, name, v1) => self[name].?(v1)

pub type Document

pub extern "js" fn document(self : Window) -> Document =
  #| (self) => self.document

// body
pub extern "js" fn body(self : Document) -> Element =
  #| (self) => self.body

// head
pub extern "js" fn head(self : Document) -> Element =
  #| (self) => self.head

pub extern "js" fn query_selector(
  self : Document,
  selector : String
) -> Element =
  #| (self, selector) => self.querySelector(selector)

pub extern "js" fn Element::query_selector(
  self : Element,
  selector : String
) -> Element =
  #| (self, selector) => self.querySelector(selector)

// create_element
pub extern "js" fn create_element(self : Document, name : String) -> Element =
  #| (self, name) => self.createElement(name)

pub extern "js" fn append_child(self : Node, child : Node) -> Unit =
  #| (self, child) => self.appendChild(child)

// insert_before on Node
pub extern "js" fn insert_before(
  self : Node,
  new_child : Node,
  reference_child : Node?
) -> Unit =
  #| (self, new_child, reference_child) => { self.insertBefore(new_child, reference_child) }

// target on input event
pub extern "js" fn target(self : InputEvent) -> Element =
  #| (self) => self.target

pub extern "js" fn request_animation_frame(
  self : Window,
  f : (Float) -> Unit
) -> Unit =
  #| (self, f) => { self.requestAnimationFrame(f) }

// performance
pub type Performance

pub extern "js" fn performance(self : Window) -> Performance =
  #| (self) => self.performance

// performance.now
pub extern "js" fn now(self : Performance) -> Float =
  #| (self) => self.now()

/// a temporary solution for generating random id
pub extern "js" fn random_id() -> String =
  #| () => Math.random().toString(36).slice(2)

pub extern "js" fn Element::focus(self : Element) -> Unit =
  #| (self) => self.focus()

// KeyboardEventInit
pub extern "js" fn keyboard_event_init(
  self : Window,
  type_ : String
) -> KeyboardEvent =
  #| (self, type) => new KeyboardEvent(type)
