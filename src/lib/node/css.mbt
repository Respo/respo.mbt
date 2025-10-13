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
let class_name_in_tags : @hashset.HashSet[String] = @hashset.new()

///|
/// use `static_style` instead
#callsite(autofill(loc))
#deprecated
pub fn[U : Show] declare_static_style(
  rules : Array[(U, RespoStyle)],
  loc~ : SourceLoc,
) -> String {
  static_style(rules, loc~)
}

///|
/// Declare a static style in the head of the documentm for example
/// ```moonbit
/// let style_demo : String = static_style(
///  [("&", respo_style(margin=4 |> Px, background_color=Hsl(200, 90, 96)))],
/// )
/// ```
#callsite(autofill(loc))
pub fn[U : Show] static_style(
  rules : Array[(U, RespoStyle)],
  loc~ : SourceLoc,
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
    .to_string()
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

///|
/// use `contained_static_style` instead
#callsite(autofill(loc))
#deprecated
pub fn[U : Show] declare_contained_style(
  rules : Array[(String?, U, RespoStyle)],
  loc~ : SourceLoc,
) -> String {
  contained_static_style(rules, loc~)
}

///|
/// Declare a static style in the head of the documentm for example
/// ```moonbit
/// let style_demo : String = contained_static_style(
///  [(Some("@media only screen and (max-width: 600px)"), "&", respo_style(margin=4 |> Px, background_color=Hsl(200, 90, 96)))],
/// )
/// ```
#callsite(autofill(loc))
pub fn[U : Show] contained_static_style(
  rules : Array[(String?, U, RespoStyle)],
  loc~ : SourceLoc,
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
    .to_string()
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
      let mut rule_style = query
        .to_string()
        .replace(old="$0", new="." + gen_name)
        .replace(old="&", new="." + gen_name)
      rule_style += " {\n"
      rule_style += properties.to_string()
      rule_style += "}\n"
      if container is Some(container) {
        styles += "\n" + container + " {\n" + rule_style + "}\n"
      } else {
        styles += rule_style
      }
    }
    style_tag.set_inner_html(styles)
    head.reinterpret_as_node().append_child(style_tag.reinterpret_as_node())
    class_name_in_tags.add(gen_name)
    gen_name
  }
}
