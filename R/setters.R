jdate_set_field <- function(x, value, field) {
    fields <- jdate_get_fields_cpp(x)
    fields[[field]] <- vec_cast(value, integer())
    fields <- vec_recycle_common(!!!fields)
    fields <- df_list_propagate_missing(fields)
    out <- jdate(jdate_make_cpp(fields))
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
"sh_year<-.jdate" <- function(x, value) {
    jdate_set_field(x, value, "year")
}

#' @export
"sh_month<-.jdate" <- function(x, value) {
    jdate_set_field(x, value, "month")
}

#' @export
"sh_day<-.jdate" <- function(x, value) {
    jdate_set_field(x, value, "day")
}
