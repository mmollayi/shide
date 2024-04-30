.onLoad <- function(...) {
    tzdb::tzdb_initialize()

    vctrs::s3_register("pillar::pillar_shaft", "jdate")
    vctrs::s3_register("pillar::pillar_shaft", "jdatetime")
}
