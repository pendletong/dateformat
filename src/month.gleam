import birl.{
  type Month, Apr, Aug, Dec, Feb, Jan, Jul, Jun, Mar, May, Nov, Oct, Sep,
}

import util

@internal
pub fn get_month_num(month: Month) -> Int {
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

@internal
pub fn get_short_month(month: Month) -> String {
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

@internal
pub fn get_ordinal_month(month: Month) -> String {
  // todo internationalisation
  let month_num = get_month_num(month)
  util.to_ordinal(month_num)
}

@internal
pub fn get_month(month: Month) -> String {
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
