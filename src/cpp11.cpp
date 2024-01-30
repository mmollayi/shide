// Generated by cpp11: do not edit by hand
// clang-format off


#include "cpp11/declarations.hpp"
#include <R_ext/Visibility.h>

// accessors.cpp
cpp11::writable::list jdate_get_fields_cpp(const cpp11::sexp x);
extern "C" SEXP _shide_jdate_get_fields_cpp(SEXP x) {
  BEGIN_CPP11
    return cpp11::as_sexp(jdate_get_fields_cpp(cpp11::as_cpp<cpp11::decay_t<const cpp11::sexp>>(x)));
  END_CPP11
}
// accessors.cpp
cpp11::writable::list jdatetime_get_fields_cpp(const cpp11::sexp x);
extern "C" SEXP _shide_jdatetime_get_fields_cpp(SEXP x) {
  BEGIN_CPP11
    return cpp11::as_sexp(jdatetime_get_fields_cpp(cpp11::as_cpp<cpp11::decay_t<const cpp11::sexp>>(x)));
  END_CPP11
}
// accessors.cpp
cpp11::writable::integers jdate_get_yday_cpp(const cpp11::sexp x);
extern "C" SEXP _shide_jdate_get_yday_cpp(SEXP x) {
  BEGIN_CPP11
    return cpp11::as_sexp(jdate_get_yday_cpp(cpp11::as_cpp<cpp11::decay_t<const cpp11::sexp>>(x)));
  END_CPP11
}
// format.cpp
cpp11::writable::strings format_jdate_cpp(const cpp11::doubles x, const cpp11::strings& format);
extern "C" SEXP _shide_format_jdate_cpp(SEXP x, SEXP format) {
  BEGIN_CPP11
    return cpp11::as_sexp(format_jdate_cpp(cpp11::as_cpp<cpp11::decay_t<const cpp11::doubles>>(x), cpp11::as_cpp<cpp11::decay_t<const cpp11::strings&>>(format)));
  END_CPP11
}
// format.cpp
cpp11::writable::strings format_jdatetime_cpp(const cpp11::sexp x, const cpp11::strings& format);
extern "C" SEXP _shide_format_jdatetime_cpp(SEXP x, SEXP format) {
  BEGIN_CPP11
    return cpp11::as_sexp(format_jdatetime_cpp(cpp11::as_cpp<cpp11::decay_t<const cpp11::sexp>>(x), cpp11::as_cpp<cpp11::decay_t<const cpp11::strings&>>(format)));
  END_CPP11
}
// make.cpp
cpp11::doubles jdate_make_cpp(cpp11::list_of<cpp11::integers> fields);
extern "C" SEXP _shide_jdate_make_cpp(SEXP fields) {
  BEGIN_CPP11
    return cpp11::as_sexp(jdate_make_cpp(cpp11::as_cpp<cpp11::decay_t<cpp11::list_of<cpp11::integers>>>(fields)));
  END_CPP11
}
// make.cpp
cpp11::doubles jdatetime_make_cpp(cpp11::list_of<cpp11::integers> fields, const cpp11::strings& tzone);
extern "C" SEXP _shide_jdatetime_make_cpp(SEXP fields, SEXP tzone) {
  BEGIN_CPP11
    return cpp11::as_sexp(jdatetime_make_cpp(cpp11::as_cpp<cpp11::decay_t<cpp11::list_of<cpp11::integers>>>(fields), cpp11::as_cpp<cpp11::decay_t<const cpp11::strings&>>(tzone)));
  END_CPP11
}
// parse.cpp
cpp11::writable::doubles jdate_parse_cpp(const cpp11::strings& x, const cpp11::strings& format);
extern "C" SEXP _shide_jdate_parse_cpp(SEXP x, SEXP format) {
  BEGIN_CPP11
    return cpp11::as_sexp(jdate_parse_cpp(cpp11::as_cpp<cpp11::decay_t<const cpp11::strings&>>(x), cpp11::as_cpp<cpp11::decay_t<const cpp11::strings&>>(format)));
  END_CPP11
}
// parse.cpp
cpp11::writable::doubles jdatetime_parse_cpp(const cpp11::strings& x, const cpp11::strings& format, const cpp11::strings& tzone);
extern "C" SEXP _shide_jdatetime_parse_cpp(SEXP x, SEXP format, SEXP tzone) {
  BEGIN_CPP11
    return cpp11::as_sexp(jdatetime_parse_cpp(cpp11::as_cpp<cpp11::decay_t<const cpp11::strings&>>(x), cpp11::as_cpp<cpp11::decay_t<const cpp11::strings&>>(format), cpp11::as_cpp<cpp11::decay_t<const cpp11::strings&>>(tzone)));
  END_CPP11
}
// utils.cpp
cpp11::writable::doubles sys_seconds_from_local_days_cpp(const cpp11::doubles x, const cpp11::strings& tzone);
extern "C" SEXP _shide_sys_seconds_from_local_days_cpp(SEXP x, SEXP tzone) {
  BEGIN_CPP11
    return cpp11::as_sexp(sys_seconds_from_local_days_cpp(cpp11::as_cpp<cpp11::decay_t<const cpp11::doubles>>(x), cpp11::as_cpp<cpp11::decay_t<const cpp11::strings&>>(tzone)));
  END_CPP11
}
// utils.cpp
cpp11::writable::doubles local_days_from_sys_seconds_cpp(const cpp11::doubles x, const cpp11::strings& tzone);
extern "C" SEXP _shide_local_days_from_sys_seconds_cpp(SEXP x, SEXP tzone) {
  BEGIN_CPP11
    return cpp11::as_sexp(local_days_from_sys_seconds_cpp(cpp11::as_cpp<cpp11::decay_t<const cpp11::doubles>>(x), cpp11::as_cpp<cpp11::decay_t<const cpp11::strings&>>(tzone)));
  END_CPP11
}
// zone.cpp
cpp11::writable::strings get_zone_info(const cpp11::strings& x, const cpp11::strings& tzone);
extern "C" SEXP _shide_get_zone_info(SEXP x, SEXP tzone) {
  BEGIN_CPP11
    return cpp11::as_sexp(get_zone_info(cpp11::as_cpp<cpp11::decay_t<const cpp11::strings&>>(x), cpp11::as_cpp<cpp11::decay_t<const cpp11::strings&>>(tzone)));
  END_CPP11
}

extern "C" {
static const R_CallMethodDef CallEntries[] = {
    {"_shide_format_jdate_cpp",                (DL_FUNC) &_shide_format_jdate_cpp,                2},
    {"_shide_format_jdatetime_cpp",            (DL_FUNC) &_shide_format_jdatetime_cpp,            2},
    {"_shide_get_zone_info",                   (DL_FUNC) &_shide_get_zone_info,                   2},
    {"_shide_jdate_get_fields_cpp",            (DL_FUNC) &_shide_jdate_get_fields_cpp,            1},
    {"_shide_jdate_get_yday_cpp",              (DL_FUNC) &_shide_jdate_get_yday_cpp,              1},
    {"_shide_jdate_make_cpp",                  (DL_FUNC) &_shide_jdate_make_cpp,                  1},
    {"_shide_jdate_parse_cpp",                 (DL_FUNC) &_shide_jdate_parse_cpp,                 2},
    {"_shide_jdatetime_get_fields_cpp",        (DL_FUNC) &_shide_jdatetime_get_fields_cpp,        1},
    {"_shide_jdatetime_make_cpp",              (DL_FUNC) &_shide_jdatetime_make_cpp,              2},
    {"_shide_jdatetime_parse_cpp",             (DL_FUNC) &_shide_jdatetime_parse_cpp,             3},
    {"_shide_local_days_from_sys_seconds_cpp", (DL_FUNC) &_shide_local_days_from_sys_seconds_cpp, 2},
    {"_shide_sys_seconds_from_local_days_cpp", (DL_FUNC) &_shide_sys_seconds_from_local_days_cpp, 2},
    {NULL, NULL, 0}
};
}

extern "C" attribute_visible void R_init_shide(DllInfo* dll){
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
}
