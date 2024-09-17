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
