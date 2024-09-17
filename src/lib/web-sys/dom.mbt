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
  f : (MouseEvent?) -> Unit
) -> Unit =
  #| self.onclick = f

// set_ondblclick
pub extern "js" fn set_ondblclick(
  self : Element,
  f : (MouseEvent?) -> Unit
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

pub extern "js" fn append_child(self : Element, child : Node) -> Unit =
  #| self.appendChild(child)
