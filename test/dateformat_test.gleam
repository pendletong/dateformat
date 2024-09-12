import birdie
import birl.{type Time}
import dateformat.{format}
import gleam/io
import gleam/list
import gleam/string_builder
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn bracket_test() {
  let assert Ok(t) = birl.parse("20120214T15:30:17.123+01:00")

  run_tests(
    [
      #("[MM]", " - Brackets\n"),
      #("[MM] YY [YY]", " - Multiple brackets\n"),
      #("[MM", " - Unclosed Brackets\n"),
      #("[[MM]]", " - Double Brackets\n"),
      #("[[]", " - Escaped Open Bracket"),
    ],
    t,
  )
  |> birdie.snap(title: "Brackets")
}

fn run_tests(list: List(#(String, String)), time: Time) -> String {
  list
  |> list.fold(string_builder.new(), fn(sb, tst) {
    format(tst.0, time)
    |> io.debug
    |> should.be_ok
    |> string_builder.append(sb, _)
    |> string_builder.append(tst.1)
  })
  |> string_builder.to_string
}
