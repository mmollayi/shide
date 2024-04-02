#' Round Jalali dates to a specific unit of time
#'
#' * `sh_floor()` takes a `jdate` object and rounds it down to the previous unit of time.
#' * `sh_ceiling()` takes a `jdate` object and rounds it up to the next unit of time.
#' * `sh_round()` takes a `jdate` object and and rounds it up or down, depending on what is closer.
#' For dates which are exactly halfway between two consecutive units, the convention is to round up.
#'
#' @param x A vector of `jdate` objects.
#' @param unit Valid units are `day`, `week`, `month`, `quarter`, and `year`. If NULL, defaults to `day`.
#' @inheritParams rlang::args_dots_empty
#' @return A vector of `jdate` objects with the same length as x.
#' @seealso [lubridate::round_date()]
#' @examples
#' x <- jdate("1402-12-15")
#' sh_floor(x, "year")
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
    unit <- unit %||% "day"
    unit <- arg_match(unit, jdate_rounding_units())

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
    unit <- arg_match(unit, jdate_rounding_units())

    jdate(jdate_floor_cpp(x, unit))
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
    unit <- arg_match(unit, jdate_rounding_units())

    jdate(jdate_ceiling_cpp(x, unit))
}

parse_unit <- function(unit) {
    nu <- parse_unit_cpp(unit)
    i <- match(nu$unit, jdate_rounding_units())

    if (is.na(i)) {
        i <- match(nu$unit, paste0(jdate_rounding_units(), "s"))
    }

    if (is.na(i)) {
        cli::cli_abort("Invalid unit specification.")
    }

    nu$unit <- jdate_rounding_units()[i]
    nu
}

jdate_rounding_units <- function() {
    c("day", "week", "month", "quarter", "year")
}
