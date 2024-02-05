tzone <- function(x) {
    attr(x, "tzone")[[1]] %||% ""
}

jdate_get_field <- function(x, field) {
    fields <- jdate_get_fields_cpp(x)
    out <- fields[[field]]
    names(out) <- names(x)
    out
}

jdatetime_get_field <- function(x, field) {
    fields <- jdatetime_get_fields_cpp(x)
    out <- fields[[field]]
    names(out) <- names(x)
    out
}

#' @export
sh_year <- function(x) {
    UseMethod("sh_year")
}

#' @export
sh_month <- function(x) {
    UseMethod("sh_month")
}

#' @export
sh_day <- function(x) {
    UseMethod("sh_day")
}

#' @export
sh_doy <- function(x) {
    UseMethod("sh_doy")
}

#' @export
sh_hour <- function(x) {
    UseMethod("sh_hour")
}

#' @export
sh_minute <- function(x) {
    UseMethod("sh_minute")
}

#' @export
sh_second <- function(x) {
    UseMethod("sh_second")
}

#' @export
sh_year.jdate <- function(x) {
    jdate_get_field(x, "year")
}

#' @export
sh_year.jdatetime <- function(x) {
    jdatetime_get_field(x, "year")
}

#' @export
sh_month.jdate <- function(x) {
    jdate_get_field(x, "month")
}

#' @export
sh_month.jdatetime <- function(x) {
    jdatetime_get_field(x, "month")
}

#' @export
sh_day.jdate <- function(x) {
    jdate_get_field(x, "day")
}

#' @export
sh_day.jdatetime <- function(x) {
    jdatetime_get_field(x, "day")
}

#' @export
sh_doy.jdate <- function(x) {
    out <- jdate_get_doy_cpp(x)
    names(out) <- names(x)
    out
}

#' @export
sh_doy.jdatetime <- function(x) {
    out <- jdate_get_doy_cpp(as_jdate(x))
    names(out) <- names(x)
    out
}

#' @export
sh_hour.jdatetime <- function(x) {
    jdatetime_get_field(x, "hour")
}

#' @export
sh_minute.jdatetime <- function(x) {
    jdatetime_get_field(x, "minute")
}

#' @export
sh_second.jdatetime <- function(x) {
    jdatetime_get_field(x, "second")
}
