new_jdatetime <- function(x = double(), tzone = "") {
    vec_assert(x, double())

    if (is.null(tzone)) {
        tzone = ""
    }

    if (!is.character(tzone) && length(tzone) != 1L && is.na(tzone)) {
        stop("`tzone` must be a character vector of length 1 or `NULL`.")
    }

    new_vctr(x, class = "jdatetime", tzone = tzone)
}

#' Date-time based on Jalali calendar
#'
#' `jdatetime` is an S3 class for representing date-times with Jalali calendar dates.
#'  It can be constructed from character and numeric vectors.
#'
#' @details `jdatetime` is stored internaly as a double vector and has a single
#'    attribute: the timezone (tzone). Its value represents the count of seconds
#'    since the Unix epoch (a negative value if it represents an instant prior to the epoch).
#'    This implementation coincides with that of `POSIXct` class, except that `POSIXct`
#'    may not have `tzone` attribute. But for `jdatetime`, `tzone` is not optional.
#'
#' @param x A vector of numeric or character objects.
#' @param tzone A time zone name. Default value represents local time zone.
#' @param ... Arguments passed on to further methods.
#' @param format Format argument for character method.
#' @return A vector of `jdatetime` objects
#' @examples
#' ## default time zone and format
#' jdatetime("1402-09-20 18:57:09")
#' jdatetime("1402/09/20 18:57:09", tzone = "UTC", format = "%Y/%m/%d %H:%M:%S")
#' ## Will replace invalid format with NA
#' jdatetime("1402/09/20 18:57:09", format = "%Y-%m-%d %H:%M:%S")
#' ## nonexistent time will be replaced with NA
#' jdatetime("1401-01-02 00:30:00", tzone = "Asia/Tehran")
#' ## ambiguous time will be replaced with NA
#' jdatetime("1401-06-30 23:30:00", tzone = "Asia/Tehran")
#' ## Jalali date-time in Iran time zone, corresponding to Unix epoch
#' jdatetime(0, "Iran")
#' @export
jdatetime <- function(x, tzone = "",...) {
    UseMethod("jdatetime", rlang::maybe_missing(x, NULL))
}

#' @export
jdatetime.NULL <- function(x, tzone = "", ...) {
    check_dots_empty()
    new_jdatetime(tzone = tzone)
}

#' @export
jdatetime.numeric <- function(x, tzone = "", ...) {
    check_dots_empty()
    x <- vec_cast(x, double())
    new_jdatetime(x, tzone)
}

#' @export
jdatetime.character <- function(x, tzone = "", format = NULL, ...) {
    check_dots_empty()
    if (is.null(tzone)) {
        tzone <- ""
    }

    if (!is.character(tzone) && length(tzone) != 1L && is.na(tzone)) {
        stop("`tzone` must be a character vector of length 1 or `NULL`.")
    }

    local_tz <- identical(tzone, "")
    if (local_tz) {
        tzone <- get_current_tzone()
    }

    format <- format %||% "%Y-%m-%d %H:%M:%S"
    seconds_since_epoch <- jdatetime_parse_cpp(x, format, tzone)
    if (local_tz) tzone <- ""
    new_jdatetime(seconds_since_epoch, tzone)
}

#' @export
is_jdatetime <- function(x) {
    inherits(x, "jdatetime")
}

#' @export
format.jdatetime <- function(x, format = NULL, ...) {
    format <- format %||% "%Y-%m-%d %H:%M:%S"
    format_jdatetime_cpp(x, format)
}

#' @export
obj_print_data.jdatetime <- function(x, ...) {
    if (length(x) == 0) return()
    print(format(x))
}

#' Current Jalali date and datetime
#'
#' System representation of the current time as jdate and jdatetime.
#'
#' @param tzone Time zone to get the current time for.
#'
#' @return
#' - `jdate_now()` a jdate object.
#'
#' - `jdatetime_now()` a jdatetime object.
#'
#' @examples
#' # Current Jalali date in the local time zone
#' jdate_now()
#'
#' # Current Jalali date in a specified time zone
#' jdate_now("Asia/Tokyo")
#'
#' # may be true or false
#' jdate_now("Asia/Tehran") == jdate_now("Asia/Tokyo")
#'
#' # Current Jalali datetime in the local time zone
#' jdatetime_now()
#' @export
jdatetime_now <- function(tzone = "") {
    new_jdatetime(vec_data(Sys.time()), tzone)
}

#' Construct jdatetime objects from from individual components
#'
#' @export
jdatetime_make <- function(year, month = 1L, day = 1L,
                           hour = 0L, minute = 0L, second = 0L, tzone = "", ...) {
    check_dots_empty(...)

    if (rlang::is_missing(year)) {
        stop("argument \"year\" is missing, with no default")
    }

    if (is.null(tzone)) {
        tzone <- ""
    }

    if (!is.character(tzone) && length(tzone) != 1L && is.na(tzone)) {
        stop("`tzone` must be a character vector of length 1 or `NULL`.")
    }

    local_tz <- identical(tzone, "")
    if (local_tz) {
        tzone <- get_current_tzone()
    }

    fields <- list(
        year = year, month = month, day = day,
        hour = hour, minute = minute, second = second
    )
    fields <- vec_cast_common(!!!fields, .to = integer())
    fields <- vec_recycle_common(!!!fields)
    fields <- df_list_propagate_missing(fields)

    seconds_since_epoch <- jdatetime_make_cpp(fields, tzone)
    if (local_tz) tzone = ""
    new_jdatetime(seconds_since_epoch, tzone)
}

# Print ------------------------------------------------------------------

#' @export
vec_ptype_full.jdatetime <- function(x, ...) {
    tzone <- if (tzone_is_local(x)) "local" else tzone(x)
    paste0("jdatetime<", tzone, ">")
}

#' @export
vec_ptype_abbr.jdatetime <- function(x, ...) {
    "jdttm"
}

# Coerce ------------------------------------------------------------------

#' @export vec_ptype2.jdatetime
#' @method vec_ptype2 jdatetime
#' @export
vec_ptype2.jdatetime <- function(x, y, ...) {
    UseMethod("vec_ptype2.jdatetime")
}

#' @method vec_ptype2.jdatetime jdatetime
#' @export
vec_ptype2.jdatetime.jdatetime <- function(x, y, ...) {
    new_jdatetime(tzone = tzone_union(x, y))
}

#' @method vec_ptype2.jdatetime jdate
#' @export
vec_ptype2.jdatetime.jdate <- function(x, y, ...) {
    new_jdatetime(tzone = tzone(x))
}

# Cast --------------------------------------------------------------------

#' @export vec_cast.jdatetime
#' @method vec_cast jdatetime
#' @export
vec_cast.jdatetime <- function(x, to, ...) {
    UseMethod("vec_cast.jdatetime")
}

#' @method vec_cast.jdatetime jdatetime
#' @export
vec_cast.jdatetime.jdatetime <- function(x, to, ...) {
    attr(x, "tzone") <- tzone(to)
    x
}

#' @method vec_cast.jdatetime POSIXct
#' @export
vec_cast.jdatetime.POSIXct <- function(x, to, ...) {
    new_jdatetime(vec_data(x), tzone(to))
}

#' @method vec_cast.jdatetime jdate
#' @export
vec_cast.jdatetime.jdate <- function(x, to, ...) {
    tz <- tzone(to)

    local_tz <- identical(tz, "")
    if (local_tz) {
        tz <- get_current_tzone()
    }

    ss <- sys_seconds_from_local_days_cpp(vec_data(x), tz)

    if (local_tz) {
        tz <- ""
    }

    new_jdatetime(ss, tz)
}

#' @method vec_cast.jdatetime Date
#' @export
vec_cast.jdatetime.Date <- function(x, to, ...) {
    xx <- vec_cast(x, new_jdate())
    vec_cast(xx, to)
}

#' @method vec_cast.double jdatetime
#' @export
vec_cast.double.jdatetime <- function(x, to, ...) {
    vec_data(x)
}

#' @method vec_cast.integer jdatetime
#' @export
vec_cast.integer.jdatetime <- function(x, to, ...) {
    as.integer(vec_data(x))
}

#' @method vec_cast.character jdatetime
#' @export
vec_cast.character.jdatetime <- function(x, to, ...) {
    format(x)
}

#' Convert an object to a jdatetime
#'
#' A generic function that converts other date/time classes to jdatetime
#'
#' @param x a vector of jdate, POSIXct or Date.
#' @export
as_jdatetime <- function(x, tzone, ...) {
    UseMethod("as_jdatetime")
}

#' @export
as_jdatetime.default <- function(x, tzone, ...) {
    if (rlang::is_missing(tzone)) {
        tzone <- attr(x, "tzone")[[1]] %||% ""
    }

    vec_cast(x, new_jdatetime(tzone = tzone))
}

# Arithmetic --------------------------------------------------------------

#' @export vec_arith.jdatetime
#' @method vec_arith jdatetime
#' @export
vec_arith.jdatetime <- function(op, x, y, ...) {
    UseMethod("vec_arith.jdatetime", y)
}

#' @method vec_arith.jdatetime default
#' @export
vec_arith.jdatetime.default <- function(op, x, y, ...) {
    stop_incompatible_op(op, x, y)
}

#' @method vec_arith.jdatetime jdatetime
#' @export
vec_arith.jdatetime.jdatetime <- function(op, x, y, ...) {
    switch(
        op,
        `-` = new_duration(vec_arith_base("-", x, y), units = "secs"),
        stop_incompatible_op(op, x, y)
    )
}

#' @method vec_arith.jdatetime jdate
#' @export
vec_arith.jdatetime.jdate <- function(op, x, y, ...) {
    switch(
        op,
        `-` = new_duration(vec_arith_base("-", x, as_jdatetime(y)), units = "secs"),
        stop_incompatible_op(op, x, y)
    )
}

#' @method vec_arith.jdatetime numeric
#' @export
vec_arith.jdatetime.numeric <- function(op, x, y, ...) {
    switch(
        op,
        `+` = new_jdatetime(vec_arith_base(op, x, y), tzone(x)),
        `-` = new_jdatetime(vec_arith_base(op, x, y), tzone(x)),
        stop_incompatible_op(op, x, y)
    )
}

#' @method vec_arith.numeric jdatetime
#' @export
vec_arith.numeric.jdatetime <- function(op, x, y, ...) {
    switch(
        op,
        `+` = new_jdatetime(vec_arith_base(op, x, y), tzone(y)),
        stop_incompatible_op(op, x, y)
    )
}

#' @method vec_arith.jdatetime difftime
#' @export
vec_arith.jdatetime.difftime <- function(op, x, y, ...) {
    y <- vec_cast(y, new_duration(units = "secs"))

    switch(
        op,
        `+` = new_jdatetime(vec_arith_base(op, x, y), tzone(x)),
        `-` = new_jdatetime(vec_arith_base(op, x, y), tzone(x)),
        stop_incompatible_op(op, x, y)
    )
}

#' @method vec_arith.difftime jdatetime
#' @export
vec_arith.difftime.jdatetime <- function(op, x, y, ...) {
    x <- vec_cast(x, new_duration(units = "secs"))

    switch(op,
           `+` = new_jdatetime(vec_arith_base(op, x, y), tzone(y)),
           stop_incompatible_op(op, x, y)
    )
}

# Math --------------------------------------------------------------------

#' @export
vec_math.jdatetime <- function(.fn, .x, ...) {
    switch(.fn,
           is.finite = vec_math_base(.fn, .x, ...),
           is.infinite = vec_math_base(.fn, .x, ...),
           rlang::abort("unsupported operation.")
    )
}
