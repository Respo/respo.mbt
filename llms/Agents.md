# Respo MoonBit 应用开发指南 (for LLM Agents)

本文档面向 LLM 编程助手，介绍如何使用 Respo 框架编写 MoonBit 前端应用组件。

## 概述

Respo 是一个虚拟 DOM 框架，采用类似 React 的函数式组件设计模式，但使用 MoonBit 语言编写，编译为 JavaScript 运行于浏览器。

核心特点：

- **函数式组件**：组件是返回 `RespoNode[ActionOp]` 的函数
- **不可变数据设计**：Store 和 State 必须是不可变的，使用 record update 语法 `{ ..old, field: value }` 创建新实例
- **全局 Store + 局部 States Tree**：状态存储在树结构中，使用 cursor 进行定位
- **声明式 UI**：使用 DSL 风格的元素构建函数
- **引用相等优化**：由于数据不可变，未变化的引用可以跳过重绘

## 依赖导入

常用导入模式：

```moonbit
///|
using @respo_node {
  type RespoNode,
  type RespoEvent,
  type DispatchFn,
  type RespoCommonError,
  text_node,
  div,
  input,
  button,
  span,
  space,
  static_style,
  respo_attrs,
}

///|
using @css {respo_style}

///|
using @respo {type RespoStatesTree}
```

## 组件结构

### 基本组件函数

组件是一个函数，接收 states 和 props 参数，返回 `RespoNode[ActionOp]`：

```moonbit
///|
fn comp_example(
  states : RespoStatesTree,
  some_prop : String,
) -> RespoNode[ActionOp] {
  div([
    text_node("Hello, \{some_prop}"),
  ])
}
```

### 局部状态 (Local State)

使用 `states.local_pair()` 获取局部状态和 cursor：

```moonbit
///|
struct MyState {
  count : Int
} derive(Default, ToJson, FromJson)

///|
fn comp_counter(states : RespoStatesTree) -> RespoNode[ActionOp] {
  // 获取局部状态和 cursor（第三个值是可选的更新后的 tree，通常忽略）
  let ((state : MyState), cursor) = states.local_pair()

  div([
    text_node("Count: \{state.count}"),
    button(
      inner_text="Increment",
      class_name=@respo.ui_button,
      on_click=fn(_e, dispatch) {
        // 更新局部状态
        dispatch.set_state(cursor, { count: state.count + 1 })
      },
    ),
  ])
}
```

**注意事项**：

- State 结构体必须 derive `Default`, `ToJson`, `FromJson`
- 使用 `dispatch.set_state(cursor, new_state)` 更新状态
- `local_pair()` 返回二元组：`(state, cursor)`
- 更新状态时使用 record update 语法：`{ ..state, field: new_value }`

### 子状态传递

向子组件传递 states 时使用 `states.pick("key")`：

```moonbit
///|
fn comp_parent(states : RespoStatesTree) -> RespoNode[ActionOp] {
  div([
    comp_child(states.pick("child1")),
    comp_child(states.pick("child2")),
  ])
}
```

## 元素构建

### 常用元素函数

```moonbit
// div 容器
div(class_name="my-class", style=respo_style(padding=Px(8)), [
  // children...
])

// 带 key 的列表 (用于高效 diff)
div_listed([
  (RespoIndexKey("item-1"), comp_item(item1)),
  (RespoIndexKey("item-2"), comp_item(item2)),
])

// span
span(inner_text="text content", [])

// 文本节点
text_node("Hello World")

// 按钮
button(
  inner_text="Click me",
  class_name=@respo.ui_button,
  on_click=fn(e, dispatch) { /* handler */ },
)

// 输入框
input(
  class_name=@respo.ui_input,
  value=state.value,
  placeholder="Enter text...",
  on_input=fn(e, dispatch) {
    if e is Input(value~, ..) {
      dispatch.set_state(cursor, { value: value })
    }
  },
)

// 空白间隔
space(width=8)  // 水平间距
space(height=8) // 垂直间距
```

### 属性设置

```moonbit
// 使用 respo_attrs 创建属性
div(
  attrs={
    let t = respo_attrs(id="my-id", class_name="my-class")
    t.set("data-custom", "value")
    t
  },
  [],
)
```

## 事件处理

### 事件类型

```moonbit
// 点击事件
on_click=fn(e, dispatch) {
  if e is Click(original_event~, ..) {
    original_event.prevent_default()
  }
  dispatch.run(SomeAction)
}

// 输入事件
on_input=fn(e, dispatch) {
  if e is Input(value~, ..) {
    dispatch.set_state(cursor, { draft: value })
  }
}

// 键盘事件
on_keydown=fn(e, dispatch) {
  if e is Keyboard(key~, ..) {
    if key == "Enter" {
      dispatch.run(SubmitAction)
    }
  }
}

// 焦点事件
on_focus=fn(e, dispatch) { /* ... */ }
on_blur=fn(e, dispatch) { /* ... */ }
```

### Dispatch 操作

```moonbit
// 分发全局 Action
dispatch.run(SomeAction)

// 更新局部状态
dispatch.set_state(cursor, new_state)

// 清空局部状态
dispatch.empty_state(cursor)
```

## 样式系统

### 内联样式

使用 `respo_style()` 创建样式：

```moonbit
respo_style(
  padding=Px(8),
  margin=Px(4),
  color=Hsl(200, 80, 50),
  background_color=White,
  display=Flex,
  flex_direction=Column,
  justify_content=Center,
  align_items=Center,
)
```

### 静态样式 (CSS 类)

使用 `static_style` 声明静态 CSS 规则：

```moonbit
///|
let style_container : String = static_style([
  ("&", respo_style(margin=Px(4), background_color=Hsl(200, 90, 96))),
  ("&:hover", respo_style(background_color=Hsl(200, 90, 90))),
])

// 使用
div(class_name=style_container, [])
```

### 预定义 UI 类

```moonbit
@respo.ui_button          // 按钮样式
@respo.ui_button_primary  // 主要按钮
@respo.ui_button_danger   // 危险按钮
@respo.ui_input           // 输入框样式
@respo.ui_center          // 居中布局
@respo.ui_column          // 列布局
@respo.ui_row_middle      // 行布局居中
@respo.ui_row_parted      // 行布局两端对齐
@respo.ui_fullscreen      // 全屏
@respo.ui_global          // 全局样式
```

## 组件与 Effect

### 命名组件

使用 `RespoComponent::named` 创建带 effect 的命名组件：

```moonbit
///|
struct MyEffect {
  some_data : String
} derive(ToJson)

///|
impl @node.RespoEffect for MyEffect with mounted(_self, el) {
  @dom_ffi.log("Component mounted")
}

///|
impl @node.RespoEffect for MyEffect with updated(_self, el) {
  @dom_ffi.log("Component updated")
}

///|
fn comp_with_effect(states : RespoStatesTree) -> RespoNode[ActionOp] {
  let effect_data : MyEffect = { some_data: "value" }

  @node.RespoComponent::named(
    "my-component",
    effects=[effect_data],
    div([
      text_node("Component with effect"),
    ]),
  ).to_node()
}
```

### Effect 生命周期

```moonbit
impl @node.RespoEffect for MyEffect with mounted(_self, el) -> Unit {
  // 组件挂载后
}

impl @node.RespoEffect for MyEffect with before_update(_self, el) -> Unit {
  // 更新前
}

impl @node.RespoEffect for MyEffect with updated(_self, el) -> Unit {
  // 更新后
}

impl @node.RespoEffect for MyEffect with before_unmount(_self, el) -> Unit {
  // 卸载前
}
```

## Store 和 Action

### 定义 Store

Store 是不可变的，使用 record update 语法 `{..self, field: value}` 创建新的 Store。集合类型使用 `@immut/array.T` 等不可变集合：

```moonbit
///|
/// Store is immutable - all updates return new Store instances
struct Store {
  count : Int
  items : @immut/array.T[Item]  // Use immutable collections
  states : @respo.RespoStatesTree
}

///|
impl Default for Store with default() -> Store {
  { count: 0, items: @immut/array.new(), states: @respo.RespoStatesTree::default() }
}

///|
fn Store::get_states(self : Store) -> @respo.RespoStatesTree {
  self.states
}
```

### 定义 Action

```moonbit
///|
enum ActionOp {
  Noop
  StatesChange(@respo.RespoUpdateState)
  Increment
  Decrement
} derive(Eq, ToJson)

///|
impl Default for ActionOp with default() -> ActionOp {
  Noop
}

///|
impl @respo_node.RespoAction for ActionOp with build_states_action(cursor, a, j) {
  StatesChange({
    cursor,
    data: if a is Some(a) { Some(@dom_ffi.js_obscure_to_v(a)) } else { None },
    backup: j,
  })
}
```

### 更新 Store

Store 的 `update` 方法返回新的 Store 实例，不修改原有实例：

```moonbit
///|
/// Immutable update: returns a new Store with the action applied
fn Store::update(self : Store, op : ActionOp) -> Store {
  match op {
    Increment => { ..self, count: self.count + 1 }
    Decrement => { ..self, count: self.count - 1 }
    StatesChange(change) => { ..self, states: self.states.set_in(change) }
    Noop => self
  }
}
```

在 main 函数中，Store 通过 `Ref[Store]` 包装来支持可变引用：

```moonbit
app.render_loop(fn() { view(app.store.val) }, fn(op) {
  // 使用不可变更新，将新 Store 赋值给 Ref
  app.store.val = app.store.val.update(op)
})
```

**为什么要用不可变数据**：

- 通过 `physical_equal` 快速检测变化，跳过不必要的重绘
- 可预测的状态管理
- 更容易实现时间旅行调试

## 记忆化 (Memoization)

使用 `memo_once1` 等函数缓存组件以优化性能：

```moonbit
///|
let memo_comp_panel : (RespoStatesTree) -> RespoNode[ActionOp] = @respo.memo_once1(
  comp_panel,
)

// 在父组件中使用
fn view(states : RespoStatesTree) -> RespoNode[ActionOp] {
  div([
    memo_comp_panel(states.pick("panel")),
  ])
}
```

可用的记忆化函数：

- `memo_once1` ~ `memo_once5`：单槽缓存
- `memoize1` ~ `memoize5`：多槽 hashmap 缓存

## 列表渲染

使用 `div_listed` 和 `RespoIndexKey` 进行高效列表渲染：

```moonbit
///|
fn comp_list(
  states : RespoStatesTree,
  items : Array[Item],
) -> RespoNode[ActionOp] {
  let children : Array[(RespoIndexKey, RespoNode[ActionOp])] = []
  for item in items {
    children.push(
      (RespoIndexKey(item.id), comp_item(states.pick(item.id), item)),
    )
  }
  div_listed(children)
}
```

## 常用模式

### 条件渲染

```moonbit
if condition {
  div([content()])
} else {
  span([])  // 占位符
}
```

### 外部 JS 函数

```moonbit
///|
extern "js" fn random_id() -> String =
  #| () => Math.random().toString(36).slice(2)
```

### 日志输出

```moonbit
@dom_ffi.log("info message")
@dom_ffi.warn_log("warning message")
@dom_ffi.error_log("error message")
```

## 示例：完整组件

```moonbit
///|
struct FormState {
  name : String
  submitted : Bool
} derive(Default, ToJson, FromJson)

///|
fn comp_form(states : RespoStatesTree) -> RespoNode[ActionOp] {
  let ((state : FormState), cursor) = states.local_pair()

  div(class_name=@respo.ui_column, style=respo_style(padding=Px(16)), [
    input(
      class_name=@respo.ui_input,
      value=state.name,
      placeholder="Enter your name",
      on_input=fn(e, dispatch) {
        if e is Input(value~, ..) {
          dispatch.set_state(cursor, { ..state, name: value })
        }
      },
    ),
    space(height=8),
    button(
      inner_text="Submit",
      class_name=@respo.ui_button_primary,
      on_click=fn(_e, dispatch) {
        dispatch.run(SubmitName(state.name))
        dispatch.set_state(cursor, { ..state, submitted: true })
      },
    ),
    if state.submitted {
      text_node("Submitted: \{state.name}")
    } else {
      span([])
    },
  ])
}
```

## StateRef - 临时状态包装器

`StateRef[T]` 用于包装不参与序列化的临时状态（如动画偏移量、拖拽位置）。

```moonbit
///|
struct DemoState {
  items : Array[Item]              // 持久化数据
  drag_offset : @respo.StateRef[DragOffset]  // 临时数据，不序列化
} derive(Default, Eq, Hash, ToJson, FromJson)
```

**特性**：序列化时输出 `{}`，比较时忽略，页面刷新后重置为默认值。

**注意**：修改 `StateRef` 不会自动触发重绘，需手动调用 `@respo.mark_need_rerender()`。

使用 `moon doc "@respo.StateRef"` 查看完整 API。
