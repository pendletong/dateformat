//// Enables formatting of birl Time records
////
//// |                        | **Token** | **Output**                     |
//// |------------------------|-----------|--------------------------------|
//// | **Hour of Day**        | HH        | 00 - 23                        |
//// |                        | H         | 0 - 23                         |
//// |                        | hh        | 01 - 12                        |
//// |                        | h         | 1 - 12                         |
//// | **Minute of Hour**     | mm        | 00 - 59                        |
//// |                        | m         | 0 - 59                         |
//// | **Second of Minute**   | ss        | 00 - 59                        |
//// |                        | s         | 0 - 59                         |
//// | **Fraction of Second** | SSS       | 000 - 999                      |
//// |                        | SS        | 00 - 99                        |
//// |                        | S         | 0 - 9                          |
//// | **Period of Day**      | A         | AM or PM                       |
//// |                        | a         | am or pm                       |
//// | **Time Zone/Offsets**  | Z         | -14:00 - +14:00                |
//// |                        | z         | Europe/London, US/Central, etc |
//// | **Unix Timestamp**     | X         | Unix seconds                   |
//// |                        | x         | Unix milliseconds              |
//// | **Day of Week**        | d         | 0 - 6                          |
//// |                        | do        | 0th - 6th                      |
//// |                        | dd        | Su - Sa                        |
//// |                        | ddd       | Sun - Sat                      |
//// |                        | dddd      | Sunday - Saturday              |
//// | **Day of Week (ISO)**  | E         | 1 - 7                          |
//// | **Day of Month**       | D         | 1 - 31                         |
//// |                        | Do        | 1st - 31st                     |
//// |                        | DD        | 01 - 31                        |
//// | **Day of Year**        | DDD       | 1 - 366                        |
//// |                        | DDDo      | 1st - 366th                    |
//// |                        | DDDD      | 001 - 366                      |
//// | **Week of Year (ISO)** | W         | 1 - 53                         |
//// |                        | Wo        | 1st - 53rd                     |
//// |                        | WW        | 01 - 53                        |
//// | **Month**              | M         | 1 - 12                         |
//// |                        | Mo        | 1st - 12th                     |
//// |                        | MM        | 01 - 12                        |
//// |                        | MMM       | Jan - Dec                      |
//// |                        | MMMM      | January - December             |
//// | **Quarter**            | Q         | 1 - 4                          |
//// |                        | Qo        | 1st - 4th                      |
//// | **Year**               | YY        | 70 - 69                        |
//// |                        | YYYY      | 1970 - 2069                    |
////
//// Other characters are just output as is
//// Characters contained with [...] will be output without formats
//// 

import birl.{type Time}
import birl/duration

import dateformat/internal/day
import dateformat/internal/month
import dateformat/internal/time
import dateformat/internal/util
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regex.{type Match}
import gleam/result
import gleam/string
import gleam/string_builder

@internal
pub fn main() {
  io.println("Hello from dateformat!")
  // io.debug(format(
  //   //"YYYY YY Q Qo W Wo WW E Do-Mo-yyyy [dd-MM-yyyy] DDDo",
  //   "A a H HH h hh k kk m mm s ss S SS SSS z zz Z ZZ X x",
  //   birl.now(),
  // ))
  list.range(-12, 12)
  |> list.each(fn(i) {
    let dt = birl.add(birl.now(), duration.hours(i))

    io.debug(
      birl.to_iso8601(dt)
      <> " "
      <> format(
        //"YYYY YY Q Qo W Wo WW E Do-Mo-yyyy [dd-MM-yyyy] DDDo",
        "A a H HH h hh k kk m mm s ss S SS SSS Z ZZ zz X x",
        dt,
      )
      |> result.unwrap(""),
    )
  })
  birl.parse("20120214T15:30:17.123+00:00")
  |> result.unwrap(birl.now())
  |> birl.get_offset
  |> io.debug
  birl.from_unix_milli(1_234_567_890_123)
  |> birl.to_iso8601
  |> io.debug
}

// Formats the given Time using the specified format
// Can return error if the format doesn't parse successfully
//
pub fn format(fmt: String, time: Time) -> Result(String, Nil) {
  use cmp_fmt <- result.try(compile_format(fmt))

  Ok(cmp_fmt(time))
}

// Generates a function that can then be used to format
// given Time records
// Can return error if the format doesn't parse successfully
//
pub fn compile_format(fmt: String) -> Result(fn(Time) -> String, Nil) {
  let assert Ok(regex) =
    regex.from_string(
      "\\[([^\\]]*)\\]|(?:Mo|M{1,4}|DDDo|Do|D{1,4}|do|d{1,4}|E|wo|w{1,2}|Wo|W{1,2}|Qo|Q|YYYY|YY|HH|H|hh|h|mm|m|ss|s|SSS|SS|S|X|x|z|Z|.)",
    )
  use fmts <- result.try(
    regex.scan(regex, fmt)
    |> list.try_map(parse_match),
  )

  Ok(run_format(fmts, _))
}

fn run_format(fmts: List(fn(Time) -> String), time: Time) -> String {
  list.fold(fmts, string_builder.new(), fn(acc, fmt) {
    string_builder.append(acc, fmt(time))
  })
  |> string_builder.to_string
}

fn parse_match(match: Match) -> Result(fn(Time) -> String, Nil) {
  case match.content {
    // Time Zone + Offsets
    "Z" ->
      Ok(fn(t) {
        case t |> birl.get_offset {
          "Z" -> "+00:00"
          z -> z
        }
      })
    "z" -> Ok(fn(t) { t |> birl.get_timezone |> option.unwrap("") })

    // Unix timestamps
    "X" -> Ok(fn(t) { t |> birl.to_unix |> int.to_string })
    "x" -> Ok(fn(t) { t |> birl.to_unix_milli |> int.to_string })

    // AM/PM
    "A" -> Ok(fn(t) { time.to_day_period(t) })
    "a" -> Ok(fn(t) { time.to_day_period(t) |> string.lowercase })

    // Hour of Day
    "HH" ->
      Ok(fn(t) {
        t
        |> time.to_hour_of_day
        |> int.to_string
        |> string.pad_left(2, "0")
      })
    "H" -> Ok(fn(t) { t |> time.to_hour_of_day |> int.to_string })
    "hh" ->
      Ok(fn(t) {
        t |> time.to_hour_of_period |> int.to_string |> string.pad_left(2, "0")
      })
    "h" -> Ok(fn(t) { t |> time.to_hour_of_period |> int.to_string })

    // Minute of Hour
    "mm" ->
      Ok(fn(t) {
        t |> time.to_minute_of_hour |> int.to_string |> string.pad_left(2, "0")
      })
    "m" -> Ok(fn(t) { t |> time.to_minute_of_hour |> int.to_string })

    // Second of Minute
    "ss" ->
      Ok(fn(t) {
        t
        |> time.to_second_of_minute
        |> int.to_string
        |> string.pad_left(2, "0")
      })
    "s" -> Ok(fn(t) { t |> time.to_second_of_minute |> int.to_string })

    // Fraction of Second
    "SSS" ->
      Ok(fn(t) {
        t |> time.to_milli_of_second |> int.to_string |> string.pad_left(3, "0")
      })
    "SS" ->
      Ok(fn(t) {
        { t |> time.to_milli_of_second } / 10
        |> int.to_string
        |> string.pad_left(2, "0")
      })
    "S" ->
      Ok(fn(t) {
        { t |> time.to_milli_of_second } / 100
        |> int.to_string
      })

    // Year
    "YYYY" -> Ok(fn(t) { { t |> birl.get_day }.year |> int.to_string })
    "YY" -> Ok(fn(t) { { t |> birl.get_day }.year % 100 |> int.to_string })

    // Quarter
    "Q" ->
      Ok(fn(t) {
        { t |> birl.month |> month.to_month_num } / 4 + 1 |> int.to_string
      })
    "Qo" ->
      Ok(fn(t) {
        { t |> birl.month |> month.to_month_num } / 4 + 1
        |> util.to_ordinal
      })

    // Week
    "W" -> Ok(fn(t) { t |> day.to_iso_week_of_year |> int.to_string })
    "WW" ->
      Ok(fn(t) {
        t |> day.to_iso_week_of_year |> int.to_string |> string.pad_left(2, "0")
      })
    "Wo" -> Ok(fn(t) { t |> day.to_iso_week_of_year |> util.to_ordinal })
    "w" -> todo
    "ww" -> todo
    "wo" -> todo

    // Day
    "E" -> Ok(fn(t) { t |> day.to_day_of_week(True) |> int.to_string })
    "d" -> Ok(fn(t) { t |> day.to_day_of_week(False) |> int.to_string })
    "do" -> Ok(fn(t) { t |> day.to_day_of_week(False) |> util.to_ordinal })
    "dd" -> Ok(fn(t) { t |> day.to_weekday_shorter_string })
    "ddd" -> Ok(fn(t) { t |> day.to_weekday_short_string })
    "dddd" -> Ok(fn(t) { t |> day.to_weekday_string })
    "D" -> Ok(fn(t) { t |> date |> int.to_string })
    "Do" -> Ok(fn(t) { t |> date |> util.to_ordinal })
    "DD" -> Ok(fn(t) { t |> date |> int.to_string |> string.pad_left(2, "0") })
    "DDD" -> Ok(fn(t) { t |> day.to_day_of_year |> int.to_string })
    "DDDo" -> Ok(fn(t) { t |> day.to_day_of_year |> util.to_ordinal })
    "DDDD" ->
      Ok(fn(t) {
        t |> day.to_day_of_year |> int.to_string |> string.pad_left(2, "0")
      })

    // Month
    "M" -> Ok(fn(t) { t |> birl.month |> month.to_month_num |> int.to_string })
    "MM" ->
      Ok(fn(t) {
        t
        |> birl.month
        |> month.to_month_num
        |> int.to_string
        |> string.pad_left(2, "0")
      })
    "MMM" ->
      Ok(fn(t) {
        t
        |> birl.month
        |> month.to_short_month
      })
    "MMMM" ->
      Ok(fn(t) {
        t
        |> birl.month
        |> month.to_long_month
      })
    "Mo" ->
      Ok(fn(t) {
        t
        |> birl.month
        |> month.to_ordinal_month
      })
    el -> {
      case match.submatches {
        [] -> Ok(fn(_t) { el })
        [Some(el)] -> Ok(fn(_t) { el })
        _ -> Error(Nil)
      }
    }
  }
}

fn date(time: Time) -> Int {
  let day = time |> birl.get_day
  day.date
}
