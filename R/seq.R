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
    check_dots_empty()

    if (missing(from)) {
        stop("'from' must be specified")
    }

    if (!inherits(from, "jdate")) {
        stop("'from' must be a \"jdate\" object")
    }

    if (length(from) != 1L) {
        stop("'from' must be of length 1")
    }

    if (!missing(to)) {
        if (!inherits(to, "jdate")) {
            stop("'to' must be a \"jdate\" object")
        }
        if (length(to) != 1L) {
            stop("'to' must be of length 1")
        }
    }

    if (!missing(along.with)) {
        length.out <- length(along.with)
    } else if (!is.null(length.out)) {
        if (length(length.out) != 1L) {
            stop("'length.out' must be of length 1")
        }

        length.out <- ceiling(length.out)
    }

    status <- c(!missing(to), !missing(by), !is.null(length.out))
    if (sum(status) != 2L) {
        stop("exactly two of 'to', 'by' and 'length.out' / 'along.with' must be specified")
    }

    if (missing(by)) {
        res <- seq.int(as.integer(from), as.integer(to), length.out = length.out)
        return(jdate(res))
    }

    bv <- parse_by(by, "days")
    valid = bv$valid
    by <- bv$by

    if (valid <= 2L) {
        if (!is.null(length.out)) {
            res <- seq.int(as.integer(from), by = by, length.out = length.out)
        } else {
            res <- seq.int(0, as.integer(to - from), by) + as.integer(from)
        }

    } else {
        r1 <- jdate_get_fields_cpp(from)
        if (valid == 5L) {
            if (missing(to)) {
                yr <- seq.int(r1$year, by = by, length.out = length.out)
            } else {
                to0 <- jdate_get_fields_cpp(to)
                yr <- seq.int(r1$year, to0$year, by)
            }

            res <- jdate_seq_by_year_cpp(from, as.integer(yr))
        } else {
            if (valid == 4L) {
                by <- by * 3
            }

            if (missing(to)) {
                mon <- seq.int(r1$mon, by = by, length.out = length.out)
            } else {
                to0 <- jdate_get_fields_cpp(to)
                mon <- seq.int(r1$mon, 12 * (to0$year - r1$year) +
                                   to0$mon, by)
            }

            res <- jdate_seq_by_month_cpp(from, as.integer(mon))
        }
    }

    if (!missing(to)) {
        to <- as.double(to)
        res <- if (by > 0) {
            res[res <= to]
        } else {
            res[res >= to]
        }
    }

    jdate(res)
}

jdate_seq_units <- c("days", "weeks", "months", "quarters", "years")
jdatetime_seq_units <- c(
    "secs", "mins", "hours", "days", "weeks", "months", "years", "DSTdays", "quarters"
)

parse_by_jdate <- function(by) {
    if (length(by) != 1L){
        cli::cli_abort("{.var by} must be of length 1.")
    }

    if (is.na(by)) {
        cli::cli_abort("{.var by} is NA.")
    }

    if (is.numeric(by)) {
        return(list(by = by, valid = 0))
    }

    if (inherits(by, "difftime")) {
        if (!attr(by, "units") %in% c("days", "weeks")) {
            cli::cli_abort("Only `days` and `weeks` units are supported
                           for {.var by} of class difftime.")
        }
        by <- vec_cast(by, new_duration(units = "days"))
        return(list(by = vec_data(by), valid = 0))
    }

    if (is.character(by)) {
        by2 <- parse_unit_cpp("1 1 DSTdays year")
        if (length(by2) > 2L || length(by2) < 1L) {
            cli::cli_abort("Invalid {.var by} specification.")
        }

        valid <- pmatch(by2[length(by2)], jdate_seq_units)

        if (is.na(valid)) {
            cli::cli_abort("Invalid {.var by} specification.")
        }

        if (valid <= 2L) {
            by <- c(1, 7)[valid]
            if (length(by2) == 2L) {
                by <- by * as.integer(by2[1L])
            }
        } else {
            by <- if (length(by2) == 2L) {
                as.integer(by2[1L])
            } else {
                1
            }
        }
        return(list(by = by, valid = valid))
    }

    cli::cli_abort("Invalid {.var by} specification.")
}

parse_by <- function(by, resolution) {
    if (length(by) != 1L){
        cli::cli_abort("{.var by} must be of length 1.")
    }

    if (is.na(by)) {
        cli::cli_abort("{.var by} is NA.")
    }

    if (is.numeric(by)) {
        return(list(by = by, valid = 0))
    }

    if (inherits(by, "difftime")) {
        if ((resolution == "days") && (!attr(by, "units") %in% c("days", "weeks"))) {
            cli::cli_abort("Only `days` and `weeks` units are supported
                           for {.var by} of class difftime.")
        }

        by <- vec_cast(by, new_duration(units = resolution))
        return(list(by = vec_data(by), valid = 0))
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
        } else {
            by <- by2$n
        }

        return(list(by = by, valid = valid))
    }

    cli::cli_abort("Invalid {.var by} specification.")
}
