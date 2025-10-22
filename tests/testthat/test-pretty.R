test_that("pretty returns the desired output", {
    x <- jdate(c("1401-01-05", "1401-12-25"))
    out <- structure(
        jdate(c("1401-01-01", "1401-04-01", "1401-07-01", "1401-10-01", "1402-01-01")),
        labels = c("Far", "Tir", "Meh", "Dey", "Far"),
        format = "%b"
    )
    expect_identical(pretty_jdate(x), out)

    x <- jdate(c("1401-01-05", "1401-05-02"))
    out <- structure(
        jdate(c("1401-01-01", "1401-02-01", "1401-03-01", "1401-04-01", "1401-05-01", "1401-06-01")),
        labels = c("Far", "Ord", "Kho", "Tir", "Mor", "Sha"),
        format = "%b"
    )
    expect_identical(pretty_jdate(x), out)

    # test for the case rng_diff < as.difftime(n, units = "days")
    x <- jdate(c("1401-01-05", "1401-01-06"))
    out <- structure(
        jdate(c("1401-01-03", "1401-01-04", "1401-01-05", "1401-01-06", "1401-01-07", "1401-01-08")),
        labels = c("Far 03", "Far 04", "Far 05", "Far 06", "Far 07", "Far 08"),
        format = "%b %d"
    )
    expect_identical(pretty_jdate(x), out)

    x <- jdate(c("1401-01-05", "1401-04-10"))
    out <- structure(
        jdate(c("1401-01-01", "1401-02-01", "1401-03-01", "1401-04-01", "1401-05-01")),
        labels = c("Far", "Ord", "Kho", "Tir", "Mor"),
        format = "%b"
    )
    expect_identical(pretty_jdate(x), out)

    x <- jdate(c("1404-01-03", "1404-02-31"))
    out <- structure(
        seq(jdate("1404-01-02"), jdate("1404-03-03"), by = "week"),
        labels = c("Far 02", "Far 09", "Far 16", "Far 23", "Far 30", "Ord 06",
                   "Ord 13", "Ord 20", "Ord 27", "Kho 03"),
        format = "%b %d"
    )
    expect_identical(pretty_jdate(x, n = 5, min.n = 5), out)

    x <- jdate(c("1401-04-10", "1401-08-30"))
    out <- structure(
        jdate(c("1401-04-01", "1401-07-01", "1401-10-01")),
        labels = c("Tir", "Meh", "Dey"),
        format = "%b"
    )
    expect_identical(pretty_jdate(x, n = 3), out)
})
