import birl.{type Time, Day, Fri, Mon, Sat, Sun, Thu, TimeOfDay, Tue, Wed}
import gleam/float
import gleam/int

const micro_in_day = 86_400_000_000

@internal
pub fn day_of_week(time: Time, iso: Bool) -> Int {
  case birl.weekday(time), iso {
    Mon, _ -> 1
    Tue, _ -> 2
    Wed, _ -> 3
    Thu, _ -> 4
    Fri, _ -> 5
    Sat, _ -> 6
    Sun, False -> 0
    Sun, True -> 7
  }
}

@internal
pub fn day_of_year(t2: Time) -> Int {
  let time = TimeOfDay(0, 0, 0, 0)
  let t2 = t2 |> birl.set_time_of_day(time)
  let day = t2 |> birl.get_day
  let t1 =
    t2
    |> birl.set_day(Day(year: day.year, month: 1, date: 1))
    |> birl.set_time_of_day(time)

  let duration_micro =
    { t2 |> birl.to_unix_micro } - { t1 |> birl.to_unix_micro }
  1 + duration_micro / micro_in_day
}

@internal
pub fn iso_week_of_year(t: Time) -> Int {
  let day_num = { day_of_week(t, False) + 6 } % 7
  let day = birl.get_day(t)
  let t = birl.set_day(t, Day(..day, date: day.date - day_num + 3))
  let first_thursday = birl.to_unix_micro(t)
  let t = birl.set_day(t, Day(..birl.get_day(t), month: 1, date: 1))
  let t = case day_of_week(t, False) {
    4 -> t
    d -> {
      birl.set_day(
        t,
        Day(..birl.get_day(t), month: 1, date: 1 + { { 4 - d } + 7 } % 7),
      )
    }
  }
  1
  + float.truncate(float.ceiling(
    int.to_float(first_thursday - birl.to_unix_micro(t)) /. 604_800_000_000.0,
  ))
}

@internal
pub fn to_weekday_string(time: Time) -> String {
  case birl.weekday(time) {
    Mon -> "Monday"
    Tue -> "Tuesday"
    Wed -> "Wednesday"
    Thu -> "Thursday"
    Fri -> "Friday"
    Sat -> "Saturday"
    Sun -> "Sunday"
  }
}

@internal
pub fn to_weekday_short_string(time: Time) -> String {
  case birl.weekday(time) {
    Mon -> "Mon"
    Tue -> "Tue"
    Wed -> "Wed"
    Thu -> "Thu"
    Fri -> "Fri"
    Sat -> "Sat"
    Sun -> "Sun"
  }
}

@internal
pub fn to_weekday_shorter_string(time: Time) -> String {
  case birl.weekday(time) {
    Mon -> "Mo"
    Tue -> "Tu"
    Wed -> "We"
    Thu -> "Th"
    Fri -> "Fr"
    Sat -> "Sa"
    Sun -> "Su"
  }
}
