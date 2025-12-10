# Agent 使用指南：MoonBit 不可变数据结构

## 快速开始

作为 AI agent，当你需要在 MoonBit 代码中使用不可变数据结构时，这里是你的实用指南。

## 场景驱动的选择指南

### 场景 1: 需要安全地修改数组

**问题**: 用户想要修改数组，但不想影响原始数据
**解决方案**: 使用不可变数组

```moonbit
// ❌ 错误：会修改原数组
let arr = [1, 2, 3, 4, 5]
arr[2] = 10  // 这会修改原数组！

// ✅ 正确：使用不可变数组
let arr = @immut/array.from_array([1, 2, 3, 4, 5])
let new_arr = arr.set(2, 10)  // 返回新数组，原数组不变

// 可以继续链式操作
let final_arr = new_arr.push(6).set(0, 100)
```

### 场景 2: 构建配置映射

**问题**: 用户需要构建一个配置字典，支持增量更新
**解决方案**: 使用不可变哈希映射

```moonbit
// 构建配置
let config = @immut/hashmap.new()
  |> fn(map) { map.add("host", "localhost") }
  |> fn(map) { map.add("port", "8080") }
  |> fn(map) { map.add("debug", "true") }

// 创建新配置（不影响原配置）
let prod_config = config
  |> fn(map) { map.add("debug", "false") }
  |> fn(map) { map.add("host", "prod.example.com") }

// 获取配置值
let host = prod_config.get("host")  // Some("prod.example.com")
```

### 场景 3: 维护唯一元素集合

**问题**: 用户需要维护一个去重的元素集合
**解决方案**: 使用不可变哈希集合

```moonbit
// 构建用户标签集合
let tags = @immut/hashset.from_array(["python", "ml", "data"])

// 添加新标签（返回新集合）
let updated_tags = tags.add("ai").add("backend")

// 检查标签是否存在
if updated_tags.contains("ml") {
  // 处理机器学习相关的逻辑
}

// 合并两个用户的标签
let user1_tags = @immut/hashset.from_array(["python", "ml"])
let user2_tags = @immut/hashset.from_array(["java", "backend"])
let all_tags = user1_tags.union(user2_tags)  // {"python", "ml", "java", "backend"}
```

### 场景 4: 需要有序的数据处理

**问题**: 用户需要保持元素的有序性，支持范围查询
**解决方案**: 使用不可变排序集合或映射

```moonbit
// 维护有序的时间戳集合
let timestamps = @immut/sorted_set.from_array([1623456789, 1623456790, 1623456791])
let updated_timestamps = timestamps.add(1623456792)

// 获取时间范围
let recent = updated_timestamps  // 自动保持排序

// 有序映射：用户ID到用户名的映射
let users = @immut/sorted_map.from_array([
  (1001, "Alice"), (1002, "Bob"), (1003, "Charlie")
])
let updated_users = users.add(1004, "David")

// 获取用户ID范围
let min_id = updated_users.min_key()  // Some(1001)
let max_id = updated_users.max_key()  // Some(1004)
```

### 场景 5: 任务调度和优先级处理

**问题**: 用户需要处理带优先级的任务队列
**解决方案**: 使用不可变优先队列

```moonbit
// 定义任务类型
enum Task {
  High(String)
  Normal(String)
  Low(String)
}

// 构建任务队列
let tasks = @immut/priority_queue.new()
  |> fn(q) { q.push(Normal("发送邮件")) }
  |> fn(q) { q.push(High("修复bug")) }
  |> fn(q) { q.push(Low("清理日志")) }

// 处理最高优先级任务
match tasks.peek() {
  Some(High(task)) => {
    let remaining = tasks.pop()  // 移除已处理的任务
    println("处理高优先级任务: " + task)
  }
  _ => println("没有高优先级任务")
}
```

## Agent 代码生成模板

### 模板 1: 配置管理

```moonbit
// 当用户需要管理配置时，使用这个模板
let build_config = fn() {
  @immut/hashmap.new()
    |> fn(map) { map.add("database_url", env.get("DB_URL") ?: "default") }
    |> fn(map) { map.add("api_key", env.get("API_KEY") ?: "") }
    |> fn(map) { map.add("timeout", "30") }
}

// 更新配置的函数
let update_config = fn(config : @immut/hashmap.HashMap[String, String], key : String, value : String) {
  config.add(key, value)  // 返回新配置
}
```

### 模板 2: 状态管理

```moonbit
// 当用户需要管理应用状态时，使用这个模板
struct AppState {
  users : @immut/hashmap.HashMap[Int, String]
  active_users : @immut/hashset.HashSet[Int]
  message_queue : @immut/array.Array[String]
}

let init_state = fn() {
  {
    users: @immut/hashmap.new(),
    active_users: @immut/hashset.new(),
    message_queue: @immut/array.new()
  }
}

let add_user = fn(state : AppState, user_id : Int, username : String) {
  {
    ..state,
    users: state.users.add(user_id, username),
    active_users: state.active_users.add(user_id)
  }
}
```

### 模板 3: 数据转换管道

```moonbit
// 当用户需要构建数据处理管道时，使用这个模板
let process_data = fn(input : @immut/array.Array[Int]) {
  input
    |> fn(arr) { arr.map(fn(x) { x * 2 }) }  // 假设有map函数
    |> fn(arr) { arr.filter(fn(x) { x > 10 }) }  // 假设有filter函数
    |> fn(arr) { arr.push(999) }
}
```

## 常见问题解决方案

### 问题 1: "如何在不修改原数组的情况下添加元素？"

```moonbit
// Agent 应该生成的代码
let original = @immut/array.from_array([1, 2, 3])
let with_new_element = original.push(4)  // [1, 2, 3, 4]
let with_multiple = with_new_element.push(5).push(6)  // [1, 2, 3, 4, 5, 6]
// original 仍然是 [1, 2, 3]
```

### 问题 2: "如何合并两个映射？"

```moonbit
// Agent 应该生成的代码
let map1 = @immut/hashmap.from_array([("a", 1), ("b", 2)])
let map2 = @immut/hashmap.from_array([("b", 3), ("c", 4)])

// 方法1：使用fold
let merged = map2.fold(init=map1, fn(acc, key, value) { acc.add(key, value) })

// 方法2：逐个添加
let merged = map1.add("b", 3).add("c", 4)
```

### 问题 3: "如何安全地更新嵌套结构？"

```moonbit
// Agent 应该生成的代码
struct User {
  id : Int
  name : String
  tags : @immut/hashset.HashSet[String]
}

let add_user_tag = fn(user : User, tag : String) {
  {
    ..user,
    tags: user.tags.add(tag)  // 只更新tags字段
  }
}
```

## 性能注意事项

作为 Agent，在生成代码时需要考虑：

1. **避免大量小更新**：频繁的单个元素更新会影响性能

   ```moonbit
   // ❌ 不推荐
   let arr = @immut/array.new()
   for i = 0; i < 1000; i = i + 1 {
     arr = arr.push(i)  // 每次都会创建新数组
   }

   // ✅ 推荐：批量操作
   let arr = @immut/array.from_array([0, 1, 2, ..., 999])
   ```

2. **利用结构共享**：旧版本数据结构可以安全保留

   ```moonbit
   let v1 = @immut/array.from_array([1, 2, 3])
   let v2 = v1.push(4)  // v1和v2共享[1, 2, 3]部分
   // 两个版本都可以安全使用
   ```

3. **选择合适的数据结构**：
   - 需要随机访问 → `immut/array`
   - 需要键值映射 → `immut/hashmap`
   - 需要去重集合 → `immut/hashset`
   - 需要有序数据 → `immut/sorted_map`/`immut/sorted_set`

## 错误处理模式

```moonbit
// 安全获取值的模式
let safe_get = fn(map : @immut/hashmap.HashMap[String, Int], key : String) -> Int {
  match map.get(key) {
    Some(value) => value
    None => 0  // 默认值
  }
}

// 批量操作的安全模式
let safe_update = fn(arr : @immut/array.Array[Int], index : Int, value : Int) -> @immut/array.Array[Int] {
  if index >= 0 && index < arr.length() {
    arr.set(index, value)
  } else {
    arr  // 返回原数组
  }
}
```

## 调试技巧

作为 Agent，帮助用户调试不可变数据结构：

```moonbit
// 打印数据结构内容
let debug_map = fn(map : @immut/hashmap.HashMap[String, String]) {
  println("Map contents:")
  map.iter(fn(key, value) {
    println(key + " -> " + value)
  })
}

// 比较两个版本
let compare_versions = fn(v1 : @immut/array.Array[Int], v2 : @immut/array.Array[Int]) {
  println("Version 1 length: " + v1.length().to_string())
  println("Version 2 length: " + v2.length().to_string())
  // 可以进一步比较具体内容
}
```

## struct 和 enum 的不可变更新

### struct 不可变更新模式

MoonBit 中的 struct 字段默认是不可变的，但可以通过创建新实例来更新：

```moonbit
// 定义一个用户结构
struct User {
  id : Int
  name : String
  email : String
  active : Bool
}

// 创建用户
let user = User::{ id: 1, name: "Alice", email: "alice@example.com", active: true }

// ❌ 错误：不能直接修改字段
// user.name = "Bob"  // 编译错误！

// ✅ 正确：创建新实例进行更新
let updated_user = User::{
  id: user.id,
  name: "Bob",           // 更新这个字段
  email: user.email,     // 保持其他字段不变
  active: user.active
}

// ✅ 更简洁的更新函数（使用 functional update 语法）
let update_user_name = fn(user : User, new_name : String) -> User {
  User::{ ..user, name: new_name }  // 使用 ..user 语法复制其他字段
}

let user_with_new_name = update_user_name(user, "Charlie")
```

### 重要：含有私有字段的 struct 更新

根据 MoonBit 2024 年 11 月的更新，public struct 现在可以包含私有字段：

```moonbit
// 在模块内部定义
pub struct Config {
  pub api_key : String
  pub timeout : Int
  priv internal_state : Int  // 私有字段
}

// 从外部更新时，只能更新 public 字段，私有字段保持不变
let update_config = fn(config : Config, new_timeout : Int) -> Config {
  Config::{ ..config, timeout: new_timeout }  // ✓ 正确：只更新 public 字段
}

// ❌ 错误：不能从外部访问或修改私有字段
// Config::{ ..config, internal_state: 42 }  // 编译错误！
```

### enum 不可变更新模式

enum 的更新通过模式匹配和重新构建实现：

```moonbit
// 定义一个任务状态枚举
enum TaskStatus {
  Pending
  InProgress(percentage~ : Int)
  Completed(completed_at~ : String)
  Failed(reason~ : String)
}

// 创建任务状态
let task = TaskStatus::InProgress(percentage=50)

// 更新任务进度
let updated_task = match task {
  InProgress(percentage~) => TaskStatus::InProgress(percentage=75)
  other => other  // 其他状态保持不变
}

// 完成任务的函数
let complete_task = fn(status : TaskStatus) -> TaskStatus {
  match status {
    InProgress(_) => TaskStatus::Completed(completed_at="2024-01-15")
    Pending => TaskStatus::Completed(completed_at="2024-01-15")
    _ => status  // 已完成或失败的任务保持不变
  }
}
```

### 复杂嵌套结构的不可变更新

#### 真实案例：JSON AST 的深层嵌套更新

基于 MoonBit 标准库中的 JSON 处理场景，这里是一个 5 层嵌套的实际案例：

```moonbit
// JSON 数据结构（来自标准库实际用例）
enum Json {
  Null
  True
  False
  Number(Double, repr~ : String?)
  String(String)
  Array(Array[Json])
  Object(Map[String, Json])
}

// 复杂的嵌套 JSON 结构（实际开发中常见）
let api_response = Json::Object({
  "data": Json::Object({
    "user": Json::Object({
      "profile": Json::Object({
        "settings": Json::Object({
          "theme": Json::String("dark"),
          "notifications": Json::True,
          "language": Json::String("en")
        }),
        "preferences": Json::Array([
          Json::String("email"),
          Json::String("push")
        ])
      }),
      "id": Json::Number(123.0),
      "name": Json::String("Alice")
    }),
    "status": Json::String("success")
  }),
  "timestamp": Json::Number(1704067200.0)
})

// ❌ 错误：不能直接修改嵌套结构
// api_response["data"]["user"]["profile"]["settings"]["theme"] = Json::String("light")

// ✅ 正确的深层嵌套更新方法
let update_theme = fn(json : Json, new_theme : String) -> Json {
  match json {
    Object(root) => {
      // 创建新的根对象
      let new_root = Map::new()

      // 复制所有根级字段
      for key, value in root {
        match key {
          "data" => {
            // 递归更新 data 字段
            match update_data_theme(value, new_theme) {
              Some(updated_data) => new_root.set(key, updated_data)
              None => () // 如果更新失败，保持原值
            }
          }
          _ => new_root.set(key, value) // 其他字段保持不变
        }
      }
      Object(new_root)
    }
    _ => json // 不是对象，返回原值
  }
}

// 辅助函数：更新 data 字段的主题
let update_data_theme = fn(data : Json, new_theme : String) -> Json? {
  match data {
    Object(data_obj) => {
      let new_data = Map::new()
      for key, value in data_obj {
        match key {
          "user" => {
            match update_user_theme(value, new_theme) {
              Some(updated_user) => new_data.set(key, updated_user)
              None => ()
            }
          }
          _ => new_data.set(key, value)
        }
      }
      Some(Object(new_data))
    }
    _ => Some(data)
  }
}

// 辅助函数：更新 user 字段的主题
let update_user_theme = fn(user : Json, new_theme : String) -> Json? {
  match user {
    Object(user_obj) => {
      let new_user = Map::new()
      for key, value in user_obj {
        match key {
          "profile" => {
            match update_profile_theme(value, new_theme) {
              Some(updated_profile) => new_user.set(key, updated_profile)
              None => ()
            }
          }
          _ => new_user.set(key, value)
        }
      }
      Some(Object(new_user))
    }
    _ => Some(user)
  }
}

// 辅助函数：更新 profile 字段的主题
let update_profile_theme = fn(profile : Json, new_theme : String) -> Json? {
  match profile {
    Object(profile_obj) => {
      let new_profile = Map::new()
      for key, value in profile_obj {
        match key {
          "settings" => {
            match update_settings_theme(value, new_theme) {
              Some(updated_settings) => new_profile.set(key, updated_settings)
              None => ()
            }
          }
          _ => new_profile.set(key, value)
        }
      }
      Some(Object(new_profile))
    }
    _ => Some(profile)
  }
}

// 最终辅助函数：更新 settings 中的主题
let update_settings_theme = fn(settings : Json, new_theme : String) -> Json? {
  match settings {
    Object(settings_obj) => {
      let new_settings = Map::new()
      for key, value in settings_obj {
        match key {
          "theme" => new_settings.set(key, Json::String(new_theme))
          _ => new_settings.set(key, value) // 保持其他设置不变
        }
      }
      Some(Object(new_settings))
    }
    _ => Some(settings)
  }
}

// 使用更新函数
let updated_response = update_theme(api_response, "light")
```

#### 实际案例：JSON 路径的递归构建和更新

基于 MoonBit 标准库中的 `JsonPath` 实现，展示深层嵌套的递归更新：

```moonbit
// JSON 路径结构（来自标准库）
enum JsonPath {
  Root
  Key(JsonPath, key~ : String)
  Index(JsonPath, index~ : Int)
}

// 构建深层嵌套路径（5 层嵌套）
let deep_path = Root
  .add_key("data")
  .add_key("user")
  .add_index(0)
  .add_key("profile")
  .add_key("settings")

// 递归更新函数：根据路径更新 JSON
def update_by_path(json : Json, path : JsonPath, new_value : Json) -> Json {
  match (json, path) {
    (obj, Root) => json  // 到达根路径，返回原值

    (Object(map), Key(parent_path, key~)) => {
      let new_map = Map::new()

      // 递归处理父路径
      let updated_parent = update_by_path(Object(map), parent_path, Object(map))

      match updated_parent {
        Object(updated_map) => {
          // 更新指定 key 的值
          for k, v in updated_map {
            if k == key {
              // 如果这是路径的最后一部分，应用新值
              if path.is_leaf() {
                new_map.set(k, new_value)
              } else {
                // 继续递归到更深的路径
                new_map.set(k, update_by_path(v, path.parent(), new_value))
              }
            } else {
              new_map.set(k, v)  // 保持其他字段不变
            }
          }
          Object(new_map)
        }
        _ => json
      }
    }

    (Array(arr), Index(parent_path, index~)) => {
      let new_arr = Array::new()

      // 递归处理数组中的指定索引
      for i, item in arr {
        if i == index {
          if path.is_leaf() {
            new_arr.push(new_value)  // 到达目标索引，应用新值
          } else {
            // 继续递归到更深的路径
            new_arr.push(update_by_path(item, path.parent(), new_value))
          }
        } else {
          new_arr.push(item)  // 保持其他元素不变
        }
      }
      Array(new_arr)
    }

    _ => json  // 不匹配的情况，返回原值
  }
}

// 辅助函数判断是否为叶子节点
impl JsonPath {
  fn is_leaf(self : JsonPath) -> Bool {
    match self {
      Root => true
      Key(parent, ..) | Index(parent, ..) => parent.is_leaf()
    }
  }

  fn parent(self : JsonPath) -> JsonPath {
    match self {
      Root => Root
      Key(parent, ..) | Index(parent, ..) => parent
    }
  }
}

// 更实用的路径构建函数
impl JsonPath {
  fn add_key(self : JsonPath, key : String) -> JsonPath {
    Key(self, key~)
  }

  fn add_index(self : JsonPath, index : Int) -> JsonPath {
    Index(self, index~)
  }
}

// 使用示例：更新深层嵌套的 JSON 数据
let user_data = Json::Object({
  "users": Json::Array([
    Json::Object({
      "id": Json::Number(1.0),
      "profile": Json::Object({
        "name": Json::String("Alice"),
        "settings": Json::Object({
          "theme": Json::String("dark"),
          "notifications": Json::True
        })
      })
    }),
    Json::Object({
      "id": Json::Number(2.0),
      "profile": Json::Object({
        "name": Json::String("Bob"),
        "settings": Json::Object({
          "theme": Json::String("light"),
          "notifications": Json::False
        })
      })
    })
  ])
})

// 更新第一个用户的主题设置
let user_path = Root.add_key("users").add_index(0).add_key("profile").add_key("settings").add_key("theme")
let updated_data = update_by_path(user_data, user_path, Json::String("auto"))

// 实际开发中的实用函数：批量更新多个路径
def update_multiple_paths(json : Json, updates : Array[(JsonPath, Json)]) -> Json {
  updates.fold(init=json, fn(acc, update) {
    let (path, new_value) = update
    update_by_path(acc, path, new_value)
  })
}

// 批量更新多个设置
let updates = [
  (Root.add_key("users").add_index(0).add_key("profile").add_key("settings").add_key("theme"), Json::String("auto")),
  (Root.add_key("users").add_index(0).add_key("profile").add_key("settings").add_key("notifications"), Json::False),
  (Root.add_key("users").add_index(1).add_key("profile").add_key("settings").add_key("theme"), Json::String("dark"))
]

let batch_updated = update_multiple_paths(user_data, updates)
```

#### 实际案例：树形结构的递归更新

基于 MoonBit 不可变集合中的 HAMT（哈希数组映射树）实现，展示树形结构的深层更新：

```moonbit
// 树节点定义（来自 immut/hashmap 实际实现）
priv enum Node[K, V] {
  Flat(K, V, Path)                           // 叶子节点
  Leaf(K, V, @list.List[(K, V)])             // 冲突链表
  Branch(@sparse_array.SparseArray[Node[K, V]]) // 分支节点
}

// 路径信息（用于树导航）
priv struct Path {
  shift : Int
  bitmap : Int
}

// 递归的树更新函数（基于标准库模式）
let rec update_tree_node = fn[K : Eq + Hash, V](
  node : Node[K, V],
  key : K,
  new_value : V,
  hash : Int,
  depth : Int
) -> Node[K, V] {
  match node {
    // 叶子节点：检查键是否匹配
    Flat(k, v, path) => {
      if k == key {
        // 找到目标键，更新值
        Flat(k, new_value, path)
      } else {
        // 键冲突，需要创建分支节点
        let new_hash = k.hash()
        if hash == new_hash {
          // 相同哈希，转换为冲突链表
          Leaf(k, v, List::[(k, v), (key, new_value)])
        } else {
          // 不同哈希，创建分支
          let branch = create_branch_for_two_nodes(
            Flat(k, v, path),
            Flat(key, new_value, Path::{ shift: depth * 5, bitmap: 1 })
          )
          branch
        }
      }
    }

    // 冲突链表：遍历查找匹配的键
    Leaf(k, v, conflicts) => {
      if k == key {
        // 更新链表头
        Leaf(k, new_value, conflicts)
      } else {
        // 在链表中查找并更新
        let updated_conflicts = conflicts.map(fn(pair) {
          let (k2, v2) = pair
          if k2 == key {
            (k2, new_value)  // 找到并更新
          } else {
            (k2, v2)         // 保持其他对不变
          }
        })
        Leaf(k, v, updated_conflicts)
      }
    }

    // 分支节点：递归到正确的子节点
    Branch(children) => {
      let index = (hash >> (depth * 5)) & 0x1F  // 计算子节点索引
      let child_index = calculate_child_index(children.bitmap, index)

      match children.get(child_index) {
        Some(child) => {
          // 递归更新子节点
          let updated_child = update_tree_node(child, key, new_value, hash, depth + 1)
          let new_children = children.set(child_index, updated_child)
          Branch(new_children)
        }
        None => {
          // 没有对应的子节点，创建新的叶子节点
          let new_child = Flat(key, new_value, Path::{ shift: (depth + 1) * 5, bitmap: 1 })
          let new_children = children.insert(child_index, new_child)
          Branch(new_children)
        }
      }
    }
  }
}

// 实际的树结构更新示例
let rec update_nested_tree = fn[K : Eq + Hash, V](
  root : Node[K, V]?,
  keys : Array[K],
  values : Array[V],
  index : Int
) -> Node[K, V]? {
  if index >= keys.length() {
    return root
  }

  match root {
    Some(node) => {
      let key = keys[index]
      let value = values[index]
      let hash = key.hash()

      // 更新当前节点
      let updated_node = update_tree_node(node, key, value, hash, 0)

      // 递归处理剩余的键值对
      update_nested_tree(Some(updated_node), keys, values, index + 1)
    }
    None => {
      // 创建新的根节点并继续
      if index < keys.length() {
        let key = keys[index]
        let value = values[index]
        let hash = key.hash()
        let new_node = Flat(key, value, Path::{ shift: 0, bitmap: 1 })
        update_nested_tree(Some(new_node), keys, values, index + 1)
      } else {
        None
      }
    }
  }
}

// 实际使用：批量更新嵌套的树结构
let batch_update_tree = fn[K : Eq + Hash, V](
  tree : Node[K, V]?,
  updates : Array[(K, V)]
) -> Node[K, V]? {
  let keys = updates.map(fn(update) { let (k, _) = k; k })
  let values = updates.map(fn(update) { let (_, v) = v; v })
  update_nested_tree(tree, keys, values, 0)
}
```

#### 实际开发场景：配置模板的深层合并

```moonbit
// 多层配置模板结构（实际项目场景）
struct DeploymentConfig {
  environments : Map[String, EnvironmentConfig]
  defaults : ServiceDefaults
  scaling : ScalingPolicy
}

struct EnvironmentConfig {
  services : Map[String, ServiceConfig]
  database : DatabaseCluster
  network : NetworkConfig
}

struct ServiceConfig {
  replicas : Int
  resources : ResourceRequirements
  env_vars : Map[String, String]
  health_check : HealthCheckConfig
}

struct ResourceRequirements {
  requests : ResourceLimits
  limits : ResourceLimits
}

struct ResourceLimits {
  cpu : String
  memory : String
  storage : String?
}

// ✅ 深层嵌套合并：更新特定服务的资源限制
let update_service_resources = fn(
  config : DeploymentConfig,
  env_name : String,
  service_name : String,
  new_cpu_request : String,
  new_memory_limit : String
) -> DeploymentConfig {
  match config.environments.get(env_name) {
    Some(env) => {
      match env.services.get(service_name) {
        Some(service) => {
          let updated_service = ServiceConfig::{
            ..service,
            resources: ResourceRequirements::{
              requests: ResourceLimits::{
                ..service.resources.requests,
                cpu: new_cpu_request
              },
              limits: ResourceLimits::{
                ..service.resources.limits,
                memory: new_memory_limit
              }
            }
          }

          let updated_services = env.services.add(service_name, updated_service)
          let updated_env = EnvironmentConfig::{
            ..env,
            services: updated_services
          }

          DeploymentConfig::{
            ..config,
            environments: config.environments.add(env_name, updated_env)
          }
        }
        None => config  // 服务不存在
      }
    }
    None => config  // 环境不存在
  }
}

// ✅ 批量更新多个服务的配置
let batch_update_services = fn(
  config : DeploymentConfig,
  env_name : String,
  updates : Array[(String, ServiceConfig)]
) -> DeploymentConfig {
  match config.environments.get(env_name) {
    Some(env) => {
      let updated_services = updates.fold(init=env.services, fn(services, update) {
        let (service_name, new_config) = update
        services.add(service_name, new_config)
      })

      let updated_env = EnvironmentConfig::{
        ..env,
        services: updated_services
      }

      DeploymentConfig::{
        ..config,
        environments: config.environments.add(env_name, updated_env)
      }
    }
    None => config
  }
}
```

### 使用 Option 和 Result 的安全更新

```moonbit
// 安全地更新可能不存在的值
struct UserProfile {
  username : String
  email : String?
  bio : String?
}

let update_email = fn(profile : UserProfile, new_email : String) -> UserProfile {
  UserProfile::{ ..profile, email: Some(new_email) }
}

// 使用 Result 处理可能的错误
let validate_and_update = fn(profile : UserProfile, email : String) -> Result[UserProfile, String] {
  if email.contains("@") {
    Ok(UserProfile::{ ..profile, email: Some(email) })
  } else {
    Err("Invalid email format")
  }
}
```

### 不可变数据结构的组合更新

```moonbit
// 结合使用 struct 和不可变集合
struct UserManager {
  users : @immut/hashmap.HashMap[Int, User]
  active_users : @immut/hashset.HashSet[Int]
  next_id : Int
}

// 添加新用户（返回新的 UserManager）
let add_user = fn(manager : UserManager, name : String, email : String) -> UserManager {
  let new_user = User::{ id: manager.next_id, name, email, active: true }
  UserManager::{
    users: manager.users.add(manager.next_id, new_user),
    active_users: manager.active_users.add(manager.next_id),
    next_id: manager.next_id + 1
  }
}

// ✅ 更新用户信息（使用 functional update 语法）
let update_user_email = fn(manager : UserManager, user_id : Int, new_email : String) -> UserManager {
  match manager.users.get(user_id) {
    Some(user) => {
      let updated_user = User::{ ..user, email: new_email }
      UserManager::{
        ..manager,
        users: manager.users.add(user_id, updated_user)  // 替换用户
      }
    }
    None => manager  // 用户不存在，返回原管理器
  }
}

// ✅ 停用用户（组合更新）
let deactivate_user = fn(manager : UserManager, user_id : Int) -> UserManager {
  match manager.users.get(user_id) {
    Some(user) => {
      let updated_user = User::{ ..user, active: false }
      UserManager::{
        ..manager,
        users: manager.users.add(user_id, updated_user),
        active_users: manager.active_users.remove(user_id)
      }
    }
    None => manager
  }
}
```

## 迁移指南

当用户需要从可变数据结构迁移到不可变数据结构时：

```moonbit
// 从可变数组迁移
let migrate_array = fn() {
  // 旧代码（可变）
  let mut_arr = [1, 2, 3]
  mut_arr[1] = 20

  // 新代码（不可变）
  let immut_arr = @immut/array.from_array([1, 2, 3])
  let new_arr = immut_arr.set(1, 20)
  new_arr
}

// 从可变映射迁移
let migrate_map = fn() {
  // 旧代码（可变）
  // let mut_map = {"key": "value"}
  // mut_map["new_key"] = "new_value"

  // 新代码（不可变）
  let immut_map = @immut/hashmap.from_array([("key", "value")])
  let new_map = immut_map.add("new_key", "new_value")
  new_map
}

// 从可变 struct 迁移
let migrate_struct = fn() {
  // 旧代码（假设有可变字段）
  // struct User { mut name: String }
  // let user = User::{ name: "Alice" }
  // user.name = "Bob"

  // 新代码（不可变）
  struct User { name: String }
  let user = User::{ name: "Alice" }
  let new_user = User::{ ..user, name: "Bob" }
  new_user
}
```

## Agent 代码生成检查清单

作为 Agent，在生成 struct/enum 不可变更新代码时，请检查：

1. **是否尝试直接修改字段？** → 提示使用结构重建
2. **是否可以使用 `..` functional update 语法？** → 简化嵌套更新
3. **是否处理所有 enum 变体？** → 确保模式匹配完整
4. **是否保持不可变性？** → 所有更新都应返回新实例
5. **是否提供合理的默认值？** → 处理 None/Err 情况
6. **是否涉及私有字段？** → 确保只更新 public 字段
7. **是否可以使用标签参数语法？** → 使用 `field~` 语法提高可读性

### 最新的语法更新（2024 年 11 月）

MoonBit 现在支持后缀风格的标签参数语法：

```moonbit
// ✅ 新的后缀语法（推荐）
enum Task {
  Pending(priority~ : Int)
  Completed(date~ : String)
}

let task = Task::Pending(priority=5)
let updated = Task::Pending(priority=10)

// 旧的前缀语法（已废弃）
// enum Task {
//   Pending(~priority : Int)  // 已废弃
// }
// let task = Task::Pending(~priority=5)  // 已废弃
```

记住：MoonBit 的 struct 和 enum 默认是不可变的，所有"更新"都是通过创建新实例实现的。作为 Agent，你的目标是帮助用户写出优雅、高效的不可变更新代码，并跟上最新的语法变化。
