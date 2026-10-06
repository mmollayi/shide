# this is a modified version of an internal function with the same name in vctrs package
maxtype_mat <- function(types) {
    nms <- vapply(types, vec_ptype_full, character(1))
    grid <- expand.grid(x = types, y = types)
    grid$max <- mapply(
        function(x, y) vec_ptype_full(vec_ptype2(x, y)),
        grid$x,
        grid$y
    )
    matrix(grid$max, nrow = length(types), dimnames = list(nms, nms))
}

test_labels <- sh_labels(
    month = paste0("Month-", 1:12),
    month_abbr = paste0("Mon-", 1:12),
    weekday = paste0("Weekday-", 1:7),
    weekday_abbr = paste0("Wd-", 1:7),
    am_pm = c("A", "P")
)
