library(stringr)
library(dplyr)

cleanup <- function(x) {
    x |>
        str_sub(400) |>
        str_replace_all("ﻣﺎرس", "3") |>
        str_remove_all("[:alpha:]") |>
        str_remove_all("\\\n") |>
        str_remove_all("\\(|\\)|\\.") |>
        str_remove_all("\\u202a|\\u202b|\\u202c") |>
        str_remove_all("[\u0660-\u0669]") |>
        str_remove_all("[\u06f0-\u06f9]") |>
        str_trim() |>
        str_split("\\s{15,}") |> unlist() |>
        str_split("\\s{1,}")
}

# dataset uptained from https://calendar.ut.ac.ir/Fa/News/Data/Doc/KabiseShamsi1206-1498-new.pdf
pdf_file <- pdftools::pdf_text("./data-raw/KabiseShamsi1206-1498-new.pdf")
x <- purrr::map(pdf_file, cleanup)
x <- purrr::list_flatten(x)
x <- do.call("rbind", x)
colnames(x) <- c("jalali_date", "year", "month", "day")

jalali_leap_years <- x |>
    as_tibble() |>
    mutate(month = paste0("0", month)) |>
    tidyr::unite("gregorian_date", c(year, month, day), sep = "-") |>
    mutate(gregorian_date = as.Date(gregorian_date)) |>
    mutate(four_year_leap_year = str_detect(jalali_date, "^\\*{1}\\d")) |>
    mutate(five_year_leap_year = str_detect(jalali_date, "^\\*{2}\\d")) |>
    mutate(jalali_date = str_remove_all(jalali_date, "\\D") |> paste0("-01-01")) |>
    mutate(leap_year = four_year_leap_year | five_year_leap_year, .after = gregorian_date)


usethis::use_data(jalali_leap_years, overwrite = TRUE, internal = TRUE)
