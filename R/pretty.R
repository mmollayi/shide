calc_steps <- function(span, sep) {
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

# pretty_jdate <- function(x, n = 5, min.n = n%/%2, sep = " ", ...) {
#     stopifnot(min.n <= n)
#     zz <- rx <- range(x, na.rm = TRUE)
#     D <- diff(nzz <- as.numeric(zz))
#     browser()
# }
