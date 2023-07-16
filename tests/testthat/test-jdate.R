test_that("jdates have informative types", {
    expect_equal(vec_ptype_abbr(jdate_now()), "jdate")
    expect_equal(vec_ptype_full(jdate_now()), "jdate")
})

# cast: ---------------------------------------------------------------------

test_that("safe casts work as expected", {
    date <- jdate("1402-09-15")

    expect_equal(vec_cast(NULL, date), NULL)
    expect_equal(vec_cast(date, date), date)
    expect_equal(vec_cast(as_jdatetime(date), date), date)
})

test_that("can cast NA", {
    expect_equal(vec_cast(NA, new_jdate()), new_jdate(NA_real_))
})
