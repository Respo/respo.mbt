///|
struct Store {
  mut counted : Int
  mut tasks : Array[Task]
  states : RespoStatesTree
} derive(ToJson, FromJson)

///|
impl Default for Store with default() -> Store {
  { counted: 0, tasks: [], states: RespoStatesTree::default() }
}

///|
struct Task {
  id : String
  mut done : Bool
  mut content : String
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
  }
  logger.write_string(ret)
}

///|
fn get_states(self : Store) -> @respo.RespoStatesTree {
  self.states
}

///|
/// TODO mutation might break memoization infuture
fn update(self : Store, op : ActionOp) -> Unit {
  match op {
    Increment => self.counted += 1
    StatesChange(change) => self.states.set_in_mut(change)
    Decrement => self.counted -= 1
    AddTask(id, content) => {
      let task = {
        id,
        done: false,
        content,
        time: @dom_ffi.window().performance().now().to_double(),
      }
      self.tasks.push(task)
    }
    RemoveTask(id) => self.tasks = self.tasks.filter(fn(task) { task.id != id })
    UpdateTask(id, content) =>
      self.tasks.each(fn(task) { if task.id == id { task.content = content } })
    ToggleTask(id) =>
      // self.tasks = self.tasks.map(|task| {
      //   if task.id == id {
      //     Task {
      //       done: !task.done,
      //       ..task
      //     }
      //   } else {
      //     task
      //   }
      // })
      self.tasks.each(task => if task.id == id { task.done = not(task.done) })
    _ => ()
  }
}
