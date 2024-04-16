test_that("prototype objects are generated as expected", {
    expect_equal(jdatetime(), new_jdatetime())
    expect_equal(jdatetime(tzone = "UTC"), new_jdatetime(tzone = "UTC"))
})

test_that("jdatetime parser works as expected", {
    expect_identical(
        jdatetime("1402-11-07", format = "%Y-%m-%d"),
        jdatetime("1402-11-07 00:00:00")
    )

    expect_equal(
        vec_data(jdatetime("1403-01-28 16:38:51", tzone = "Asia/Tehran",
                           format = "%F %X")),
        1713272931
    )
    expect_equal(
        vec_data(jdatetime("1403-01-28 17", tzone = "Asia/Tehran",
                           format = "%F %H")),
        1713274200
    )
    expect_equal(
        vec_data(jdatetime("1403-01-28 17", tzone = "Asia/Tehran",
                           format = "%F %M")),
        1713214020
    )
    expect_equal(
        vec_data(jdatetime("1403-01-28 17", tzone = "Asia/Tehran",
                           format = "%F %S")),
        1713213017
    )
})

