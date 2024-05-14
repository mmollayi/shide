# this is a modified version of an internal function with the same name in vctrs package
maxtype_mat <- function(types) {
    nms <- vapply(types, vec_ptype_full, character(1))
    grid <- expand.grid(x = types, y = types)
    grid$max <- mapply(function(x, y) vec_ptype_full(vec_ptype2(x, y)), grid$x, grid$y)
    matrix(grid$max, nrow = length(types), dimnames = list(nms, nms))
}
