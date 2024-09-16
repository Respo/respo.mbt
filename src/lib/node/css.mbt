pub type RespoStyle Array[(String, String)] derive(Eq)

pub fn respo_style() -> RespoStyle {
  []
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

fn is_empty(self : RespoStyle) -> Bool {
  self._.is_empty()
}

fn to_string(self : RespoStyle) -> String {
  let mut result = ""
  for pair in self._ {
    let (property, value) = pair
    result = result + property + ": " + value + ";\n"
  }
  result
}

/// TODO implement methods for RespoStyle
