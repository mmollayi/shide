seq.jdate <- function(from, to, by, length.out = NULL, along.with = NULL, ...) {
    check_dots_empty()

    if (missing(from)) {
        stop("'from' must be specified")
    } else {
        if (!inherits(from, "jdate")) {
            stop("'from' must be a \"jdate\" object")
        }

        if (length(from) != 1L) {
            stop("'from' must be of length 1")
        }

        from <- as.Date(from)
    }

    if (!missing(to)) {
        if (!inherits(to, "jdate")) {
            stop("'to' must be a \"jdate\" object")
        }
        if (length(to) != 1L) {
            stop("'to' must be of length 1")
        }

        to <- as.Date(to)
    }

    if (!missing(by)) {
        if (length(by) != 1L) {
            stop("'by' must be of length 1")
        }

        if (is.character(by)) {
            by2 <- strsplit(by, " ", fixed = TRUE)[[1L]]
            if (length(by2) > 2L || length(by2) < 1L) {
                stop("invalid 'by' string")
            }
            valid <- pmatch(by2[length(by2)], c(
                "days", "weeks"
            ))

            if (is.na(valid)) {
                stop("invalid string for 'by'")
            }
        }
    }

    args <- list(
        from = from,
        to = maybe_missing(to, default = NULL),
        by = maybe_missing(by, default = NULL),
        length.out = maybe_missing(length.out, default = NULL),
        along.with = maybe_missing(along.with, default = NULL)
    )
    args <- args[!vapply(args, is.null, logical(1))]

    res <- do.call("seq.Date", args)
    as_jdate(res)
}

seq.jdatetime <- function(from, to, by, length.out = NULL, along.with = NULL) {
    if (missing(from)) {
        stop("'from' must be specified")
    } else {
        if (!inherits(from, "jdatetime")) {
            stop("'from' must be a \"jdatetime\" object")
        }

        if (length(from) != 1L) {
            stop("'from' must be of length 1")
        }

        from <- as.POSIXct(from)
    }

    if (!missing(to)) {
        if (!inherits(to, "jdatetime")) {
            stop("'to' must be a \"jdatetime\" object")
        }
        if (length(to) != 1L) {
            stop("'to' must be of length 1")
        }

        to <- as.POSIXct(to)
    }

    if (!missing(by)) {
        if (length(by) != 1L) {
            stop("'by' must be of length 1")
        }

        if (is.character(by)) {
            by2 <- strsplit(by, " ", fixed = TRUE)[[1L]]
            if (length(by2) > 2L || length(by2) < 1L) {
                stop("invalid 'by' string")
            }
            valid <- pmatch(by2[length(by2)], c(
                "secs", "mins", "hours", "days", "weeks", "months"
            ))

            if (is.na(valid)) {
                stop("invalid string for 'by'")
            }
        }
    }

    args <- list(
        from = from,
        to = maybe_missing(to, default = NULL),
        by = maybe_missing(by, default = NULL),
        length.out = maybe_missing(length.out, default = NULL),
        along.with = maybe_missing(along.with, default = NULL)
    )
    args <- args[!vapply(args, is.null, logical(1))]

    res <- do.call("seq.POSIXt", args)
    as_jdatetime(res)
}
