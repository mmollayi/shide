test_that("prototype objects are generated as expected", {
    expect_equal(jdatetime(), new_jdatetime())
    expect_equal(jdatetime(tzone = "UTC"), new_jdatetime(tzone = "UTC"))
})

test_that("jdatetime parser works as expected", {
    expect_identical(jdatetime("1402-11-07", format = "%Y-%m-%d"), jdatetime("1402-11-07 00:00:00"))
})

