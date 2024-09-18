pub fn patch_tree[T](
  tree : RespoNode[T],
  old_tree : RespoNode[T],
  mount_target : @web_sys.Node,
  changes : Array[DomChange[T]],
  handle_event : (RespoEventMark) -> Unit!RespoCommonError
) -> Unit!RespoCommonError {
  // let el = mount_target.dyn_ref::<Element>().expect("to element");

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
            mount_target.first_child().unwrap(),
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
              for idx, effect in effects.iter2() {
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
    }
  }
  for op in changes {
    // crate::util::log!("op: {:?}", op);
    let target = find_coord_dom_target!(
      mount_target.first_child().or_error!(RespoCommonError("mount position")),
      op.get_dom_path(),
    )
    match op {
      DomChange::ModifyAttrs(~set, ~unset, ..) => {
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
      DomChange::ModifyStyle(~set, ~unset, ..) => {
        let style = target.reinterpret_as_element().style()
        for s in unset {
          style.remove_property(s)
        }
        for pair in set {
          let (k, v) = pair
          style.set_property(k, v)
        }
      }
      DomChange::ModifyEvent(~add, ~remove, ~coord, ..) => {
        let el = target.reinterpret_as_element()
        for k in add.iter() {
          attach_event!(el, k, coord, handle_event)
        }
        for k in remove {
          match k {
            "click" => el.set_onclick(None)
            "input" => el.reinterpret_as_html_input_element().set_oninput(None)
            _ => @web_sys.warn_log("TODO event" + k)
          }
        }
      }
      DomChange::ReplaceElement(~node, ~coord, ..) => {
        let parent = target.parent_element()
        let new_element = build_dom_tree!(node, coord, handle_event)
        parent.insert_before(new_element, Some(target))
        target.remove()
      }
      DomChange::ModifyChildren(~operations, ~coord, ..) => {
        let base_tree = load_coord_target_tree!(tree, coord[:])
        let old_base_tree = load_coord_target_tree!(old_tree, coord[:])
        for op in operations {
          match op {
            ChildDomOp::Append(k, node) => {
              let mut next_coord = coord
              next_coord.push(RespoCoord::Key(k))
              let new_element = build_dom_tree!(node, next_coord, handle_event)
              target.append_child(new_element)
            }
            ChildDomOp::Prepend(k, node) => {
              let mut next_coord = coord
              next_coord.push(RespoCoord::Key(k))
              let new_element = build_dom_tree!(node, next_coord, handle_event)
              if target.child_nodes().is_empty() {
                target.append_child(new_element)
              } else {
                let base = target.first_child()
                target.reinterpret_as_element().insert_before(new_element, base)
              }
            }
            ChildDomOp::RemoveAt(idx) => {
              let child = target
                .children()
                .get(idx.reinterpret_as_int())
                .unwrap()
              target.remove_child(child)
            }
            ChildDomOp::InsertAfter(idx, k, node) => {
              let children = target.children()
              if idx >= children.length().reinterpret_as_uint() {
                raise RespoCommonError(
                  "child to insert not found at {}" + idx.to_string(),
                )
              } else {
                let handler = handle_event
                let mut next_coord = coord
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
                }
              }
            }
            ChildDomOp::NestedEffect(
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
                      // effect._.run(effect_type, nested_el)
                      // TODO
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
      DomChange::Effect(~coord, ~effect_type, ~skip_indexes, ..) => {
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
          RespoNode::Component({ effects, .. }) =>
            for idx, effect in effects {
              if not(skip_indexes.contains(idx)) {
                // effect._.run(effect_type, target)
                // TODO
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
  key : String,
  coord : Array[RespoCoord],
  handle_event : (RespoEventMark) -> Unit!RespoCommonError
) -> Unit!RespoCommonError {
  // crate::util::log!("attach event {}", key);
  match key {
    "click" => {
      let handler = fn(e : @web_sys.MouseEvent) -> Unit {
        let wrap_event = RespoEvent::Click(
          client_x=e.client_x(),
          client_y=e.client_y(),
          original_event=e,
        )
        let e = handle_event?({ coord, name: "click", event_info: wrap_event })
        match e {
          Ok(_) => ()
          Err(e) => @web_sys.error_log("handle click event: " + e.to_string())
        }
        // @web_sys.error_log("handle click event: " + e.to_string())
      }
      element.set_onclick(Some(handler))
    }
    "dblclick" => {
      let handler = fn(e : @web_sys.MouseEvent) {
        let wrap_event = RespoEvent::Click(
          client_x=e.client_x(),
          client_y=e.client_y(),
          original_event=e,
        )
        let ret = handle_event?(
          { coord, name: "dblclick", event_info: wrap_event },
        )
        match ret {
          Ok(_) => ()
          Err(e) =>
            @web_sys.error_log("handle dblclick event: " + e.to_string())
        }
      }
      element.set_ondblclick(Some(handler))
    }
    "input" => {
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
        let ret = handle_event?(
          { coord, name: "input", event_info: wrap_event },
        )
        match ret {
          Ok(_) => ()
          Err(e) => @web_sys.error_log("handle input event: " + e.to_string())
        }
      }
      match element.tag_name() {
        "INPUT" =>
          element.reinterpret_as_html_input_element().set_oninput(Some(handler))
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
    "change" => {
      let handler = fn(e : @web_sys.InputEvent) {
        let wrap_event = RespoEvent::Input(
          value=e.target().reinterpret_as_html_input_element().value(),
          original_event=e,
        )
        let ret = handle_event?(
          { coord, name: "change", event_info: wrap_event },
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
    "keydown" => {
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
          { coord, name: "keydown", event_info: wrap_event },
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
    "keyup" => {
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
          { coord, name: "keyup", event_info: wrap_event },
        )
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
    "keypress" => {
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
          { coord, name: "keypress", event_info: wrap_event },
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
    "focus" => {
      let handler = fn(e : @web_sys.FocusEvent) {
        let wrap_event = RespoEvent::Focus(e)
        let ret = handle_event?(
          { coord, name: "focus", event_info: wrap_event },
        )
        match ret {
          Ok(_) => ()
          Err(e) => @web_sys.error_log("handle focus event: " + e.to_string())
        }
      }
      element.reinterpret_as_html_input_element().set_onfocus(Some(handler))
    }
    "blur" => {
      let handler = fn(e : @web_sys.BlurEvent) -> Unit {
        let wrap_event = RespoEvent::Blur(e)
        let ret = handle_event?({ coord, name: "blur", event_info: wrap_event })
        match ret {
          Ok(_) => ()
          Err(e) => @web_sys.error_log("handle blur event: " + e.to_string())
        }
      }
      element.reinterpret_as_html_input_element().set_onblur(Some(handler))
    }
    _ => @web_sys.warn_log("unhandled event:" + key)
  }
}
