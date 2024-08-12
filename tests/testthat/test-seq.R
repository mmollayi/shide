test_that("combining `by` with `length.out` works as expected", {
    expect_identical(
        seq(jdate("1401-01-01"), by = 2, length.out = 3),
        jdate_make(1401, 1, c(1, 3, 5))
    )

    tz <- "Asia/Tehran"
    expect_identical(
        seq(jdatetime_make(1401, 1, 1, tzone = tz), by = 2, length.out = 3),
        jdatetime_make(1401, 1, 1, second = c(0, 2, 4), tzone = tz)
    )
})

test_that("combining `to` with `length.out` works as expected", {
    expect_identical(
        seq(jdate("1401-01-01"), to = jdate("1401-01-05"), length.out = 3),
        jdate_make(1401, 1, c(1, 3, 5))
    )

    tz <- "Asia/Tehran"
    expect_identical(
        seq(jdatetime_make(1401, 1, 1, tzone = tz),
            to = jdatetime_make(1401, 1, 1, second = 4, tzone = tz), length.out = 3),
        jdatetime_make(1401, 1, 1, second = c(0, 2, 4), tzone = tz)
    )
})

test_that("if `by` has `years` unit, in case of encountering invalid date, overflow to the next valid day", {
    expect_identical(
        seq(jdate("1399-12-30"), by = "2 years", length.out = 4),
        jdate(c("1399-12-30", "1402-01-01", "1403-12-30", "1406-01-01"))
    )
})

test_that("if `by` has `months` unit, in case of encountering invalid date, overflow to the next valid day", {
    expect_identical(
        seq(jdate("1400-04-31"), by = "2 months", length.out = 6),
        jdate(c("1400-04-31", "1400-06-31", "1400-09-01", "1400-11-01", "1401-01-01", "1401-02-31"))
    )
})

test_that("if `by` has `quarters` unit, in case of encountering invalid date, overflow to the next valid day", {
    expect_identical(
        seq(jdate("1399-06-31"), by = "2 quarters", length.out = 5),
        jdate(c("1399-06-31", "1400-01-01", "1400-06-31", "1401-01-01", "1401-06-31"))
    )
})

test_that("integer `by` works as expected", {
    expect_identical(
        seq(jdate(0), jdate(2), "days"),
        seq(jdate(0), jdate(2), 1)
    )

    expect_identical(
        seq(jdatetime(0), jdatetime(2), new_duration(1, "secs")),
        seq(jdatetime(0), jdatetime(2), 1)
    )
})

test_that("fractional sequences work as expected", {
    expect_identical(
        vec_data(seq(jdate(0), jdate(3), length.out = 3)),
        c(0, 1, 3)
    )

    expect_identical(
        vec_data(seq(jdate(0), jdate(-3), length.out = 3)),
        c(0, -1, -3)
    )

    expect_identical(
        vec_data(seq(jdatetime(0), jdatetime(3), length.out = 3)),
        c(0, 1, 3)
    )

    expect_identical(
        vec_data(seq(jdatetime(0), jdatetime(-3), length.out = 3)),
        c(0, -1, -3)
    )
})

test_that("'days' and 'DSTdays' units work as expected around DST gaps and fallbacks", {
    tz <- "Asia/Tehran"
    dt1 <- jdatetime("1401-01-01 12:00:00", tz)
    dt2 <- jdatetime("1401-06-30 12:00:00", tz)

    expect_identical(
        seq(dt1, by = "days", length.out = 2),
        jdatetime_make(1401, 1, 1:2, 12:13, tzone = tz)
    )

    expect_identical(
        seq(dt1, by = "DSTdays", length.out = 2),
        jdatetime_make(1401, 1, 1:2, 12, tzone = tz)
    )

    expect_identical(
        seq(dt2, by = "days", length.out = 2),
        jdatetime_make(1401, 6, 30:31, 12:11, tzone = tz)
    )

    expect_identical(
        seq(dt2, by = "DSTdays", length.out = 2),
        jdatetime_make(1401, 6, 30:31, 12, tzone = tz)
    )
})

test_that("nonexistent times result in `NA`", {
    tz <- "Asia/Tehran"

    expect_identical(
        seq(jdatetime_make(1401, 1, 1, tzone = tz), by = "DSTdays", length.out = 2),
        jdatetime_make(c(1401, NA), 1, 1, tzone = tz)
    )

    expect_identical(
        seq(jdatetime_make(1399, 12, 2, tzone = tz), by = "months", length.out = 2),
        jdatetime_make(c(1399, NA), 12, 2, tzone = tz)
    )
})
