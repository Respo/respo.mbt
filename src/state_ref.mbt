///|
/// StateRef wraps a mutable Ref while serializing to an empty JSON object.
/// Use it for ephemeral fields that should not affect persisted snapshots.
pub struct StateRef[T] {
  cell : Ref[T]
}

///|
pub impl[T] Eq for StateRef[T] with equal(_self, _other) {
  return true
}

///|
pub impl[T] Hash for StateRef[T] with hash_combine(_self, hasher) {
  "[Ref]".hash_combine(hasher)
}

///|
pub impl[T : Default] Default for StateRef[T] with default() {
  StateRef::new(T::default())
}

///|
pub fn[T] StateRef::new(value : T) -> StateRef[T] {
  { cell: Ref::new(value) }
}

///|
/// Returns the underlying Ref so callers can mutate the payload directly.
pub fn[T] StateRef::borrow(self : StateRef[T]) -> Ref[T] {
  self.cell
}

///|
pub impl[T] ToJson for StateRef[T] with to_json(_self) {
  let empty_object : Map[String, Json] = {}
  Json::object(empty_object)
}

///|
pub impl[T : Default] @json.FromJson for StateRef[T] with from_json(
  _json,
  _path,
) {
  StateRef::default()
}

///|
/// Show implementation - displays as StateRef(...) to avoid exposing internals
pub impl[T : Show] Show for StateRef[T] with output(self, logger) {
  logger.write_string("StateRef(")
  self.cell.val.output(logger)
  logger.write_string(")")
}

///|
/// Get the current value (read-only)
pub fn[T] StateRef::get(self : StateRef[T]) -> T {
  self.cell.val
}

///|
/// Set a new value
pub fn[T] StateRef::set(self : StateRef[T], value : T) -> Unit {
  self.cell.val = value
}

///|
/// Update the value using a function
pub fn[T] StateRef::update(self : StateRef[T], f : (T) -> T) -> Unit {
  self.cell.val = f(self.cell.val)
}
