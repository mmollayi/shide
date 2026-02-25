#' Format Jalali date-time objects
#'
#' Format objects of class `jdate` and `jdatetime` into character vectors
#' using a specified format string and optional localized labels.
#'
#' @param x A `jdate` or `jdatetime` vector.
#' @param format A character string specifying the output format. If `NULL`,
#'   a default format is used.
#' @param tz Optional time zone for `jdatetime` objects. If provided, the
#'   date-time is formatted as if displayed in this time zone.
#' @inheritParams rlang::args_dots_empty
#' @param labels An object of class `shide_labels` created from [sh_labels()]
#' @return A character vector representing the formatted dates or date-times.
#' @seealso [base::strftime()]
#' @name shide-format
NULL

#' @rdname shide-format
#' @export
format.jdate <- function(x, format = NULL, ..., labels = NULL) {
    check_character(format, allow_na = FALSE, allow_null = TRUE)
    format <- format %||% "%Y-%m-%d"
    if (is.null(labels)) {
        labels <- shide_labels_default
    } else {
        if (!inherits(labels, "shide_labels")) {
            cli::cli_abort("{.var labels} must be a {.cls shide_lables} object.")
        }
    }

    out <- format_jdate_cpp(x, format, labels$month,
                            labels$month_abbr, labels$weekday, labels$weekday_abbr)
    names(out) <- names(x)
    out
}

#' @rdname shide-format
#' @export
format.jdatetime <- function(x, format = NULL, tz = NULL, ..., labels = NULL) {
    check_character(format, allow_na = FALSE, allow_null = TRUE)
    format <- format %||% "%Y-%m-%d %T"

    if (!is.null(tz))
        x <- as_jdatetime(x, tz)

    if (is.null(labels)) {
        labels <- shide_labels_default
    } else {
        if (!inherits(labels, "shide_labels")) {
            cli::cli_abort("{.var labels} must be a {.cls shide_lables} object.")
        }
    }

    out <- format_jdatetime_cpp(x, format, labels$month, labels$month_abbr,
                                labels$weekday, labels$weekday_abbr, labels$am_pm)
    names(out) <- names(x)
    out
}
