sh_lables <- function(month, month_abbr = month, weekday, weekday_abbr = weekday, am_pm) {
    if (!is_character(month, n = 12L)) {
        cli::cli_abort("{.var month} must be a character vector of length 12.")
    }
    if (!is_character(month_abbr, n = 12L)) {
        cli::cli_abort("{.var month_abbr} must be a character vector of length 12.")
    }
    if (!is_character(weekday, n = 7L)) {
        cli::cli_abort("{.var weekday} must be a character vector of length 7.")
    }
    if (!is_character(weekday_abbr, n = 7L)) {
        cli::cli_abort("{.var weekday_abbr} must be a character vector of length 7.")
    }
    if (!is_character(am_pm, n = 2L)) {
        cli::cli_abort("{.var am_pm} must be a character vector of length 2.")
    }

    structure(
        list(
            month = enc2utf8(month),
            month_abbr = enc2utf8(month_abbr),
            weekday = enc2utf8(weekday),
            weekday_abbr = enc2utf8(weekday_abbr),
            am_pm = enc2utf8(am_pm)
        ),
        class = "shide_labels"
    )
}

#' @export
print.shide_labels <- function(x, ...) {
    cat(
        "<shide_labels>\n",
        "\nMonths:\n", paste0(x$month, collapse = ", "),
        "\n\nMonth abbreviations:\n", paste0(x$month_abbr, collapse = ", "),
        "\n\nWeekdays:\n", paste0(x$weekday, collapse = ", "),
        "\n\nWeekday abbreviations:\n", paste0(x$weekday_abbr, collapse = ", ", sep = ""),
        "\n\nAM/PM:\n", paste0(x$am_pm, collapse = "/"),
        sep = ""
    )
}
