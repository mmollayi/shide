test_that("individual formatting flags work as expected", {
    x <- jdatetime("1404-09-06 13:48:04", "Asia/Tehran")
    cases <- c(
        "%a" = "Thu",
        "%A" = "Thursday",
        "%b" = "Aza",
        "%B" = "Azar",
        "%C" = "14",
        "%d" = "06",
        "%e" = " 6",
        "%F" = "1404-09-06",
        "%H" = "13",
        "%I" = "01",
        "%j" = "252",
        "%J" = "1404/09/06",
        "%m" = "09",
        "%M" = "48",
        "%p" = "PM",
        "%r" = "01:48:04 PM",
        "%R" = "13:48",
        "%S" = "04",
        "%T" = "13:48:04",
        "%Y" = "1404",
        "%y" = "04",
        "%z" = "+0330",
        "%Z" = "Asia/Tehran",
        "%%" = "%",
        "%n" = "\n",
        "%t" = "\t"
    )

    out <- vapply(
        X = names(cases),
        FUN = function(format) format(x, format = format),
        FUN.VALUE = character(1)
    )

    expect_identical(out, cases)
})

test_that("formatting jdate objects with %z or %Z returns NA", {
    x <- jdate("1404-09-26")
    expect_true(is.na(format(x, "%z")))
    expect_true(is.na(format(x, "%Z")))
})

test_that("%I and %p agree at midnight and noon", {
    x <- jdatetime_make(1404, 9, 6, c(0, 12), 0, 0)
    expect_identical(format(x, "%I %p"), c("12 AM", "12 PM"))
})

test_that("common composite formats work", {
    x <- jdatetime_make(1404, 9, 6, 13, 48, 4)

    expect_identical(format(x, "%Y/%m/%d"), "1404/09/06")
    expect_identical(format(x, "%Y/%m/%d %R"), "1404/09/06 13:48")
    expect_identical(format(x, "%A %Y/%m/%d"), "Thursday 1404/09/06")
    expect_identical(format(x, "%J %T"), "1404/09/06 13:48:04")
    expect_identical(format(x, "%J %I:%M %p"), "1404/09/06 01:48 PM")
    expect_identical(format(x, "%d %B %Y"), "06 Azar 1404")
    expect_identical(format(x, "Date: %J"), "Date: 1404/09/06")
    expect_identical(format(x, "%F at %R"), "1404-09-06 at 13:48")
})
