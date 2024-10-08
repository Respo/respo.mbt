pub fn patch_tree[T](
  tree : RespoNode[T],
  old_tree : RespoNode[T],
  mount_target : @web_sys.Node,
  changes : Array[DomChange[T]],
  handle_event : (RespoEventMark) -> Unit!RespoCommonError
) -> Unit!RespoCommonError {
  // let el = mount_target.dyn_ref::<Element>().expect("to element");

  @web_sys.log("changes:(\{changes.length()}) " + changes.join(","))
  if mount_target.child_nodes().length() != 1 {
    raise RespoCommonError(
      "expected a single node under mount target, got: " +
      mount_target.child_nodes().length().to_string(),
    )
  }

  // handle BeforeUpdate before DOM changes
  for op in changes {
    match op {
      DomChange::Effect(~coord, ~effect_type, ~skip_indexes, ..) =>
        if effect_type == RespoEffectType::BeforeUpdate {
          let target = find_coord_dom_target!(
            mount_target.first_child(),
            op.get_dom_path(),
          )
          let target_tree = if effect_type == RespoEffectType::BeforeUnmount {
            load_coord_target_tree!(old_tree, coord[:])
          } else {
            load_coord_target_tree!(tree, coord[:])
          }
          match target_tree {
            RespoNode::Component(left) => {
              let { effects, .. } = left
              for idx, _effect in effects.iter2() {
                if not(skip_indexes.contains(idx)) {
                  // effect._.run(effect_type, target)
                  // TODO
                }
              }
            }
            _ =>
              @web_sys.warn_log(
                "expected component for effects, got: \{target_tree}",
              )
          }
        }
      // handle effect before update
      _ => ()
    }
  }
  for op in changes {
    @web_sys.log("op: " + op.to_string())
    // @web_sys.debugger()
    let target = find_coord_dom_target!(
      mount_target.first_child(),
      op.get_dom_path(),
    )
    match op {
      ModifyAttrs(~set, ~unset, ..) => {
        let el = target.reinterpret_as_element()
        for pair in set {
          let (k, v) = pair
          if k == "innerText" {
            el.set_inner_text(v)
          } else if k == "innerHTML" {
            el.set_inner_html(v)
          } else if k == "htmlFor" {
            el.set_html_for(v)
          } else if k == "value" {
            match el.tag_name() {
              "INPUT" => {
                let input_el = el.reinterpret_as_html_input_element()
                let prev_value = input_el.value()
                if prev_value != v {
                  input_el.set_value(v)
                }
              }
              "TEXTAREA" => {
                let textarea_el = el.reinterpret_as_html_textarea_element()
                let prev_value = textarea_el.value()
                if prev_value != v {
                  textarea_el.set_value(v)
                }
              }
              name => raise RespoCommonError("unsupported value for:" + name)
            }
          } else {
            el.set_attribute(k, v)
          }
        }
        for k in unset {
          if k == "innerText" {
            el.set_inner_text("")
          } else if k == "innerHTML" {
            el.set_inner_html("")
          } else if k == "value" {
            let input_el = el.reinterpret_as_html_input_element()
            let prev_value = input_el.value()
            if not(prev_value.is_empty()) {
              input_el.set_value("")
            }
          } else {
            el.remove_attribute(k)
          }
        }
      }
      ModifyStyle(~set, ~unset, ..) => {
        let style = target.style()
        for s in unset {
          style.remove_property(s)
        }
        for pair in set {
          let (k, v) = pair
          style.set_property(k, v)
        }
      }
      ModifyEvent(~add, ~remove, ~coord, ..) => {
        let el = target.reinterpret_as_element()
        for k in add.iter() {
          attach_event!(el, k, coord, handle_event)
        }
        for k in remove {
          match k {
            Click => el.unset_onclick()
            Input => el.reinterpret_as_html_input_element().unset_oninput()
            _ => @web_sys.warn_log("TODO event: " + k.to_string())
          }
        }
      }
      ReplaceElement(~node, ~coord, ..) => {
        let parent = target.parent_element()
        let new_element = build_dom_tree!(node, coord, handle_event)
        parent.insert_before(new_element, Some(target))
        target.remove()
      }
      ModifyChildren(~operations, ~coord, ..) => {
        let base_tree = load_coord_target_tree!(tree, coord[:])
        let old_base_tree = load_coord_target_tree!(old_tree, coord[:])
        for op in operations {
          match op {
            Append(k, node) => {
              let next_coord = coord.copy()
              next_coord.push(RespoCoord::Key(k))
              let new_element = build_dom_tree!(node, next_coord, handle_event)
              target.append_child(new_element)
            }
            Prepend(k, node) => {
              let next_coord = coord.copy()
              next_coord.push(RespoCoord::Key(k))
              let new_element = build_dom_tree!(node, next_coord, handle_event)
              if target.child_nodes().is_empty() {
                target.append_child(new_element)
              } else {
                let base = target.first_child()
                target
                .reinterpret_as_element()
                .insert_before(new_element, Some(base))
              }
            }
            RemoveAt(idx) => {
              let child = target
                .children()
                .get(idx.reinterpret_as_int())
                .unwrap()
              target.remove_child(child)
            }
            InsertAfter(idx, k, node) => {
              let children = target.children()
              if idx >= children.length().reinterpret_as_uint() {
                raise RespoCommonError(
                  "child to insert not found at {}" + idx.to_string(),
                )
              } else {
                let handler = handle_event
                let next_coord = coord.copy()
                next_coord.push(RespoCoord::Key(k))
                let new_element = build_dom_tree!(node, next_coord, handler)
                match
                  (idx + 1).compare(children.length().reinterpret_as_uint()) {
                  -1 => {
                    let child = children
                      .get(idx.reinterpret_as_int() + 1)
                      .unwrap()
                    target.insert_before(new_element, Some(child))
                  }
                  0 => target.append_child(new_element)
                  1 =>
                    raise RespoCommonError(
                      "out of bounds: \{idx} of \{children.length()} at coord \{coord}",
                    )
                  _ => () // compare returns -1, 0, 1
                }
              }
            }
            NestedEffect(
              ~nested_coord,
              nested_dom_path=nesteed_dom_path,
              ~effect_type,
              ~skip_indexes
            ) => {
              let target_tree = if effect_type == RespoEffectType::BeforeUnmount {
                load_coord_target_tree!(old_base_tree, nested_coord[:])
              } else {
                load_coord_target_tree!(base_tree, nested_coord[:])
              }
              let nested_el = find_coord_dom_target!(target, nesteed_dom_path)
              match target_tree {
                RespoNode::Component({ effects, .. }) =>
                  for idx, effect in effects {
                    if not(skip_indexes.contains(idx)) {
                      let f = effect.handler
                      f(effect_type, nested_el)
                    }
                  }
                _ =>
                  @web_sys.warn_log(
                    "expected component for effects, got: \{target_tree}",
                  )
              }
            }
          }
        }
      }
      Effect(~coord, ~effect_type, ~skip_indexes, ..) => {
        if effect_type == RespoEffectType::BeforeUpdate {
          // should be handled before current pass
          continue
        }
        let target_tree = if effect_type == RespoEffectType::BeforeUnmount {
          load_coord_target_tree!(old_tree, coord[:])
        } else {
          load_coord_target_tree!(tree, coord[:])
        }
        match target_tree {
          Component({ effects, .. }) =>
            for idx, effect in effects {
              if not(skip_indexes.contains(idx)) {
                let f = effect.handler
                f(effect_type, target)
              }
            }
          _ =>
            @web_sys.warn_log(
              "expected component for effects, got: \{target_tree}",
            )
        }
      }
    }
  }
}

fn find_coord_dom_target(
  mount_target : @web_sys.Node,
  coord : Array[UInt]
) -> @web_sys.Node!RespoCommonError {
  let mut target = mount_target
  for idx in coord {
    let child = target.child_nodes().get(idx.reinterpret_as_int())
    if child.is_empty() {
      raise RespoCommonError("no child at index " + idx.to_string())
    }
    target = child.or_error!(
      RespoCommonError("does not find child at index: " + idx.to_string()),
    )
  }
  target
}

pub fn attach_event(
  element : @web_sys.Element,
  key : RespoEventType,
  coord : Array[RespoCoord],
  handle_event : (RespoEventMark) -> Unit!RespoCommonError
) -> Unit!RespoCommonError {
  @web_sys.log("attach event: " + key.to_string())
  match key {
    Click => {
      let handler = fn(e : @web_sys.MouseEvent) -> Unit {
        let wrap_event = RespoEvent::Click(
          client_x=e.client_x(),
          client_y=e.client_y(),
          original_event=e,
        )
        let e = handle_event?({ coord, name: Click, event_info: wrap_event })
        match e {
          Ok(_) => ()
          Err(e) => @web_sys.error_log("handle click event: " + e.to_string())
        }
      }
      element.set_onclick(handler)
    }
    DblClick => {
      let handler = fn(e : @web_sys.MouseEvent) {
        let wrap_event = RespoEvent::Click(
          client_x=e.client_x(),
          client_y=e.client_y(),
          original_event=e,
        )
        let ret = handle_event?(
          { coord, name: DblClick, event_info: wrap_event },
        )
        match ret {
          Ok(_) => ()
          Err(e) =>
            @web_sys.error_log("handle dblclick event: " + e.to_string())
        }
      }
      element.set_ondblclick(handler)
    }
    Input => {
      let handler = fn(e : @web_sys.InputEvent) {
        let target = e.target()
        let el : @web_sys.Element = target
        let value = match el.tag_name() {
          "INPUT" => el.reinterpret_as_html_input_element().value()
          "TEXTAREA" => el.reinterpret_as_html_textarea_element().value()
          _ =>
            // TODO Error
            return
        }
        let wrap_event = RespoEvent::Input(~value, original_event=e)
        let ret = handle_event?({ coord, name: Input, event_info: wrap_event })
        match ret {
          Ok(_) => ()
          Err(e) => @web_sys.error_log("handle input event: " + e.to_string())
        }
      }
      match element.tag_name() {
        "INPUT" =>
          element.reinterpret_as_html_input_element().set_oninput(handler)
        "TEXTAREA" =>
          element
          .reinterpret_as_html_textarea_element()
          .set_oninput(Some(handler))
        _ =>
          raise RespoCommonError(
            "unsupported input event: " + element.tag_name(),
          )
      }
    }
    Changle => {
      let handler = fn(e : @web_sys.InputEvent) {
        let wrap_event = RespoEvent::Input(
          value=e.target().reinterpret_as_html_input_element().value(),
          original_event=e,
        )
        let ret = handle_event?(
          { coord, name: Changle, event_info: wrap_event },
        )
        match ret {
          Ok(_) => ()
          Err(e) => @web_sys.error_log("handle change event: " + e.to_string())
        }
      }
      match element.tag_name() {
        "INPUT" =>
          element
          .reinterpret_as_html_input_element()
          .set_onchange(Some(handler))
        "TEXTAREA" =>
          element
          .reinterpret_as_html_textarea_element()
          .set_onchange(Some(handler))
        _ =>
          @web_sys.warn_log(
            "not handled change event for element: " + element.tag_name(),
          )
      }
    }
    Keydown => {
      let handler = fn(e : @web_sys.KeyboardEvent) {
        // crate::util::log!("calling handler");
        let wrap_event = RespoEvent::Keyboard(
          key=e.key(),
          key_code=e.key_code(),
          shift_key=e.shift_key(),
          ctrl_key=e.ctrl_key(),
          alt_key=e.alt_key(),
          meta_key=e.meta_key(),
          repeat=e.repeat(),
          original_event=e,
        )
        let ret = handle_event?(
          { coord, name: Keydown, event_info: wrap_event },
        )
        match ret {
          Ok(_) => ()
          Err(e) => @web_sys.error_log("handle keydown event: " + e.to_string())
        }
      }
      match element.tag_name() {
        "INPUT" =>
          element
          .reinterpret_as_html_input_element()
          .set_onkeydown(Some(handler))
        "TEXTAREA" =>
          element
          .reinterpret_as_html_textarea_element()
          .set_onkeydown(Some(handler))
        _ =>
          @web_sys.warn_log(
            "not handled keydown event for element: " + element.tag_name(),
          )
      }
    }
    Keyup => {
      let handler = fn(e : @web_sys.KeyboardEvent) {
        let wrap_event = RespoEvent::Keyboard(
          key=e.key(),
          key_code=e.key_code(),
          shift_key=e.shift_key(),
          ctrl_key=e.ctrl_key(),
          alt_key=e.alt_key(),
          meta_key=e.meta_key(),
          repeat=e.repeat(),
          original_event=e,
        )
        let ret = handle_event?({ coord, name: Keyup, event_info: wrap_event })
        match ret {
          Ok(_) => ()
          Err(e) => @web_sys.error_log("handle keyup event: " + e.to_string())
        }
      }
      match element.tag_name() {
        "INPUT" =>
          element.reinterpret_as_html_input_element().set_onkeyup(Some(handler))
        "TEXTAREA" =>
          element
          .reinterpret_as_html_textarea_element()
          .set_onkeyup(Some(handler))
        _ =>
          raise RespoCommonError(
            "not handled keyup event for element: " + element.tag_name(),
          )
      }
    }
    Keypress => {
      let handler = fn(e : @web_sys.KeyboardEvent) {
        let wrap_event = RespoEvent::Keyboard(
          key=e.key(),
          key_code=e.key_code(),
          shift_key=e.shift_key(),
          ctrl_key=e.ctrl_key(),
          alt_key=e.alt_key(),
          meta_key=e.meta_key(),
          repeat=e.repeat(),
          original_event=e,
        )
        let ret = handle_event?(
          { coord, name: Keypress, event_info: wrap_event },
        )
        match ret {
          Ok(_) => ()
          Err(e) =>
            @web_sys.error_log("handle keypress event: " + e.to_string())
        }
      }
      match element.tag_name() {
        "INPUT" =>
          element
          .reinterpret_as_html_input_element()
          .set_onkeypress(Some(handler))
        "TEXTAREA" =>
          element
          .reinterpret_as_html_textarea_element()
          .set_onkeypress(Some(handler))
        _ =>
          raise RespoCommonError(
            "not handled keypress event for element: " + element.tag_name(),
          )
      }
    }
    Focus => {
      let handler = fn(e : @web_sys.FocusEvent) {
        let wrap_event : RespoEvent = Focus(e)
        let ret = handle_event?({ coord, name: Focus, event_info: wrap_event })
        match ret {
          Ok(_) => ()
          Err(e) => @web_sys.error_log("handle focus event: " + e.to_string())
        }
      }
      element.reinterpret_as_html_input_element().set_onfocus(Some(handler))
    }
    Blur => {
      let handler = fn(e : @web_sys.BlurEvent) -> Unit {
        let wrap_event = RespoEvent::Blur(e)
        let ret = handle_event?({ coord, name: Blur, event_info: wrap_event })
        match ret {
          Ok(_) => ()
          Err(e) => @web_sys.error_log("handle blur event: " + e.to_string())
        }
      }
      element.reinterpret_as_html_input_element().set_onblur(Some(handler))
    }
    _ => @web_sys.warn_log("unhandled event: " + key.to_string())
  }
}
