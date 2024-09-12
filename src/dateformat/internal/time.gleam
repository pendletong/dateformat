import birl.{type Time}

pub fn to_hour_of_day(time: Time) -> Int {
  { time |> birl.get_time_of_day }.hour
}

pub fn to_hour_of_period(time: Time) -> Int {
  case to_hour_of_day(time) {
    0 | 12 -> 12
    m if m < 12 -> m
    m -> m - 12
  }
}

pub fn to_day_period(time: Time) -> String {
  case to_hour_of_day(time) {
    m if m < 12 -> "AM"
    _ -> "PM"
  }
}

pub fn to_minute_of_hour(time: Time) -> Int {
  { time |> birl.get_time_of_day }.minute
}

pub fn to_second_of_minute(time: Time) -> Int {
  { time |> birl.get_time_of_day }.second
}

pub fn to_milli_of_second(time: Time) -> Int {
  { time |> birl.get_time_of_day }.milli_second
}
