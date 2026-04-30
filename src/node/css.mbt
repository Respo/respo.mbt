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
/// Generate a CSS class name from a SourceLoc.
/// Preferred format (JSON): `{"pkg":"tiye/respo/main","filename":"task.mbt","start_line":118,...}`
/// -> `tiye_respo_main_task_118`
/// Fallback format (string): `file.mbt:line:col-line:col@namespace/module`
/// -> `tiye_respo_ui_226_34-238_3`
fn gen_class_name_from_loc(loc : SourceLoc) -> String {
  // Try to parse JSON format first
  let json_str = loc.to_json_string()
  let json = try? @json.parse(json_str[:])
  match json {
    Ok(json) => {
      let pkg = if json is Object(obj) { obj.get("pkg") } else { None }
      let filename = if json is Object(obj) {
        obj.get("filename")
      } else {
        None
      }
      let start_line = if json is Object(obj) {
        obj.get("start_line")
      } else {
        None
      }
      match (pkg, filename, start_line) {
        (Some(String(pkg)), Some(String(filename)), Some(Number(start_line, ..))
        ) => {
          let pkg_clean = pkg.replace_all(old="/", new="_")
          let file_clean = filename.replace_all(old=".mbt", new="")
          let line = start_line.to_int().to_string()
          pkg_clean + "_" + file_clean + "_" + line
        }
        _ => gen_class_name_from_loc_fallback(loc)
      }
    }
    Err(_) => gen_class_name_from_loc_fallback(loc)
  }
}

///|
/// Fallback for old SourceLoc format without JSON support.
/// The SourceLoc format is: `file.mbt:line:col-line:col@namespace/module`
/// e.g., `ui.mbt:226:34-238:3@tiye/respo` -> `tiye_respo_ui_226_34-238_3`
fn gen_class_name_from_loc_fallback(loc : SourceLoc) -> String {
  let loc_str = loc.to_string()
  let parts : Array[_] = loc_str.split("@").collect()
  // clean file part: extract after /src/ and replace special chars
  fn clean_file_part(s : StringView) -> String {
    s
    .split("/src/")
    .last()
    .unwrap()
    .replace_all(old="/", new="_")
    .replace_all(old=".mbt", new="_")
    .replace_all(old=":", new="_")
    .replace_all(old=".", new="_")
    .to_owned()
  }

  if parts.length() >= 2 {
    let file_part = parts[0] // e.g., ui.mbt:226:34-238:3
    let ns_part = parts[1] // e.g., tiye/respo
    let ns_clean = ns_part
      .replace_all(old="/", new="_")
      .replace_all(old=".", new="_")
    (ns_clean + "_" + clean_file_part(file_part)).to_owned()
  } else {
    // fallback for old format without namespace
    clean_file_part(loc_str[:])
  }
}

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
/// ```moonbit nocheck
/// let _style_demo : String = static_style([
///   ("&", @css.respo_style(margin=4 |> Px, background_color=Hsl(200, 90, 96))),
/// ])
/// ```
#callsite(autofill(loc))
pub fn[U : Show] static_style(
  rules : Array[(U, RespoStyle)],
  loc~ : SourceLoc,
) -> String {
  // @dom_ffi.warn_log("SourceLoc:" + loc.to_json_string())
  let gen_name = gen_class_name_from_loc(loc)
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
/// ```moonbit nocheck
/// let _style_demo : String = contained_static_style([
///   (
///     Some("@media only screen and (max-width: 600px)"),
///     "&",
///     @css.respo_style(margin=4 |> Px, background_color=Hsl(200, 90, 96)),
///   ),
/// ])
/// ```
#callsite(autofill(loc))
pub fn[U : Show] contained_static_style(
  rules : Array[(String?, U, RespoStyle)],
  loc~ : SourceLoc,
) -> String {
  let gen_name = gen_class_name_from_loc(loc)
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
