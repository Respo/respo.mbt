pub(all) enum CssSize {
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
    Auto => "auto"
    Px(value) => "\{value}px"
    Percent(value) => "\{value}%"
    Em(value) => "\{value}em"
    Rem(value) => "\{value}rem"
    Vw(value) => "\{value}vw"
    Vh(value) => "\{value}vh"
    Custom(value) => value
  }
}
