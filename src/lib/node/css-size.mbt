pub enum CssSize {
  Auto
  Px(Int)
  Percent(Int)
  Em(Int)
  Rem(Int)
  Vw(Int)
  Vh(Int)
  Custom(String)
} derive(Eq)

pub fn CssSize::to_string(self : CssSize) -> String {
  match self {
    CssSize::Auto => "auto"
    CssSize::Px(value) => "\{value}px"
    CssSize::Percent(value) => "\{value}%"
    CssSize::Em(value) => "\{value}em"
    CssSize::Rem(value) => "\{value}rem"
    CssSize::Vw(value) => "\{value}vw"
    CssSize::Vh(value) => "\{value}vh"
    CssSize::Custom(value) => value
  }
}

pub enum CssPx {
  Px(Int)
} derive(Eq)

pub fn CssPx::to_string(self : CssPx) -> String {
  match self {
    CssPx::Px(value) => "\{value}px"
  }
}
