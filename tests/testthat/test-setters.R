test_that("setter functions work as expected", {
    dt <- jdatetime("1402-12-07 15:03:15", tz = "Asia/Tehran")
    d <- as_jdate(dt)

    sh_second(dt) <- 20:21
    expect_equal(sh_second(dt), 20:21)
    expect_error(sh_second(d) <- 20)

    sh_minute(dt) <- c(1, 10)
    expect_equal(sh_minute(dt), c(1, 10))
    expect_error(sh_minute(d) <- 1)

    sh_hour(dt) <- 12
    expect_equal(sh_hour(dt), c(12, 12))
    expect_error(sh_hour(d) <- 12)

    sh_day(d) <- c(17, 27)
    sh_day(dt) <- c(17, 27)
    expect_equal(sh_day(d), c(17, 27))
    expect_equal(sh_day(dt), c(17, 27))

    sh_mday(d) <- c(15, 25)
    sh_mday(dt) <- c(15, 25)
    expect_equal(sh_mday(d), c(15, 25))
    expect_equal(sh_mday(dt), c(15, 25))

    sh_month(d) <- c(2, 11)
    sh_month(dt) <- c(2, 11)
    expect_equal(sh_month(d), c(2, 11))
    expect_equal(sh_month(dt), c(2, 11))

    sh_year(d) <- c(1367, 1403)
    sh_year(dt) <- c(1367, 1403)
    expect_equal(sh_year(d), c(1367, 1403))
    expect_equal(sh_year(dt), c(1367, 1403))
})

test_that("setter functions return NA for NA input values", {
    dt <- jdatetime(c("1402-12-07 15:03:15", "1402-12-17 11:07:07"), tz = "Asia/Tehran")
    d <- as_jdate(dt)

    sh_hour(dt[1]) <- NA
    sh_year(d[1]) <- NA
    expect_equal(d, vec_c(NA, d[2]))
    expect_equal(dt,vec_c(NA, dt[2]))
})

test_that("setter functions return NA for invalid input values", {
    dt <- jdatetime(c("1402-12-07 15:03:15", "1402-12-17 11:07:07"), tz = "Asia/Tehran")
    d <- as_jdate(dt)

    sh_hour(dt[1]) <- 24
    sh_month(d[1]) <- 13
    expect_equal(d, vec_c(NA, d[2]))
    expect_equal(dt,vec_c(NA, dt[2]))
})
