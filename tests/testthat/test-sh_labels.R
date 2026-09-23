test_that("sh_labels() returns a shide_labels object or fails as expected", {
    mn <- letters[1:12]
    wd <- letters[1:7]
    ap <- c("AM", "PM")

    expect_s3_class(
        sh_labels(month = mn, weekday = wd, am_pm = ap),
        "shide_labels"
    )
    expect_error(sh_labels(month = mn[1:11], weekday = wd, am_pm = ap))
    expect_error(sh_labels(month = 1:12, weekday = wd, am_pm = ap))
    expect_error(sh_labels(month = mn, weekday = wd[1:6], am_pm = ap))
    expect_error(sh_labels(month = mn, weekday = 1:7, am_pm = ap))
    expect_error(sh_labels(month = mn, weekday = wd, am_pm = ap[1]))
    expect_error(sh_labels(month = mn, weekday = wd, am_pm = 1:2))
})

test_that("sh_labels() supports partial arguments", {
    expect_identical(sh_labels(), shide_labels_default)

    mn <- paste0("M", seq_len(12))
    lbls <- sh_labels(
        month = mn,
        month_abbr = shide_labels_default$month_abbr,
        weekday = shide_labels_default$weekday,
        weekday_abbr = shide_labels_default$weekday_abbr,
        am_pm = shide_labels_default$am_pm
    )
    expect_identical(lbls, sh_labels(month = mn))
})
