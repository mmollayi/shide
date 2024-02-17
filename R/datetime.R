#' @method vec_cast.POSIXct jdatetime
#' @export
vec_cast.POSIXct.jdatetime <- function(x, to, ...) {
    new_datetime(vec_data(x), tzone(to))
}

#' @method vec_cast.POSIXct jdate
#' @export
vec_cast.POSIXct.jdate <- function(x, to, ...) {
    tz <- tzone(to)
    xx <- vec_cast(x, new_jdatetime(tzone = tz))
    vec_cast(xx, new_datetime(tzone = tz))
}

#' @method as.POSIXct jdate
#' @export
as.POSIXct.jdate <- function(x, tz = "", ...) {
    vec_cast(x, new_datetime(tzone = tz))
}

#' @method as.POSIXct jdatetime
#' @export
as.POSIXct.jdatetime <- function(x, tz, ...) {
    if (rlang::is_missing(tz)) {
        tz <- tzone(x)
    }

    vec_cast(x, new_datetime(tzone = tz))
}
