//! Some pre-defined styles for layout fonts, and form elements.
//! Highly coupled with styles from <http://ui.respo-mvc.org/> .
//!
//! - Layouts: flexbox rows and columns, also with centering
//! - Elements: button, input, textarea, and link from Respo UI.
//! - Fonts: fancy(Josefin Sans), normal(Hind), code(monospace from system).
//!
//! Since this is CSS rules, you can combine styles with:
//!
//! ```ignore
//! format!("{} {} {}", ui_input(), your_shared(), your_own())
//! ```

///|
pub let default_fonts : String = "Hind,Verdana,'Hiragino Sans GB','WenQuanYi Micro Hei','Microsoft Yahei',sans-serif"

///|
pub let code_fonts : String = "Source Code Pro, Menlo, Ubuntu Mono, Consolas, monospace"

///|
pub let fancy_fonts : String = "Josefin Sans, Helvetica neue, Arial, sans-serif"

///|
pub let normal_fonts : String = "Hind, Helvatica, Arial, sans-serif"

///|
pub let ui_global : String = declare_static_style([
  (
    "&",
    respo_style(
      font_family=default_fonts,
      line_height=Em(2),
      font_size=14,
      color=Hsl(0, 0, 20),
    ),
  ),
  ("& *", respo_style(box_sizing=BorderBox)),
])

///|
pub let ui_input : String = declare_static_style([
  (
    "&",
    respo_style(
      border=@node.CssBorder::new(color=Hsl(0, 0, 80)),
      border_radius=4,
      padding_top=Px(4),
      padding_right=Px(8),
      padding_bottom=Px(4),
      padding_left=Px(8),
      min_width=Px(120),
      line_height=Em(1.5),
      font_family=default_fonts,
      vertical_align=Middle,
    ),
  ),
  (
    "&:focus",
    respo_style(
      border=@node.CssBorder::new(width=1, style=Solid, color=Hsl(200, 50, 75)),
      box_shadow="0 0 4px 0 hsl(200, 70%, 50%)",
    ),
  ),
])

///|
pub let ui_button : String = declare_static_style([
  (
    "&",
    respo_style(
      background_color=White,
      border_style=Solid,
      border_width=Px(1),
      border_color=Hsl(200, 100, 76),
      min_width=Px(80),
      line_height=Px(24),
      border_radius=4,
      font_size=14,
      cursor=Pointer,
      transition_duration=Ms(200),
      text_align=Center,
    ),
  ),
  ("&:hover", respo_style(background_color=Hsl(0, 0, 98))),
  ("&:active", respo_style(transform=Scale(1.02), transition_duration=Ms(0))),
])

///|
pub let ui_button_primary : String = declare_static_style([
  (
    "&",
    respo_style(
      outline=None,
      color=White,
      background_color=Hsl(220, 80, 60),
      border=@node.CssBorder::new(width=0, style=Solid, color=Hsl(220, 80, 60)),
      min_width=Px(80),
      line_height=Px(24),
      border_radius=4,
      font_size=14,
      cursor=Pointer,
      transition_duration=Ms(200),
      text_align=Center,
    ),
  ),
  ("&:hover", respo_style(background_color=Hsl(220, 80, 64))),
  (
    "&:active",
    respo_style(
      transform=Scale(1.02),
      background_color=Hsl(220, 80, 68),
      transition_duration=Ms(0),
    ),
  ),
])

///|
pub let ui_button_danger : String = declare_static_style([
  (
    "&",
    respo_style(
      outline=None,
      color=White,
      background_color=Hsl(6, 100, 60),
      border=@node.CssBorder::new(width=0, style=Solid, color=Hsl(6, 100, 60)),
      min_width=Px(80),
      line_height=Px(24),
      border_radius=4,
      font_size=14,
      cursor=Pointer,
      transition_duration=Ms(200),
      text_align=Center,
    ),
  ),
  ("&:hover", respo_style(background_color=Hsl(6, 100, 64))),
  (
    "&:active",
    respo_style(
      transform=Scale(1.02),
      background_color=Hsl(6, 100, 68),
      transition_duration=Ms(0),
    ),
  ),
])

///| layout items in column and center them with flexbox
/// demos https://ui.respo-mvc.org/#/layouts.html
pub let ui_center : String = declare_static_style([
  (
    "&",
    respo_style(
      display=Flex,
      flex_direction=Column,
      justify_content=Center,
      align_items=Center,
    ),
  ),
])

///| layout items in column and center them with flexbox
/// demos https://ui.respo-mvc.org/#/layouts.html
pub let ui_column : String = declare_static_style([
  ("&", respo_style(display=Flex, flex_direction=Column, align_items=Stretch)),
])

///| layout items in column with flexbox, space around
/// demos https://ui.respo-mvc.org/#/layouts.html
pub let ui_column_dispersive : String = declare_static_style([
  (
    "&",
    respo_style(
      display=Flex,
      flex_direction=Column,
      justify_content=SpaceAround,
      align_items=Center,
    ),
  ),
])

///| layout items in column with flexbox, space evenly
/// demos https://ui.respo-mvc.org/#/layouts.html
pub let ui_column_evenly : String = declare_static_style([
  (
    "&",
    respo_style(
      display=Flex,
      flex_direction=Column,
      justify_content=SpaceEvenly,
      align_items=Center,
    ),
  ),
])

///| layout items in column with flexbox, space between
/// demos https://ui.respo-mvc.org/#/layouts.html
pub let ui_column_parted : String = declare_static_style([
  (
    "&",
    respo_style(
      display=Flex,
      flex_direction=Column,
      justify_content=SpaceBetween,
      align_items=Stretch,
    ),
  ),
])

///| expand item with flex:1
pub let ui_expand : String = declare_static_style([("&", respo_style(flex=1))])

///| full page with absolute position
pub let ui_fullscreen : String = declare_static_style([
  (
    "&",
    respo_style(
      position=Absolute,
      left=Px(0),
      top=Px(0),
      width=Percent(100),
      height=Percent(100),
      overflow=Auto,
    ),
  ),
])

///| monospace font for code, Source Code Pro, Menlo, Ubuntu Mono, Consolas
pub let ui_font_code : String = declare_static_style([
  ("&", respo_style(font_family=code_fonts)),
])

///| fancy font for title, Josefin Sans, Helvetica neue, Arial
/// refers to https://fonts.google.com/specimen/Josefin+Sans or https://cdn.tiye.me/favored-fonts/main-fonts.css
pub let ui_font_fancy : String = declare_static_style([
  ("&", respo_style(font_family=fancy_fonts)),
])

///| normal font for text, Hind, Helvatica, Arial
/// refers to https://fonts.google.com/specimen/Hind or https://cdn.tiye.me/favored-fonts/main-fonts.css
pub let ui_font_normal : String = declare_static_style([
  ("&", respo_style(font_family=normal_fonts)),
])

///|
pub let ui_textarea : String = declare_static_style([
  (
    "&",
    respo_style(
      outline=None,
      font_size=14,
      font_family=default_fonts,
      border=@node.CssBorder::new(width=1, style=Solid, color=Hsl(0, 0, 20)),
      border_radius=4,
      padding=Px(8),
      min_width=Px(240),
      vertical_align=Top,
    ),
  ),
])

///|
pub let ui_link : String = declare_static_style([
  (
    "&",
    respo_style(
      text_decoration=Underline,
      user_select=None,
      height=Px(24),
      line_height=Px(24),
      margin=Px(4),
      display=InlineBlock,
      color=Hsl(200, 100, 76),
      cursor=Pointer,
    ),
  ),
])

///| layout items in row with flexbox, items are stretched
/// demos https://ui.respo-mvc.org/#/layouts.html
pub let ui_row : String = declare_static_style([
  ("&", respo_style(display=Flex, flex_direction=Row, align_items=Stretch)),
])

///| layout items in row with flexbox, center them
/// demos https://ui.respo-mvc.org/#/layouts.html
pub let ui_row_center : String = declare_static_style([
  (
    "&",
    respo_style(
      display=Flex,
      flex_direction=Row,
      justify_content=Center,
      align_items=Center,
    ),
  ),
])

///| layout items in row with flexbox, space around
/// demos https://ui.respo-mvc.org/#/layouts.html
pub let ui_row_dispersive : String = declare_static_style([
  (
    "&",
    respo_style(
      display=Flex,
      flex_direction=Row,
      justify_content=SpaceAround,
      align_items=Center,
    ),
  ),
])

///| layout items in row with flexbox, space evenly
/// demos https://ui.respo-mvc.org/#/layouts.html
pub let ui_row_evenly : String = declare_static_style([
  (
    "&",
    respo_style(
      display=Flex,
      flex_direction=Row,
      justify_content=SpaceEvenly,
      align_items=Center,
    ),
  ),
])

///| layout items in row with flexbox, space between
/// demos https://ui.respo-mvc.org/#/layouts.html
pub let ui_row_middle : String = declare_static_style([
  (
    "&",
    respo_style(
      display=Flex,
      flex_direction=Row,
      justify_content=FlexStart,
      align_items=Center,
    ),
  ),
])

///| layout items in row with flexbox, space between
/// demos https://ui.respo-mvc.org/#/layouts.html
pub let ui_row_parted : String = declare_static_style([
  (
    "&",
    respo_style(
      display=Flex,
      flex_direction=Row,
      justify_content=SpaceBetween,
      align_items=Center,
    ),
  ),
])

///| common CSS resets for Respo pages
pub let preset : String = declare_static_style([
  (
    "body",
    respo_style(
      margin=Px(0),
      overscroll_behavior_x=None,
      overscroll_behavior_y=None,
    ),
  ),
  ("body *", respo_style(box_sizing=BorderBox)),
  ("::-webkit-scrollbar", respo_style(width=Px(4), height=Px(4))),
  ("::-webkit-scrollbar-track", respo_style(background_color=Hsl(0, 0, 100))),
  (
    "::-webkit-scrollbar-thumb",
    respo_style(background_color=Hsla(180, 40, 76, 0.8)),
  ),
  ("::-webkit-scrollbar-corner", respo_style(background_color=Transparent)),
  ("::-webkit-resizer", respo_style(background_color=Transparent)),
])
