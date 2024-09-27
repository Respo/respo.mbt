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
  ~color? : CssColor,
  ~background_color? : String,
  ~font_size? : UInt,
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
  ~line_height? : CssLineHeight,
  ~letter_spacing? : String,
  ~white_space? : String,
  ~word_break? : String,

  // Visual Effects
  ~opacity? : Int,
  ~visibility? : String,
  ~box_shadow? : String,
  ~transition? : String,
  ~box_sizing? : CssBoxSizing
) -> RespoStyle {
  let style : Array[(String, String)] = []
  match color {
    Some(value) => style.push(("color", value.to_string()))
    None => ()
  }
  match background_color {
    Some(value) => style.push(("background-color", value))
    None => ()
  }
  match font_size {
    Some(value) => style.push(("font-size", value.to_string()))
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
    Some(value) => style.push(("line-height", value.to_string()))
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
  match box_sizing {
    Some(value) => style.push(("box-sizing", value.to_string()))
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
    Static => "static"
    Relative => "relative"
    Absolute => "absolute"
    Fixed => "fixed"
    Sticky => "sticky"
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
    Hsla(h, s, l, a) => "hsla(\{h}, \{s}%, \{l}%, \{a})"
    Hsl(h, s, l) => "hsl(\{h}, \{s}%, \{l}%)"
    Hsluva(h, s, l, a) => "hsluva(\{h}, \{s}%, \{l}%, \{a})"
    Hsluv(h, s, l) => "hsluv(\{h}, \{s}%, \{l}%)"
    Rgba(r, g, b, a) => "rgba(\{r}, \{g}, \{b}, \{a})"
    Rgb(r, g, b) => "rgb(\{r}, \{g}, \{b})"
    Hex(r, g, b) => "#\{r}\{g}\{b}"
    Red => "red"
    Green => "green"
    Blue => "blue"
    White => "white"
    Black => "black"
    Gray => "gray"
    Yellow => "yellow"
    Purple => "purple"
    Cyan => "cyan"
    Orange => "orange"
    Pink => "pink"
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
    Em(value) => "\{value}em"
    Px(value) => "\{value}px"
    Percent(value) => "\{value}%"
    Normal => "normal"
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
    Block => "block"
    Inline => "inline"
    InlineBlock => "inline-block"
    Flex => "flex"
    InlineFlex => "inline-flex"
    Grid => "grid"
    InlineGrid => "inline-grid"
    None => "none"
  }
}

pub enum CssFlexWrap {
  Wrap
  Nowrap
  WrapReverse
} derive(Eq)

pub fn CssFlexWrap::to_string(self : CssFlexWrap) -> String {
  match self {
    Wrap => "wrap"
    Nowrap => "nowrap"
    WrapReverse => "wrap-reverse"
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
    Row => "row"
    RowReverse => "row-reverse"
    Column => "column"
    ColumnReverse => "column-reverse"
  }
}

pub enum CssVerticalAlign {
  Top
  Middle
  Bottom
}

pub fn CssVerticalAlign::to_string(self : CssVerticalAlign) -> String {
  match self {
    Top => "top"
    Middle => "middle"
    Bottom => "bottom"
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
    FlexStart => "flex-start"
    FlexEnd => "flex-end"
    Center => "center"
    SpaceBetween => "space-between"
    SpaceAround => "space-around"
    SpaceEvenly => "space-evenly"
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
    FlexStart => "flex-start"
    FlexEnd => "flex-end"
    Center => "center"
    Baseline => "baseline"
    Stretch => "stretch"
  }
}

pub enum CssBorderStyle {
  Solid
  Dashed
  Dotted
} derive(Eq)

pub fn CssBorderStyle::to_string(self : CssBorderStyle) -> String {
  match self {
    Solid => "solid"
    Dashed => "dashed"
    Dotted => "dotted"
  }
}

pub enum CssBackgroundSize {
  Cover
  Contain
  Wh(UInt, UInt)
} derive(Eq)

pub fn CssBackgroundSize::to_string(self : CssBackgroundSize) -> String {
  match self {
    Cover => "cover"
    Contain => "contain"
    Wh(w, h) => "\{w}px \{h}px"
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
    Visible => "visible"
    Hidden => "hidden"
    Scroll => "scroll"
    Auto => "auto"
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
    Translate(x, y) => "translate(\{x}px, \{y}px)"
    TranslateX(x) => "translateX(\{x}px)"
    TranslateY(y) => "translateY(\{y}px)"
    Scale(value) => "scale(\{value})"
    Rotate(deg) => "rotate(\{deg}deg)"
    Skew(x, y) => "skew(\{x}deg, \{y}deg)"
    Matrix(a, b, c, d, e, f) => "matrix(\{a}, \{b}, \{c}, \{d}, \{e}, \{f})"
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
    Ease => "ease"
    Linear => "linear"
    EaseIn => "ease-in"
    EaseOut => "ease-out"
    EaseInOut => "ease-in-out"
    StepStart => "step-start"
    StepEnd => "step-end"
  }
}

pub enum CssTextOverflow {
  Clip
  Ellipsis
} derive(Eq)

pub fn CssTextOverflow::to_string(self : CssTextOverflow) -> String {
  match self {
    Clip => "clip"
    Ellipsis => "ellipsis"
  }
}

pub enum CssBoxSizing {
  BorderBox
  ContentBox
} derive(Eq)

pub fn CssBoxSizing::to_string(self : CssBoxSizing) -> String {
  match self {
    BorderBox => "border-box"
    ContentBox => "content-box"
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
    Left => "left"
    Right => "right"
    Center => "center"
    Justify => "justify"
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
    Normal => "normal"
    Bold => "bold"
    Bolder => "bolder"
    Lighter => "lighter"
    Weight(value) => "\{value}"
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
    None => "none"
    Underline => "underline"
    Overline => "overline"
    LineThrough => "line-through"
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
pub fn declare_static_style[U : Show](
  rules : Array[(U, RespoStyle)],
  ~loc : SourceLoc = _
) -> String {
  @web_sys.warn_log("SourceLoc" + loc.to_string())
  let gen_name = loc
    .to_string()
    .split("/src/")
    .last()
    .unwrap()
    .replace_all(old="/", new="$")
    .replace_all(old=":", new="$c_")
    .replace_all(old=".", new="$d_")
  if class_name_in_tags.contains(gen_name) {
    gen_name
  } else {
    let window = @web_sys.window()
    let document = window.document()
    let head = document.head()
    let style_tag = document.create_element("style")
    style_tag.set_attribute("id", "def__" + gen_name)
    style_tag.set_attribute("loc", loc.to_string())
    let mut styles = ""
    for pair in rules {
      let (query, properties) = pair
      styles = styles +
        query
        .to_string()
        .replace(old="$0", new="." + gen_name)
        .replace(old="&", new="." + gen_name)
      styles = styles + " {\n"
      styles = styles + properties.to_string()
      styles = styles + "}\n"
    }
    style_tag.set_inner_html(styles)
    head.reinterpret_as_node().append_child(style_tag.reinterpret_as_node())
    class_name_in_tags.insert(gen_name)
    gen_name
  }
}
