get_sys_info <- function(x) {
    out <- get_sys_info_cpp(x)
    out <- vctrs::data_frame(
        name = out$name,
        abbreviation = out$abbreviation,
        offset = new_duration(out$offset, "secs"),
        dst = new_duration(out$dst, "mins")
    )
    return(out)
}
