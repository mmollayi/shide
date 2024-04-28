test_that("sh_floor works as expected for each unit", {
    d <- jdate(c("1367-09-06", "1371-03-13"))
    expect_identical(sh_floor(d), jdate(c("1367-09-06", "1371-03-13")))
    expect_identical(sh_floor(d, "day"), jdate(c("1367-09-06", "1371-03-13")))
    expect_identical(sh_floor(d, "week"), jdate(c("1367-09-05", "1371-03-09")))
    expect_identical(sh_floor(d, "month"), jdate(c("1367-09-01", "1371-03-01")))
    expect_identical(sh_floor(d, "quarter"), jdate(c("1367-07-01", "1371-01-01")))
    expect_identical(sh_floor(d, "year"), jdate(c("1367-01-01", "1371-01-01")))
})

test_that("sh_floor works as expected for multi-units", {
    d <- jdate(c("1367-09-06", "1371-03-13"))
    expect_identical(sh_floor(d, "2 days"), jdate(c("1367-09-05", "1371-03-13")))
    expect_identical(sh_floor(d, "10 days"), jdate(c("1367-09-01", "1371-03-11")))
    expect_identical(sh_floor(d, "4 months"), jdate(c("1367-09-01", "1371-01-01")))
    expect_identical(sh_floor(d, "2 quarters"), jdate(c("1367-07-01", "1371-01-01")))
    expect_identical(sh_floor(d, "2 years"), jdate(c("1366-01-01", "1370-01-01")))
    expect_identical(sh_floor(d, "3 years"), jdate(c("1365-01-01", "1371-01-01")))
})

test_that("sh_ceiling works as expected for each unit", {
    d <- jdate(c("1367-09-06", "1371-03-13"))
    expect_identical(sh_ceiling(d, "day"), jdate(c("1367-09-06", "1371-03-13")) + 1)
    expect_identical(sh_ceiling(d, "week"), jdate(c("1367-09-12", "1371-03-16")))
    expect_identical(sh_ceiling(d, "month"), jdate(c("1367-10-01", "1371-04-01")))
    expect_identical(sh_ceiling(d, "quarter"), jdate(c("1367-10-01", "1371-04-01")))
    expect_identical(sh_ceiling(d, "year"), jdate(c("1368-01-01", "1372-01-01")))
})

test_that("sh_round works as expected for each unit", {
    d <- jdate(c("1367-09-06", "1371-03-13"))
    expect_identical(sh_round(d, "day"), jdate(c("1367-09-06", "1371-03-13")))
    expect_identical(sh_round(d, "week"), jdate(c("1367-09-05", "1371-03-16")))
    expect_identical(sh_round(d, "month"), jdate(c("1367-09-01", "1371-03-01")))
    expect_identical(sh_round(d, "quarter"), jdate(c("1367-10-01", "1371-04-01")))
    expect_identical(sh_round(d, "year"), jdate(c("1368-01-01", "1371-01-01")))
})

test_that("sh_round works as expected for each unit", {
    d <- jdate(c("1367-09-06", "1371-03-13"))
    expect_identical(sh_round(d, "day"), jdate(c("1367-09-06", "1371-03-13")))
    expect_identical(sh_round(d, "week"), jdate(c("1367-09-05", "1371-03-16")))
    expect_identical(sh_round(d, "month"), jdate(c("1367-09-01", "1371-03-01")))
    expect_identical(sh_round(d, "quarter"), jdate(c("1367-10-01", "1371-04-01")))
    expect_identical(sh_round(d, "year"), jdate(c("1368-01-01", "1371-01-01")))
})

test_that("sh_round works as expected for dates that are exactly halfway between two consecutive units", {
    expect_identical(sh_round(jdate("1402-08-16"), "month"), jdate("1402-09-01"))
    expect_identical(sh_round(jdate("1402-08-16"), "quarter"), jdate("1402-10-01"))
    expect_identical(sh_round(jdate("1403-06-29"), "year"), jdate("1404-01-01"))
})

test_that("rounding works correctly for dates around the origin", {
    d <- jdate(c("1348-10-10", "1348-10-11", "1348-10-16"))
    expect_identical(sh_floor(d, "month"), vec_rep(jdate(c("1348-10-01")), 3))
    expect_identical(sh_ceiling(d, "month"), vec_rep(jdate(c("1348-11-01")), 3))
    expect_identical(sh_floor(d, "year"), vec_rep(jdate(c("1348-01-01")), 3))
})

test_that("parse_unit works as expected", {
    expect_identical(
        lapply(
            c("day", "days", "1day", "1days", "1.days", "1 day", "1 days", " 1 days "),
            parse_unit
        ),
        rep(list(list(n = 1, unit = "day")), 8)
    )

})

test_that("parse_unit errors as expected", {
    expect_error(parse_unit("1d"))
    expect_error(parse_unit(c("days", "months")))
    expect_error(parse_unit("1"))
    expect_error(parse_unit("1.5 days"))
    expect_error(parse_unit("0 days"))
    expect_error(parse_unit("2327 years"))
    expect_error(parse_unit("2 weeks"))
})
