tzone <- function(x) {
    attr(x, "tzone")[[1]] %||% ""
}

#' @export
sh_year <- function(x) {
    UseMethod("sh_year")
}

#' @export
sh_year.jdate <- function(x) {
    fields <- jdate_get_fields_cpp(x)
    fields$year
}

#' @export
sh_year.jdatetime <- function(x) {
    fields <- jdatetime_get_fields_cpp(x)
    fields$year
}

#' @export
sh_month <- function(x) {
    UseMethod("sh_month")
}

#' @export
sh_month.jdate <- function(x) {
    fields <- jdate_get_fields_cpp(x)
    fields$month
}

#' @export
sh_month.jdatetime <- function(x) {
    fields <- jdatetime_get_fields_cpp(x)
    fields$month
}

#' @export
sh_day <- function(x) {
    UseMethod("sh_day")
}

#' @export
sh_day.jdate <- function(x) {
    fields <- jdate_get_fields_cpp(x)
    fields$day
}

#' @export
sh_day.jdatetime <- function(x) {
    fields <- jdatetime_get_fields_cpp(x)
    fields$day
}

#' @export
sh_doy <- function(x) {
    UseMethod("sh_doy")
}

#' @export
sh_doy.jdate <- function(x) {
    jdate_get_doy_cpp(x)
}

#' @export
sh_doy.jdatetime <- function(x) {
    jdate_get_doy_cpp(as_jdate(x))
}

#' @export
sh_hour <- function(x) {
    UseMethod("sh_hour")
}

#' @export
sh_hour.jdatetime <- function(x) {
    fields <- jdatetime_get_fields_cpp(x)
    fields$hour
}

#' @export
sh_minute <- function(x) {
    UseMethod("sh_minute")
}

#' @export
sh_minute.jdatetime <- function(x) {
    fields <- jdatetime_get_fields_cpp(x)
    fields$minute
}

#' @export
sh_second <- function(x) {
    UseMethod("sh_second")
}

#' @export
sh_second.jdatetime <- function(x) {
    fields <- jdatetime_get_fields_cpp(x)
    fields$second
}
