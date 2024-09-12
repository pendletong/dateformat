import birl.{
  type Month, Apr, Aug, Dec, Feb, Jan, Jul, Jun, Mar, May, Nov, Oct, Sep,
}

import dateformat/internal/util

pub fn to_month_num(month: Month) -> Int {
  case month {
    Jan -> 1
    Feb -> 2
    Mar -> 3
    Apr -> 4
    May -> 5
    Jun -> 6
    Jul -> 7
    Aug -> 8
    Sep -> 9
    Oct -> 10
    Nov -> 11
    Dec -> 12
  }
}

pub fn to_short_month(month: Month) -> String {
  // todo internationalisation
  case month {
    Jan -> "Jan"
    Feb -> "Feb"
    Mar -> "Mar"
    Apr -> "Apr"
    May -> "May"
    Jun -> "Jun"
    Jul -> "Jul"
    Aug -> "Aug"
    Sep -> "Sep"
    Oct -> "Oct"
    Nov -> "Nov"
    Dec -> "Dec"
  }
}

pub fn to_ordinal_month(month: Month) -> String {
  // todo internationalisation
  let month_num = to_month_num(month)
  util.to_ordinal(month_num)
}

pub fn to_long_month(month: Month) -> String {
  // todo internationalisation
  case month {
    Jan -> "January"
    Feb -> "February"
    Mar -> "March"
    Apr -> "April"
    May -> "May"
    Jun -> "June"
    Jul -> "July"
    Aug -> "August"
    Sep -> "September"
    Oct -> "October"
    Nov -> "November"
    Dec -> "December"
  }
}
