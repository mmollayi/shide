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

# coercion ------------------------------------------------------------------------------------

test_that("vec_ptype2(<jdate>, NA) is symmetric", {
    d <- jdate()
    expect_identical(vec_ptype2(d, NA), vec_ptype2(NA, d))
})

# cast ----------------------------------------------------------------------------------------

test_that("jdate casts work as expected", {
    d <- jdate("1402-09-15")

    expect_identical(vec_cast(NULL, d), NULL)
    expect_identical(vec_cast(d, d), d)
    expect_identical(vec_cast(as_jdatetime(d), d), d)

    na_d <- jdate(NA_real_)
    expect_identical(vec_cast(NA, jdate()), na_d)
    expect_identical(vec_cast(na_d, na_d), na_d)
    expect_identical(vec_cast(as_jdatetime(na_d), na_d), na_d)
})

test_that("Date <-> jdate conversion works as expected", {
    expect_identical(as_jdate(as.Date("2024-01-23")), jdate("1402-11-03"))
    expect_identical(as.Date(jdate("1402-11-03")), as.Date("2024-01-23"))
    expect_identical(
        as.Date(jdate(jalali_leap_years$jalali_date)),
        jalali_leap_years$gregorian_date
    )
    expect_identical(
        jdate(jalali_leap_years$jalali_date),
        as_jdate(jalali_leap_years$gregorian_date)
    )
})

test_that("jdate <-> jdatetime conversion works as expected", {
    expect_identical(jdate(NA_real_), as_jdate(jdatetime(NA_real_)))
    expect_identical(jdatetime(NA_real_), as_jdatetime(jdate(NA_real_)))

    d <- jdate("1403-02-26")
    dt <- jdatetime("1403-02-26 00:00:00", tz = "Asia/Tehran")

    expect_identical(tzone(vec_cast(d, dt)), "Asia/Tehran")
    expect_identical(format(vec_cast(d, dt), "%H:%M:%S"), "00:00:00")
    expect_identical(vec_cast(dt, d), d)
    expect_identical(vec_cast(vec_cast(d, dt), d), d)
    expect_identical(vec_cast(vec_cast(dt, d), dt), dt)
})

# arithmetic ----------------------------------------------------------------------------------

test_that("jdate vs numeric arithmetic works as expected", {
    d <- jdate("1403-02-31")

    expect_identical(vec_arith("+", d, 1), d + 1)
    expect_identical(vec_arith("+", 1, d), d + 1)
    expect_identical(vec_arith("-", d, 1), d - 1)
    expect_error(vec_arith("-", 1, d), class = "vctrs_error_incompatible_op")
    expect_error(vec_arith("*", 1, d), class = "vctrs_error_incompatible_op")
    expect_error(vec_arith("*", d, 1), class = "vctrs_error_incompatible_op")
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
