test_that("jdatetimes have informative types", {
    expect_equal(vec_ptype_abbr(jdatetime_now()), "jdttm")
    expect_equal(vec_ptype_full(jdatetime_now()), "jdatetime<local>")
})

test_that("prototype objects are generated as expected", {
    expect_equal(jdatetime(), new_jdatetime())
    expect_equal(jdatetime(tzone = "UTC"), new_jdatetime(tzone = "UTC"))
})

# constructor ---------------------------------------------------------------

test_that("can create a jdatetime", {
    expect_identical(
        jdatetime(),
        structure(double(), class = c("jdatetime", "vctrs_vctr"), tzone = "")
    )
    expect_identical(
        jdatetime(0),
        structure(0, class = c("jdatetime", "vctrs_vctr"), tzone = "")
    )
    expect_identical(jdatetime(0L), jdatetime(0))
})

test_that("input names are retained", {
    expect_named(jdatetime(c(x = 0)), "x")
})

test_that("tzone is allowed to be `NULL`", {
    expect_identical(jdatetime(tzone = NULL), jdatetime(tzone = ""))
})

test_that("tzone must be a scalar character or NULL", {
    expect_identical(jdatetime(tzone = NULL), jdatetime(tzone = ""))
    expect_error(jdatetime(tzone = 1))
    expect_error(jdatetime(tzone = c("UTC", "")))
    expect_error(jdatetime(tzone = NA_character_))
})

test_that("jdatetime covers the whole range intended range", {
    expect_equal(
        format(jdatetime(c("-1095-01-01 00:00:00", "2326-12-29 23:59:59"), "UTC")),
        c("-1095-01-01 00:00:00 +0000", "2326-12-29 23:59:59 +0000")
    )
})

# coercion ------------------------------------------------------------------------------------

# these tests are brought over from vctrs package
test_that("tz comes from first non-empty", {
    # On the assumption that if you've set the time zone explicitly it
    # should win

    x <- jdatetime("1403-02-25 11:45:03")
    y <- jdatetime("1403-02-25 11:45:03", tz = "Asia/Tehran")

    expect_identical(vec_ptype2(x, y), y[0])
    expect_identical(vec_ptype2(y, x), y[0])

    z <- jdatetime("1403-02-25 11:45:03", tz = "UTC")
    expect_identical(vec_ptype2(y, z), y[0])
    expect_identical(vec_ptype2(z, y), z[0])
})

test_that("jdatetime coercions are symmetric and unchanging", {
    types <- list(
        jdate(),
        jdatetime(),
        jdatetime(tzone = "UTC")
    )
    mat <- maxtype_mat(types)

    expect_true(isSymmetric(mat))

    local_options(width = 100)
    expect_snapshot(print(mat))
})

test_that("vec_ptype2(<jdatetime>, NA) is symmetric", {
    dt <- jdatetime()
    expect_identical(
        vec_ptype2(dt, NA),
        vec_ptype2(NA, dt)
    )
})

# cast ----------------------------------------------------------------------------------------

test_that("jdatetime casts work as expected", {
    dt <- jdatetime("1403-02-29 00:00:00", tz = "UTC")

    expect_identical(vec_cast(NULL, dt), NULL)
    expect_identical(vec_cast(dt, dt), dt)
    expect_identical(vec_cast(as_jdate(dt), dt), dt)

    na_dt <- jdatetime(NA_real_, tzone = "UTC")

    expect_identical(vec_cast(NA, jdatetime(tzone = "UTC")), na_dt)
    expect_identical(vec_cast(na_dt, na_dt), na_dt)
    expect_identical(vec_cast(as_jdate(na_dt), na_dt), na_dt)

})

test_that("casting to another time zone retains the underlying data", {
    dt <- jdatetime("1403-02-31 14:46:24", tz = "Asia/Tehran")

    expect_equal(
        vec_data(vec_cast(dt, jdatetime(tzone = "UTC"))),
        vec_data(dt)
    )
})

# arithmetic ----------------------------------------------------------------------------------

test_that("jdate vs numeric arithmetic works as expected", {
    dt <- jdatetime("1403-02-31 00:00:00", tzone = "Asia/Tehran")

    expect_identical(vec_arith("+", dt, 1), dt + 1)
    expect_identical(vec_arith("+", 1, dt), dt + 1)
    expect_identical(vec_arith("-", dt, 1), dt - 1)
    expect_error(vec_arith("-", 1, dt), class = "vctrs_error_incompatible_op")
    expect_error(vec_arith("*", 1, dt), class = "vctrs_error_incompatible_op")
    expect_error(vec_arith("*", dt, 1), class = "vctrs_error_incompatible_op")
})

test_that("jdatetime vs jdate-jdatetime arithmetic works as expected", {
    d <- jdate("1403-02-31")
    dt1 <- jdatetime("1403-02-31 00:00:00", tzone = "Asia/Tokyo")
    dt2 <- as_jdatetime(d)

    expect_error(vec_arith("+", dt1, dt1), class = "vctrs_error_incompatible_op")
    expect_identical(vec_arith("-", dt1, dt1), dt1 - dt1)

    expect_error(vec_arith("+", dt1, d), class = "vctrs_error_incompatible_op")
    expect_identical(vec_arith("-", dt1, d), difftime(dt1, as_jdatetime(d), units = "secs"))

    expect_identical(vec_arith("-", dt2, d), as.difftime(0, units = "secs"))
})

# math ----------------------------------------------------------------------------------------

test_that("jdatetime math works as expected", {
    testthat::expect_true(is.finite(jdatetime(0)))
    testthat::expect_false(is.infinite(jdatetime(0)))
    expect_error(vec_math("sum", jdatetime()))
})

# parse ---------------------------------------------------------------------------------------

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
})

test_that("jdatetime works as expected at time zone boundaries", {
    tz <- "Asia/Tehran"
    expect_identical(
        jdatetime("1401-01-01 23:59:59", tz) + 1,
        jdatetime("1401-01-02 01:00:00", tz)
    )

    expect_identical(
        jdatetime("1401-06-30 23:59:59", tz) + 1,
        jdatetime("1401-06-30 23:00:00", tz, ambiguous = "latest")
    )
})

test_that("jdatetime_make works as expected", {
    tz <- "Asia/Tehran"
    expect_identical(
        jdatetime_make(1402:1403, 2, 7, 9, 22, 44, tz),
        jdatetime(c("1402-02-07 09:22:44", "1403-02-07 09:22:44"), tz)
    )

    expect_identical(
        jdatetime_make(1401, 6, 30, 23, 0, 0, tz, ambiguous = "latest"),
        jdatetime("1401-06-30 23:00:00", tz, ambiguous = "latest")
    )
})
