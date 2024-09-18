/// compare hashmap
fn hashmap_eq[T : Eq, K : Eq + Hash](
  xs : @hashmap.T[K, T],
  ys : @hashmap.T[K, T]
) -> Bool {
  if xs.size() != ys.size() {
    return false
  }
  for pair in xs {
    let (k, v) = pair
    match ys.get(k) {
      Some(y) => if v != y { return false }
      None => return false
    }
  }
  true
}

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
  let win = @web_sys.window()
  let cb = Ref::new(fn(t: Float) -> Unit {
    // placeholder
  })
  cb.val = fn(t: Float) -> Unit {
    let ret = f?(t)
    match ret {
      Ok(_) => win.request_animation_frame(cb.val)
      Err(e) => @web_sys.error_log(e.to_string())
    }
  }
}