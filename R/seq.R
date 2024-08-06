#' Generate regular sequences of Jalali dates
#'
#' The method for [seq] for objects of class `jdate`.
#'
#' @inheritParams base::seq.Date
#' @details
#' `by` can be specified in several ways:
#' * A number, taken to be in days.
#' * A object of class [difftime].
#' * A character string, containing one of "day", "week", "month", "quarter" or "year".
#'   This can optionally be preceded by a (positive or negative) integer
#'   and a space, or followed by "s".
#'
#' @section Comparison with `seq.Date()`:
#' The source code of `seq.jdate()` is a modified version of the code used in `base::seq.Date()`.
#' But a few behaviors of the latter are changed:
#' * In base R, invalid dates resolve by overflowing according to the number of days that the
#'   date is invalid by. But `seq.jdate()` resolves invalid dates by rolling forward to the
#'   first day of the next month.
#'
#' * If usage of `to` and `length.out` results in a fractional sequence between `from` and `to`,
#'   base R keeps the fraction in the underlying data of the output `Date` object. But since
#'   `jdate` is built upon whole numbers, the fractional part is dropped in the output.
#'
#' These differences are illustrated in the examples.
#'
#' @return A vector of `jdate` objects.
#' @seealso [base::seq.Date()]
#' @examples
#' # by days
#' seq(jdate("1402-01-01"), jdate("1402-01-10"), 1)
#' # by 2 weeks
#' seq(jdate("1402-01-01"), jdate("1402-04-01"), "2 weeks")
#' # first days of years
#' seq(jdate("1390-01-01"), jdate("1399-01-01"), "years")
#' # by month
#' seq(jdate("1400-01-01"), by = "month", length.out = 12)
#' # quarters
#' seq(jdate("1400-01-01"), jdate("1403-01-01"), by = "quarter")
#'
#' # fractional dates are allowed in `seq.Date()`, but not in `seq.jdate()`
#' unclass(seq(as.Date(0), as.Date(3), length.out = 3))
#' unclass(seq(jdate(0), jdate(2), length.out = 3))
#'
#' # resloving strategy for invalid dates is different in 'seq.jdate()' compared to 'seq.Date()'
#' seq(as.Date("2021-01-31"), by = "months", length.out = 2)
#' seq(jdate("1402-06-31"), by = "6 months", length.out = 2)
#' @export
seq.jdate <- function(from, to, by, length.out = NULL, along.with = NULL, ...) {
    args <- validate_seq_args("jdate", from, to, by, length.out, along.with, ...)
    from <- args$from
    to <- args$to
    by <- args$by
    length.out <- args$length.out

    if (missing(by)) {
        res <- seq.int(as.integer(from), as.integer(to), length.out = length.out)
        return(jdate(res))
    }

    nu <- parse_by(by, "days")
    unit <- nu$unit
    n <- nu$n

    jdate_seq_impl(from, to, length.out, unit, n)
}

#' Generate regular sequences of Jalali date-times
#'
#' The method for [seq] for objects of class `jdatetime`.
#'
#' @inheritParams base::seq.POSIXt
#' @details
#' `by` can be specified in several ways:
#' * A number, taken to be in seconds.
#' * A object of class [difftime].
#' * A character string, containing one of "sec", "min", "hour", "day", "DSTday",
#'   "week", "month", "quarter" or "year".
#'   This can optionally be preceded by a (positive or negative) integer
#'   and a space, or followed by "s".
#'
#' @return A vector of `jdatetime` objects.
#' @seealso [base::seq.POSIXt()]
#' @examples
#' # first days of years
#' seq(jdatetime_make(1390, 1, 1), jdatetime_make(1399, 1, 1), "years")
#' # by month
#' seq(jdatetime_make(1400, 1, 1), by = "month", length.out = 12)
#' seq(jdatetime_make(1400, 1, 31), by = "month", length.out = 12)
#' # days vs DSTdays
#' seq(jdatetime_make(1400, 1, 1, 12, tzone = "Asia/Tehran"), by = "day", length.out = 2)
#' seq(jdatetime_make(1400, 1, 1, 12, tzone = "Asia/Tehran"), by = "DSTday", length.out = 2)
#' seq(jdatetime_make(1400, 1, 1, 12, tzone = "Asia/Tehran"), by = "1 week", length.out = 2)
#' seq(jdatetime_make(1400, 1, 1, 12, tzone = "Asia/Tehran"), by = "7 DSTdays", length.out = 2)
#' @export
seq.jdatetime <- function(from, to, by, length.out = NULL, along.with = NULL, ...) {
    args <- validate_seq_args("jdatetime", from, to, by, length.out, along.with, ...)
    from <- args$from
    to <- args$to
    by <- args$by
    length.out <- args$length.out
    tz <- tzone(from)

    if (missing(by)) {
        res <- seq.int(as.integer(from), as.integer(to), length.out = length.out)
        return(jdatetime(res, tzone = tz))
    }

    nu <- parse_by(by, "secs")
    unit <- nu$unit
    n <- nu$n

    if (unit == "secs") {
        if (!is.null(length.out)) {
            res <- seq.int(as.integer(from), by = n, length.out = length.out)
        } else {
            res <- seq.int(0, as.integer(to - from), n) + as.integer(from)
        }
        return(jdatetime(res, tz))
    }

    r1 <- jdatetime_get_fields_cpp(from)
    if (unit %in% c("months", "years")) {
        if (missing(to)) {
            to0 <- args$to
        } else {
            to0 <- as_jdate(to)
        }

        d <- jdate_seq_impl(as_jdate(from), to0, length.out, unit, n)
    }

    if (unit == c("DSTdays")) {
        if (!missing(to)) {
            ## We might have a short day, so need to over-estimate.
            length.out <- 2L + floor((unclass(to) - unclass(from))/(n * 86400))
        }

        d <- jdate_seq_impl(as_jdate(from), length.out = length.out, unit = "days", n = n)
    }

    d_fields <- jdate_get_fields_cpp(d)
    out <- jdatetime_update(from, d_fields)

    if (!missing(to)) {
        out <- if (n > 0) {
            out[out <= to]
        } else {
            out[out >= to]
        }
    }

    out
}

jdate_seq_impl <- function(from, to, length.out, unit, n) {
    if (unit == "days") {
        if (!is.null(length.out)) {
            res <- seq.int(as.integer(from), by = n, length.out = length.out)
        } else {
            res <- seq.int(0, as.integer(to - from), n) + as.integer(from)
        }
        return(jdate(res))
    }

    r1 <- jdate_get_fields_cpp(from)
    if (unit == "months") {
        if (missing(to)) {
            mon <- seq.int(r1$mon, by = n, length.out = length.out)
        } else {
            to0 <- jdate_get_fields_cpp(to)
            mon <- seq.int(r1$mon, 12 * (to0$year - r1$year) + to0$mon, n)
        }

        res <- jdate_seq_by_month_cpp(from, as.integer(mon))
    }

    if (unit == "years") {
        if (missing(to)) {
            yr <- seq.int(r1$year, by = n, length.out = length.out)
        } else {
            to0 <- jdate_get_fields_cpp(to)
            yr <- seq.int(r1$year, to0$year, n)
        }

        res <- jdate_seq_by_year_cpp(from, as.integer(yr))
    }

    if (!missing(to)) {
        to <- as.double(to)
        res <- if (n > 0) {
            res[res <= to]
        } else {
            res[res >= to]
        }
    }

    jdate(res)
}

jdate_seq_units <- c("days", "weeks", "months", "quarters", "years")
jdatetime_seq_units <- c("secs", "mins", "hours", jdate_seq_units, "DSTdays")

parse_by <- function(by, resolution) {
    if (missing(by)) {
        return(list(n = 1, unit = resolution))
    }

    if (length(by) != 1L){
        cli::cli_abort("{.var by} must be of length 1.")
    }

    if (is.na(by)) {
        cli::cli_abort("{.var by} is NA.")
    }

    if (is.numeric(by)) {
        return(list(n = by, unit = resolution))
    }

    if (inherits(by, "difftime")) {
        if ((resolution == "days") && (!attr(by, "units") %in% c("days", "weeks"))) {
            cli::cli_abort("Only `days` and `weeks` units are supported
                           for {.var by} of class difftime.")
        }

        by <- vec_cast(by, new_duration(units = resolution))
        return(list(n = vec_data(by), unit = resolution))
    }

    if (is.character(by)) {
        by2 <- parse_unit_cpp(by)
        seq_units <- switch(resolution, "days" = jdate_seq_units, "secs" = jdatetime_seq_units)
        valid <- pmatch(by2$unit, seq_units)

        if (is.na(valid)) {
            cli::cli_abort("Invalid {.var by} specification.")
        }

        if (valid <= match("weeks", seq_units)) {
            by <- vec_cast(new_duration(by2$n, seq_units[valid]), new_duration(units = resolution))
            by <- vec_data(by)
            return(list(n = by, unit = resolution))
        }

        if (seq_units[valid] == "quarters") {
            return(list(n = by2$n * 3, unit = "months"))
        }

        return(list(n = by2$n, unit = seq_units[valid]))
    }

    cli::cli_abort("Invalid {.var by} specification.")
}

validate_seq_args <- function(class, from, to, by, length.out = NULL, along.with = NULL, ...) {
    check_dots_empty()

    if (missing(from)) {
        cli::cli_abort("{.var from} must be specified.")
    }

    if (!inherits(from, class)) {
        cli::cli_abort("{.var from} must be a {.cls {class}} object.")
    }

    if (length(from) != 1L) {
        cli::cli_abort("{.var from} must be of length 1.")
    }

    if (!missing(to)) {
        if (!inherits(to, class)) {
            cli::cli_abort("{.var to} must be a {.cls {class}} object.")
        }
        if (length(to) != 1L) {
            cli::cli_abort("{.var to} must be of length 1.")
        }
    }

    if (!is.null(along.with)) {
        length.out <- length(along.with)
    } else if (!is.null(length.out)) {
        if (length(length.out) != 1L) {
            cli::cli_abort("{.var length.out} must be of length 1.")
        }

        length.out <- ceiling(length.out)
    }

    status <- c(!missing(to), !missing(by), !is.null(length.out))
    if (sum(status) != 2L) {
        cli::cli_abort("exactly two of {.var to}, {.var by} and
                       {.var length.out} / {.var along.with} must be specified.")
    }

    list(from = from, to = rlang::maybe_missing(to),
         by = rlang::maybe_missing(by), length.out = length.out)
}
