# borrowed from vctrs
tzone_is_local <- function(x) {
    identical(tzone(x), "")
}

# borrowed from vctrs
tzone_union <- function(x, y) {
    if (tzone_is_local(x)) {
        tzone(y)
    } else {
        tzone(x)
    }
}

get_current_tzone <- function() {
    tz <- Sys.timezone()
    if (is.na(tz) || !nzchar(tz)) {
        warning("System timezone name is unknown. Please set environment variable TZ. Using UTC.")
        tz <- "UTC"
    }
    tz
}

set_attributes <- function(x, attributes) {
    attributes(x) <- attributes
    x
}

unstructure <- function(x) {
    set_attributes(x, NULL)
}

vec_unstructure <- function(x) {
    # Must unclass first because `names()` might not be the same length before
    # and after unclassing
    x <- unclass(x)
    out <- unstructure(x)
    names(out) <- names(x)
    out
}

df_list_propagate_missing <- function(x) {
    x <- new_data_frame(x)

    complete <- vec_detect_complete(x)
    if (all(complete)) {
        return(vec_unstructure(x))
    }

    incomplete <- !complete
    missing <- vec_detect_missing(x)

    aligned <- missing == incomplete
    if (all(aligned)) {
        # Already fully missing where incomplete
        return(vec_unstructure(x))
    }

    n <- length(x)
    out <- vector("list", length = n)
    out <- rlang::set_names(out, names(x))

    # Propagate missings
    x <- vec_assign(x, incomplete, NA)

    vec_unstructure(x)
}
