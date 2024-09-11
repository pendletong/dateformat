import birl.{type Time}

import day
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regex.{type Match}
import gleam/result
import gleam/string
import gleam/string_builder
import month
import util

pub fn main() {
  io.println("Hello from dateformat!")
  io.debug(format(
    "YYYY YY Q Qo W Wo WW E Do-Mo-yyyy [dd-MM-yyyy] DDDo",
    birl.now(),
  ))
}

pub fn format(fmt: String, time: Time) -> Result(String, Nil) {
  use cmp_fmt <- result.try(compile_format(fmt))

  Ok(cmp_fmt(time))
}

pub fn compile_format(fmt: String) -> Result(fn(Time) -> String, Nil) {
  let assert Ok(regex) =
    regex.from_string(
      "\\[([^\\[]*)\\]|(?:Mo|M{1,4}|DDDo|Do|D{1,4}|do|d{1,4}|E|wo|w{1,2}|Wo|W{1,2}|Qo|Q|YYYY|YY|.)",
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
    "YYYY" -> Ok(fn(t) { { t |> birl.get_day }.year |> int.to_string })
    "YY" -> Ok(fn(t) { { t |> birl.get_day }.year % 100 |> int.to_string })
    "Q" ->
      Ok(fn(t) {
        { { t |> birl.month |> month.get_month_num } + 3 } / 4 |> int.to_string
      })
    "Qo" ->
      Ok(fn(t) {
        { { t |> birl.month |> month.get_month_num } + 3 } / 4
        |> util.to_ordinal
      })
    "W" -> Ok(fn(t) { t |> day.iso_week_of_year |> int.to_string })
    "WW" ->
      Ok(fn(t) {
        t |> day.iso_week_of_year |> int.to_string |> string.pad_left(2, "0")
      })
    "Wo" -> Ok(fn(t) { t |> day.iso_week_of_year |> util.to_ordinal })
    "w" -> todo
    "ww" -> todo
    "wo" -> todo
    "E" -> Ok(fn(t) { t |> day.day_of_week(True) |> int.to_string })
    "d" -> Ok(fn(t) { t |> day.day_of_week(False) |> int.to_string })
    "do" -> Ok(fn(t) { t |> day.day_of_week(False) |> util.to_ordinal })
    "dd" -> Ok(fn(t) { t |> day.to_weekday_shorter_string })
    "ddd" -> Ok(fn(t) { t |> day.to_weekday_short_string })
    "dddd" -> Ok(fn(t) { t |> day.to_weekday_string })
    "D" -> Ok(fn(t) { t |> date |> int.to_string })
    "Do" -> Ok(fn(t) { t |> date |> util.to_ordinal })
    "DD" -> Ok(fn(t) { t |> date |> int.to_string |> string.pad_left(2, "0") })
    "DDD" -> Ok(fn(t) { t |> day.day_of_year |> int.to_string })
    "DDDo" -> Ok(fn(t) { t |> day.day_of_year |> util.to_ordinal })
    "DDDD" ->
      Ok(fn(t) {
        t |> day.day_of_year |> int.to_string |> string.pad_left(2, "0")
      })

    "M" -> Ok(fn(t) { t |> birl.month |> month.get_month_num |> int.to_string })
    "MM" ->
      Ok(fn(t) {
        t
        |> birl.month
        |> month.get_month_num
        |> int.to_string
        |> string.pad_left(2, "0")
      })
    "MMM" ->
      Ok(fn(t) {
        t
        |> birl.month
        |> month.get_short_month
      })
    "MMMM" ->
      Ok(fn(t) {
        t
        |> birl.month
        |> month.get_month
      })
    "Mo" ->
      Ok(fn(t) {
        t
        |> birl.month
        |> month.get_ordinal_month
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
