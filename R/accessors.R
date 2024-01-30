tzone <- function(x) {
    attr(x, "tzone")[[1]] %||% ""
}

#' @method year jdate
#' @export
year.jdate <- function(x) {
    fields <- jdate_get_fields_cpp(x)
    fields$year
}

#' @method month jdate
#' @export
month.jdate <- function(x) {
    fields <- jdate_get_fields_cpp(x)
    fields$month
}

#' @method mday jdate
#' @export
mday.jdate <- function(x) {
    fields <- jdate_get_fields_cpp(x)
    fields$day
}

#' @method yday jdate
#' @export
yday.jdate <- function(x) {
    jdate_get_yday_cpp(x)
}

#' @method year jdatetime
#' @export
year.jdatetime <- function(x) {
    fields <- jdatetime_get_fields_cpp(x)
    fields$year
}

#' @method month jdatetime
#' @export
month.jdatetime <- function(x) {
    fields <- jdatetime_get_fields_cpp(x)
    fields$month
}

#' @method mday jdatetime
#' @export
mday.jdatetime <- function(x) {
    fields <- jdatetime_get_fields_cpp(x)
    fields$day
}

#' @method hour jdatetime
#' @export
hour.jdatetime <- function(x) {
    fields <- jdatetime_get_fields_cpp(x)
    fields$hour
}

#' @method minute jdatetime
#' @export
minute.jdatetime <- function(x) {
    fields <- jdatetime_get_fields_cpp(x)
    fields$minute
}

#' @method second jdatetime
#' @export
second.jdatetime <- function(x) {
    fields <- jdatetime_get_fields_cpp(x)
    fields$second
}

#' @method yday jdatetime
#' @export
yday.jdatetime <- function(x) {
    jdate_get_yday_cpp(as_jdate(x))
}

#' @method tz jdatetime
#' @export
tz.jdatetime <- function(x) {
    tzone(x)
}
