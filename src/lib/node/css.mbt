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
