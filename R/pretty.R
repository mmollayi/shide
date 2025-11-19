#' Pretty breakpoints for Jalali date-times
#'
#' Generates a sequence of about n+1 equally spaced nice,
#' human-friendly time breaks which cover the given range.
#'
#' @param x A vector of `jdate` or `jdatetime` objects.
#' @param n Integer giving the desired number of intervals.
#' @param min.n Nonnegative integer giving the minimal number of intervals.
#' @param sep A character string, serving as a separator for certain formats
#'     (e.g., between month and year).
#' @inheritParams rlang::args_dots_empty
#' @method pretty jdate
#' @export
pretty.jdate <- function(x, n = 5, min.n = n%/%2, sep = " ", ...) {
    check_dots_empty()
    sh_pretty(x, n, min.n, sep)
}

#' @method pretty jdatetime
#' @export
pretty.jdatetime <- function(x, n = 5, min.n = n%/%2, sep = " ", ...) {
    check_dots_empty()
    sh_pretty(x, n, min.n, sep)
}

sh_pretty <- function(x, n = 5, min.n = n%/%2, sep = " ") {
    stopifnot(min.n <= n)
    if (all(is.na(x)))
        return(structure(NA_character_, labels = NA_character_, format = NA_character_))

    resolution <- c("days", "secs")[as.logical(inherits(x, c("jdate", "jdatetime"), which = TRUE))]
    rng <- range(x, na.rm = TRUE)
    # to remove subsecond
    if (resolution == "secs")
        rng <- c(sh_floor(rng[1]), sh_ceiling(rng[2]))

    rng_diff <- diff(rng)
    if (rng_diff < as.difftime(n, units = resolution)) {
        rng <- widen_range(rng, n, resolution)
        if (resolution == "days") {
            sq <- seq(rng[1], rng[2], by = resolution)
            return(make_output(sq, format = paste("%b", "%d", sep = sep)))
        }

        rng_diff <- diff(rng)
    }

    xspan <- as.numeric(rng_diff, units = "secs")
    steps <- gen_steps_data(xspan, sep)
    # crudely work out number of steps in the given interval
    nsteps <- xspan / steps$seconds
    i <- i0 <- which.min(abs(nsteps - n))
    step_i <- steps[i,] |> as.list()
    sq <- calc_steps(rng, step_i$spec, step_i$start)
    len <- length(sq) - 1L
    # bump it up if below acceptable threshold
    while (len < min.n) {
        i <- i - 1L
        step_i <- steps[i,] |> as.list()
        sq <- calc_steps(rng, step_i$spec, step_i$start)
        len <- length(sq) - 1L
    }

    i_is_modified <- i < i0
    dn <- len - n
    # perfect
    if (dn == 0L) {
        return(make_output(sq, step_i$format))
    }
    # too many ticks
    if (dn > 0L && i_is_modified) {
        return(make_output(sq, step_i$format))
    }
    # too few, but i = 1
    if (resolution == "secs" && dn < 0L && i == 1L) {
        return(make_output(sq, step_i$format))
    }

    # too many ticks or too few ticks
    i2 <- ifelse(dn > 0L, min(i + 1L, nrow(steps)), i - 1L)
    step_i2 <- steps[i2,] |> as.list()
    sq2 <- calc_steps(rng, step_i2$spec, step_i2$start)
    len2 <- length(sq2) - 1L
    # work out whether sq2 or sq is better
    if (len2 < min.n) {
        return(make_output(sq, step_i$format))
    } else if (abs(len2 - n) < abs(dn)) {
        return(make_output(sq2, step_i2$format))
    } else {
        return(make_output(sq, step_i$format))
    }
}

gen_steps_data <- function(span, sep) {
    MIN <- 60
    HOUR <- MIN * 60
    DAY <- HOUR * 24
    YEAR <- DAY * 365.25
    MONTH <- YEAR / 12

    steps <- list(
        list(spec = "1 sec",      seconds = 1, start = "mins", format = "%S"),
        list(spec = "2 secs",     seconds = 2),
        list(spec = "5 secs",     seconds = 5),
        list(spec = "10 secs",    seconds = 10),
        list(spec = "15 secs",    seconds = 15),
        list(spec = "30 secs",    seconds = 30, format = "%H:%M:%S"),
        list(spec = "1 min",      seconds = 1*MIN, format = "%H:%M"),
        list(spec = "2 mins",     seconds = 2*MIN, start = "hours"),
        list(spec = "5 mins",     seconds = 5*MIN),
        list(spec = "10 mins",    seconds = 10*MIN),
        list(spec = "15 mins",    seconds = 15*MIN),
        list(spec = "30 mins",    seconds = 30*MIN),
        list(spec = "1 hour",     seconds = 1*HOUR, format = ifelse(span <= DAY, "%H:%M", paste("%b %d", "%H:%M", sep = sep))),
        list(spec = "3 hours",    seconds = 3*HOUR, start = "days"),
        list(spec = "6 hours",    seconds = 6*HOUR, format = paste("%b %d", "%H:%M", sep = sep)),
        list(spec = "12 hours",   seconds = 12*HOUR),
        list(spec = "1 DSTday",   seconds = 1*DAY, format = paste("%b", "%d", sep = sep)),
        list(spec = "2 DSTdays",  seconds = 2*DAY),
        list(spec = "1 week",     seconds = 7*DAY, start = "weeks"),
        list(spec = "halfmonth",  seconds = MONTH/2, start = "months"),
        list(spec = "1 month",    seconds = 1*MONTH, format = ifelse(span < YEAR, "%b", paste("%b", "%Y", sep = sep))),
        list(spec = "3 months",   seconds = 3*MONTH, start = "years"),
        list(spec = "6 months",   seconds = 6*MONTH, format = "%Y-%m"),
        list(spec = "1 year",     seconds = 1*YEAR, format = "%Y"),
        list(spec = "2 years",    seconds = 2*YEAR, start = "decades"),
        list(spec = "5 years",    seconds = 5*YEAR),
        list(spec = "10 years",   seconds = 10*YEAR),
        list(spec = "20 years",   seconds = 20*YEAR, start = "centuries"),
        list(spec = "50 years",   seconds = 50*YEAR),
        list(spec = "100 years",  seconds = 100*YEAR),
        list(spec = "200 years",  seconds = 200*YEAR),
        list(spec = "500 years",  seconds = 500*YEAR),
        list(spec = "1000 years", seconds = 1000*YEAR)
    )

    # carry forward 'format' and 'start' to following steps
    for (i in seq_along(steps)) {
        if (is.null(steps[[i]]$start))
            steps[[i]]$start <- steps[[i-1]]$start
        if (is.null(steps[[i]]$format))
            steps[[i]]$format <- steps[[i-1]]$format
    }

    do.call("rbind.data.frame", steps)
}

make_output <- function(x, format) {
    structure(
        x,
        labels = format(x, format),
        format = format
    )
}

# calculate actual number of ticks in the given interval
calc_steps <- function(lim, by, unit) {
    start <- floor_(lim[1], unit)
    end <- ceiling_(lim[2], unit)

    steps <- seq_(start, end, by = by)
    if (anyNA(steps)) {
        steps <- steps[!is.na(steps)]
        if (!length(steps))
            return(steps)
    }

    r1 <- sum(steps <= lim[1])
    r2 <- length(steps) + 1 - sum(steps >= lim[2])
    if (r2 == length(steps) + 1) {
        stop("this shouldn't have had happen")
        nat <- seq_(steps[length(steps)], by = by, length = 2)[2]
        if (is.na(nat) || !(nat > steps[length(steps)]))
            r2 <- length(steps)
        else steps[r2] <- nat
    }
    steps[r1:r2]
}

floor_ <- function(x, unit = c("secs", "mins", "hours", "days",
                               "weeks", "months", "years", "decades", "centuries")) {
    unit <- match.arg(unit)
    if (unit %in% c("secs", "mins", "decades", "centuries"))
        unit <- switch(
            unit,
            "secs" = "seconds",
            "mins" = "minutes",
            "decades" = "10 years",
            "centuries" = "100 years"
        )

    sh_floor(x, unit)
}

ceiling_ <- function(x, unit = c("secs", "mins", "hours", "days",
                                 "weeks", "months", "years", "decades", "centuries")) {
    unit <- match.arg(unit)
    if (unit %in% c("secs", "mins", "decades", "centuries"))
        unit <- switch(
            unit,
            "secs" = "seconds",
            "mins" = "minutes",
            "decades" = "10 years",
            "centuries" = "100 years"
        )

    sh_ceiling(x, unit)
}

seq_ <- function(from, to, by, length=NULL) {
    if (is_jdate(from) && grepl("DSTday", by))
        by <- sub("DSTday", "day", by)

    if(missing(by) || !identical(by, "halfmonth"))
        return( seq(from, to, by = by, length.out=length) )
    # else  by == "halfmonth" => can only go forward (!)
    l2 <- NULL
    if (!is.null(length))
        l2 <- ceiling(length/2)

    x1 <- seq(from, to, by = "months", length.out = l2)
    x2 <- x1
    md <- unique(sh_mday(x1))
    stopifnot(length(md) == 1)

    if(md <= 14) {
        sh_mday(x2) <- md + 14L
    } else {
        sh_mday(x2) <- 1L
        sh_month(x2) <- sh_month(x2) + 1L
    }

    sort(c(x1, x2))
}

widen_range <- function(rng, n, resolution) {
    resolution <- rlang::arg_match(resolution, c("days", "secs"))
    r <- as.numeric(as.difftime(n, units = resolution) - diff(rng))
    m1 <- r %/% 2
    m2 <- m1 + (r %% 2)
    c(rng[1] - m1, rng[2] + m2)
}
