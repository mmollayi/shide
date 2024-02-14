jdate_update <- function(x, fields) {
    fields <- vec_cast_common(!!!fields, .to = integer())
    fields <- vec_recycle_common(!!!fields, .size = vec_size(x))
    fields <- df_list_propagate_missing(fields)
    fields_x <- jdate_get_fields_cpp(x)
    fields_out <- vec_assign(fields_x, names(fields), fields)
    out <- jdate_make_cpp(fields_out)
    names(out) <- names(x)
    jdate(out)
}
