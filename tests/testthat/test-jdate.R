test_that("jdates have informative types", {
    expect_equal(vec_ptype_abbr(jdate_now()), "jdate")
    expect_equal(vec_ptype_full(jdate_now()), "jdate")
})

# constructor ---------------------------------------------------------------

test_that("can create a jdate", {
    expect_identical(jdate(), structure(double(), class = c("jdate", "vctrs_vctr")))
    expect_identical(jdate(0), structure(0, class = c("jdate", "vctrs_vctr")))
    expect_identical(jdate(0), jdate(0L))
})

test_that("input names are retained", {
    expect_named(jdate(c(x = 0)), "x")
})

# cast: ---------------------------------------------------------------------

test_that("safe casts work as expected", {
    d <- jdate("1402-09-15")

    expect_equal(vec_cast(NULL, d), NULL)
    expect_equal(vec_cast(d, d), d)
    expect_equal(vec_cast(as_jdatetime(d), d), d)
})

test_that("can cast NA", {
    expect_equal(vec_cast(NA, new_jdate()), new_jdate(NA_real_))
})

test_that("Date <-> jdate conversion works as expected", {
    expect_identical(as_jdate(as.Date("2024-01-23")), jdate("1402-11-03"))
    expect_identical(as.Date(jdate("1402-11-03")), as.Date("2024-01-23"))
    expect_identical(as.Date(jdate(jalali_leap_years$jalali_date)), jalali_leap_years$gregorian_date)
    expect_identical(jdate(jalali_leap_years$jalali_date), as_jdate(jalali_leap_years$gregorian_date))
})

test_that("jdate <-> jdatetime conversion works as expected", {
    expect_identical(jdate(NA_real_), as_jdate(jdatetime(NA_real_)))
    expect_identical(jdatetime(NA_real_), as_jdatetime(jdate(NA_real_)))
})

test_that("jdate parser works as expected", {
    sd <- 19829
    expect_equal(vec_data(jdate("1403 01 28", format = "%Y %m %d")), sd)
    expect_equal(vec_data(jdate("1403 01 28", format = "%Y %m %e")), sd)
    expect_equal(vec_data(jdate("1403-01-28", format = "%F")), sd)
    expect_equal(vec_data(jdate("1403 1 28", format = "%Y %m %d")), sd)
    expect_equal(vec_data(jdate("1403 1 28", format = "%Y %m %e")), sd)
    expect_equal(vec_data(jdate("1403 32", format = "%Y %j")), sd + 4)
    expect_equal(vec_data(jdate("1403-01-28", format = " %F")), sd)
    expect_equal(vec_data(jdate(" 1403-01-28", format = " %F")), sd)
    expect_equal(vec_data(jdate("  1403-01-28", format = " %F")), sd)
    expect_equal(vec_data(jdate(" 1403-01-28", format = "%n%F")), sd)
    expect_equal(vec_data(jdate(" 1403-01-28", format = "%n%F")), sd)
    expect_equal(vec_data(jdate("1403-01-28", format = "%t%F")), sd)
    expect_equal(vec_data(jdate(" 1403-01-28", format = "%t%F")), sd)
})

test_that("jdate parser fails as expected", {
    expect_identical(jdate("1403-10-31"), jdate(NA_real_))
    expect_identical(jdate("1403 10 31", format = "%Y %m %e"), jdate(NA_real_))
    expect_identical(jdate("1403 13 1", format = "%Y %m %d"), jdate(NA_real_))
    expect_identical(jdate("1403-02-01", format = "%n%F"), jdate(NA_real_))
    expect_identical(jdate("  1403-02-01", format = "%n%F"), jdate(NA_real_))
    expect_identical(jdate("  1403-02-01", format = "%t%F"), jdate(NA_real_))
})

test_that("jdate_make works as expected", {
    expect_identical(jdate_make(1401:1402, 1, 1), jdate(c("1401-01-01", "1402-01-01")))
    expect_error(jdate_make(1401:1403, 1:2, 1))
})
