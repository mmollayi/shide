## Resubmission

This is a patch release related to failed installation of `shide` package on older versions
of R. The problems are shown on https://cran.r-project.org/web/checks/check_results_shide.html

The problems is `chooseOpsMethod()` function that I've used in my code, which looks
to have been introduced in R 4.3.0. I have incremented the minimum version dependency on R to
4.3.0 to fix the issue.

## R CMD check results

0 errors | 0 warnings | 0 note
