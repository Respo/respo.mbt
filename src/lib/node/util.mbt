// compare hashset
fn hashset_eq[T : Eq + Hash](xs : @hashset.T[T], ys : @hashset.T[T]) -> Bool {
  if xs.size() != ys.size() {
    return false
  }
  for x in xs {
    if not(ys.contains(x)) {
      return false
    }
  }
  true
}

pub fn raf_loop(f : (Float) -> Unit!RespoCommonError) -> Unit {
  let win = @dom_ffi.window()
  let cb = Ref::new(
    fn(_t : Float) -> Unit {
      // placeholder

    },
  )
  cb.val = fn(t : Float) -> Unit {
    let ret = f?(t)
    match ret {
      Ok(_) => win.request_animation_frame(cb.val)
      Err(e) => @dom_ffi.error_log(e.to_string())
    }
  }
  win.request_animation_frame(cb.val)
}

/// convert a list of strings to a single string with spaces between them,
/// mainly used for concatenating class names
pub fn str_spaced(wrap_parens~ : Bool = false, s : Array[String]) -> String {
  let mut ret = ""
  for idx, piece in s.iter2() {
    if idx > 0 {
      ret = ret + " "
    }
    ret = ret + piece
  }
  if wrap_parens {
    ret = "(" + ret + ")"
  }
  ret
}
