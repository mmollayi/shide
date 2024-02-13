test_that("sh_year extracts correct year", {
    dt <- jdatetime("1402-11-10 22:24:15", tz = "Asia/Tehran")
    d <- as_jdate(dt)

    expect_equal(sh_year(dt), 1402)
    expect_equal(sh_year(d), 1402)
})

test_that("sh_month extracts correct month", {
    dt <- jdatetime("1402-11-10 22:24:15", tz = "Asia/Tehran")
    d <- as_jdate(dt)

    expect_equal(sh_month(dt), 11)
    expect_equal(sh_month(d), 11)
})

test_that("sh_day extracts correct day", {
    dt <- jdatetime("1402-11-10 22:24:15", tz = "Asia/Tehran")
    d <- as_jdate(dt)

    expect_equal(sh_day(dt), 10)
    expect_equal(sh_day(d), 10)
})

test_that("sh_doy extracts correct day of year", {
    dt <- jdatetime("1402-11-10 22:24:15", tz = "Asia/Tehran")
    d <- as_jdate(dt)

    expect_equal(sh_doy(dt), 316)
    expect_equal(sh_doy(d), 316)
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


