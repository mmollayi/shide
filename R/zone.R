get_sys_info <- function(x) {
    out <- get_sys_info_cpp(x)
    vctrs::data_frame(
        name = out$name,
        abbreviation = out$abbreviation,
        offset = new_duration(out$offset, "secs"),
        dst = new_duration(out$dst, "mins")
    )
}

get_local_info <- function(x, tzone) {
    out <- get_local_info_cpp(x, tzone)
    vctrs::data_frame(
        name = out$name,
        type = out$type,
        first = vctrs::data_frame(
            abbreviation = out$first$abreviation,
            offset = out$first$offset,
            dst = out$first$dst
        ),
        second = vctrs::data_frame(
            abbreviation = out$second$abreviation,
            offset = out$second$offset,
            dst = out$second$dst
        )
    )
}
