///|
pub(all) type RespoStyle Array[(String, String)] derive(Eq, Default)

// is_empty
///|
pub fn is_empty(self : RespoStyle) -> Bool {
  self._.is_empty()
}

///|
pub fn RespoStyle::to_string(self : RespoStyle) -> String {
  let mut result = ""
  for pair in self._ {
    let (property, value) = pair
    result = result + property + ": " + value + ";"
  }
  result
}

///| for custom styles not defined with enum, use this function to add
pub fn add(self : RespoStyle, property : String, value : String) -> RespoStyle {
  self._.push((property, value))
  self
}

///|
pub fn merge(self : RespoStyle, other : RespoStyle) -> RespoStyle {
  let mut result = self
  for pair in other._ {
    let (property, value) = pair
    result = result.add(property, value)
  }
  result
}

///|
fn length(self : RespoStyle) -> Int {
  self._.length()
}

///| Create a new RespoStyle object
pub fn respo_style(
  // Basic Styling
  color? : CssColor,
  background_color? : CssColor,
  font_size? : UInt,
  font_family? : String,
  font_weight? : String,
  text_align? : CssTextAlign,
  display? : CssDisplay,
  margin? : CssSize,
  padding? : CssSize,
  border? : CssBorder,
  width? : CssSize,
  height? : CssSize,

  // Layout & Positioning
  position? : CssPosition,
  top? : CssSize,
  right? : CssSize,
  bottom? : CssSize,
  left? : CssSize,
  float? : String,
  clear? : String,
  overflow? : CssOverflow,
  z_index? : Int,
  flex? : Float,
  flex_direction? : CssFlexDirection,
  justify_content? : CssFlexJustifyContent,
  align_items? : CssFlexAlignItems,
  align_content? : CssFlexAlignContent,
  order? : Int,

  // Text Styling
  text_decoration? : CssTextDecoration,
  text_transform? : String,
  line_height? : CssLineHeight,
  letter_spacing? : String,
  white_space? : String,
  word_break? : CssWordBreak,

  // Visual Effects
  opacity? : Int,
  visibility? : String,
  box_shadow? : String,
  transition? : String,
  box_sizing? : CssBoxSizing,

  // more
  border_radius? : Float,
  padding_top? : CssSize,
  padding_bottom? : CssSize,
  padding_left? : CssSize,
  padding_right? : CssSize,
  min_width? : CssSize,
  max_width? : CssSize,
  vertical_align? : CssVerticalAlign,
  border_style? : CssBorderStyle,
  border_color? : CssColor,
  border_width? : CssSize,
  cursor? : CssCursor,
  transition_duration? : CssDuration,
  transform? : CssTransform,
  outline? : CssOutline,
  user_select? : CssUserSelect,
  margin_top? : CssSize,
  margin_bottom? : CssSize,
  margin_left? : CssSize,
  margin_right? : CssSize,
  max_height? : CssSize,
  transform_property? : Array[String],
  gap? : CssSize,
  content? : String,
  content_visibility? : CssContentVisibility,
  filter? : CssFilter,
  object_fit? : CssObjectFit,
  overscroll_behavior_x? : CssOverscrollBehavior,
  overscroll_behavior_y? : CssOverscrollBehavior
) -> RespoStyle {
  let style : Array[(String, String)] = []
  match color {
    Some(value) => style.push(("color", value.to_string()))
    None => ()
  }
  match background_color {
    Some(value) => style.push(("background-color", value.to_string()))
    None => ()
  }
  match font_size {
    Some(value) => style.push(("font-size", value.to_string() + "px"))
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
    Some(value) => style.push(("text-align", value.to_string()))
    None => ()
  }
  match display {
    Some(value) => style.push(("display", value.to_string()))
    None => ()
  }
  match margin {
    Some(value) => style.push(("margin", value.to_string()))
    None => ()
  }
  match padding {
    Some(value) => style.push(("padding", value.to_string()))
    None => ()
  }
  match border {
    Some(value) => style.push(("border", value.to_string()))
    None => ()
  }
  match width {
    Some(value) => style.push(("width", value.to_string()))
    None => ()
  }
  match height {
    Some(value) => style.push(("height", value.to_string()))
    None => ()
  }
  match position {
    Some(value) => style.push(("position", value.to_string()))
    None => ()
  }
  match top {
    Some(value) => style.push(("top", value.to_string()))
    None => ()
  }
  match right {
    Some(value) => style.push(("right", value.to_string()))
    None => ()
  }
  match bottom {
    Some(value) => style.push(("bottom", value.to_string()))
    None => ()
  }
  match left {
    Some(value) => style.push(("left", value.to_string()))
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
    Some(value) => style.push(("overflow", value.to_string()))
    None => ()
  }
  match z_index {
    Some(value) => style.push(("z-index", value.to_string()))
    None => ()
  }
  match flex {
    Some(value) => style.push(("flex", value.to_string()))
    None => ()
  }
  match flex_direction {
    Some(value) => style.push(("flex-direction", value.to_string()))
    None => ()
  }
  match justify_content {
    Some(value) => style.push(("justify-content", value.to_string()))
    None => ()
  }
  match align_items {
    Some(value) => style.push(("align-items", value.to_string()))
    None => ()
  }
  match align_content {
    Some(value) => style.push(("align-content", value.to_string()))
    None => ()
  }
  match order {
    Some(value) => style.push(("order", value.to_string()))
    None => ()
  }
  match text_decoration {
    Some(value) => style.push(("text-decoration", value.to_string()))
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
    Some(value) => style.push(("word-break", value.to_string()))
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
  match border_radius {
    Some(value) => style.push(("border-radius", value.to_string() + "px"))
    None => ()
  }
  match padding_top {
    Some(value) => style.push(("padding-top", value.to_string()))
    None => ()
  }
  match padding_bottom {
    Some(value) => style.push(("padding-bottom", value.to_string()))
    None => ()
  }
  match padding_left {
    Some(value) => style.push(("padding-left", value.to_string()))
    None => ()
  }
  match padding_right {
    Some(value) => style.push(("padding-right", value.to_string()))
    None => ()
  }
  match max_width {
    Some(value) => style.push(("max-width", value.to_string()))
    None => ()
  }
  match min_width {
    Some(value) => style.push(("min-width", value.to_string()))
    None => ()
  }
  match vertical_align {
    Some(value) => style.push(("vertical-align", value.to_string()))
    None => ()
  }
  match border_color {
    Some(value) => style.push(("border-color", value.to_string()))
    None => ()
  }
  match border_width {
    Some(value) => style.push(("border-width", value.to_string()))
    None => ()
  }
  match border_style {
    Some(value) => style.push(("border-style", value.to_string()))
    None => ()
  }
  match cursor {
    Some(value) => style.push(("cursor", value.to_string()))
    None => ()
  }
  match transition_duration {
    Some(value) => style.push(("transition-duration", value.to_string()))
    None => ()
  }
  match transform {
    Some(value) => style.push(("transform", value.to_string()))
    None => ()
  }
  match outline {
    Some(value) => style.push(("outline", value.to_string()))
    None => ()
  }
  match user_select {
    Some(value) => style.push(("user-select", value.to_string()))
    None => ()
  }
  match margin_top {
    Some(value) => style.push(("margin-top", value.to_string()))
    None => ()
  }
  match margin_bottom {
    Some(value) => style.push(("margin-bottom", value.to_string()))
    None => ()
  }
  match margin_left {
    Some(value) => style.push(("margin-left", value.to_string()))
    None => ()
  }
  match margin_right {
    Some(value) => style.push(("margin-right", value.to_string()))
    None => ()
  }
  match max_height {
    Some(value) => style.push(("max-height", value.to_string()))
    None => ()
  }
  match transform_property {
    Some(xs) => {
      let value = String::concat(xs, separator=",")
      style.push(("transform-property", value))
    }
    None => ()
  }
  match gap {
    Some(value) => style.push(("gap", value.to_string()))
    None => ()
  }
  match content {
    Some(value) => style.push(("content", value))
    None => ()
  }
  match content_visibility {
    Some(value) => style.push(("content-visibility", value.to_string()))
    None => ()
  }
  match filter {
    Some(value) => style.push(("filter", value.to_string()))
    None => ()
  }
  match object_fit {
    Some(value) => style.push(("object-fit", value.to_string()))
    None => ()
  }
  match overscroll_behavior_x {
    Some(value) => style.push(("overscroll-behavior-x", value.to_string()))
    None => ()
  }
  match overscroll_behavior_y {
    Some(value) => style.push(("overscroll-behavior-y", value.to_string()))
    None => ()
  }
  RespoStyle(style)
}

///|
pub(all) enum CssOutline {
  None
  Outline(CssSize, CssBorderStyle, CssColor)
} derive(Eq)

///|
pub fn CssOutline::to_string(self : CssOutline) -> String {
  match self {
    None => "none"
    Outline(width, style, color) =>
      str_spaced([width.to_string(), style.to_string(), color.to_string()])
  }
}

///|
pub(all) enum CssDuration {
  Ms(Int)
  S(Float)
}

///|
pub fn CssDuration::to_string(self : CssDuration) -> String {
  match self {
    Ms(value) => "\{value}ms"
    S(value) => "\{value}s"
  }
}

///|
pub(all) enum CssUserSelect {
  None
  Text
  All
  Auto
}

///|
pub fn CssUserSelect::to_string(self : CssUserSelect) -> String {
  match self {
    None => "none"
    Text => "text"
    All => "all"
    Auto => "auto"
  }
}

///|
pub(all) enum CssPosition {
  Static
  Relative
  Absolute
  Fixed
  Sticky
} derive(Eq)

///|
pub fn CssPosition::to_string(self : CssPosition) -> String {
  match self {
    Static => "static"
    Relative => "relative"
    Absolute => "absolute"
    Fixed => "fixed"
    Sticky => "sticky"
  }
}

///|
pub(all) enum CssColor {
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
  RawString(String)
  Transparent
} derive(Eq)

///|
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
    RawString(value) => value
    Transparent => "transparent"
  }
}

///|
impl Show for CssColor with output(self, logger) {
  logger.write_string(CssColor::to_string(self))
}

///|
pub(all) enum CssLineHeight {
  Em(Float)
  Px(Float)
  Percent(Float)
  Normal
} derive(Eq)

///|
pub fn CssLineHeight::to_string(self : CssLineHeight) -> String {
  match self {
    Em(value) => "\{value}em"
    Px(value) => "\{value}px"
    Percent(value) => "\{value}%"
    Normal => "normal"
  }
}

///|
pub(all) enum CssWordBreak {
  Normal
  BreakAll
  KeepAll
  BreakWord
}

///|
pub fn CssWordBreak::to_string(self : CssWordBreak) -> String {
  match self {
    Normal => "normal"
    BreakAll => "break-all"
    KeepAll => "keep-all"
    BreakWord => "break-word"
  }
}

///|
pub(all) enum CssDisplay {
  Block
  Inline
  InlineBlock
  Flex
  InlineFlex
  Grid
  InlineGrid
  None
} derive(Eq)

///|
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

///|
pub(all) enum CssFlexWrap {
  Wrap
  Nowrap
  WrapReverse
} derive(Eq)

///|
pub fn CssFlexWrap::to_string(self : CssFlexWrap) -> String {
  match self {
    Wrap => "wrap"
    Nowrap => "nowrap"
    WrapReverse => "wrap-reverse"
  }
}

///|
pub(all) enum CssFlexDirection {
  Row
  RowReverse
  Column
  ColumnReverse
} derive(Eq)

///|
pub fn CssFlexDirection::to_string(self : CssFlexDirection) -> String {
  match self {
    Row => "row"
    RowReverse => "row-reverse"
    Column => "column"
    ColumnReverse => "column-reverse"
  }
}

///|
pub(all) enum CssVerticalAlign {
  Top
  Middle
  Bottom
}

///|
pub fn CssVerticalAlign::to_string(self : CssVerticalAlign) -> String {
  match self {
    Top => "top"
    Middle => "middle"
    Bottom => "bottom"
  }
}

///|
pub(all) enum CssFlexJustifyContent {
  FlexStart
  FlexEnd
  Center
  SpaceBetween
  SpaceAround
  SpaceEvenly
} derive(Eq)

///|
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

///|
pub(all) enum CssFlexAlignItems {
  FlexStart
  FlexEnd
  Center
  Baseline
  Stretch
} derive(Eq)

///|
pub fn CssFlexAlignItems::to_string(self : CssFlexAlignItems) -> String {
  match self {
    FlexStart => "flex-start"
    FlexEnd => "flex-end"
    Center => "center"
    Baseline => "baseline"
    Stretch => "stretch"
  }
}

///|
pub(all) enum CssFlexAlignContent {
  FlexStart
  FlexEnd
  Center
  SpaceBetween
  SpaceAround
  Stretch
} derive(Eq)

///|
pub fn CssFlexAlignContent::to_string(self : CssFlexAlignContent) -> String {
  match self {
    FlexStart => "flex-start"
    FlexEnd => "flex-end"
    Center => "center"
    SpaceBetween => "space-between"
    SpaceAround => "space-around"
    Stretch => "stretch"
  }
}

///|
pub(all) enum CssBorderStyle {
  Solid
  Dashed
  Dotted
} derive(Eq)

///|
pub fn CssBorderStyle::to_string(self : CssBorderStyle) -> String {
  match self {
    Solid => "solid"
    Dashed => "dashed"
    Dotted => "dotted"
  }
}

///|
pub(all) type CssBorder (Float, CssBorderStyle, CssColor)

///|
pub fn CssBorder::to_string(self : CssBorder) -> String {
  let (width, style, color) = self._
  str_spaced([width.to_string() + "px " + style.to_string(), color.to_string()])
}

///|
pub fn CssBorder::new(
  width~ : Float = 1.0,
  style~ : CssBorderStyle = Solid,
  color~ : CssColor = Black
) -> CssBorder {
  (width, style, color)
}

///|
pub(all) enum CssBackgroundSize {
  Cover
  Contain
  Wh(UInt, UInt)
} derive(Eq)

///|
pub fn CssBackgroundSize::to_string(self : CssBackgroundSize) -> String {
  match self {
    Cover => "cover"
    Contain => "contain"
    Wh(w, h) => "\{w}px \{h}px"
  }
}

///|
pub(all) enum CssOverflow {
  Visible
  Hidden
  Scroll
  Auto
} derive(Eq)

///|
pub fn CssOverflow::to_string(self : CssOverflow) -> String {
  match self {
    Visible => "visible"
    Hidden => "hidden"
    Scroll => "scroll"
    Auto => "auto"
  }
}

///|
pub(all) enum CssTransform {
  Translate(Int, Int)
  TranslateX(Int)
  TranslateY(Int)
  Scale(Float)
  Rotate(Int)
  Skew(Int, Int)
  Matrix(Float, Float, Float, Float, Float, Float)
} derive(Eq)

///|
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

///|
pub(all) enum CssTimingFunction {
  Ease
  Linear
  EaseIn
  EaseOut
  EaseInOut
  StepStart
  StepEnd
} derive(Eq)

///|
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

///|
pub(all) enum CssTextOverflow {
  Clip
  Ellipsis
} derive(Eq)

///|
pub fn CssTextOverflow::to_string(self : CssTextOverflow) -> String {
  match self {
    Clip => "clip"
    Ellipsis => "ellipsis"
  }
}

///|
pub(all) enum CssBoxSizing {
  BorderBox
  ContentBox
} derive(Eq)

///|
pub fn CssBoxSizing::to_string(self : CssBoxSizing) -> String {
  match self {
    BorderBox => "border-box"
    ContentBox => "content-box"
  }
}

///|
pub(all) enum CssTextAlign {
  Left
  Right
  Center
  Justify
} derive(Eq)

///|
pub fn CssTextAlign::to_string(self : CssTextAlign) -> String {
  match self {
    Left => "left"
    Right => "right"
    Center => "center"
    Justify => "justify"
  }
}

///|
pub(all) enum CssFontWeight {
  Normal
  Bold
  Bolder
  Lighter
  Weight(Int)
} derive(Eq)

///|
pub fn CssFontWeight::to_string(self : CssFontWeight) -> String {
  match self {
    Normal => "normal"
    Bold => "bold"
    Bolder => "bolder"
    Lighter => "lighter"
    Weight(value) => "\{value}"
  }
}

///|
pub(all) enum CssTextDecoration {
  None
  Underline
  Overline
  LineThrough
} derive(Eq)

///|
pub fn CssTextDecoration::to_string(self : CssTextDecoration) -> String {
  match self {
    None => "none"
    Underline => "underline"
    Overline => "overline"
    LineThrough => "line-through"
  }
}

///|
pub(all) enum CssCursor {
  Auto
  Default
  None
  Pointer
  ContextMenu
  Help
  Progress
  Wait
  Cell
  Crosshair
  Text
  VerticalText
  Alias
  Copy
  Move
  NoDrop
  NotAllowed
  Grab
  Grabbing
  AllScroll
  ColResize
  RowResize
  NResize
  EResize
  SResize
  WResize
  NeResize
  NwResize
  SeResize
  SwResize
  EwResize
  NsResize
  NeswResize
  NwseResize
  ZoomIn
  ZoomOut
} derive(Eq)

///|
pub fn CssCursor::to_string(self : CssCursor) -> String {
  match self {
    Auto => "auto"
    Default => "default"
    None => "none"
    Pointer => "pointer"
    ContextMenu => "context-menu"
    Help => "help"
    Progress => "progress"
    Wait => "wait"
    Cell => "cell"
    Crosshair => "crosshair"
    Text => "text"
    VerticalText => "vertical-text"
    Alias => "alias"
    Copy => "copy"
    Move => "move"
    NoDrop => "no-drop"
    NotAllowed => "not-allowed"
    Grab => "grab"
    Grabbing => "grabbing"
    AllScroll => "all-scroll"
    ColResize => "col-resize"
    RowResize => "row-resize"
    NResize => "n-resize"
    EResize => "e-resize"
    SResize => "s-resize"
    WResize => "w-resize"
    NeResize => "ne-resize"
    NwResize => "nw-resize"
    SeResize => "se-resize"
    SwResize => "sw-resize"
    EwResize => "ew-resize"
    NsResize => "ns-resize"
    NeswResize => "nesw-resize"
    NwseResize => "nwse-resize"
    ZoomIn => "zoom-in"
    ZoomOut => "zoom-out"
  }
}

///|
pub(all) enum CssContentVisibility {
  Visible
  Hidden
  Auto
} derive(Eq)

///|
pub fn CssContentVisibility::to_string(self : CssContentVisibility) -> String {
  match self {
    Visible => "visible"
    Hidden => "hidden"
    Auto => "auto"
  }
}

///| https://developer.mozilla.org/en-US/docs/Web/CSS/filter
pub(all) enum CssFilter {
  None
  Blur(Float)
  Brightness(Float)
  Contrast(Float)
  Grayscale(Float)
  HueRotate(Float)
  Invert(Float)
  Opacity(Float)
  Saturate(Float)
  Sepia(Float)
  DropShadow(Float, Float, Float, CssColor)
  Url(String)
  Revert
  RevertLayer
}

///|
pub fn CssFilter::to_string(self : CssFilter) -> String {
  match self {
    None => "none"
    Blur(value) => "blur(\{value}px)"
    Brightness(value) => "brightness(\{value})"
    Contrast(value) => "contrast(\{value})"
    Grayscale(value) => "grayscale(\{value})"
    HueRotate(value) => "hue-rotate(\{value}deg)"
    Invert(value) => "invert(\{value})"
    Opacity(value) => "opacity(\{value})"
    Saturate(value) => "saturate(\{value})"
    Sepia(value) => "sepia(\{value})"
    DropShadow(x, y, blur, color) =>
      "drop-shadow(\{x}px \{y}px \{blur}px \{color})"
    Url(value) => "url(\{value})"
    Revert => "revert"
    RevertLayer => "revert-layer"
  }
}

///|
pub(all) enum CssObjectFit {
  Fill
  Contain
  Cover
  None
  ScaleDown
} derive(Eq)

///|
pub fn CssObjectFit::to_string(self : CssObjectFit) -> String {
  match self {
    Fill => "fill"
    Contain => "contain"
    Cover => "cover"
    None => "none"
    ScaleDown => "scale-down"
  }
}

///|
pub(all) enum CssOverscrollBehavior {
  Auto
  Contain
  None
}

///|
pub fn CssOverscrollBehavior::to_string(self : CssOverscrollBehavior) -> String {
  match self {
    Auto => "auto"
    Contain => "contain"
    None => "none"
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

///|
let class_name_in_tags : @hashset.T[String] = @hashset.new()

///| Declare a static style in the head of the documentm for example
/// ```moonbit
/// let style_demo : String = declare_static_style(
///  [("&", respo_style(margin=Px(4), background_color=Hsl(200, 90, 96)))],
/// )
/// ```
pub fn declare_static_style[U : Show](
  rules : Array[(U, RespoStyle)],
  loc~ : SourceLoc = _
) -> String {
  // @dom_ffi.warn_log("SourceLoc" + loc.to_string())
  let gen_name = loc
    .to_string()
    .split("/src/") // assumed code in src/
    .last()
    .unwrap()
    .replace_all(old="/", new="_")
    .replace_all(old=".mbt", new="_")
    .replace_all(old=":", new="_")
    .replace_all(old=".", new="_")
  if class_name_in_tags.contains(gen_name) {
    gen_name
  } else {
    let window = @dom_ffi.window()
    let document = window.document()
    let head = document.head()
    let style_tag = document.create_element("style")
    style_tag.set_attribute("id", gen_name)
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
    class_name_in_tags.add(gen_name)
    gen_name
  }
}

///| Declare a static style in the head of the documentm for example
/// ```moonbit
/// let style_demo : String = declare_contained_style(
///  [(Some("@media only screen and (max-width: 600px)"), "&", respo_style(margin=Px(4), background_color=Hsl(200, 90, 96)))],
/// )
/// ```
pub fn declare_contained_style[U : Show](
  rules : Array[(String?, U, RespoStyle)],
  loc~ : SourceLoc = _
) -> String {
  // @dom_ffi.warn_log("SourceLoc" + loc.to_string())
  let gen_name = loc
    .to_string()
    .split("/src/") // assumed code in src/
    .last()
    .unwrap()
    .replace_all(old="/", new="_")
    .replace_all(old=".mbt", new="_")
    .replace_all(old=":", new="_")
    .replace_all(old=".", new="_")
  if class_name_in_tags.contains(gen_name) {
    gen_name
  } else {
    let window = @dom_ffi.window()
    let document = window.document()
    let head = document.head()
    let style_tag = document.create_element("style")
    style_tag.set_attribute("id", gen_name)
    style_tag.set_attribute("loc", loc.to_string())
    let mut styles = ""
    for pair in rules {
      let (container, query, properties) = pair
      styles = styles +
        query
        .to_string()
        .replace(old="$0", new="." + gen_name)
        .replace(old="&", new="." + gen_name)
      styles = styles + " {\n"
      styles = styles + properties.to_string()
      styles = styles + "}\n"
      if not(container.is_empty()) {
        styles = container.unwrap() + " {\n" + styles + "}\n"
      }
    }
    style_tag.set_inner_html(styles)
    head.reinterpret_as_node().append_child(style_tag.reinterpret_as_node())
    class_name_in_tags.add(gen_name)
    gen_name
  }
}
