test_that("shide_labels() returns a shide_labels object or fails as expected", {
    mn = letters[1:12]
    wd = letters[1:7]
    ap = c("AM", "PM")

    expect_s3_class(sh_labels(month = mn, weekday = wd, am_pm = ap), "shide_labels")
    expect_error(sh_labels(month = mn[1:11], weekday = wd, am_pm = ap))
    expect_error(sh_labels(month = 1:12, weekday = wd, am_pm = ap))
    expect_error(sh_labels(month = mn, weekday = wd[1:6], am_pm = ap))
    expect_error(sh_labels(month = mn, weekday = 1:7, am_pm = ap))
    expect_error(sh_labels(month = mn, weekday = wd, am_pm = ap[1]))
    expect_error(sh_labels(month = mn, weekday = wd, am_pm = 1:2))
})
