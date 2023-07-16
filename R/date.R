#' @method vec_cast.Date jdate
#' @export
vec_cast.Date.jdate <- function(x, to, ...) {
    new_date(vec_data(x))
}

#' @method vec_cast.Date jdatetime
#' @export
vec_cast.Date.jdatetime <- function(x, to, ...) {
    as.Date(as.POSIXct(x), tz = tzone(x))
}
#
#' @method as.Date jdate
#' @export
as.Date.jdate <- function(x, ...) {
    new_date(vec_data(x))
}

#' @method as.Date jdatetime
#' @export
as.Date.jdatetime <- function(x, tz, ...) {
    if (rlang::is_missing(tz)) {
        tz <- tzone(x)
    }

    as.Date(as.POSIXct(x, tz), tz = tz)
}
