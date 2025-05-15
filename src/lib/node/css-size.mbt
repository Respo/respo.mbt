///|
pub(all) enum CssSize {
  Auto
  Px(Float)
  Percent(Float)
  Em(Float)
  Rem(Float)
  Vw(Int)
  Vh(Int)
  Custom(String)
} derive(Eq)

///|
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

///|
pub impl Show for CssSize with output(self, logger) {
  logger.write_string(CssSize::to_string(self))
}
