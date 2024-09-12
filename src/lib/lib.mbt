pub fn js_log1(s : Js_string) -> Unit = "basic" "jslog_1"

pub fn onload() -> Unit {
  js_log1("Hello, world!".to_js_string())
  // js_log1(1000)
}
