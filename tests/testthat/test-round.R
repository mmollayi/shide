test_that("sh_floor.jdate works as expected for each unit", {
    d <- jdate(c("1367-09-06", "1371-03-13"))

    expect_identical(sh_floor(d), d)
    expect_identical(sh_floor(d, "day"), d)
    expect_identical(sh_floor(d, "week"), jdate(c("1367-09-05", "1371-03-09")))
    expect_identical(sh_floor(d, "month"), jdate(c("1367-09-01", "1371-03-01")))
    expect_identical(sh_floor(d, "quarter"), jdate(c("1367-07-01", "1371-01-01")))
    expect_identical(sh_floor(d, "year"), jdate(c("1367-01-01", "1371-01-01")))
})

test_that("sh_floor.jdatetime works as expected for each unit", {
    tz <- "Asia/Tehran"
    dt <- jdatetime(c("1367-09-06 12:27:56", "1371-03-13 14:02:25"), tz)


    expect_identical(sh_floor(dt), dt)
    expect_identical(sh_floor(dt, "second"), dt)
    expect_identical(
        sh_floor(dt, "minute"),
        jdatetime(c("1367-09-06 12:27", "1371-03-13 14:02"), tz, format = "%F %H:%M")
    )

    expect_identical(
        sh_floor(dt, "hour"),
        jdatetime(c("1367-09-06 12", "1371-03-13 14"), tz, format = "%F %H")
    )

    expect_identical(
        sh_floor(dt, "day"), jdatetime(c("1367-09-06", "1371-03-13"), tz, format = "%F")
    )
    expect_identical(
        sh_floor(dt, "week"), jdatetime(c("1367-09-05", "1371-03-09"), tz, format = "%F")
    )
    expect_identical(
        sh_floor(dt, "month"), jdatetime(c("1367-09-01", "1371-03-01"), tz, format = "%F")
    )
    expect_identical(
        sh_floor(dt, "quarter"), jdatetime(c("1367-07-01", "1371-01-01"), tz, format = "%F")
    )
    expect_identical(
        sh_floor(dt, "year"), jdatetime(c("1367-01-01", "1371-01-01"), tz, format = "%F")
    )
})

test_that("sh_floor.jdate works as expected for multi-units", {
    d <- jdate(c("1367-09-06", "1371-03-13"))

    expect_identical(sh_floor(d, "2 days"), jdate(c("1367-09-05", "1371-03-13")))
    expect_identical(sh_floor(d, "10 days"), jdate(c("1367-09-01", "1371-03-11")))
    expect_identical(sh_floor(d, "4 months"), jdate(c("1367-09-01", "1371-01-01")))
    expect_identical(sh_floor(d, "2 quarters"), jdate(c("1367-07-01", "1371-01-01")))
    expect_identical(sh_floor(d, "2 years"), jdate(c("1366-01-01", "1370-01-01")))
    expect_identical(sh_floor(d, "3 years"), jdate(c("1365-01-01", "1371-01-01")))
})

test_that("sh_floor.jdatetime works as expected for multi-units", {
    tz <- "Asia/Tehran"
    dt <- jdatetime(c("1367-09-06 12:27:56", "1371-03-13 14:02:25"), tz)

    expect_identical(
        sh_floor(dt, "30 seconds"),
        jdatetime(c("1367-09-06 12:27:30", "1371-03-13 14:02:00"), tz)
    )
    expect_identical(
        sh_floor(dt, "20 minutes"),
        jdatetime(c("1367-09-06 12:20", "1371-03-13 14:00"), tz, format = "%F %H:%M")
    )

    expect_identical(
        sh_floor(dt, "6 hours"),
        jdatetime(c("1367-09-06 12", "1371-03-13 12"), tz, format = "%F %H")
    )

    expect_identical(
        sh_floor(dt, "10 days"), jdatetime(c("1367-09-01", "1371-03-11"), tz, format = "%F")
    )
    expect_identical(
        sh_floor(dt, "4 month"), jdatetime(c("1367-09-01", "1371-01-01"), tz, format = "%F")
    )
    expect_identical(
        sh_floor(dt, "2 quarters"), jdatetime(c("1367-07-01", "1371-01-01"), tz, format = "%F")
    )
    expect_identical(
        sh_floor(dt, "3 years"), jdatetime(c("1365-01-01", "1371-01-01"), tz, format = "%F")
    )
})

test_that("sh_ceiling.jdate works as expected for each unit", {
    d <- jdate(c("1367-09-06", "1371-03-13"))

    expect_identical(sh_ceiling(d, "day"), jdate(c("1367-09-06", "1371-03-13")) + 1)
    expect_identical(sh_ceiling(d, "week"), jdate(c("1367-09-12", "1371-03-16")))
    expect_identical(sh_ceiling(d, "month"), jdate(c("1367-10-01", "1371-04-01")))
    expect_identical(sh_ceiling(d, "quarter"), jdate(c("1367-10-01", "1371-04-01")))
    expect_identical(sh_ceiling(d, "year"), jdate(c("1368-01-01", "1372-01-01")))
})

test_that("sh_ceiling.jdatetime works as expected for each unit", {
    tz <- "Asia/Tehran"
    dt <- jdatetime(c("1367-09-06 12:27:56", "1371-03-13 14:02:25"), tz)

    expect_identical(sh_ceiling(dt), dt)
    expect_identical(sh_ceiling(dt, "second"), dt)
    expect_identical(
        sh_ceiling(dt, "minute"),
        jdatetime(c("1367-09-06 12:28", "1371-03-13 14:03"), tz, format = "%F %H:%M")
    )

    expect_identical(
        sh_ceiling(dt, "hour"),
        jdatetime(c("1367-09-06 13", "1371-03-13 15"), tz, format = "%F %H")
    )

    expect_identical(
        sh_ceiling(dt, "day"), jdatetime(c("1367-09-07", "1371-03-14"), tz, format = "%F")
    )
    expect_identical(
        sh_ceiling(dt, "week"), jdatetime(c("1367-09-12", "1371-03-16"), tz, format = "%F")
    )
    expect_identical(
        sh_ceiling(dt, "month"), jdatetime(c("1367-10-01", "1371-04-01"), tz, format = "%F")
    )
    expect_identical(
        sh_ceiling(dt, "quarter"), jdatetime(c("1367-10-01", "1371-04-01"), tz, format = "%F")
    )
    expect_identical(
        sh_ceiling(dt, "year"), jdatetime(c("1368-01-01", "1372-01-01"), tz, format = "%F")
    )
})

test_that("sh_ceiling does not round up datetimes that are already on a boundary", {
    tz <- "Asia/Tehran"
    dt1 <- jdatetime_make(1402, 1, 1, tzone = tz)
    dt2 <- jdatetime_make(1402, 1, 1, 12, tzone = tz)

    expect_equal(sh_ceiling(dt1, "year"), dt1)
    expect_equal(sh_ceiling(dt1, "month"), dt1)
    expect_equal(sh_ceiling(dt1, "day"), dt1)
    expect_equal(sh_ceiling(dt1, "2 years"), dt1)
    expect_equal(sh_ceiling(dt1, "3 years"), jdatetime_make(1404, 1, 1, tzone = tz))
    expect_equal(sh_ceiling(dt1, "5 years"), jdatetime_make(1405, 1, 1, tzone = tz))
    expect_equal(sh_ceiling(dt2, "hour"), dt2)
    expect_equal(sh_ceiling(dt2, "3 hours"), dt2)
    expect_equal(sh_ceiling(dt2, "5 hours"), jdatetime_make(1402, 1, 1, 15, tzone = tz))
    expect_equal(sh_ceiling(dt2, "minute"), dt2)
    expect_equal(sh_ceiling(dt2, "second"), dt2)
    expect_equal(sh_ceiling(dt2, "2 seconds"), dt2)
    expect_equal(sh_ceiling(dt2, "5 seconds"), dt2)
})

test_that("sh_round works as expected for each unit", {
    d <- jdate(c("1367-09-06", "1371-03-13"))
    expect_identical(sh_round(d, "day"), jdate(c("1367-09-06", "1371-03-13")))
    expect_identical(sh_round(d, "week"), jdate(c("1367-09-05", "1371-03-16")))
    expect_identical(sh_round(d, "month"), jdate(c("1367-09-01", "1371-03-01")))
    expect_identical(sh_round(d, "quarter"), jdate(c("1367-10-01", "1371-04-01")))
    expect_identical(sh_round(d, "year"), jdate(c("1368-01-01", "1371-01-01")))
})

test_that("sh_round works as expected for each unit", {
    d <- jdate(c("1367-09-06", "1371-03-13"))
    expect_identical(sh_round(d, "day"), jdate(c("1367-09-06", "1371-03-13")))
    expect_identical(sh_round(d, "week"), jdate(c("1367-09-05", "1371-03-16")))
    expect_identical(sh_round(d, "month"), jdate(c("1367-09-01", "1371-03-01")))
    expect_identical(sh_round(d, "quarter"), jdate(c("1367-10-01", "1371-04-01")))
    expect_identical(sh_round(d, "year"), jdate(c("1368-01-01", "1371-01-01")))
})

test_that("sh_round works as expected for dates that are exactly halfway between two consecutive units", {
    expect_identical(sh_round(jdate("1402-08-16"), "month"), jdate("1402-09-01"))
    expect_identical(sh_round(jdate("1402-08-16"), "quarter"), jdate("1402-10-01"))
    expect_identical(sh_round(jdate("1403-06-29"), "year"), jdate("1404-01-01"))
})

test_that("rounding works correctly for dates around the origin", {
    d <- jdate(c("1348-10-10", "1348-10-11", "1348-10-16"))
    expect_identical(sh_floor(d, "month"), vec_rep(jdate(c("1348-10-01")), 3))
    expect_identical(sh_ceiling(d, "month"), vec_rep(jdate(c("1348-11-01")), 3))
    expect_identical(sh_floor(d, "year"), vec_rep(jdate(c("1348-01-01")), 3))
})

test_that("parse_unit works as expected", {
    expect_identical(
        lapply(
            c("day", "days", "1day", "1days", "1.days", "1 day", "1 days", " 1 days "),
            parse_unit, resolution = "days"
        ),
        rep(list(list(n = 1, unit = "day")), 8)
    )

})

test_that("parse_unit errors as expected", {
    expect_error(parse_unit("1d", "days"))
    expect_error(parse_unit(c("days", "months"), "days"))
    expect_error(parse_unit("1", "days"))
    expect_error(parse_unit("1.5 days", "days"))
    expect_error(parse_unit("0 days", "days"))
    expect_error(parse_unit("2327 years", "days"))
    expect_error(parse_unit("2 weeks", "days"))
})
