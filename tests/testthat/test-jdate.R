test_that("jdates have informative types", {
    expect_equal(vec_ptype_abbr(jdate_now()), "jdate")
    expect_equal(vec_ptype_full(jdate_now()), "jdate")
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
