pub type RespoStyle Array[(String, String)] derive(Eq)

// is_empty
pub fn is_empty(self : RespoStyle) -> Bool {
  self._.is_empty()
}

pub fn to_string(self : RespoStyle) -> String {
  let mut result = ""
  for pair in self._ {
    let (property, value) = pair
    result = result + property + ": " + value + ";\n"
  }
  result
}

fn insert(self : RespoStyle, property : String, value : String) -> RespoStyle {
  self._.push((property, value))
  self
}

fn render_rules(rules : Array[(String, RespoStyle)]) -> String {
  let mut result = ""
  for rule in rules {
    let (query, value) = rule
    result = result + query + " {\n" + value.to_string() + "\n}\n"
  }
  result
}

fn length(self : RespoStyle) -> Int {
  self._.length()
}

/// Create a new RespoStyle object
pub fn RespoStyle::new(
  // Basic Styling
  ~color? : String,
  ~background_color? : String,
  ~font_size? : String,
  ~font_family? : String,
  ~font_weight? : String,
  ~text_align? : String,
  ~display? : String,
  ~margin? : String,
  ~padding? : String,
  ~border? : String,
  ~width? : String,
  ~height? : String,

  // Layout & Positioning
  ~position? : String,
  ~top? : String,
  ~right? : String,
  ~bottom? : String,
  ~left? : String,
  ~float? : String,
  ~clear? : String,
  ~overflow? : String,
  ~z_index? : Int,
  ~flex? : String,
  ~flex_direction? : String,
  ~justify_content? : String,
  ~align_items? : String,
  ~align_content? : String,
  ~order? : Int,

  // Text Styling
  ~text_decoration? : String,
  ~text_transform? : String,
  ~line_height? : String,
  ~letter_spacing? : String,
  ~white_space? : String,
  ~word_break? : String,

  // Visual Effects
  ~opacity? : Int,
  ~visibility? : String,
  ~box_shadow? : String,
  ~transition? : String
) -> RespoStyle {
  let style : Array[(String, String)] = []
  match color {
    Some(value) => style.push(("color", value))
    None => ()
  }
  match background_color {
    Some(value) => style.push(("background-color", value))
    None => ()
  }
  match font_size {
    Some(value) => style.push(("font-size", value))
    None => ()
  }
  match font_family {
    Some(value) => style.push(("font-family", value))
    None => ()
  }
  match font_weight {
    Some(value) => style.push(("font-weight", value))
    None => ()
  }
  match text_align {
    Some(value) => style.push(("text-align", value))
    None => ()
  }
  match display {
    Some(value) => style.push(("display", value))
    None => ()
  }
  match margin {
    Some(value) => style.push(("margin", value))
    None => ()
  }
  match padding {
    Some(value) => style.push(("padding", value))
    None => ()
  }
  match border {
    Some(value) => style.push(("border", value))
    None => ()
  }
  match width {
    Some(value) => style.push(("width", value))
    None => ()
  }
  match height {
    Some(value) => style.push(("height", value))
    None => ()
  }
  match position {
    Some(value) => style.push(("position", value))
    None => ()
  }
  match top {
    Some(value) => style.push(("top", value))
    None => ()
  }
  match right {
    Some(value) => style.push(("right", value))
    None => ()
  }
  match bottom {
    Some(value) => style.push(("bottom", value))
    None => ()
  }
  match left {
    Some(value) => style.push(("left", value))
    None => ()
  }
  match float {
    Some(value) => style.push(("float", value))
    None => ()
  }
  match clear {
    Some(value) => style.push(("clear", value))
    None => ()
  }
  match overflow {
    Some(value) => style.push(("overflow", value))
    None => ()
  }
  match z_index {
    Some(value) => style.push(("z-index", value.to_string()))
    None => ()
  }
  match flex {
    Some(value) => style.push(("flex", value))
    None => ()
  }
  match flex_direction {
    Some(value) => style.push(("flex-direction", value))
    None => ()
  }
  match justify_content {
    Some(value) => style.push(("justify-content", value))
    None => ()
  }
  match align_items {
    Some(value) => style.push(("align-items", value))
    None => ()
  }
  match align_content {
    Some(value) => style.push(("align-content", value))
    None => ()
  }
  match order {
    Some(value) => style.push(("order", value.to_string()))
    None => ()
  }
  match text_decoration {
    Some(value) => style.push(("text-decoration", value))
    None => ()
  }
  match text_transform {
    Some(value) => style.push(("text-transform", value))
    None => ()
  }
  match line_height {
    Some(value) => style.push(("line-height", value))
    None => ()
  }
  match letter_spacing {
    Some(value) => style.push(("letter-spacing", value))
    None => ()
  }
  match white_space {
    Some(value) => style.push(("white-space", value))
    None => ()
  }
  match word_break {
    Some(value) => style.push(("word-break", value))
    None => ()
  }
  match opacity {
    Some(value) => style.push(("opacity", value.to_string()))
    None => ()
  }
  match visibility {
    Some(value) => style.push(("visibility", value))
    None => ()
  }
  match box_shadow {
    Some(value) => style.push(("box-shadow", value))
    None => ()
  }
  match transition {
    Some(value) => style.push(("transition", value))
    None => ()
  }
  RespoStyle(style)
}

/// TODO implement methods for RespoStyle

pub enum CssPosition {
  Static
  Relative
  Absolute
  Fixed
  Sticky
} derive(Eq)

pub fn CssPosition::to_string(self : CssPosition) -> String {
  match self {
    CssPosition::Static => "static"
    CssPosition::Relative => "relative"
    CssPosition::Absolute => "absolute"
    CssPosition::Fixed => "fixed"
    CssPosition::Sticky => "sticky"
  }
}

pub enum CssColor {
  Hsla(UInt, UInt, UInt, Float)
  Hsl(UInt, UInt, UInt)
  Hsluva(UInt, UInt, UInt, Float)
  Hsluv(UInt, UInt, UInt)
  Rgba(UInt, UInt, UInt, Float)
  Rgb(UInt, UInt, UInt)
  Hex(UInt, UInt, UInt)
  Red
  Green
  Blue
  White
  Black
  Gray
  Yellow
  Purple
  Cyan
  Orange
  Pink
} derive(Eq)

pub fn CssColor::to_string(self : CssColor) -> String {
  match self {
    CssColor::Hsla(h, s, l, a) => "hsla(\{h}, \{s}%, \{l}%, \{a})"
    CssColor::Hsl(h, s, l) => "hsl(\{h}, \{s}%, \{l}%)"
    CssColor::Hsluva(h, s, l, a) => "hsluva(\{h}, \{s}%, \{l}%, \{a})"
    CssColor::Hsluv(h, s, l) => "hsluv(\{h}, \{s}%, \{l}%)"
    CssColor::Rgba(r, g, b, a) => "rgba(\{r}, \{g}, \{b}, \{a})"
    CssColor::Rgb(r, g, b) => "rgb(\{r}, \{g}, \{b})"
    CssColor::Hex(r, g, b) => "#\{r}\{g}\{b}"
    CssColor::Red => "red"
    CssColor::Green => "green"
    CssColor::Blue => "blue"
    CssColor::White => "white"
    CssColor::Black => "black"
    CssColor::Gray => "gray"
    CssColor::Yellow => "yellow"
    CssColor::Purple => "purple"
    CssColor::Cyan => "cyan"
    CssColor::Orange => "orange"
    CssColor::Pink => "pink"
  }
}

pub enum CssLineHeight {
  Em(Float)
  Px(Float)
  Percent(Float)
  Normal
} derive(Eq)

pub fn CssLineHeight::to_string(self : CssLineHeight) -> String {
  match self {
    CssLineHeight::Em(value) => "\{value}em"
    CssLineHeight::Px(value) => "\{value}px"
    CssLineHeight::Percent(value) => "\{value}%"
    CssLineHeight::Normal => "normal"
  }
}

pub enum CssDisplay {
  Block
  Inline
  InlineBlock
  Flex
  InlineFlex
  Grid
  InlineGrid
  None
} derive(Eq)

pub fn CssDisplay::to_string(self : CssDisplay) -> String {
  match self {
    CssDisplay::Block => "block"
    CssDisplay::Inline => "inline"
    CssDisplay::InlineBlock => "inline-block"
    CssDisplay::Flex => "flex"
    CssDisplay::InlineFlex => "inline-flex"
    CssDisplay::Grid => "grid"
    CssDisplay::InlineGrid => "inline-grid"
    CssDisplay::None => "none"
  }
}

pub enum CssFlexWrap {
  Wrap
  Nowrap
  WrapReverse
} derive(Eq)

pub fn CssFlexWrap::to_string(self : CssFlexWrap) -> String {
  match self {
    CssFlexWrap::Wrap => "wrap"
    CssFlexWrap::Nowrap => "nowrap"
    CssFlexWrap::WrapReverse => "wrap-reverse"
  }
}

pub enum CssFlexDirection {
  Row
  RowReverse
  Column
  ColumnReverse
} derive(Eq)

pub fn CssFlexDirection::to_string(self : CssFlexDirection) -> String {
  match self {
    CssFlexDirection::Row => "row"
    CssFlexDirection::RowReverse => "row-reverse"
    CssFlexDirection::Column => "column"
    CssFlexDirection::ColumnReverse => "column-reverse"
  }
}

pub enum CssVerticalAlign {
  Top
  Middle
  Bottom
}

pub fn CssVerticalAlign::to_string(self : CssVerticalAlign) -> String {
  match self {
    CssVerticalAlign::Top => "top"
    CssVerticalAlign::Middle => "middle"
    CssVerticalAlign::Bottom => "bottom"
  }
}

pub enum CssFlexJustifyContent {
  FlexStart
  FlexEnd
  Center
  SpaceBetween
  SpaceAround
  SpaceEvenly
} derive(Eq)

pub fn CssFlexJustifyContent::to_string(self : CssFlexJustifyContent) -> String {
  match self {
    CssFlexJustifyContent::FlexStart => "flex-start"
    CssFlexJustifyContent::FlexEnd => "flex-end"
    CssFlexJustifyContent::Center => "center"
    CssFlexJustifyContent::SpaceBetween => "space-between"
    CssFlexJustifyContent::SpaceAround => "space-around"
    CssFlexJustifyContent::SpaceEvenly => "space-evenly"
  }
}

pub enum CssFlexAlignItems {
  FlexStart
  FlexEnd
  Center
  Baseline
  Stretch
} derive(Eq)

pub fn CssFlexAlignItems::to_string(self : CssFlexAlignItems) -> String {
  match self {
    CssFlexAlignItems::FlexStart => "flex-start"
    CssFlexAlignItems::FlexEnd => "flex-end"
    CssFlexAlignItems::Center => "center"
    CssFlexAlignItems::Baseline => "baseline"
    CssFlexAlignItems::Stretch => "stretch"
  }
}

pub enum CssBorderStyle {
  Solid
  Dashed
  Dotted
} derive(Eq)

pub fn CssBorderStyle::to_string(self : CssBorderStyle) -> String {
  match self {
    CssBorderStyle::Solid => "solid"
    CssBorderStyle::Dashed => "dashed"
    CssBorderStyle::Dotted => "dotted"
  }
}

pub enum CssBackgroundSize {
  Cover
  Contain
  Wh(UInt, UInt)
} derive(Eq)

pub fn CssBackgroundSize::to_string(self : CssBackgroundSize) -> String {
  match self {
    CssBackgroundSize::Cover => "cover"
    CssBackgroundSize::Contain => "contain"
    CssBackgroundSize::Wh(w, h) => "\{w}px \{h}px"
  }
}

pub enum CssOverflow {
  Visible
  Hidden
  Scroll
  Auto
} derive(Eq)

pub fn CssOverflow::to_string(self : CssOverflow) -> String {
  match self {
    CssOverflow::Visible => "visible"
    CssOverflow::Hidden => "hidden"
    CssOverflow::Scroll => "scroll"
    CssOverflow::Auto => "auto"
  }
}

pub enum CssTransform {
  Translate(Int, Int)
  TranslateX(Int)
  TranslateY(Int)
  Scale(Float)
  Rotate(Int)
  Skew(Int, Int)
  Matrix(Float, Float, Float, Float, Float, Float)
} derive(Eq)

pub fn CssTransform::to_string(self : CssTransform) -> String {
  match self {
    CssTransform::Translate(x, y) => "translate(\{x}px, \{y}px)"
    CssTransform::TranslateX(x) => "translateX(\{x}px)"
    CssTransform::TranslateY(y) => "translateY(\{y}px)"
    CssTransform::Scale(value) => "scale(\{value})"
    CssTransform::Rotate(deg) => "rotate(\{deg}deg)"
    CssTransform::Skew(x, y) => "skew(\{x}deg, \{y}deg)"
    CssTransform::Matrix(a, b, c, d, e, f) =>
      "matrix(\{a}, \{b}, \{c}, \{d}, \{e}, \{f})"
  }
}

pub enum CssTimingFunction {
  Ease
  Linear
  EaseIn
  EaseOut
  EaseInOut
  StepStart
  StepEnd
} derive(Eq)

pub fn CssTimingFunction::to_string(self : CssTimingFunction) -> String {
  match self {
    CssTimingFunction::Ease => "ease"
    CssTimingFunction::Linear => "linear"
    CssTimingFunction::EaseIn => "ease-in"
    CssTimingFunction::EaseOut => "ease-out"
    CssTimingFunction::EaseInOut => "ease-in-out"
    CssTimingFunction::StepStart => "step-start"
    CssTimingFunction::StepEnd => "step-end"
  }
}

pub enum CssTextOverflow {
  Clip
  Ellipsis
} derive(Eq)

pub fn CssTextOverflow::to_string(self : CssTextOverflow) -> String {
  match self {
    CssTextOverflow::Clip => "clip"
    CssTextOverflow::Ellipsis => "ellipsis"
  }
}

pub enum CssBoxSizing {
  BorderBox
  ContentBox
} derive(Eq)

pub fn CssBoxSizing::to_string(self : CssBoxSizing) -> String {
  match self {
    CssBoxSizing::BorderBox => "border-box"
    CssBoxSizing::ContentBox => "content-box"
  }
}

pub enum CssTextAlign {
  Left
  Right
  Center
  Justify
} derive(Eq)

pub fn CssTextAlign::to_string(self : CssTextAlign) -> String {
  match self {
    CssTextAlign::Left => "left"
    CssTextAlign::Right => "right"
    CssTextAlign::Center => "center"
    CssTextAlign::Justify => "justify"
  }
}

pub enum CssFontWeight {
  Normal
  Bold
  Bolder
  Lighter
  Weight(Int)
} derive(Eq)

pub fn CssFontWeight::to_string(self : CssFontWeight) -> String {
  match self {
    CssFontWeight::Normal => "normal"
    CssFontWeight::Bold => "bold"
    CssFontWeight::Bolder => "bolder"
    CssFontWeight::Lighter => "lighter"
    CssFontWeight::Weight(value) => "\{value}"
  }
}

pub enum CssTextDecoration {
  None
  Underline
  Overline
  LineThrough
} derive(Eq)

pub fn CssTextDecoration::to_string(self : CssTextDecoration) -> String {
  match self {
    CssTextDecoration::None => "none"
    CssTextDecoration::Underline => "underline"
    CssTextDecoration::Overline => "overline"
    CssTextDecoration::LineThrough => "line-through"
  }
}

// /// turns `src/a/b.rs` into `a_b`, (used inside macro)
// pub fn css_name_from_path(p: &str) -> String {
//   let mut s = p.to_owned();
//   if let Some(x) = s.strip_prefix("src/") {
//     s = x.to_string();
//   }
//   if let Some(x) = s.strip_suffix(".rs") {
//     s = x.to_string();
//   }
//   s.replace("::", "_").replace(['/', '.'], "_")
// }

let class_name_in_tags : @hashset.T[String] = @hashset.new()

/// Moonbit version, use [T] for <T> for generics, GC language no need to use to_owned() and &
pub fn declare_static_style[T : Show, U : Show](
  name : T,
  rules : Array[(U, RespoStyle)]
) -> String {
  if class_name_in_tags.contains(name.to_string()) {
    name.to_string()
  } else {
    let window = @web_sys.window()
    let document = window.document()
    let head = document.head()
    let style_tag = document.create_element("style")
    style_tag.set_attribute("id", "def__" + name.to_string())
    let mut styles = ""
    for pair in rules {
      let (query, properties) = pair
      styles = styles +
        query
        .to_string()
        .replace(old="$0", new="." + name.to_string())
        .replace(old="&", new="." + name.to_string())
      styles = styles + " {\n"
      styles = styles + properties.to_string()
      styles = styles + "}\n"
    }
    style_tag.set_inner_html(styles)
    head.reinterpret_as_node().append_child(style_tag.reinterpret_as_node())
    class_name_in_tags.insert(name.to_string())
    name.to_string()
  }
}
