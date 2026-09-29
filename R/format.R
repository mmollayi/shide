#' Format Jalali date-time objects
#'
#' Format objects of class `jdate` and `jdatetime` into character vectors
#' using a specified format string and optional localized labels.
#'
#' @param x A `jdate` or `jdatetime` vector.
#' @param format A character string specifying the output format. If `NULL`,
#'   a default format is used. See "Format directives" for a complete list
#'   of supported directives.
#' @param tz Optional time zone for `jdatetime` objects. If provided, the
#'   date-time is formatted as if displayed in this time zone.
#' @inheritParams rlang::args_dots_empty
#' @param labels An object of class `shide_labels` created from [sh_labels()]
#' @section Format directives:
#' The `format` string may contain ordinary characters and formatting
#' directives. Ordinary characters are copied unchanged to the output.
#' Formatting directives begin with `%` and are replaced by the corresponding
#' date or time component.
#'
#' - %a: Abbreviated weekday name.
#' - %A: Full weekday name.
#' - %b: Abbreviated month name.
#' - %B: Full month name.
#' - %C: Year divided by 100 using floored division, zero-padded if the result is a single digit (00–99).
#' - %d: Day of the month as a zero-padded decimal number (01-31).
#' - %e: Day of the month as a space-padded decimal number ( 1-31).
#' - %F: Equivalent to %Y-%m-%d.
#' - %J: Equivalent to %Y/%m/%d.
#' - %H: Hour as a zero-padded decimal number using a 24-hour clock (00-23).
#' - %I: Hour as a zero-padded decimal number using a 12-hour clock (01-12).
#' - %j: Day of the year as a zero-padded decimal number (001-366).
#' - %m: Month as a zero-padded decimal number (01-12).
#' - %M: Minute as a zero-padded decimal number (00-59).
#' - %n: Newline character.
#' - %p: AM/PM indicator.
#' - %r: Equivalent to %I:%M:%S %p.
#' - %R: Equivalent to %H:%M.
#' - %S: Second as a zero-padded decimal number (00-59).
#' - %t: Tab character.
#' - %T: Equivalent to %H:%M:%S.
#' - %y: Last two decimal digits of the year, zero-padded if the result is a single digit (00-99).
#' - %Y: Year as a four-digits zero-padded decimal number (0000-9999).
#' - %z: Signed offset from UTC in the form `+HHMM` or `-HHMM`.
#' - %Z: Time zone abbreviation or name.
#' - %%: A % character.
#' @return A character vector representing the formatted dates or date-times.
#' @seealso [base::strftime()]
#' @name shide-format
#' @examples
#' x <- jdate("1405-06-29")
#' format(x, "%Y/%m/%d")
#' format(x, "%J")
#' format(x, "%A, %d %B %Y")
#'
#' # Use custom labels
#' labels <- sh_labels(
#'    weekday = c(
#'        "Shanbe", "Yekshanbe", "Doshanbe", "Seshanbe",
#'        "Chaharshanbe", "Panjshanbe", "Adine"
#'    )
#' )
#' format(x, "%A, %d %B %Y", labels = labels)
#'
#' x <- jdatetime("1405-06-29 12:00:00", tzone = "Asia/Tehran")
#' # Format the same instant in different time zones.
#' format(x, "%F %T %Z (%z)")
#' format(x, "%F %T %Z (%z)", tz = "UTC")
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
            cli::cli_abort(
                "{.var labels} must be a {.cls shide_lables} object."
            )
        }
    }

    out <- format_jdate_cpp(
        x,
        format,
        labels$month,
        labels$month_abbr,
        labels$weekday,
        labels$weekday_abbr
    )
    names(out) <- names(x)
    out
}

#' @rdname shide-format
#' @export
format.jdatetime <- function(x, format = NULL, tz = NULL, ..., labels = NULL) {
    check_character(format, allow_na = FALSE, allow_null = TRUE)
    format <- format %||% "%Y-%m-%d %T"

    if (!is.null(tz)) {
        x <- as_jdatetime(x, tz)
    }

    if (is.null(labels)) {
        labels <- shide_labels_default
    } else {
        if (!inherits(labels, "shide_labels")) {
            cli::cli_abort(
                "{.var labels} must be a {.cls shide_lables} object."
            )
        }
    }

    out <- format_jdatetime_cpp(
        x,
        format,
        labels$month,
        labels$month_abbr,
        labels$weekday,
        labels$weekday_abbr,
        labels$am_pm
    )
    names(out) <- names(x)
    out
}
