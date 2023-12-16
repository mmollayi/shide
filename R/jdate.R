new_jdate <- function(x = double()) {
    vec_assert(x, double())
    new_vctr(x, class = "jdate")
}

#' Jalali calendar dates
#'
#' `jdate` is an S3 class for representing Jalali calendar dates. It can be constructed
#' from character and numeric vectors.
#'
#' @details `jdate` is stored internaly as a double vector and doesn’t have any attributes.
#'    Its value represents the count of days since the Unix epoch (a negative value
#'    if it represents a date prior to the epoch). This implementation coincides
#'    with the implementation of `Date` class.
#' @param x A vector of numeric or character objects.
#' @param ... Arguments passed on to further methods.
#' @param format Format argument for character method.
#' @return A vector of `jdate` objects.
#' @examples
#' jdate("1402-09-20")
#' jdate("1402/09/20", format = "%Y/%m/%d")
#' ## Will replace invalid date format with NA
#' jdate("1402/09/20", format = "%Y-%m-%d")
#' ## Invalid dates will be replaced with NA
#' jdate("1402-12-30")
#' ## Jalali date corresponding to "1970-01-01"
#' jdate(0)
#'
#' @export
jdate <- function(x, ...) {
    UseMethod("jdate")
}

#' @export
jdate.NULL <- function(x, ...) {
    check_dots_empty()
    new_jdate()
}

#' @rdname jdate
#' @export
jdate.numeric <- function(x, ...) {
    check_dots_empty()
    x <- vec_cast(x, double())
    new_jdate(x)
}

#' @rdname jdate
#' @export
jdate.character <- function(x, format = NULL, ...) {
    check_dots_empty()
    format <- format %||% "%Y-%m-%d"
    days_since_epoch <- jdate_parse_cpp(x, format)
    new_jdate(days_since_epoch)
}

#' Check an object for its class
#'
#' * `is_jdate()` checks whether an object is of class `jdate`.
#' * `is_jdatetime()` checks whether an object is of class `jdatetime`.
#' @param x An object to test.
#' @return `TRUE` or `FALSE`.
#' @examples
#' is_jdate(jdate_now() + 1) # TRUE
#' is_jdatetime(jdatetime_now() + as.difftime(2, units = "hours")) # TRUE
#' @export
is_jdate <- function(x) {
    inherits(x, "jdate")
}

#' @export
format.jdate <- function(x, format = NULL, ...) {
    format <- format %||% "%Y-%m-%d"
    format_jdate_cpp(x, format)
}

#' @export
obj_print_data.jdate <- function(x, ...) {
    if (length(x) == 0) return()
    print(format(x))
}

#' @rdname jdatetime_now
#' @export
jdate_now <- function(tzone = "") {
    as_jdate(jdatetime_now(tzone))
}

#' @rdname jdatetime_make
#' @export
jdate_make <- function(year, month = 1L, day = 1L, ...) {
    check_dots_empty()

    if (rlang::is_missing(year)) {
        stop("argument \"year\" is missing, with no default")
    }

    fields <- list(year = year, month = month, day = day)
    fields <- vec_cast_common(!!!fields, .to = integer())
    fields <- vec_recycle_common(!!!fields)
    fields <- df_list_propagate_missing(fields)
    new_jdate(jdate_make_cpp(fields))
}

# Print ------------------------------------------------------------------

#' @export
vec_ptype_full.jdate <- function(x, ...) {
    "jdate"
}

#' @export
vec_ptype_abbr.jdate <- function(x, ...) {
    "jdate"
}

# Coerce ------------------------------------------------------------------

#' @rdname shide-vctrs
#' @export vec_ptype2.jdate
#' @method vec_ptype2 jdate
#' @export
vec_ptype2.jdate <- function(x, y, ...) {
    UseMethod("vec_ptype2.jdate")
}

#' @method vec_ptype2.jdate jdate
#' @export
vec_ptype2.jdate.jdate <- function(x, y, ...) new_jdate()

#' @method vec_ptype2.jdate jdatetime
#' @export
vec_ptype2.jdate.jdatetime <- function(x, y, ...) {
    new_jdatetime(tzone = tzone(y))
}

# Cast --------------------------------------------------------------------

#' @rdname shide-vctrs
#' @export vec_cast.jdate
#' @method vec_cast jdate
#' @export
vec_cast.jdate <- function(x, to, ...) {
    UseMethod("vec_cast.jdate")
}

#' @method vec_cast.jdate jdate
#' @export
vec_cast.jdate.jdate <- function(x, to, ...) {
    x
}

#' @method vec_cast.jdate Date
#' @export
vec_cast.jdate.Date <- function(x, to, ...) {
    new_jdate(vec_data(x))
}

#' @method vec_cast.jdate POSIXct
#' @export
vec_cast.jdate.POSIXct <- function(x, to, ...) {
    vec_cast(as.Date(x, tz = tzone(x)), new_jdate())
}

#' @method vec_cast.jdate jdatetime
#' @export
vec_cast.jdate.jdatetime <- function(x, to, ...) {
    tz <- tzone(to)
    if (identical(tz, "")) {
        tz <- get_current_tzone()
    }

    ld <- local_days_from_sys_seconds_cpp(vec_data(x), tz)
    new_jdate(ld)
}

#' @method vec_cast.double jdate
#' @export
vec_cast.double.jdate <- function(x, to, ...) {
    vec_data(x)
}

#' @method vec_cast.integer jdate
#' @export
vec_cast.integer.jdate <- function(x, to, ...) {
    as.integer(vec_data(x))
}

#' @method vec_cast.character jdate
#' @export
vec_cast.character.jdate <- function(x, to, ...) {
    format(x)
}

#' Convert an object to a `jdate`
#'
#' A generic function that converts other date/time classes to `jdate`.
#'
#' @details Unlike R's `as.Date.POSIXct()` method, `as_jdate` does not expose a time zone argument
#'     and uses time zone attribute of input datetime object for conversion.
#' @param x a vector of `jdatetime`, `POSIXct` or `Date`.
#' @inheritParams rlang::args_dots_empty
#' @return A vector of `jdate` objects with the same length as x.
#' @examples
#' as_jdate(as.Date("2023-12-12"))
#' as_jdate(jdatetime("1402-09-21 13:14:00", tzone = "Asia/Tehran"))
#' as_jdate(as.POSIXct("2023-12-12 13:14:00", tz = "Asia/Tehran"))
#' @export
as_jdate <- function(x, ...) {
    UseMethod("as_jdate")
}

#' @export
as_jdate.default <- function(x, ...) {
    vec_cast(x, new_jdate())
}

# Arithmetic --------------------------------------------------------------

#' @rdname shide-vctrs
#' @export vec_arith.jdate
#' @method vec_arith jdate
#' @export
vec_arith.jdate <- function(op, x, y, ...) {
    UseMethod("vec_arith.jdate", y)
}

#' @method vec_arith.jdate default
#' @export
vec_arith.jdate.default <- function(op, x, y, ...) {
    stop_incompatible_op(op, x, y)
}


#' @method vec_arith.jdate jdate
#' @export
vec_arith.jdate.jdate <- function(op, x, y, ...) {
    switch(
        op,
        `-` = new_duration(vec_arith_base("-", x, y), units = "days"),
        stop_incompatible_op(op, x, y)
    )
}

#' @method vec_arith.jdate jdatetime
#' @export
vec_arith.jdate.jdatetime <- function(op, x, y, ...) {
    switch(
        op,
        `-` = new_duration(vec_arith_base("-", as_jdatetime(x), y), units = "secs"),
        stop_incompatible_op(op, x, y)
    )
}

#' @method vec_arith.jdate numeric
#' @export
vec_arith.jdate.numeric <- function(op, x, y, ...) {
    switch(
        op,
        `+` = new_jdate(vec_arith_base(op, x, y)),
        `-` = new_jdate(vec_arith_base(op, x, y)),
        stop_incompatible_op(op, x, y)
    )
}

#' @method vec_arith.numeric jdate
#' @export
vec_arith.numeric.jdate <- function(op, x, y, ...) {
    switch(
        op,
        `+` = new_jdate(vec_arith_base(op, x, y)),
        stop_incompatible_op(op, x, y)
    )
}

#' @method vec_arith.jdate difftime
#' @export
vec_arith.jdate.difftime <- function(op, x, y, ...) {
    y <- vec_cast(y, new_duration(units = "days"))
    if (y != floor(y)) {
        # this is slightly different from vctrs approach
        maybe_lossy_cast(
            floor(y), y, new_duration(units = "days"),
            lossy = TRUE, x_arg = "", to_arg = ""
        )
    }

    switch(
        op,
        `+` = ,
        `-` = new_jdate(vec_arith_base(op, x, y)),
        stop_incompatible_op(op, x, y)
    )
}

#' @method vec_arith.difftime jdate
#' @export
vec_arith.difftime.jdate <- function(op, x, y, ...) {
    x <- vec_cast(x, new_duration(units = "days"))
    if (x != floor(x)) {
        # this is slightly different from vctrs approach
        maybe_lossy_cast(
            floor(x), x, new_duration(units = "days"),
            lossy = TRUE, x_arg = "", to_arg = ""
        )
    }

    switch(
        op,
        `+` = new_jdate(vec_arith_base(op, x, y)),
        stop_incompatible_op(op, x, y)
    )
}

# Math --------------------------------------------------------------------

#' @rdname shide-vctrs
#' @export
vec_math.jdate <- function(.fn, .x, ...) {
    switch(.fn,
           is.finite = vec_math_base(.fn, .x, ...),
           is.infinite = vec_math_base(.fn, .x, ...),
           rlang::abort("unsupported operation.")
    )
}

#' @export
chooseOpsMethod.jdate <- function(x, y, mx, my, cl, reverse) TRUE
