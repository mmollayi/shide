test_that("leap year calculation is accurate", {
    expect_equal(sh_year_is_leap(jdate(jalali_leap_years$jalali_date)), jalali_leap_years$leap_year)
})
