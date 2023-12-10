
<!-- README.md is generated from README.Rmd. Please edit that file -->

# shide

<!-- badges: start -->
<!-- badges: end -->

## Overview

`shide` is an R package that provides date and date-time support based
on Jalali calendar. `jdate` and `jdatetime` are two simple classes for
storing Jalali dates and date-times respectively. These classes are
implemented based on the infrastructure provided by the `vctrs` package.

## Installation

You can install the development version of shide from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("mmollayi/shide")
```

## Features

- Conversion between Jalali and Gregorian calendars.
- Parsing and formatting of Jalali dates and date-times.
- Time zones and daylight saving times support via IANA time zone
  database. Access to IANA time zone database files is provided by
  `tzdb` package.
- `jdate` and `jdatetime` are built upon numeric vectors, just like
  `Date` and `POSIXct`. So conversion between date classes (`jdate` and
  `Date`) and date-time classes (`jdatetime` and `POSIXct`) comes at
  zero cost.
- Both `jdate` and `jdatetime` can be used as column in a data frame.
- Compatible with R’s `difftime` class. For example, subtraction of two
  `jdate`s results a `difftime` object.

## Usage

As with `Date` class, a `jdate` object can be generated from character
and numeric vectors and also from individual components. To parse a
character vector that represents Jalali dates, use `jdate()` and supply
a format string:

``` r
library(shide)

jdate("1402-09-13")
#> <jdate[1]>
#> [1] "1402-09-13"
jdate("1402/09/13", format = "%Y/%m/%d")
#> <jdate[1]>
#> [1] "1402-09-13"
```

Unlike `as.Date()`, `jdate()` method for numeric inputs does not expose
`origin` argument.

``` r
# Jalali date that corresponds to "1970-01-01"
jdate(0)
#> <jdate[1]>
#> [1] "1348-10-11"
```

To create a `jdate` from individual components, use `jdate_make()`:

``` r
jdate_make(1399, 12 ,30)
#> <jdate[1]>
#> [1] "1399-12-30"
```

Like `jdate` a `jdatetime` object can be generated from a character or
numeric vector or from individual components. But a timezone should be
supplied in either case:

``` r
jdatetime("1402-09-13 15:37:29", tzone = "")
#> <jdatetime<local>[1]>
#> [1] "1402-09-13 15:37:29"
jdatetime("1402/09/13 15:37:29", tzone = "Asia/Tehran", format = "%Y/%m/%d %H:%M:%S")
#> <jdatetime<Asia/Tehran>[1]>
#> [1] "1402-09-13 15:37:29"

# Jalali date-time that corresponds to Unix epoch
jdatetime(0, tzone ="Asia/Tehran")
#> <jdatetime<Asia/Tehran>[1]>
#> [1] "1348-10-11 03:30:00"

jdatetime_make(1399, 12 ,30, 23, 59, 59, "Asia/Tehran")
#> <jdatetime<Asia/Tehran>[1]>
#> [1] "1399-12-30 23:59:59"
```

Converting other date and date-time classes to `jdate` and `jdatetime`
is possible with `as_jdate()` and `as_jdatetime()` respectively:

``` r
as_jdate(Sys.Date())
#> <jdate[1]>
#> [1] "1402-09-19"
as_jdatetime(Sys.time())
#> <jdatetime<local>[1]>
#> [1] "1402-09-19 17:12:47"
```
