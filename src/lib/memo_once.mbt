//! Memoization with a single cache slot. This is useful in retained mode GUIs where the cache is not cleared between frames.

///| Memoize a function with a single cache slot, taking one argument.
pub fn[K : Eq, V] memo_once1(f : (K) -> V) -> (K) -> V {
  let mut cache : (K, V)? = None
  fn(k : K) -> V {
    match cache {
      Some(pair) =>
        if pair.0 == k {
          pair.1
        } else {
          let v = f(k)
          cache = Some((k, v))
          v
        }
      None => {
        let v = f(k)
        cache = Some((k, v))
        v
      }
    }
  }
}

///| Memoize a function with a single cache slot, taking two arguments.
pub fn[K1 : Eq, K2 : Eq, V] memo_once2(f : (K1, K2) -> V) -> (K1, K2) -> V {
  let mut cache : ((K1, K2), V)? = None
  fn(k1 : K1, k2 : K2) -> V {
    match cache {
      Some(pair) =>
        if pair.0 == (k1, k2) {
          pair.1
        } else {
          let v = f(k1, k2)
          cache = Some(((k1, k2), v))
          v
        }
      None => {
        let v = f(k1, k2)
        cache = Some(((k1, k2), v))
        v
      }
    }
  }
}

///| Memoize a function with a single cache slot, taking three arguments.
pub fn[K1 : Eq, K2 : Eq, K3 : Eq, V] memo_once3(
  f : (K1, K2, K3) -> V
) -> (K1, K2, K3) -> V {
  let mut cache : ((K1, K2, K3), V)? = None
  fn(k1 : K1, k2 : K2, k3 : K3) -> V {
    match cache {
      Some(pair) =>
        if pair.0 == (k1, k2, k3) {
          pair.1
        } else {
          let v = f(k1, k2, k3)
          cache = Some(((k1, k2, k3), v))
          v
        }
      None => {
        let v = f(k1, k2, k3)
        cache = Some(((k1, k2, k3), v))
        v
      }
    }
  }
}

///| Memoize a function with a single cache slot, taking four arguments.
pub fn[K1 : Eq, K2 : Eq, K3 : Eq, K4 : Eq, V] memo_once4(
  f : (K1, K2, K3, K4) -> V
) -> (K1, K2, K3, K4) -> V {
  let mut cache : ((K1, K2, K3, K4), V)? = None
  fn(k1 : K1, k2 : K2, k3 : K3, k4 : K4) -> V {
    match cache {
      Some(pair) =>
        if pair.0 == (k1, k2, k3, k4) {
          pair.1
        } else {
          let v = f(k1, k2, k3, k4)
          cache = Some(((k1, k2, k3, k4), v))
          v
        }
      None => {
        let v = f(k1, k2, k3, k4)
        cache = Some(((k1, k2, k3, k4), v))
        v
      }
    }
  }
}

///| Memoize a function with a single cache slot, taking five arguments.
pub fn[K1 : Eq, K2 : Eq, K3 : Eq, K4 : Eq, K5 : Eq, V] memo_once5(
  f : (K1, K2, K3, K4, K5) -> V
) -> (K1, K2, K3, K4, K5) -> V {
  let mut cache : ((K1, K2, K3, K4, K5), V)? = None
  fn(k1 : K1, k2 : K2, k3 : K3, k4 : K4, k5 : K5) -> V {
    match cache {
      Some(pair) =>
        if pair.0 == (k1, k2, k3, k4, k5) {
          pair.1
        } else {
          let v = f(k1, k2, k3, k4, k5)
          cache = Some(((k1, k2, k3, k4, k5), v))
          v
        }
      None => {
        let v = f(k1, k2, k3, k4, k5)
        cache = Some(((k1, k2, k3, k4, k5), v))
        v
      }
    }
  }
}
