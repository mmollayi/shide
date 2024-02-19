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
