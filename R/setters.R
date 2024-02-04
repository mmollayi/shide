jdate_set_field <- function(x, value, field) {
    fields <- jdate_get_fields_cpp(x)
    fields[[field]] <- vec_cast(value, integer())
    fields <- vec_recycle_common(!!!fields)
    fields <- df_list_propagate_missing(fields)
    out <- jdate(jdate_make_cpp(fields))
    names(out) <- names(x)
    out
}

jdatetime_set_field <- function(x, value, field) {
    tz <- tzone(x)
    local_tz <- identical(tz, "")
    if (local_tz) {
        tz <- get_current_tzone()
    }

    fields <- jdatetime_get_fields_cpp(x)
    fields[[field]] <- vec_cast(value, integer())
    fields <- vec_recycle_common(!!!fields)
    fields <- df_list_propagate_missing(fields)
    out <- jdatetime_make_cpp(fields, tz)
    if (local_tz) tz = ""
    out <- jdatetime(out, tz)
    names(out) <- names(x)
    out
}

#' @export
"sh_year<-" <- function(x, value) {
    UseMethod("sh_year<-")
}

#' @export
"sh_month<-" <- function(x, value) {
    UseMethod("sh_month<-")
}

#' @export
"sh_day<-" <- function(x, value) {
    UseMethod("sh_day<-")
}

#' @export
"sh_hour<-" <- function(x, value) {
    UseMethod("sh_hour<-")
}

#' @export
"sh_minute<-" <- function(x, value) {
    UseMethod("sh_minute<-")
}

#' @export
"sh_second<-" <- function(x, value) {
    UseMethod("sh_second<-")
}

#' @export
"sh_year<-.jdate" <- function(x, value) {
    jdate_set_field(x, value, "year")
}

#' @export
"sh_year<-.jdatetime" <- function(x, value) {
    jdatetime_set_field(x, value, "year")
}

#' @export
"sh_month<-.jdate" <- function(x, value) {
    jdate_set_field(x, value, "month")
}

#' @export
"sh_month<-.jdatetime" <- function(x, value) {
    jdatetime_set_field(x, value, "month")
}

#' @export
"sh_day<-.jdate" <- function(x, value) {
    jdate_set_field(x, value, "day")
}

#' @export
"sh_day<-.jdatetime" <- function(x, value) {
    jdatetime_set_field(x, value, "day")
}

#' @export
"sh_hour<-.jdatetime" <- function(x, value) {
    jdatetime_set_field(x, value, "hour")
}

#' @export
"sh_minute<-.jdatetime" <- function(x, value) {
    jdatetime_set_field(x, value, "minute")
}

#' @export
"sh_second<-.jdatetime" <- function(x, value) {
    jdatetime_set_field(x, value, "second")
}
