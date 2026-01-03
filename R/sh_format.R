#' @export
sh_format <- function(x, ...) {
    UseMethod("sh_format")
}

#' @export
sh_format.jdate <- function(x, format = NULL, ..., labels = NULL) {
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

#' @export
sh_format.jdatetime <- function(x, format = NULL, ..., labels = NULL) {
    format <- format %||% "%Y-%m-%d %T %z"
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
