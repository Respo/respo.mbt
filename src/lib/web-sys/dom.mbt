/// DOM Node type
pub type Node

pub extern "js" fn child_nodes(self : Node) -> Array[Node] =
  #| node.childNodes

// children
pub extern "js" fn children(self : Node) -> Array[Node] =
  #| node.children

pub extern "js" fn reinterpret_as_element(self : Node) -> Element =
  #| self as Element

// reinterpret_as_node
pub extern "js" fn reinterpret_as_node(self : Element) -> Node =
  #| self as Node

// first_child
pub extern "js" fn first_child(self : Node) -> Node? =
  #| self.firstChild

pub type Element

pub extern "js" fn set_inner_html(self : Element, html : String) -> Unit =
  #| self.innerHTML = html

pub extern "js" fn set_inner_text(self : Element, text : String) -> Unit =
  #| self.innerText = text

pub extern "js" fn set_html_for(self : Element, html : String) -> Unit =
  #| self.htmlFor = html

pub extern "js" fn tag_name(self : Element) -> String =
  #| self.tagName

pub extern "js" fn set_attribute(
  self : Element,
  name : String,
  value : String
) -> Unit =
  #| self.setAttribute(name, value)

// remove_attribute
pub extern "js" fn remove_attribute(self : Element, name : String) -> Unit =
  #| self.removeAttribute(name)

// set_onkeypress on input
pub extern "js" fn set_onkeypress(
  self : HtmlInputElement,
  f : ((KeyboardEvent) -> Unit)?
) -> Unit =
  #| self.onkeypress = f

// set_onkeypress on textarea
pub extern "js" fn set_onkeypress(
  self : HtmlTextAreaElement,
  f : ((KeyboardEvent) -> Unit)?
) -> Unit =
  #| self.onkeypress = f

// set_onkeydown on input
pub extern "js" fn set_onkeydown(
  self : HtmlInputElement,
  f : ((KeyboardEvent) -> Unit)?
) -> Unit =
  #| self.onkeydown = f

// set_onkeydown on textarea
pub extern "js" fn set_onkeydown(
  self : HtmlTextAreaElement,
  f : ((KeyboardEvent) -> Unit)?
) -> Unit =
  #| self.onkeydown = f

// set_onkeyup on input
pub extern "js" fn set_onkeyup(
  self : HtmlInputElement,
  f : ((KeyboardEvent) -> Unit)?
) -> Unit =
  #| self.onkeyup = f

// set_onkeyup on textarea
pub extern "js" fn set_onkeyup(
  self : HtmlTextAreaElement,
  f : ((KeyboardEvent) -> Unit)?
) -> Unit =
  #| self.onkeyup = f

// style
pub type CSSStyleDeclaration

pub extern "js" fn style(self : Element) -> CSSStyleDeclaration =
  #| self.style

pub type HtmlInputElement

pub extern "js" fn reinterpret_as_html_input_element(
  self : Element
) -> HtmlInputElement =
  #| self as HtmlInputElement

pub type HtmlTextAreaElement

// set_onblur
pub extern "js" fn set_onblur(
  self : HtmlInputElement,
  f : ((BlurEvent) -> Unit)?
) -> Unit =
  #| self.onblur = f

// set_onfocus on input
pub extern "js" fn set_onfocus(
  self : HtmlInputElement,
  f : ((FocusEvent) -> Unit)?
) -> Unit =
  #| self.onfocus = f

// set_onblur on textarea
pub extern "js" fn set_onblur(
  self : HtmlTextAreaElement,
  f : ((BlurEvent) -> Unit)?
) -> Unit =
  #| self.onblur = f

// set_onfocus on textarea
pub extern "js" fn set_onfocus(
  self : HtmlTextAreaElement,
  f : ((FocusEvent) -> Unit)?
) -> Unit =
  #| self.onfocus = f

// set_onchange on input
pub extern "js" fn set_onchange(
  self : HtmlInputElement,
  f : ((InputEvent) -> Unit)?
) -> Unit =
  #| self.onchange = f

// set_onchange on textarea
pub extern "js" fn set_onchange(
  self : HtmlTextAreaElement,
  f : ((InputEvent) -> Unit)?
) -> Unit =
  #| self.onchange = f

// set_oninput on input
pub extern "js" fn set_oninput(
  self : HtmlInputElement,
  f : ((InputEvent) -> Unit)?
) -> Unit =
  #| self.oninput = f

// set_oninput on textarea
pub extern "js" fn set_oninput(
  self : HtmlTextAreaElement,
  f : ((InputEvent) -> Unit)?
) -> Unit =
  #| self.oninput = f

pub extern "js" fn value(self : HtmlInputElement) -> String =
  #| self.value

pub extern "js" fn set_value(self : HtmlInputElement, value : String) -> Unit =
  #| self.value = value

pub extern "js" fn value(self : HtmlTextAreaElement) -> String =
  #| self.value

pub extern "js" fn set_value(
  self : HtmlTextAreaElement,
  value : String
) -> Unit =
  #| self.value = value

// parent_element
pub extern "js" fn parent_element(self : Node) -> Element =
  #| self.parentElement

// insert_before
pub extern "js" fn insert_before(
  self : Element,
  new_child : Node,
  reference_child : Node?
) -> Unit =
  #| self.insertBefore(new_child, reference_child)

pub extern "js" fn reinterpret_as_html_textarea_element(
  self : Element
) -> HtmlTextAreaElement =
  #| self as HtmlTextAreaElement

// remove
pub extern "js" fn remove(self : Node) -> Unit =
  #| self.remove()

// remove_child from Node
pub extern "js" fn remove_child(self : Node, child : Node) -> Unit =
  #| self.removeChild(child)

// set_property
pub extern "js" fn set_property(
  self : CSSStyleDeclaration,
  name : String,
  value : String
) -> Unit =
  #| self[name] = value

// remove_property
pub extern "js" fn remove_property(
  self : CSSStyleDeclaration,
  name : String
) -> Unit =
  #| delete self[name]

pub type InputEvent

pub type FocusEvent

pub type BlurEvent

pub type MouseEvent

// client_x
pub extern "js" fn client_x(self : MouseEvent) -> Float =
  #| self.clientX

// client_y
pub extern "js" fn client_y(self : MouseEvent) -> Float =
  #| self.clientY

pub extern "js" fn warn_log(msg : String) -> Unit =
  #| console.warn(msg)

pub extern "js" fn error_log(msg : String) -> Unit =
  #| console.error(msg)

// set_onclick
pub extern "js" fn set_onclick(
  self : Element,
  f : ((MouseEvent) -> Unit)?
) -> Unit =
  #| self.onclick = f

// set_ondblclick
pub extern "js" fn set_ondblclick(
  self : Element,
  f : ((MouseEvent) -> Unit)?
) -> Unit =
  #| self.ondblclick = f

pub type KeyboardEvent

// key
pub extern "js" fn key(self : KeyboardEvent) -> String =
  #| self.key

// key_code
pub extern "js" fn key_code(self : KeyboardEvent) -> UInt =
  #| self.keyCode

// shift_key
pub extern "js" fn shift_key(self : KeyboardEvent) -> Bool =
  #| self.shiftKey

// ctrl_key
pub extern "js" fn ctrl_key(self : KeyboardEvent) -> Bool =
  #| self.ctrlKey

// alt_key
pub extern "js" fn alt_key(self : KeyboardEvent) -> Bool =
  #| self.altKey

// meta_key
pub extern "js" fn meta_key(self : KeyboardEvent) -> Bool =
  #| self.metaKey

// repeat
pub extern "js" fn repeat(self : KeyboardEvent) -> Bool =
  #| self.repeat

/// window
pub type Window

pub extern "js" fn window() -> Window =
  #| window

pub type Document

pub extern "js" fn document(self : Window) -> Document =
  #| self.document

// create_element
pub extern "js" fn create_element(self : Document, name : String) -> Element =
  #| self.createElement(name)

pub extern "js" fn append_child(self : Node, child : Node) -> Unit =
  #| self.appendChild(child)

// insert_before on Node
pub extern "js" fn insert_before(
  self : Node,
  new_child : Node,
  reference_child : Node?
) -> Unit =
  #| self.insertBefore(new_child, reference_child)

// target on input event
pub extern "js" fn target(self : InputEvent) -> Element =
  #| self.target

pub extern "js" fn request_animation_frame(
  self : Window,
  f : (Float) -> Unit
) -> Unit =
  #| self.requestAnimationFrame(f)

// performance
pub type Performance

pub extern "js" fn performance(self : Window) -> Performance =
  #| self.performance

// performance.now
pub extern "js" fn now(self : Performance) -> Float =
  #| self.now()
