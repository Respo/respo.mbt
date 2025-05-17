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
pub impl Show for CssSize with output(self, logger) {
  let ret = match self {
    Auto => "auto"
    Px(value) => "\{value}px"
    Percent(value) => "\{value}%"
    Em(value) => "\{value}em"
    Rem(value) => "\{value}rem"
    Vw(value) => "\{value}vw"
    Vh(value) => "\{value}vh"
    Custom(value) => value
  }
  logger.write_string(ret)
}
