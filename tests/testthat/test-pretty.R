test_that("pretty returns desired outputs for various jdate inputs", {
    x <- jdate(c("1401-01-05", "1401-12-25"))
    out <- structure(
        jdate(c("1401-01-01", "1401-04-01", "1401-07-01", "1401-10-01", "1402-01-01")),
        labels = c("Far", "Tir", "Meh", "Dey", "Far"),
        format = "%b"
    )
    expect_identical(pretty_jdate(x, n = 5), out)

    x <- jdate(c("1401-01-05", "1401-05-02"))
    out <- structure(
        jdate(c("1401-01-01", "1401-02-01", "1401-03-01", "1401-04-01", "1401-05-01", "1401-06-01")),
        labels = c("Far", "Ord", "Kho", "Tir", "Mor", "Sha"),
        format = "%b"
    )
    expect_identical(pretty_jdate(x, n = 5), out)

    # test for the case rng_diff < as.difftime(n, units = "days")
    x <- jdate(c("1401-01-05", "1401-01-06"))
    out <- structure(
        jdate(c("1401-01-03", "1401-01-04", "1401-01-05", "1401-01-06", "1401-01-07", "1401-01-08")),
        labels = c("Far 03", "Far 04", "Far 05", "Far 06", "Far 07", "Far 08"),
        format = "%b %d"
    )
    expect_identical(pretty_jdate(x, n = 5), out)

    x <- jdate(c("1401-01-05", "1401-04-10"))
    out <- structure(
        jdate(c("1401-01-01", "1401-02-01", "1401-03-01", "1401-04-01", "1401-05-01")),
        labels = c("Far", "Ord", "Kho", "Tir", "Mor"),
        format = "%b"
    )
    expect_identical(pretty_jdate(x, n = 5), out)

    x <- jdate(c("1401-01-05", "1401-04-10"))
    out <- structure(
        jdate(c("1401-01-01", "1401-01-15", "1401-02-01", "1401-02-15", "1401-03-01",
                "1401-03-15", "1401-04-01", "1401-04-15")),
        labels = c("Far 01", "Far 15", "Ord 01", "Ord 15", "Kho 01", "Kho 15", "Tir 01", "Tir 15"),
        format = "%b %d"
    )
    expect_identical(pretty_jdate(x, n = 5, min.n = 5), out)

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

    x <- jdate(c("1367-09-06", "1404-07-30"))
    out <- structure(
        seq(jdate("1360-01-01"), by = "10 years", length.out = 6),
        labels = c("1360", "1370", "1380", "1390", "1400", "1410"),
        format = "%Y"
    )
    expect_identical(pretty_jdate(x, n = 6), out)

    x <- jdate("1404-08-19")
    out <- structure(
        jdate(c("1404-08-18", "1404-08-19", "1404-08-20")),
        labels = c("Aba 18", "Aba 19", "Aba 20"),
        format = "%b %d"
    )
    expect_identical(pretty_jdate(x, n = 2), out)
})

test_that("pretty returns desired outputs for various jdatetime inputs", {
    tz <- "Asia/Tehran"
    x <- jdatetime(c("1404-01-01 00:00:00", "1404-01-01 12:00:00"), tz)
    out <- structure(
        seq(x[1], by = "3 hours", length.out = 5),
        labels = c("00:00", "03:00", "06:00", "09:00", "12:00"),
        format = "%H:%M"
    )
    expect_identical(pretty_jdatetime(x, n = 5), out)

    x <- jdatetime(c("1404-01-01 00:00:00", "1404-01-01 12:00:00"), tz)
    out <- structure(
        seq(x[1], by = "hours", length.out = 13),
        labels = format(seq(x[1], by = "hours", length.out = 13), "%H:%M"),
        format = "%H:%M"
    )
    expect_identical(pretty_jdatetime(x, n = 6, min.n = 5), out)

    x <- jdatetime(c("1404-01-01 00:00:00", "1404-01-02 01:00:00"), tz)
    out <- structure(
        seq(x[1], by = "hours", length.out = 26),
        labels = format(
            seq(x[1], by = "hours", length.out = 26),
            "%b %d %H:%M"
        ),
        format = "%b %d %H:%M"
    )
    expect_identical(pretty_jdatetime(x, n = 20), out)

    x <- jdatetime(c("1404-01-01 00:00:00", "1404-01-01 00:00:04"), tz)
    out <- structure(
        seq(x[1], by = "secs", length.out = 6),
        labels = c("00", "01", "02", "03", "04", "05"),
        format = "%S"
    )
    expect_identical(pretty_jdatetime(x, n = 5), out)

    x <- jdatetime(c("1401-06-30 23:00:00", "1401-06-31 01:00:00"), tz)
    out <- structure(
        seq(x[1], by = "hours", length.out = 4),
        labels = c("23:00", "23:00", "00:00", "01:00"),
        format = "%H:%M"
    )
    expect_identical(pretty_jdatetime(x, n = 4), out)

    x <- jdatetime("1404-08-21 18:06:33", tz)
    out <- structure(
        seq(x[1] - 1, by = "secs", length.out = 3),
        labels = c("32", "33", "34"),
        format = "%S"
    )
    expect_identical(pretty_jdatetime(x, n = 2), out)
})
