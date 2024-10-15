struct Store {
  mut counted : Int
  mut tasks : Array[Task]
  states : @respo.RespoStatesTree
} derive(ToJson, @json.FromJson)

fn Store::default() -> Store {
  { counted: 0, tasks: [], states: @respo.RespoStatesTree::default() }
}

struct Task {
  id : String
  mut done : Bool
  mut content : String
  time : Double
} derive(Default, Eq, Hash, ToJson, @json.FromJson)

enum IndentOp {
  Noop
  IncTwice
}

enum ActionOp {
  Noop
  StatesChange(@respo.RespoUpdateState)
  Intent(IndentOp)
  Increment
  Decrement
  IncTwice
  AddTask(String, String)
  RemoveTask(String)
  UpdateTask(String, String)
  ToggleTask(String)
}

fn ActionOp::default() -> ActionOp {
  Noop
}

impl @respo_node.RespoAction for ActionOp with build_states_action(cursor, a) {
  StatesChange({ cursor, data: a })
}

fn ActionOp::to_string(self : ActionOp) -> String {
  match self {
    Noop => "Noop"
    StatesChange(states) =>
      "StatesChange(\{states.cursor}  \{states.data.to_json()})"
    Intent(intent) => "Intent(...)"
    Increment => "Increment"
    Decrement => "Decrement"
    IncTwice => "IncTwice"
    AddTask(id, content) => "AddTask(" + id + ", " + content + ")"
    RemoveTask(id) => "RemoveTask(" + id + ")"
    UpdateTask(id, content) => "UpdateTask(" + id + ", " + content + ")"
    ToggleTask(id) => "ToggleTask(" + id + ")"
  }
}

fn get_states(self : Store) -> @respo.RespoStatesTree {
  self.states
}

/// TODO mutation might break memoization infuture
fn update(self : Store, op : ActionOp) -> Unit {
  match op {
    Increment => self.counted += 1
    StatesChange(states) => self.states.set_in_mut(states)
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
      self.tasks.each(
        fn(task) { if task.id == id { task.done = task.done.not() } },
      )
    _ => ()
  }
}
