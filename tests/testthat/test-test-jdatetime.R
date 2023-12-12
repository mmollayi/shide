test_that("prototype objects are generated as expected", {
    expect_equal(jdatetime(), new_jdatetime())
    expect_equal(jdatetime(tzone = "UTC"), new_jdatetime(tzone = "UTC"))
})
