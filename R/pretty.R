pretty_jdate <- function(x, n = 5, min.n = n%/%2, sep = " ", ...) {
    stopifnot(min.n <= n)
    zz <- rx <- range(x, na.rm = TRUE)
    D <- diff(nzz <- as.numeric(zz))
    if (diff(zz) < as.difftime(n, units = "days")) {
        browser()
        r <- n - D
        m <- max(0, r %/% 2)
        m2 <- m + (r %% 2)
        repeat {
            dd <- seq(zz[1] - m, zz[2] + m2, by = "1 day")
            if (length(dd) >= min.n)
                break

            if (m < m2) {
                m <- m+1
            } else {
                m2 <- m2+1
            }
        }

        return(make_output(dd, format = paste("%b", "%d", sep = sep)))
    }

    xspan <- as.numeric(diff(zz), units = "secs")
    steps <- gen_steps_data(xspan, sep)
    nsteps <- xspan/steps$seconds
    init.i <- init.i0 <- which.min(abs(nsteps - n))
    st.i <- steps[init.i,] |> as.list()
    init.at <- calc_steps(zz, st.i$spec, st.i$start)
    init.n <- length(init.at) - 1L
    R <- TRUE
    L.fail <- R.fail <- FALSE
    while (init.n < min.n) {
        if (init.i == 1L) {
            if (R) {
                nat <- seq_(init.at[length(init.at)], by = st.i$spec,
                            length = 2)[2]
                R.fail <- is.na(nat) || !(nat > init.at[length(init.at)])
                if (!R.fail)
                    init.at[length(init.at) + 1] <- nat
            }
            else {
                nat <- seq_(init.at[1], by = paste0("-",
                                                    st.i$spec), length = 2)[2]
                L.fail <- is.na(nat) || !(nat < init.at[1])
                if (!L.fail) {
                    init.at[seq_along(init.at) + 1] <- init.at
                    init.at[1] <- nat
                }
            }
            if (R.fail && L.fail)
                stop("failed to add more ticks; 'min.n' too large?")
            R <- !R
        }
        else {
            init.i <- init.i - 1L
            st.i <- steps[init.i,] |> as.list()
            init.at <- calc_steps(zz, st.i$spec, st.i$start)
        }
    }

    if (init.n == n) {
        return(make_output(init.at, st.i$format))
    }

    # if (init.n > n) {
    #
    # }

    dn <- length(init.at) - 1L - n
    i2 <- ifelse(dn > 0L, min(init.i + 1L, nrow(steps)), init.i - 1L)
    st <- steps[i2,] |> as.list()
    new.at <- calc_steps(zz, st$spec, st$start)
    new.n <- length(new.at) - 1L
    make_output(init.at, st.i$format)
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

    ## carry forward 'format' and 'start' to following steps
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
        # if (isDate) {
        #     if(round) {
        #         as.Date(round(x, units = "days"))
        #     } else {
        #         x
        #     }
        # } else {
        #     as.POSIXct(x)
        # }

        labels = format(x, format),
        format = format)
}

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
    if (unit %in% c("decades", "centuries"))
        unit <- switch(unit, "decades" = "10 years", "centuries" = "100 years")

    sh_floor(x, unit)
}

ceiling_ <- function(x, unit = c("secs", "mins", "hours", "days",
                                 "weeks", "months", "years", "decades", "centuries")) {
    unit <- match.arg(unit)
    if (unit %in% c("decades", "centuries"))
        unit <- switch(unit, "decades" = "10 years", "centuries" = "100 years")

    sh_ceiling(x, unit)
}

seq_ <- function(from, to, by, length=NULL) {
    if (is_jdate(from) && grepl("DSTday", by))
        by <- sub("DSTday", "day", by)

    if(missing(by) || !identical(by, "halfmonth"))
        return( seq(from, to, by = by, length.out=length) )
    ## else  by == "halfmonth" => can only go forward (!)
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
