test_that("sh_floor works as expected for each unit", {
    d <- jdate(c("1367-09-06", "1371-03-13"))
    expect_identical(sh_floor(d, "day"), jdate(c("1367-09-06", "1371-03-13")))
    expect_identical(sh_floor(d, "week"), jdate(c("1367-09-05", "1371-03-09")))
    expect_identical(sh_floor(d, "month"), jdate(c("1367-09-01", "1371-03-01")))
    expect_identical(sh_floor(d, "quarter"), jdate(c("1367-07-01", "1371-01-01")))
    expect_identical(sh_floor(d, "year"), jdate(c("1367-01-01", "1371-01-01")))
})

test_that("sh_ceiling works as expected for each unit", {
    d <- jdate(c("1367-09-06", "1371-03-13"))
    expect_identical(sh_ceiling(d, "day"), jdate(c("1367-09-06", "1371-03-13")))
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

