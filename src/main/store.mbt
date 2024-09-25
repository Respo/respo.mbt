pub struct Store {
  mut counted : Int
  mut tasks : Array[Task]
  mut states : @respo.RespoStatesTree
} derive(ToJson, @json.FromJson)

pub fn Store::default() -> Store {
  { counted: 0, tasks: [], states: @respo.RespoStatesTree::default() }
}

pub struct Task {
  id : String
  mut done : Bool
  mut content : String
  mut time : Double
} derive(Default, Eq, Hash, ToJson, @json.FromJson)

pub enum IndentOp {
  Noop
  IncTwice
}

pub enum ActionOp {
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

fn states_action(
  _self : ActionOp,
  states : @respo.RespoUpdateState
) -> ActionOp {
  ActionOp::StatesChange(states)
}

fn get_states(self : Store) -> @respo.RespoStatesTree {
  self.states
}

/// TODO mutation might break memoization infuture
fn updates(self : Store, op : ActionOp) -> Unit!@respo_node.RespoCommonError {
  match op {
    ActionOp::Increment => self.counted += 1
    ActionOp::Decrement => self.counted -= 1
    ActionOp::AddTask(id, content) => {
      let task = {
        id,
        done: false,
        content,
        time: @web_sys.window().performance().now().to_double(),
      }
      self.tasks.push(task)
    }
    ActionOp::RemoveTask(id) =>
      self.tasks = self.tasks.filter(fn(task) { task.id != id })
    ActionOp::UpdateTask(id, content) =>
      self.tasks.each(fn(task) { if task.id == id { task.content = content } })
    ActionOp::ToggleTask(id) =>
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
