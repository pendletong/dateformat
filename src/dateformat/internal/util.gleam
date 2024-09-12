import gleam/int

pub fn to_ordinal(num: Int) -> String {
  // todo internationalisation

  case num {
    n if n > 100 -> {
      int.to_string(num / 100) <> to_ordinal(num % 100)
    }
    n if n > 3 && n < 20 -> int.to_string(num) <> "th"
    n -> {
      int.to_string(num)
      <> case n % 10 {
        1 -> "st"
        2 -> "nd"
        3 -> "rd"
        _ -> "th"
      }
    }
  }
}
