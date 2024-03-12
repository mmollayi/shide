test_that("combining `by` with `length.out` works as expected", {
    expect_identical(
        seq(jdate("1401-01-01"), by = 2, length.out = 3),
        jdate_make(1401, 1, c(1, 3, 5))
    )
})

test_that("combining `to` with `length.out` works as expected", {
    expect_identical(
        seq(jdate("1401-01-01"), to = jdate("1401-01-05"), length.out = 3),
        jdate_make(1401, 1, c(1, 3, 5))
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

test_that("fractional sequences work as expected", {
    expect_identical(
        vec_data(seq(jdate(0), jdate(3), length.out = 3)),
        c(0, 1, 3)
    )

    expect_identical(
        vec_data(seq(jdate(0), jdate(-3), length.out = 3)),
        c(0, -1, -3)
    )
})
