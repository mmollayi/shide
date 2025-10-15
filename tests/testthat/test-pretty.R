test_that("pretty returns the desired output", {
    x <- seq(jdate("1401-01-05"), jdate("1401-12-25"), by = 1)
    out <- structure(
        jdate(c("1401-01-01", "1401-04-01", "1401-07-01", "1401-10-01", "1402-01-01")),
        labels = c("Far", "Tir", "Meh", "Dey", "Far"),
        format = "%b"
    )
    expect_identical(pretty_jdate(x), out)

    x <- seq(jdate("1401-01-05"), jdate("1401-05-02"), by = 1)
    out <- structure(
        jdate(c("1401-01-01", "1401-02-01", "1401-03-01", "1401-04-01", "1401-05-01", "1401-06-01")),
        labels = c("Far", "Ord", "Kho", "Tir", "Mor", "Sha"),
        format = "%b"
    )
    expect_identical(pretty_jdate(x), out)

    x <- seq(jdate("1401-01-05"), jdate("1401-01-06"), by = 1)
    out <- structure(
        jdate(c("1401-01-03", "1401-01-04", "1401-01-05", "1401-01-06", "1401-01-07", "1401-01-08")),
        labels = c("Far 03", "Far 04", "Far 05", "Far 06", "Far 07", "Far 08"),
        format = "%b %d"
    )
    expect_identical(pretty_jdate(x), out)
})
