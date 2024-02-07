#' Determine if a Jalali year is a leap year
#'
#' Check if an instant is in a leap year according to the Jalali calendar.
#' @param x A `jdate` or `jdatetime` object or a numeric vector representing Jalali years.
#' @return `TRUE` if in a leap year or `FALSE` otherwise.
#' @examples
#' sh_year_is_leap(jdatetime("1399-01-01 00:00:00"))
#' x <- seq(jdate("1400-01-01"), by = "years", length.out = 10)
#' names(x) <- sh_year(x)
#' sh_year_is_leap(x)
#' @export
sh_year_is_leap <- function(x) {
    if (is.numeric(x)) {
        yr <- as.integer(x)
    } else {
        yr <- sh_year(x)
    }

    out <- year_is_leap_cpp(yr)
    names(out) <- names(x)
    out
}
