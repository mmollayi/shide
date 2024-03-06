jdate_get_field <- function(x, field) {
    fields <- jdate_get_fields_cpp(x)
    out <- fields[[field]]
    names(out) <- names(x)
    out
}

jdatetime_get_field <- function(x, field) {
    fields <- jdatetime_get_fields_cpp(x)
    out <- fields[[field]]
    names(out) <- names(x)
    out
}

#' Get/set the year component of Jalali date-time objects
#'
#' @details
#' For assignment, `x` and `value` are recycled to their common size using
#' [tidyverse recycling rules][vctrs::vector_recycling_rules].
#' @param x A vector of `jdate` or `jdatetime` objects.
#' @param value A numeric vector.
#' @return The year component of x as an integer.
#' @examples
#' x <- jdate("1402-12-14")
#' sh_year(x)
#' sh_year(x) <- 1400:1401
#' @export
sh_year <- function(x) {
    UseMethod("sh_year")
}

#' @export
sh_quarter <- function(x) {
    (sh_month(x) - 1) %/% 3L + 1
}

#' Get/set the month component of Jalali date-time objects
#'
#' @details
#' For assignment, `x` and `value` are recycled to their common size using
#' [tidyverse recycling rules][vctrs::vector_recycling_rules].
#' @param x A vector of `jdate` or `jdatetime` objects.
#' @param value A numeric vector.
#' @return The month component of x as an integer.
#' @examples
#' x <- jdate("1402-12-14")
#' sh_month(x)
#' sh_month(x) <- 10:11
#' @export
sh_month <- function(x) {
    UseMethod("sh_month")
}

#' Get/set the days components of Jalali date-time objects
#'
#' * `sh_day()` and `sh_day<-()` retrieves and replaces the day of the month respectively.
#' * `mday()` and `m⁠day<-()`⁠ are aliases for `day()` and ⁠`day<-()⁠`.
#' * `sh_wday()` retrieves the day of the week.
#' * `sh_qday()` retrieves the day of the quarter.
#' * `sh_yday()` retrieves the day of the year.
#'
#' @details
#' For assignment, `x` and `value` are recycled to their common size using
#' [tidyverse recycling rules][vctrs::vector_recycling_rules].
#' @param x A vector of `jdate` or `jdatetime` objects.
#' @param value A numeric vector.
#' @return The days component of x as an integer.
#' @examples
#' x <- jdate("1402-12-14")
#' sh_day(x)
#' sh_mday(x)
#' sh_qday(x)
#' sh_wday(x)
#' sh_yday(x)
#' sh_mday(x) <- 12:13
#' @export
sh_day <- function(x) {
    UseMethod("sh_day")
}

#' @rdname sh_day
#' @export
sh_mday <- function(x) {
    UseMethod("sh_day")
}

#' @rdname sh_day
#' @export
sh_wday <- function(x) {
    UseMethod("sh_wday")
}

#' @rdname sh_day
#' @export
sh_qday <- function(x) {
    UseMethod("sh_qday")
}

#' @rdname sh_day
#' @export
sh_yday <- function(x) {
    UseMethod("sh_yday")
}

#' Get/set the time components of `jdatetime` objects
#'
#' @details
#' For assignment, `x` and `value` are recycled to their common size using
#' [tidyverse recycling rules][vctrs::vector_recycling_rules].
#' @param x A vector of `jdatetime` objects.
#' @param value A numeric vector.
#' @return
#' An integer vector representing the hour, minute or second component of x,
#' depending on the function being called.
#' @examples
#' x <- jdatetime("1402-12-14 19:13:31")
#' sh_second(x)
#' sh_hour(x) <- 17:18
#' @export
sh_hour <- function(x) {
    UseMethod("sh_hour")
}

#' @rdname sh_hour
#' @export
sh_minute <- function(x) {
    UseMethod("sh_minute")
}

#' @rdname sh_hour
#' @export
sh_second <- function(x) {
    UseMethod("sh_second")
}

#' @export
sh_tzone <- function(x) {
    UseMethod("sh_tzone")
}

#' @rdname sh_year
#' @export
sh_year.jdate <- function(x) {
    jdate_get_field(x, "year")
}

#' @rdname sh_year
#' @export
sh_year.jdatetime <- function(x) {
    jdatetime_get_field(x, "year")
}

#' @rdname sh_month
#' @export
sh_month.jdate <- function(x) {
    jdate_get_field(x, "month")
}

#' @rdname sh_month
#' @export
sh_month.jdatetime <- function(x) {
    jdatetime_get_field(x, "month")
}

#' @rdname sh_day
#' @export
sh_day.jdate <- function(x) {
    jdate_get_field(x, "day")
}

#' @rdname sh_day
#' @export
sh_day.jdatetime <- function(x) {
    jdatetime_get_field(x, "day")
}

#' @rdname sh_day
#' @export
sh_wday.jdate <- function(x) {
    out <- jdate_get_wday_cpp(x)
    names(out) <- names(x)
    out
}

#' @rdname sh_day
#' @export
sh_wday.jdatetime <- function(x) {
    out <- jdate_get_wday_cpp(as_jdate(x))
    names(out) <- names(x)
    out
}

#' @rdname sh_day
#' @export
sh_qday.jdate <- function(x) {
    out <- jdate_get_qday_cpp(x)
    names(out) <- names(x)
    out
}

#' @rdname sh_day
#' @export
sh_qday.jdatetime <- function(x) {
    out <- jdate_get_qday_cpp(as_jdate(x))
    names(out) <- names(x)
    out
}

#' @rdname sh_day
#' @export
sh_yday.jdate <- function(x) {
    out <- jdate_get_yday_cpp(x)
    names(out) <- names(x)
    out
}

#' @rdname sh_day
#' @export
sh_yday.jdatetime <- function(x) {
    out <- jdate_get_yday_cpp(as_jdate(x))
    names(out) <- names(x)
    out
}

#' @rdname sh_hour
#' @export
sh_hour.jdatetime <- function(x) {
    jdatetime_get_field(x, "hour")
}

#' @rdname sh_hour
#' @export
sh_minute.jdatetime <- function(x) {
    jdatetime_get_field(x, "minute")
}

#' @rdname sh_hour
#' @export
sh_second.jdatetime <- function(x) {
    jdatetime_get_field(x, "second")
}

#' @export
sh_tzone.jdatetime <- function(x) {
    attr(x, "tzone")
}

