/// types for HTML elements. if you find a missing element, please open an PR.
/// thanks to Copilot for helping me fill in this file.

///| <div> element with children.
pub fn div[T](
  class_name? : String,
  class_list~ : Array[String] = [],
  attrs~ : Map[String, String] = {},
  event~ : Map[
    RespoEventType,
    (RespoEvent, DispatchFn[T]) -> Unit!RespoCommonError,
  ] = {},
  style~ : RespoStyle = respo_style(),
  children : Array[RespoNode[T]],
  innerHTML? : String
) -> RespoNode[T] {
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  if innerHTML is Some(innerHTML) {
    attrs.set("innerHTML", innerHTML)
  }
  Element({
    name: "div",
    attrs,
    event,
    style,
    children: children.mapi(fn(idx, child) {
      (RespoIndexKey(idx.to_string()), child)
    }),
  })
}

///|
/// Combines a base class name with a list of additional class names into a
/// single string, with class names separated by spaces. Returns `None` if both
/// inputs are empty.
fn combile_classes(class_name : String?, class_list : Array[String]) -> String? {
  let mut class_content = ""
  if class_name is Some(class_name) {
    class_content += " " + class_name
  }
  if not(class_list.is_empty()) {
    for class_name in class_list {
      class_content += " " + class_name
    }
  }
  class_content = class_content.trim(" ").to_string()
  if class_content.is_empty() {
    None
  } else {
    Some(class_content)
  }
}

///| create a list of `<div/>` elements with children. `IndexKey` is used in children for quick diffing.
pub fn div_listed[T](
  class_name? : String,
  class_list~ : Array[String] = [],
  attrs~ : Map[String, String] = {},
  event~ : Map[
    RespoEventType,
    (RespoEvent, DispatchFn[T]) -> Unit!RespoCommonError,
  ] = {},
  style~ : RespoStyle = respo_style(),
  children : Array[(RespoIndexKey, RespoNode[T])]
) -> RespoNode[T] {
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  Element({ name: "div", attrs, event, style, children })
}

///|
pub fn span[T](
  class_name? : String,
  class_list~ : Array[String] = [],
  inner_text? : String,
  innerHTML? : String,
  attrs~ : Map[String, String] = {},
  event~ : Map[
    RespoEventType,
    (RespoEvent, DispatchFn[T]) -> Unit!RespoCommonError,
  ] = {},
  style~ : RespoStyle = respo_style(),
  children : Array[RespoNode[T]]
) -> RespoNode[T] {
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  if inner_text is Some(inner_text) {
    attrs.set("innerText", inner_text)
  }
  if innerHTML is Some(innerHTML) {
    attrs.set("innerHTML", innerHTML)
  }
  Element({
    name: "span",
    attrs,
    event,
    style,
    children: children.mapi(fn(idx, child) {
      (RespoIndexKey(idx.to_string()), child)
    }),
  })
}

///| internally using span element to render text.
pub fn text_node[T](
  class_name? : String,
  class_list~ : Array[String] = [],
  style? : RespoStyle,
  text : String
) -> RespoNode[T] {
  span(
    inner_text=text,
    class_name=class_name.or_default(),
    class_list~,
    style=style.or_default(),
    [],
  )
}

///|
pub fn button[T](
  class_name? : String,
  class_list~ : Array[String] = [],
  inner_text~ : String,
  attrs~ : Map[String, String] = {},
  event~ : Map[
    RespoEventType,
    (RespoEvent, DispatchFn[T]) -> Unit!RespoCommonError,
  ] = {},
  style~ : RespoStyle = respo_style()
) -> RespoNode[T] {
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  attrs.set("innerText", inner_text)
  Element({ name: "button", attrs, event, style, children: [] })
}

///|
pub fn input[T](
  class_name? : String,
  class_list~ : Array[String] = [],
  autocomplete? : TextareaElementAutoComplete,
  autofocus? : Bool,
  disabled? : Bool,
  name? : String,
  placeholder? : String,
  readonly_? : Bool,
  spellcheck? : Bool,
  attrs~ : Map[String, String] = {},
  value~ : String,
  event~ : Map[
    RespoEventType,
    (RespoEvent, DispatchFn[T]) -> Unit!RespoCommonError,
  ] = {},
  style~ : RespoStyle = respo_style()
) -> RespoNode[T] {
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  if autocomplete is Some(autocomplete) {
    attrs.set(
      "autocomplete",
      match autocomplete {
        On => "on"
        Off => "off"
      },
    )
  }
  if autofocus is Some(autofocus) {
    attrs.set("autofocus", if autofocus { "true" } else { "false" })
  }
  if disabled is Some(disabled) {
    attrs.set("disabled", if disabled { "true" } else { "false" })
  }
  if name is Some(name) {
    attrs.set("name", name)
  }
  if placeholder is Some(placeholder) {
    attrs.set("placeholder", placeholder)
  }
  if readonly_ is Some(readonly_) {
    attrs.set("readonly", if readonly_ { "true" } else { "false" })
  }
  if spellcheck is Some(spellcheck) {
    attrs.set("spellcheck", if spellcheck { "true" } else { "false" })
  }
  attrs.set("value", value)
  Element({ name: "input", attrs, event, style, children: [] })
}

///|
pub(all) enum TextareaElementAutoComplete {
  On
  Off
}

///|
pub fn textarea[T](
  class_name? : String,
  class_list~ : Array[String] = [],
  value~ : String,
  autocomplete? : TextareaElementAutoComplete,
  autofocus? : Bool,
  disabled? : Bool,
  name? : String,
  placeholder? : String,
  readonly_? : Bool,
  spellcheck? : Bool,
  attrs~ : Map[String, String] = {},
  event~ : Map[
    RespoEventType,
    (RespoEvent, DispatchFn[T]) -> Unit!RespoCommonError,
  ] = {},
  style~ : RespoStyle = respo_style()
) -> RespoNode[T] {
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  attrs.set("value", value)
  if autocomplete is Some(autocomplete) {
    attrs.set(
      "autocomplete",
      match autocomplete {
        TextareaElementAutoComplete::On => "on"
        TextareaElementAutoComplete::Off => "off"
      },
    )
  }
  if autofocus is Some(autofocus) {
    attrs.set("autofocus", if autofocus { "true" } else { "false" })
  }
  if disabled is Some(disabled) {
    attrs.set("disabled", if disabled { "true" } else { "false" })
  }
  if name is Some(name) {
    attrs.set("name", name)
  }
  if placeholder is Some(placeholder) {
    attrs.set("placeholder", placeholder)
  }
  if readonly_ is Some(readonly_) {
    attrs.set("readonly", if readonly_ { "true" } else { "false" })
  }
  if spellcheck is Some(spellcheck) {
    attrs.set("spellcheck", if spellcheck { "true" } else { "false" })
  }
  Element({ name: "textarea", attrs, event, style, children: [] })
}

///|
pub(all) enum AnchorElementTarget {
  Blank
  Parent
  Self
  Top
}

///|
pub fn to_string(self : AnchorElementTarget) -> String {
  match self {
    AnchorElementTarget::Blank => "_blank"
    AnchorElementTarget::Parent => "_parent"
    AnchorElementTarget::Self => "_self"
    AnchorElementTarget::Top => "_top"
  }
}

///| anchor element
/// https://developer.mozilla.org/en-US/docs/Web/HTML/Element/a
pub fn a[T](
  inner_text~ : String,
  class_name? : String,
  class_list~ : Array[String] = [],
  /// The URL that the hyperlink points to.
  /// will override href in attrs.
  href~ : String,
  /// The value of the download attribute, which will be used when the user triggers a download.
  /// will override download in attrs.
  download? : String,
  /// The target attribute specifies where to open the linked document.
  /// will override target in attrs.
  target? : AnchorElementTarget,
  attrs~ : Map[String, String] = {},
  /// mime type of the linked document.
  type_? : String,
  event~ : Map[
    RespoEventType,
    (RespoEvent, DispatchFn[T]) -> Unit!RespoCommonError,
  ] = {},
  style~ : RespoStyle = respo_style()
) -> RespoNode[T] {
  attrs.set("href", href)
  attrs.set("innerText", inner_text)
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  if download is Some(download) {
    attrs.set("download", download)
  }
  if target is Some(target) {
    attrs.set("target", target.to_string())
  }
  if type_ is Some(type_) {
    attrs.set("type", type_)
  }
  Element({ name: "a", attrs, event, style, children: [] })
}

///|
pub fn br[T](
  attrs~ : Map[String, String] = {},
  event~ : Map[
    RespoEventType,
    (RespoEvent, DispatchFn[T]) -> Unit!RespoCommonError,
  ] = {},
  style~ : RespoStyle = respo_style()
) -> RespoNode[T] {
  Element({ name: "br", attrs, event, style, children: [] })
}

///|
pub(all) enum IframeElementLoading {
  Eager
  Lazy
}

///|
pub fn iframe[T](
  class_name? : String,
  class_list~ : Array[String] = [],
  height? : Int,
  width? : Int,
  loading? : IframeElementLoading,
  src~ : String,
  attrs~ : Map[String, String] = {},
  event~ : Map[
    RespoEventType,
    (RespoEvent, DispatchFn[T]) -> Unit!RespoCommonError,
  ] = {},
  style~ : RespoStyle = respo_style()
) -> RespoNode[T] {
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  attrs.set("src", src)
  if height is Some(height) {
    attrs.set("height", height.to_string())
  }
  if width is Some(width) {
    attrs.set("width", width.to_string())
  }
  if loading is Some(loading) {
    attrs.set(
      "loading",
      match loading {
        Eager => "eager"
        Lazy => "lazy"
      },
    )
  }
  Element({ name: "iframe", attrs, event, style, children: [] })
}

///|
pub fn canvas[T](
  class_name? : String,
  class_list~ : Array[String] = [],
  height? : Int,
  width? : Int,
  attrs~ : Map[String, String] = {},
  event~ : Map[
    RespoEventType,
    (RespoEvent, DispatchFn[T]) -> Unit!RespoCommonError,
  ] = {},
  style~ : RespoStyle = respo_style()
) -> RespoNode[T] {
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  if height is Some(height) {
    attrs.set("height", height.to_string())
  }
  if width is Some(width) {
    attrs.set("width", width.to_string())
  }
  Element({ name: "canvas", attrs, event, style, children: [] })
}

///|
pub fn code[T](
  class_name? : String,
  class_list~ : Array[String] = [],
  inner_text~ : String,
  attrs~ : Map[String, String] = {},
  event~ : Map[
    RespoEventType,
    (RespoEvent, DispatchFn[T]) -> Unit!RespoCommonError,
  ] = {},
  style~ : RespoStyle = respo_style()
) -> RespoNode[T] {
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  attrs.set("innerText", inner_text)
  Element({ name: "code", attrs, event, style, children: [] })
}

///|
pub fn pre[T](
  class_name? : String,
  class_list~ : Array[String] = [],
  inner_text? : String,
  innerHTML? : String,
  attrs~ : Map[String, String] = {},
  event~ : Map[
    RespoEventType,
    (RespoEvent, DispatchFn[T]) -> Unit!RespoCommonError,
  ] = {},
  style~ : RespoStyle = respo_style()
) -> RespoNode[T] {
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  if inner_text is Some(inner_text) {
    attrs.set("innerText", inner_text)
  }
  if innerHTML is Some(innerHTML) {
    attrs.set("innerHTML", innerHTML)
  }
  Element({ name: "pre", attrs, event, style, children: [] })
}

///|
pub fn p[T](
  class_name? : String,
  class_list~ : Array[String] = [],
  inner_text~ : String,
  attrs~ : Map[String, String] = {},
  style~ : RespoStyle = respo_style(),
  children : Array[RespoNode[T]]
) -> RespoNode[T] {
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  attrs.set("innerText", inner_text)
  let children = children.mapi(fn(idx, child) {
    (RespoIndexKey(idx.to_string()), child)
  })
  Element({ name: "p", attrs, event: {}, style, children })
}

///|
pub fn blockquote[T](
  class_name? : String,
  class_list~ : Array[String] = [],
  inner_text~ : String,
  attrs~ : Map[String, String] = {},
  style~ : RespoStyle = respo_style(),
  children : Array[RespoNode[T]]
) -> RespoNode[T] {
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  attrs.set("innerText", inner_text)
  let children = children.mapi(fn(idx, child) {
    (RespoIndexKey(idx.to_string()), child)
  })
  Element({ name: "blockquote", attrs, event: {}, style, children })
}

///|
pub(all) enum ImgElementLoading {
  Eager
  Lazy
}

///|
pub fn img[T](
  class_name? : String,
  class_list~ : Array[String] = [],
  alt~ : String,
  height? : Int,
  src~ : String,
  width? : Int,
  loading? : ImgElementLoading,
  attrs~ : Map[String, String] = {},
  event~ : Map[
    RespoEventType,
    (RespoEvent, DispatchFn[T]) -> Unit!RespoCommonError,
  ] = {},
  style~ : RespoStyle = respo_style()
) -> RespoNode[T] {
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  attrs.set("alt", alt)
  attrs.set("src", src)
  if height is Some(height) {
    attrs.set("height", height.to_string())
  }
  if width is Some(width) {
    attrs.set("width", width.to_string())
  }
  if loading is Some(loading) {
    attrs.set(
      "loading",
      match loading {
        Eager => "eager"
        Lazy => "lazy"
      },
    )
  }
  Element({ name: "img", attrs, event, style, children: [] })
}

///|
pub(all) enum VideoElementPreload {
  Auto
  Metadata
  None
}

///|
pub fn video[T](
  class_name? : String,
  class_list~ : Array[String] = [],
  height? : Int,
  width? : Int,
  src~ : String,
  controls? : Bool,
  preload? : VideoElementPreload,
  attrs~ : Map[String, String] = {},
  event~ : Map[
    RespoEventType,
    (RespoEvent, DispatchFn[T]) -> Unit!RespoCommonError,
  ] = {},
  style~ : RespoStyle = respo_style()
) -> RespoNode[T] {
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  attrs.set("src", src)
  if height is Some(height) {
    attrs.set("height", height.to_string())
  }
  if width is Some(width) {
    attrs.set("width", width.to_string())
  }
  if controls is Some(controls) {
    attrs.set("controls", if controls { "true" } else { "false" })
  }
  if preload is Some(preload) {
    attrs.set(
      "preload",
      match preload {
        VideoElementPreload::Auto => "auto"
        VideoElementPreload::Metadata => "metadata"
        VideoElementPreload::None => "none"
      },
    )
  }
  Element({ name: "video", attrs, event, style, children: [] })
}

///| create a `<div/>` element to render space.
pub fn space[T](
  width~ : Float = 1,
  height~ : Float = 1,
  class_name? : String,
  class_list~ : Array[String] = []
) -> RespoNode[T] {
  let attrs : Map[String, String] = {}
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  div(
    style=respo_style(
      width=width |> Px,
      height=height |> Px,
      display=if height > 1 { Block } else { InlineBlock },
    ),
    attrs~,
    [],
  )
}

///| create element with a custom name
pub fn create_element[T](
  name : String,
  attrs~ : Map[String, String] = {},
  event~ : Map[
    RespoEventType,
    (RespoEvent, DispatchFn[T]) -> Unit!RespoCommonError,
  ] = {},
  style~ : RespoStyle = respo_style(),
  children : Array[RespoNode[T]]
) -> RespoNode[T] {
  Element({
    name,
    attrs,
    event,
    style,
    children: children.mapi(fn(idx, child) {
      (RespoIndexKey(idx.to_string()), child)
    }),
  })
}
