///|
/// Global events that can be listened to by components
enum GlobalEvent {
  Placeholder // Default placeholder
  KeyPress(String) // Keyboard key press with key name
} derive(Default, Show, Eq)

///|
/// Store is immutable, use record update syntax to create new store
struct Store {
  counted : Int
  tasks : @immut/array.T[Task]
  states : RespoStatesTree
} derive(Eq)

///|
impl Default for Store with default() -> Store {
  { counted: 0, tasks: @immut/array.new(), states: RespoStatesTree::default() }
}

///|
impl ToJson for Store with to_json(self) {
  {
    "counted": self.counted.to_json(),
    "tasks": self.tasks.to_array().to_json(),
    "states": self.states.to_json(),
  }
}

///|
impl @json.FromJson for Store with from_json(json, path) {
  let obj = match json {
    Object(obj) => obj
    _ => raise @json.JsonDecodeError((path, "expected object"))
  }
  let counted : Int = match obj.get("counted") {
    Some(v) => @json.from_json(v, path~)
    None => raise @json.JsonDecodeError((path, "missing counted"))
  }
  let tasks_arr : Array[Task] = match obj.get("tasks") {
    Some(v) => @json.from_json(v, path~)
    None => raise @json.JsonDecodeError((path, "missing tasks"))
  }
  let states : RespoStatesTree = match obj.get("states") {
    Some(v) => @json.from_json(v, path~)
    None => raise @json.JsonDecodeError((path, "missing states"))
  }
  { counted, tasks: @immut/array.from_array(tasks_arr), states }
}

///|
/// Task is immutable, use record update syntax to create new task
struct Task {
  id : String
  done : Bool
  content : String
  time : Double
} derive(Default, Eq, Hash, ToJson, FromJson)

// enum IndentOp {
//   Noop
//   IncTwice
// }

///|
enum ActionOp {
  Noop
  StatesChange(@respo.RespoUpdateState)
  // Intent(IndentOp)
  Increment
  Decrement
  IncTwice
  AddTask(String, String)
  RemoveTask(String)
  UpdateTask(String, String)
  ToggleTask(String)
  ResetShortcutDemo // Reset shortcut demo state
} derive(Eq, ToJson)

///|
impl Default for ActionOp with default() -> ActionOp {
  Noop
}

///|
impl @respo_node.RespoAction for ActionOp with build_states_action(cursor, a, j) {
  StatesChange({
    cursor,
    data: if a is Some(a) {
      Some(@dom_ffi.js_obscure_to_v(a))
    } else {
      None
    },
    backup: j,
  })
}

///|
impl Show for ActionOp with output(self, logger) {
  let ret = match self {
    Noop => "Noop"
    StatesChange(state) =>
      "StatesChange(cursor: \{state.cursor}, backup: \{state.backup.to_json()})"
    // Intent(intent) => "Intent(...)"
    Increment => "Increment"
    Decrement => "Decrement"
    IncTwice => "IncTwice"
    AddTask(id, content) => "AddTask(" + id + ", " + content + ")"
    RemoveTask(id) => "RemoveTask(" + id + ")"
    UpdateTask(id, content) => "UpdateTask(" + id + ", " + content + ")"
    ToggleTask(id) => "ToggleTask(" + id + ")"
    ResetShortcutDemo => "ResetShortcutDemo"
  }
  logger.write_string(ret)
}

///|
fn Store::get_states(self : Store) -> @respo.RespoStatesTree {
  self.states
}

///|
/// Immutable update: returns a new Store with the action applied
fn Store::update(self : Store, op : ActionOp) -> Store {
  match op {
    Increment => { ..self, counted: self.counted + 1 }
    Decrement => { ..self, counted: self.counted - 1 }
    StatesChange(change) => { ..self, states: self.states.set_in(change) }
    AddTask(id, content) => {
      let task : Task = {
        id,
        done: false,
        content,
        time: @dom_ffi.window().performance().now().to_double(),
      }
      // Immutable push returns new array
      { ..self, tasks: self.tasks.push(task) }
    }
    RemoveTask(id) => {
      // Use iter + filter + from_iter for immutable filtering
      let new_tasks = @immut/array.from_iter(
        self.tasks.iter().filter(fn(task) { task.id != id }),
      )
      { ..self, tasks: new_tasks }
    }
    UpdateTask(id, content) => {
      let new_tasks = self.tasks.map(fn(task) {
        if task.id == id {
          { ..task, content, }
        } else {
          task
        }
      })
      { ..self, tasks: new_tasks }
    }
    ToggleTask(id) => {
      let new_tasks = self.tasks.map(fn(task) {
        if task.id == id {
          { ..task, done: not(task.done) }
        } else {
          task
        }
      })
      { ..self, tasks: new_tasks }
    }
    IncTwice => { ..self, counted: self.counted + 2 }
    Noop => self
    ResetShortcutDemo => self // No-op, handled by component state
  }
}
