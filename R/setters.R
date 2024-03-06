#' @rdname sh_year
#' @export
"sh_year<-" <- function(x, value) {
    UseMethod("sh_year<-")
}

#' @rdname sh_month
#' @export
"sh_month<-" <- function(x, value) {
    UseMethod("sh_month<-")
}

#' @rdname sh_day
#' @export
"sh_day<-" <- function(x, value) {
    UseMethod("sh_day<-")
}

#' @rdname sh_day
#' @export
"sh_mday<-" <- function(x, value) {
    UseMethod("sh_day<-")
}

#' @rdname sh_hour
#' @export
"sh_hour<-" <- function(x, value) {
    UseMethod("sh_hour<-")
}

#' @rdname sh_hour
#' @export
"sh_minute<-" <- function(x, value) {
    UseMethod("sh_minute<-")
}

#' @rdname sh_hour
#' @export
"sh_second<-" <- function(x, value) {
    UseMethod("sh_second<-")
}

#' @rdname sh_year
#' @export
"sh_year<-.jdate" <- function(x, value) {
    jdate_update(x, list(year = value))
}

#' @rdname sh_year
#' @export
"sh_year<-.jdatetime" <- function(x, value) {
    jdatetime_update(x, list(year = value))
}

#' @rdname sh_month
#' @export
"sh_month<-.jdate" <- function(x, value) {
    jdate_update(x, list(month = value))
}

#' @rdname sh_month
#' @export
"sh_month<-.jdatetime" <- function(x, value) {
    jdatetime_update(x, list(month = value))
}

#' @rdname sh_day
#' @export
"sh_day<-.jdate" <- function(x, value) {
    jdate_update(x, list(day = value))
}

#' @rdname sh_day
#' @export
"sh_day<-.jdatetime" <- function(x, value) {
    jdatetime_update(x, list(day = value))
}

#' @rdname sh_hour
#' @export
"sh_hour<-.jdatetime" <- function(x, value) {
    jdatetime_update(x, list(hour = value))
}

#' @rdname sh_hour
#' @export
"sh_minute<-.jdatetime" <- function(x, value) {
    jdatetime_update(x, list(minute = value))
}

#' @rdname sh_hour
#' @export
"sh_second<-.jdatetime" <- function(x, value) {
    jdatetime_update(x, list(second = value))
}
