#' Round Jalali dates to a specific unit of time
#'
#' * `sh_floor()` takes a `jdate` object and rounds it down to the previous unit of time.
#' * `sh_ceiling()` takes a `jdate` object and rounds it up to the next unit of time.
#' * `sh_round()` takes a `jdate` object and and rounds it up or down, depending on what is closer.
#' For dates which are exactly halfway between two consecutive units, the convention is to round up.
#'
#' @param x A vector of `jdate` objects.
#' @param unit A scalar character, containing a date unit or a multiple of a unit.
#'    Valid date units are `"day"`, `"week"`, `"month"`, `"quarter"` and `"year"`. These can
#'    optionally be followed by "s". If multiple of a unit is used, unit coefficient must be
#'    a whole number greater than or equal to 1. If `NULL`, defaults to `"day"`.
#' @inheritParams rlang::args_dots_empty
#' @return A vector of `jdate` objects with the same length as x.
#' @seealso [lubridate::round_date()]
#' @examples
#' x <- jdate("1402-12-15")
#' sh_floor(x, "year")
#' sh_floor(x, "2 months")
#' sh_ceiling(x, "year")
#' sh_round(x, "year")
#' sh_round(x, "week") == sh_floor(x, "week")
#' sh_round(x + 1, "week") == sh_ceiling(x, "week")
#' @export
sh_round <- function(x, unit = NULL, ...) {
    UseMethod("sh_round")
}

#' @export
sh_round.jdate <- function(x, unit = NULL, ...) {
    check_dots_empty()
    upper <- vec_data(sh_ceiling(x, unit))
    lower <- vec_data(sh_floor(x, unit))
    xx <- trunc(vec_data(x))
    up <- (upper - xx) <= (xx - lower)
    up <- !is.na(up) & up
    lower[up] <- upper[up]
    jdate(lower)
}

#' @rdname sh_round
#' @export
sh_floor <- function(x, unit = NULL, ...) {
    UseMethod("sh_floor")
}

#' @export
sh_floor.jdate <- function(x, unit = NULL, ...) {
    check_dots_empty()
    unit <- unit %||% "day"
    unit <- parse_unit(unit)
    jdate(jdate_floor_cpp(x, unit$unit, unit$n))
}

#' @rdname sh_round
#' @export
sh_ceiling <- function(x, unit = NULL, ...) {
    UseMethod("sh_ceiling")
}

#' @export
sh_ceiling.jdate <- function(x, unit = NULL, ...) {
    check_dots_empty()
    unit <- unit %||% "day"
    unit <- parse_unit(unit)
    jdate(jdate_ceiling_cpp(x, unit$unit, unit$n))
}

parse_unit <- function(unit) {
    if (!rlang::is_scalar_character(unit)) {
        cli::cli_abort("{.var unit} must be a scalar character.")
    }

    nu <- parse_unit_cpp(unit)
    i <- match(nu$unit, jdate_rounding_units)

    if (is.na(i)) {
        i <- match(nu$unit, paste0(jdate_rounding_units, "s"))

        if (is.na(i)) {
            cli::cli_abort("Invalid unit specification.")
        } else {
            nu$unit <- jdate_rounding_units[i]
        }
    }

    if (trunc(nu$n) != nu$n) {
        cli::cli_abort("Fractional units are not supported.")
    }

    if (nu$n < 1) {
        cli::cli_abort("Unit coefficient must be greater than or equal to 1.")
    }

    if (nu$n > unit_upper_limits[i]) {
        cli::cli_abort("Rounding with {nu$unit} > {unit_upper_limits[i]} is not supported.")
    }

    nu
}

unit_upper_limits <- c(
    day = 31, week = 1, month = 12, quarter = 4, year = 2326
)

jdate_rounding_units <- c("day", "week", "month", "quarter", "year")
