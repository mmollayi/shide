#include "shide.h"
#include <shide/make.h>

using cpp11::integers;
using cpp11::doubles;
using std::chrono::hours;
using std::chrono::minutes;
using std::chrono::seconds;

[[cpp11::register]]
doubles jdate_make_cpp(cpp11::list_of<cpp11::integers> fields) {
    const integers year = fields[0];
    const integers month = fields[1];
    const integers day = fields[2];

    const R_xlen_t size = year.size();
    cpp11::writable::doubles out(size);

    for (R_xlen_t i = 0; i < size; ++i) {
        if (year[i] == NA_INTEGER) {
            out[i] = NA_REAL;
            continue;
        }

        auto ymd = sh_year_month_day{date::year(year[i]), date::month(month[i]), date::day(day[i])};
        out[i] = make_jdate(ymd);
    }

    return out;
}

doubles
jdatetime_make_impl(const integers& year, const integers& month, const integers& day,
                    const integers& hour, const integers& minute, const integers& second,
                    const date::time_zone* tz, const choose c)
{
    const R_xlen_t size = year.size();
    cpp11::writable::doubles out(size);
    date::local_info info;
    struct sh_fields fds{};

    for (R_xlen_t i = 0; i < size; ++i) {
        if (year[i] == NA_INTEGER) {
            out[i] = NA_REAL;
            continue;
        }

        fds.ymd = {date::year(year[i]), date::month(month[i]), date::day(day[i])};
        fds.tod = {hours(hour[i]), minutes(minute[i]), seconds(second[i])};
        out[i] = make_jdatetime(fds, tz, info, c);
    }

    return out;
}

[[cpp11::register]]
doubles jdatetime_make_cpp(cpp11::list_of<cpp11::integers> fields,
                           const cpp11::strings& tzone, const std::string& ambiguous)
{
    const auto opt{ string_to_choose(ambiguous) };

    if (!opt) {
        cpp11::stop("Invalid ambiguous relolution strategy");
    }

    const auto Ambiguous{*opt};
    const date::time_zone* tz{};
    const std::string tz_name(tzone[0]);

    if (!tzdb::locate_zone(tz_name, tz))
    {
        cpp11::stop(std::string(tz_name + " not found in timezone database").c_str());
    }

    return jdatetime_make_impl(fields[0], fields[1], fields[2], fields[3], fields[4], fields[5],
                               tz, Ambiguous);
}

doubles jdatetime_make_with_reference_impl(const integers& year, const integers& month, const integers& day,
                                           const integers& hour, const integers& minute, const integers& second,
                                           const date::time_zone* tz, const doubles& ref) {
    const R_xlen_t size = year.size();
    cpp11::writable::doubles out(size);
    date::local_info info;
    date::sys_seconds ss_ref{};
    struct sh_fields fds{};

    for (R_xlen_t i = 0; i < size; ++i) {
        if (year[i] == NA_INTEGER) {
            out[i] = NA_REAL;
            continue;
        }

        fds.ymd = {date::year(year[i]), date::month(month[i]), date::day(day[i])};
        fds.tod = {hours(hour[i]), minutes(minute[i]), seconds(second[i])};
        ss_ref = sys_seconds_from_double(ref[i]);
        out[i] = make_jdatetime(fds, tz, info, ss_ref);
    }

    return out;
}

[[cpp11::register]]
doubles jdatetime_make_with_reference_cpp(cpp11::list_of<cpp11::integers> fields,
                                          const cpp11::strings& tzone, const cpp11::sexp x)
{
    const date::time_zone* tz{};
    const std::string tz_name(tzone[0]);

    if (!tzdb::locate_zone(tz_name, tz))
    {
        cpp11::stop(std::string(tz_name + " not found in timezone database").c_str());
    }

    const doubles xx = cpp11::as_cpp<cpp11::doubles>(x);
    return jdatetime_make_with_reference_impl(fields[0], fields[1], fields[2],
                                              fields[3], fields[4], fields[5], tz, xx);
}
