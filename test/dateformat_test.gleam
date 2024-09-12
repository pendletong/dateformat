import birdie
import birl.{type Time}
import birl/duration
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

pub fn timezone_test() {
  let assert Ok(t1) = birl.parse("20120214T15:30:17.786+01:00")
  let assert Ok(t2) = birl.parse("20120214T15:30:17.123-05:00")
  let assert Ok(t3) = birl.parse("20120214T15:30:17.123+00:00")
  let assert Ok(t4) = birl.parse("20120214T15:30:17.123+00:00")
  let assert Ok(t4) = t4 |> birl.set_timezone("Europe/Dublin")

  run_tests([#("Z", " - Timezone"), #("z", " - Region")], [t1, t2, t3, t4])
  |> birdie.snap(title: "Timezone")
}

pub fn unix_timestamp_test() {
  let t1 = birl.from_unix_milli(1_234_567_890_123)

  run_tests(
    [
      #("X", " - Timestamp"),
      #("X.S", " - Timestamp with /10 seconds"),
      #("X.SS", " - Timestamp with /100 seconds"),
      #("X.SSS", " - Timestamp with milliseconds"),
      #("x", " - Timestamp with millseconds"),
    ],
    [t1],
  )
  |> birdie.snap(title: "UNIX Timestamp")
}

pub fn week_test() {
  let assert Ok(t1) = birl.parse("20050102T00:00:00.000+00:00")
  let assert Ok(t2) = birl.parse("20051231T00:00:00.000+00:00")
  let assert Ok(t3) = birl.parse("20070101T00:00:00.000+00:00")
  let assert Ok(t4) = birl.parse("20071230T00:00:00.000+00:00")
  let assert Ok(t5) = birl.parse("20071231T00:00:00.000+00:00")
  let assert Ok(t6) = birl.parse("20080101T00:00:00.000+00:00")
  let assert Ok(t7) = birl.parse("20081228T00:00:00.000+00:00")
  let assert Ok(t8) = birl.parse("20081229T00:00:00.000+00:00")
  let assert Ok(t9) = birl.parse("20081230T00:00:00.000+00:00")
  let assert Ok(t10) = birl.parse("20081231T00:00:00.000+00:00")
  let assert Ok(t11) = birl.parse("20090101T00:00:00.000+00:00")
  let assert Ok(t12) = birl.parse("20091231T00:00:00.000+00:00")
  let assert Ok(t13) = birl.parse("20100101T00:00:00.000+00:00")
  let assert Ok(t14) = birl.parse("20100102T00:00:00.000+00:00")
  let assert Ok(t15) = birl.parse("20100103T00:00:00.000+00:00")
  // For some reason year 404 doesn't parse correctly here
  let assert Ok(t16) = birl.parse("04041231T00:00:00.000+00:00")
  let t16 = birl.add(t16, duration.days(-1))
  let assert Ok(t17) = birl.parse("04051231T00:00:00.000+00:00")
  run_tests(
    [
      #("WW", " - Padded Week of Year"),
      #("W", " - Week of Year"),
      #("Wo", " - Ordinal Week of Year"),
    ],
    [t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15, t16, t17],
  )
  |> birdie.snap(title: "Week of Year")
}

pub fn iso_weekday_test() {
  let assert Ok(t1) = birl.parse("19850204T00:00:00.000+00:00")
  let assert Ok(t2) = birl.parse("20290918T00:00:00.000+00:00")
  let assert Ok(t3) = birl.parse("20130424T00:00:00.000+00:00")
  let assert Ok(t4) = birl.parse("20150305T00:00:00.000+00:00")
  let assert Ok(t5) = birl.parse("19700102T00:00:00.000+00:00")
  let assert Ok(t6) = birl.parse("20010512T00:00:00.000+00:00")
  let assert Ok(t7) = birl.parse("20000102T00:00:00.000+00:00")

  run_tests([#("E", " - ISO Weekday")], [t1, t2, t3, t4, t5, t6, t7])
  |> birdie.snap(title: "ISO Week Day")
}

pub fn weekday_test() {
  let assert Ok(t1) = birl.parse("19850204T00:00:00.000+00:00")
  let assert Ok(t2) = birl.parse("20290918T00:00:00.000+00:00")
  let assert Ok(t3) = birl.parse("20130424T00:00:00.000+00:00")
  let assert Ok(t4) = birl.parse("20150305T00:00:00.000+00:00")
  let assert Ok(t5) = birl.parse("19700102T00:00:00.000+00:00")
  let assert Ok(t6) = birl.parse("20010512T00:00:00.000+00:00")
  let assert Ok(t7) = birl.parse("20000102T00:00:00.000+00:00")

  run_tests(
    [
      #("d", " - Weekday number"),
      #("do", " - Weekday ordinal"),
      #("dd", " - Weekday Shorter"),
      #("ddd", " - Weekday Short"),
      #("dddd", " - Weekday Long"),
    ],
    [t1, t2, t3, t4, t5, t6, t7],
  )
  |> birdie.snap(title: "Week Day")
}

pub fn quarter_test() {
  let assert Ok(t1) = birl.parse("19850204T00:00:00.000+00:00")
  let assert Ok(t2) = birl.parse("20290918T00:00:00.000+00:00")
  let assert Ok(t3) = birl.parse("20130424T00:00:00.000+00:00")
  let assert Ok(t4) = birl.parse("20150305T00:00:00.000+00:00")
  let assert Ok(t5) = birl.parse("19700102T00:00:00.000+00:00")
  let assert Ok(t6) = birl.parse("20011212T00:00:00.000+00:00")
  let assert Ok(t7) = birl.parse("20000102T00:00:00.000+00:00")

  run_tests(
    [
      #("Q", " - Quarter"),
      #("[Q]Q-YYYY", " - Quarter Pretty"),
      #("Qo", " - Quarter Ordinal"),
    ],
    [t1, t2, t3, t4, t5, t6, t7],
  )
  |> birdie.snap(title: "Quarters")
}

pub fn hoursminutes_test() {
  let assert Ok(t1) = birl.parse("20120214T12:30:17.123+01:00")
  let assert Ok(t2) = birl.parse("20120214T01:30:17.123+01:00")
  let assert Ok(t3) = birl.parse("20120214T13:30:17.123+01:00")
  let assert Ok(t4) = birl.parse("20120214T07:30:17.123+01:00")

  run_tests(
    [
      #("HHmm", " - Padded 24hr"),
      #("Hmm", " - 24hr"),
      #("hhmm", " - Padded 12hr"),
      #("hmm", " - 12hr"),
    ],
    [t1, t2, t3, t4],
  )
  |> birdie.snap(title: "Hours and Minutes")
}

pub fn day_period_test() {
  let assert Ok(t1) = birl.parse("20120214T12:30:17.123+01:00")
  let assert Ok(t2) = birl.parse("20120214T01:30:17.123+01:00")
  let assert Ok(t3) = birl.parse("20120214T13:30:17.123+01:00")
  let assert Ok(t4) = birl.parse("20120214T07:30:17.123+01:00")

  run_tests([#("A", " - Period (caps)"), #("a", " - Period")], [t1, t2, t3, t4])
  |> birdie.snap(title: "Day Period")
}

pub fn seconds_test() {
  let assert Ok(t1) = birl.parse("20120214T12:30:17.123+01:00")
  let assert Ok(t2) = birl.parse("20120214T01:30:07.123+01:00")
  let assert Ok(t3) = birl.parse("20120214T13:30:59.123+01:00")
  let assert Ok(t4) = birl.parse("20120214T07:30:00.123+01:00")

  run_tests([#("ss", " - Padded Seconds"), #("s", " - Seconds")], [
    t1,
    t2,
    t3,
    t4,
  ])
  |> birdie.snap(title: "Seconds")
}

pub fn large_test() {
  let assert Ok(t1) = birl.parse("20120214T12:30:17.123+01:00")
  let assert Ok(t2) = birl.parse("20121212T01:30:07.123+01:00")
  let assert Ok(t3) = birl.parse("20120921T13:30:59.123+01:00")
  let assert Ok(t4) = birl.parse("20120304T07:30:00.123+01:00")
  let assert Ok(t4) = t4 |> birl.set_timezone("Europe/Dublin")

  run_tests(
    [
      #(
        "HHHhhhmmmsssSSSSSSAaZzXxdddd ddd dd dodEDDDDDoDDD DD DoDWWWoWMMMM MMM MoMM MQoQYYYYYY",
        " - Large Test",
      ),
    ],
    [t1, t2, t3, t4],
  )
  |> birdie.snap(title: "Large Tests")
}

fn run_tests(list: List(#(String, String)), times: List(Time)) -> String {
  times
  |> list.fold([], fn(acc, time) {
    list.append(
      acc,
      list.fold(list, [], fn(acc2, tst) {
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
