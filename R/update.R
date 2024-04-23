jdate_update <- function(x, fields) {
    size <- vec_size_common(x = x, !!!fields)
    x <- vec_recycle(x, size)
    fields <- vec_cast_common(!!!fields, .to = integer())
    fields <- vec_recycle_common(!!!fields, .size = size)
    fields <- df_list_propagate_missing(fields)
    fields_x <- jdate_get_fields_cpp(x)
    fields_out <- vec_assign(fields_x, names(fields), fields)
    out <- jdate_make_cpp(fields_out)
    names(out) <- names(x)
    jdate(out)
}

jdatetime_update <- function(x, fields, ..., ambiguous = NULL) {
    if (!is.null(ambiguous)) {
        ambiguous <- validate_ambiguous(ambiguous)
    }

    size <- vec_size_common(x = x, !!!fields)
    x <- vec_recycle(x, size)

    tz <- tzone(x)
    local_tz <- identical(tz, "")
    if (local_tz) {
        tz <- get_current_tzone()
    }

    fields <- vec_cast_common(!!!fields, .to = integer())
    fields <- vec_recycle_common(!!!fields, .size = size)
    fields <- df_list_propagate_missing(fields)
    fields_x <- jdatetime_get_fields_cpp(x)
    fields_out <- vec_assign(fields_x, names(fields), fields)

    if (is.null(ambiguous)) {
        out <- jdatetime_make_with_reference_cpp(fields_out, tz, x)
    } else {
        out <- jdatetime_make_cpp(fields_out, tz, ambiguous = ambiguous)
    }

    if (local_tz) tz = ""
    names(out) <- names(x)
    jdatetime(out, tz)
}
