tzone <- function(x) {
    attr(x, "tzone")[[1]] %||% ""
}
