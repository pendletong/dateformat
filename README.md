# dateformat

[![Package Version](https://img.shields.io/hexpm/v/dateformat)](https://hex.pm/packages/dateformat)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/dateformat/)

Date formatting for birl Time records

```sh
gleam add dateformat@1
gleam add birl
```
```gleam
import dateformat
import birl

pub fn main() {
  let t = birl.from_unix_milli(1_234_567_890_123)

  dateformat.format("dd-MMM-YYYY HH:mm", t)
  // -> Ok("13-Feb-2009 23:31")
}
```

Further documentation can be found at <https://hexdocs.pm/dateformat>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
