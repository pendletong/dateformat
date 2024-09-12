import birdie
import birl.{type Time}
import dateformat.{format}
import gleam/io
import gleam/list
import gleam/string
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
      #("[MM]", " - Brackets"),
      #("[MM] YY [YY]", " - Multiple brackets"),
      #("[MM", " - Unclosed Brackets"),
      #("[[MM]]", " - Double Brackets"),
      #("[[]", " - Escaped Open Bracket"),
      #("DD-[\n]-MMM", " - Newlines"),
    ],
    [t],
  )
  |> birdie.snap(title: "Brackets")
}

pub fn milliseconds_test() {
  let assert Ok(t1) = birl.parse("20120214T15:30:17.786+01:00")
  let assert Ok(t2) = birl.parse("20120214T15:30:17.123+01:00")

  run_tests(
    [
      #("S", " - /10 second"),
      #("SS", " - /100 second"),
      #("SSS", " - millisecond"),
    ],
    [t1, t2],
  )
  |> birdie.snap(title: "Milliseconds")
}

fn run_tests(list: List(#(String, String)), times: List(Time)) -> String {
  list
  |> list.fold([], fn(acc, tst) {
    list.append(
      acc,
      list.fold(times, [], fn(acc2, time) {
        [
          format(tst.0, time)
          |> should.be_ok
            <> tst.1,
          ..acc2
        ]
      })
        |> list.reverse,
    )
  })
  |> string.join("\n")
}
