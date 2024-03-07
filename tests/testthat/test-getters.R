test_that("sh_year extracts correct year", {
    dt <- jdatetime("1402-11-10 22:24:15", tz = "Asia/Tehran")
    d <- as_jdate(dt)

    expect_equal(sh_year(dt), 1402)
    expect_equal(sh_year(d), 1402)
})

test_that("sh_quarter extracts correct quarter", {
    dt <- jdatetime_make(1400, c(1, 5, 8, 11), c(3, 12, 21, 29))
    d <- as_jdate(dt)

    expect_equal(sh_quarter(dt), c(1, 2, 3, 4))
    expect_equal(sh_quarter(d), c(1, 2, 3, 4))
})

test_that("sh_month extracts correct month", {
    dt <- jdatetime("1402-11-10 22:24:15", tz = "Asia/Tehran")
    d <- as_jdate(dt)

    expect_equal(sh_month(dt), 11)
    expect_equal(sh_month(d), 11)
})

test_that("days getters extracts correct days", {
    dt <- jdatetime(c("1402-11-10 22:24:15", "1403-12-30 12:00:00"), tz = "Asia/Tehran")
    d <- as_jdate(dt)

    expect_equal(sh_day(dt), c(10, 30))
    expect_equal(sh_day(d), c(10, 30))

    expect_equal(sh_mday(dt), c(10, 30))
    expect_equal(sh_mday(d), c(10, 30))

    expect_equal(sh_yday(dt), c(316, 366))
    expect_equal(sh_yday(d), c(316, 366))

    expect_equal(sh_qday(dt), c(40, 90))
    expect_equal(sh_qday(d), c(40, 90))

    expect_equal(sh_wday(dt), c(4, 6))
    expect_equal(sh_wday(d), c(4, 6))
})

test_that("sh_hour extracts correct hour", {
    dt <- jdatetime("1402-11-10 22:24:15", tz = "Asia/Tehran")
    d <- as_jdate(dt)

    expect_equal(sh_hour(dt), 22)
    expect_error(sh_hour(d))
})

test_that("sh_minute extracts correct minute", {
    dt <- jdatetime("1402-11-10 22:24:15", tz = "Asia/Tehran")
    d <- as_jdate(dt)

    expect_equal(sh_minute(dt), 24)
    expect_error(sh_minute(d))
})

test_that("sh_second extracts correct second", {
    dt <- jdatetime("1402-11-10 22:24:15", tz = "Asia/Tehran")
    d <- as_jdate(dt)

    expect_equal(sh_second(dt), 15)
    expect_error(sh_second(d))
})

test_that("sh_tzone accessor works as expected", {
    dt1 <- jdatetime("1402-12-24 14:32:15", tz = "Asia/Tehran")
    dt2 <- jdatetime("1402-12-24 14:32:15", tz = "UTC")
    d1 <- as_jdate(dt1)

    expect_equal(sh_tzone(dt1), "Asia/Tehran")
    expect_equal(sh_tzone(dt2), "UTC")
    expect_error(sh_tzone(d))
})

