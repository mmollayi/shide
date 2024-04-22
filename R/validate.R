validate_ambiguous <- function(ambiguous) {
    ambiguous <- ambiguous %||% "earliest"
    arg_match(ambiguous, c("earliest", "latest", "NA"))
}
