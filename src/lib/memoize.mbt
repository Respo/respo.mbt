//! Memoization utilities. based on work of [@hackwaly](https://taolun.moonbitlang.com/t/topic/958/2)

///|
pub fn memoize1[K : Hash + Eq, V](f : (K) -> V) -> (K) -> V {
  let map = @hashmap.new()
  fn(k : K) -> V {
    match map.get(k) {
      Some(v) => v
      None => {
        let v = f(k)
        map[k] = v
        v
      }
    }
  }
}

///|
pub fn memoize2[K1 : Hash + Eq, K2 : Hash + Eq, V](
  f : (K1, K2) -> V
) -> (K1, K2) -> V {
  let map = @hashmap.new()
  fn(k1 : K1, k2 : K2) -> V {
    match map.get((k1, k2)) {
      Some(v) => v
      None => {
        let v = f(k1, k2)
        map[(k1, k2)] = v
        v
      }
    }
  }
}

///|
pub fn memoize3[K1 : Hash + Eq, K2 : Hash + Eq, K3 : Hash + Eq, V](
  f : (K1, K2, K3) -> V
) -> (K1, K2, K3) -> V {
  let map = @hashmap.new()
  fn(k1 : K1, k2 : K2, k3 : K3) -> V {
    match map.get((k1, k2, k3)) {
      Some(v) => v
      None => {
        let v = f(k1, k2, k3)
        map[(k1, k2, k3)] = v
        v
      }
    }
  }
}

///|
pub fn memoize4[K1 : Hash + Eq, K2 : Hash + Eq, K3 : Hash + Eq, K4 : Hash + Eq, V](
  f : (K1, K2, K3, K4) -> V
) -> (K1, K2, K3, K4) -> V {
  let map = @hashmap.new()
  fn(k1 : K1, k2 : K2, k3 : K3, k4 : K4) -> V {
    match map.get((k1, k2, k3, k4)) {
      Some(v) => v
      None => {
        let v = f(k1, k2, k3, k4)
        map[(k1, k2, k3, k4)] = v
        v
      }
    }
  }
}

///|
pub fn memoize5[K1 : Hash + Eq, K2 : Hash + Eq, K3 : Hash + Eq, K4 : Hash + Eq, K5 : Hash + Eq, V](
  f : (K1, K2, K3, K4, K5) -> V
) -> (K1, K2, K3, K4, K5) -> V {
  let map = @hashmap.new()
  fn(k1 : K1, k2 : K2, k3 : K3, k4 : K4, k5 : K5) -> V {
    match map.get((k1, k2, k3, k4, k5)) {
      Some(v) => v
      None => {
        let v = f(k1, k2, k3, k4, k5)
        map[(k1, k2, k3, k4, k5)] = v
        v
      }
    }
  }
}
