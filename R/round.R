#' @export
sh_floor <- function(x, unit, ...) {
    UseMethod("sh_floor")
}

#' @export
sh_floor.jdate <- function(x, unit, ...) {
    jdate(jdate_floor_cpp(x, unit))
}

#' @export
sh_ceiling <- function(x, unit, ...) {
    UseMethod("sh_ceiling")
}

#' @export
sh_ceiling.jdate <- function(x, unit, ...) {
    jdate(jdate_ceiling_cpp(x, unit))
}

#' @export
sh_round <- function(x, unit, ...) {
    UseMethod("sh_round")
}

#' @export
sh_round.jdate <- function(x, unit, ...) {
    upper <- vec_data(sh_ceiling(x, unit))
    lower <- vec_data(sh_floor(x, unit))
    xx <- trunc(vec_data(x))
    up <- (upper - xx) <= (xx - lower)
    up <- !is.na(up) & up
    lower[up] <- upper[up]
    jdate(lower)
}
