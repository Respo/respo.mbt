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

pub let default_fonts : String = "Hind,Verdana,'Hiragino Sans GB','WenQuanYi Micro Hei','Microsoft Yahei',sans-serif"

pub let code_fonts : String = "Source Code Pro, Menlo, Ubuntu Mono, Consolas, monospace"

pub let fancy_fonts : String = "Josefin Sans, Helvetica neue, Arial, sans-serif"

pub let normal_fonts : String = "Hind, Helvatica, Arial, sans-serif"

pub let ui_global : String = @node.declare_static_style(
  [
    (
      "&",
      @node.RespoStyle::new(
        font_family=default_fonts,
        line_height=Em(2),
        font_size=14,
        color=Hsl(0, 0, 20),
      ),
    ),
    ("& *", @node.RespoStyle::new(box_sizing=BorderBox)),
  ],
)

pub let ui_input : String = @node.declare_static_style(
  [
    (
      "&",
      @node.RespoStyle::new(
        border=@node.CssBorder::new(color=Hsl(0, 0, 80)),
        border_radius=4,
        padding_top=4,
        padding_right=8,
        padding_bottom=4,
        padding_left=8,
        min_width=Px(120),
        line_height=Em(1.5),
        font_family=default_fonts,
        vertical_align=Middle,
      ),
    ),
    (
      "&:focus",
      @node.RespoStyle::new(
        border=@node.CssBorder::new(
          width=1,
          style=Solid,
          color=Hsl(200, 50, 75),
        ),
        box_shadow="0 0 4px 0 hsl(200, 70%, 50%)",
      ),
    ),
  ],
)

pub let ui_button : String = @node.declare_static_style(
  [
    (
      "&",
      @node.RespoStyle::new(
        background_color=White,
        border_style=Solid,
        border_width=1,
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
    ("&:hover", @node.RespoStyle::new(background_color=Hsl(0, 0, 98))),
    (
      "&:active",
      @node.RespoStyle::new(transform=Scale(1.02), transition_duration=Ms(0)),
    ),
  ],
)

pub let ui_button_primary : String = @node.declare_static_style(
  [
    (
      "&",
      @node.RespoStyle::new(
        outline=None,
        color=White,
        background_color=Hsl(220, 80, 60),
        border=@node.CssBorder::new(
          width=0,
          style=Solid,
          color=Hsl(220, 80, 60),
        ),
        min_width=Px(80),
        line_height=Px(24),
        border_radius=4,
        font_size=14,
        cursor=Pointer,
        transition_duration=Ms(200),
        text_align=Center,
      ),
    ),
    ("&:hover", @node.RespoStyle::new(background_color=Hsl(220, 80, 64))),
    (
      "&:active",
      @node.RespoStyle::new(
        transform=Scale(1.02),
        background_color=Hsl(220, 80, 68),
        transition_duration=Ms(0),
      ),
    ),
  ],
)

pub let ui_button_danger : String = @node.declare_static_style(
  [
    (
      "&",
      @node.RespoStyle::new(
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
    ("&:hover", @node.RespoStyle::new(background_color=Hsl(6, 100, 64))),
    (
      "&:active",
      @node.RespoStyle::new(
        transform=Scale(1.02),
        background_color=Hsl(6, 100, 68),
        transition_duration=Ms(0),
      ),
    ),
  ],
)

pub let ui_center : String = @node.declare_static_style(
  [
    (
      "&",
      @node.RespoStyle::new(
        display=Flex,
        flex_direction=Column,
        justify_content=Center,
        align_items=Center,
      ),
    ),
  ],
)

pub let column : String = @node.declare_static_style(
  [
    (
      "&",
      @node.RespoStyle::new(
        display=Flex,
        flex_direction=Column,
        align_items=Stretch,
      ),
    ),
  ],
)

pub let ui_column_dispersive : String = @node.declare_static_style(
  [
    (
      "&",
      @node.RespoStyle::new(
        display=Flex,
        flex_direction=Column,
        justify_content=SpaceAround,
        align_items=Center,
      ),
    ),
  ],
)

pub let ui_column_evenly : String = @node.declare_static_style(
  [
    (
      "&",
      @node.RespoStyle::new(
        display=Flex,
        flex_direction=Column,
        justify_content=SpaceEvenly,
        align_items=Center,
      ),
    ),
  ],
)

pub let ui_column_parted : String = @node.declare_static_style(
  [
    (
      "&",
      @node.RespoStyle::new(
        display=Flex,
        flex_direction=Column,
        justify_content=SpaceBetween,
        align_items=Stretch,
      ),
    ),
  ],
)

pub let ui_expand : String = @node.declare_static_style(
  [("&", @node.RespoStyle::new(flex=1))],
)

pub let ui_fullscreen : String = @node.declare_static_style(
  [
    (
      "&",
      @node.RespoStyle::new(
        position=Absolute,
        left=Px(0),
        top=Px(0),
        width=Percent(100),
        height=Percent(100),
        overflow=Auto,
      ),
    ),
  ],
)

pub let ui_font_code : String = @node.declare_static_style(
  [("&", @node.RespoStyle::new(font_family=code_fonts))],
)

pub let ui_font_fancy : String = @node.declare_static_style(
  [("&", @node.RespoStyle::new(font_family=fancy_fonts))],
)

pub let ui_font_normal : String = @node.declare_static_style(
  [("&", @node.RespoStyle::new(font_family=normal_fonts))],
)

pub let ui_textarea : String = @node.declare_static_style(
  [
    (
      "&",
      @node.RespoStyle::new(
        outline=None,
        font_size=14,
        font_family=default_fonts,
        border=@node.CssBorder::new(width=1, style=Solid, color=Hsl(0, 0, 20)),
        border_radius=4,
        padding=8,
        min_width=Px(240),
        vertical_align=Top,
      ),
    ),
  ],
)

pub let ui_link : String = @node.declare_static_style(
  [
    (
      "&",
      @node.RespoStyle::new(
        text_decoration=Underline,
        user_select=None,
        height=Px(24),
        line_height=Px(24),
        margin=4.0,
        display=InlineBlock,
        color=Hsl(200, 100, 76),
        cursor=Pointer,
      ),
    ),
  ],
)

pub let ui_row : String = @node.declare_static_style(
  [
    (
      "&",
      @node.RespoStyle::new(
        display=Flex,
        flex_direction=Row,
        align_items=Stretch,
      ),
    ),
  ],
)

pub let ui_row_center : String = @node.declare_static_style(
  [
    (
      "&",
      @node.RespoStyle::new(
        display=Flex,
        flex_direction=Row,
        justify_content=Center,
        align_items=Center,
      ),
    ),
  ],
)

pub let ui_row_dispersive : String = @node.declare_static_style(
  [
    (
      "&",
      @node.RespoStyle::new(
        display=Flex,
        flex_direction=Row,
        justify_content=SpaceAround,
        align_items=Center,
      ),
    ),
  ],
)

pub let ui_row_evenly : String = @node.declare_static_style(
  [
    (
      "&",
      @node.RespoStyle::new(
        display=Flex,
        flex_direction=Row,
        justify_content=SpaceEvenly,
        align_items=Center,
      ),
    ),
  ],
)

pub let ui_row_middle : String = @node.declare_static_style(
  [
    (
      "&",
      @node.RespoStyle::new(
        display=Flex,
        flex_direction=Row,
        justify_content=FlexStart,
        align_items=Center,
      ),
    ),
  ],
)

pub let ui_row_parted : String = @node.declare_static_style(
  [
    (
      "&",
      @node.RespoStyle::new(
        display=Flex,
        flex_direction=Row,
        justify_content=SpaceBetween,
        align_items=Center,
      ),
    ),
  ],
)
