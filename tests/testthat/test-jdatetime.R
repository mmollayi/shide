test_that("prototype objects are generated as expected", {
    expect_equal(jdatetime(), new_jdatetime())
    expect_equal(jdatetime(tzone = "UTC"), new_jdatetime(tzone = "UTC"))
})

test_that("jdatetime parser works as expected", {
    tz <- "Asia/Tehran"
    expect_identical(
        jdatetime("1402-11-07", format = "%Y-%m-%d"),
        jdatetime("1402-11-07 00:00:00")
    )

    expect_equal(
        vec_data(jdatetime("1403-01-28 16:38:51", tzone = tz,
                           format = "%F %X")),
        1713272931
    )
    expect_equal(
        vec_data(jdatetime("1403-01-28 17", tzone = tz,
                           format = "%F %H")),
        1713274200
    )
    expect_equal(
        vec_data(jdatetime("1403-01-28 17", tzone = tz,
                           format = "%F %M")),
        1713214020
    )
    expect_equal(
        vec_data(jdatetime("1403-01-28 17", tzone = tz,
                           format = "%F %S")),
        1713213017
    )
    expect_equal(
        vec_data(jdatetime("1403-01-29 08:55:31", tzone = tz,
                           format = "%F %T")),
        1713331531
    )
    expect_equal(
        vec_data(jdatetime("1403-01-29 08:55", tzone = tz,
                           format = "%F %R")),
        1713331500
    )
})

test_that("jdatetime parser fails as expected", {
    tz <- "Asia/Tehran"
    expect_identical(jdatetime("1403-02-01 24", tz, format = "%F %H"), jdatetime(NA_real_, tz))
    expect_identical(jdatetime("1403-02-01 60", tz, format = "%F %M"), jdatetime(NA_real_, tz))
    expect_identical(jdatetime("1403-02-01 60", tz, format = "%F %S"), jdatetime(NA_real_, tz))
    expect_identical(jdatetime("1403-02-01 24:11:19", tz, format = "%F %T"),
                     jdatetime(NA_real_, tz))

    expect_identical(jdatetime("1403-02-01 16:60:19", tz, format = "%F %T"),
                     jdatetime(NA_real_, tz))

    expect_identical(jdatetime("1403-02-01 16:11:60", tz, format = "%F %T"),
                     jdatetime(NA_real_, tz))
})

test_that("ambiguous time resolution works as expected", {
    tz <- "Asia/Tehran"
    expect_equal(
        vec_data(c(jdatetime("1401-06-30 23:00:00", tz, ambiguous = "earliest"),
                   jdatetime("1401-06-30 23:00:00", tz, ambiguous = "latest"))),
        c(1663785000, 1663788600)
    )
    expect_identical(
        jdatetime("1401-06-30 23:59:59", tz, ambiguous = "latest") + 1,
        jdatetime("1401-06-31 00:00:00", tz)
    )
    expect_identical(
        jdatetime("1401-06-30 23:00:00", tz, ambiguous = "NA"),
        jdatetime(NA_real_, tz)
    )
})

test_that("nonexistent time fails as expected", {
    tz <- "Asia/Tehran"
    expect_identical(
        jdatetime(c("1401-01-02 00:00:00", "1401-01-02 00:59:59"), tz),
        jdatetime(c(NA_real_, NA_real_), tz)
    )
    expect_identical(
        jdatetime("1401-01-01 23:59:59", tz) + 1,
        jdatetime("1401-01-02 01:00:00", tz)
    )
})
