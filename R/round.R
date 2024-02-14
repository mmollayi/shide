#' @export
sh_floor <- function(x, unit, ...) {
    UseMethod("sh_floor")
}

#' @export
sh_floor.jdate <- function(x, unit, ...) {
    switch (unit,
        year = jdate_update(x, list(day = 1, month = 1)),
        quarter = jdate_update(x, list(day = 1, month = 3 * (sh_month(x) %/% 3) + 1)),
        month = jdate_update(x, list(day = 1)),
        day = jdate_update(x, list())
    )
}
