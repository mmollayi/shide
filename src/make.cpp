#include "shide.h"
#include <map>
#include <math.h>
#include <optional>

using cpp11::integers;
using cpp11::doubles;
using std::chrono::seconds;

enum class choose { earliest, latest, NA };

std::optional<choose> string_to_choose(const std::string& choose_str) {
    static const std::map<std::string, choose> choose_map{
        {"earliest", choose::earliest},
        {"latest", choose::latest},
        {"NA", choose::NA},
    };

    auto it = choose_map.find(choose_str);
    if (it != choose_map.end()) {
        return it->second;
    }
    else {
        return {};
    }
}

choose detect_ambiguous_resolution_from_reference(const date::time_zone* tz,
                                                  const date::sys_seconds& ss_ref)
{
    date::sys_info info;
    tzdb::get_sys_info(ss_ref, tz, info);
    const date::local_seconds ls_ref{ (ss_ref + info.offset).time_since_epoch() };
    date::local_info info2;
    tzdb::get_local_info(ls_ref, tz, info2);
    const date::sys_seconds ss_ref1{ (ls_ref - info2.first.offset).time_since_epoch() };
    const date::sys_seconds ss_ref2{ (ls_ref - info2.second.offset).time_since_epoch() };

    if (ss_ref == ss_ref1)
    {
        return choose::earliest;
    }
    else if (ss_ref == ss_ref2)
    {
        return choose::latest;
    }
    else
    {
        cpp11::stop("Unknown error");
    }
}

double jdatetime_from_local_seconds(const date::local_seconds& ls, const date::time_zone* tz,
                                    date::local_info& info, const choose& c)
{
    tzdb::get_local_info(ls, tz, info);
    seconds s{};
    if (info.result == date::local_info::unique)
    {
        s = ls.time_since_epoch() - info.first.offset;
    }
    else if (info.result == date::local_info::ambiguous)
    {
        switch (c)
        {
        case choose::earliest:
            s = ls.time_since_epoch() - info.first.offset;
            break;
        case choose::latest:
            s = ls.time_since_epoch() - info.second.offset;
            break;
        case choose::NA:
            return NA_REAL;
        }
    }
    else
    {
        return NA_REAL;
    }

    return static_cast<double>(s.count());
}

double jdatetime_from_local_seconds_with_reference(const date::local_seconds& ls,
                                                   const date::time_zone* tz,
                                                   date::local_info& info,
                                                   const date::sys_seconds& ss_ref)
{
    tzdb::get_local_info(ls, tz, info);
    seconds s{};
    if (info.result == date::local_info::unique)
    {
        s = ls.time_since_epoch() - info.first.offset;
    }
    else if (info.result == date::local_info::ambiguous)
    {
        const auto c = detect_ambiguous_resolution_from_reference(tz, ss_ref);

        switch (c)
        {
        case choose::earliest:
            s = ls.time_since_epoch() - info.first.offset;
            break;
        case choose::latest:
            s = ls.time_since_epoch() - info.second.offset;
            break;
        case choose::NA:
            return NA_REAL;
        }
    }
    else
    {
        return NA_REAL;
    }

    return static_cast<double>(s.count());
}

bool hour_minute_second_ok(const int hour, const int minute, const int second)
{
    if (!(0 <= hour && hour <= 23))
        return false;

    if (!(0 <= minute && minute <= 59))
        return false;

    if (!(0 <= second && second <= 59))
        return false;

    return true;
}

bool make_local_seconds(const int year, const int month, const int day,
                        const int hour, const int minute, const int second,
                        date::local_seconds& ls)
{
    using std::chrono::hours;
    using std::chrono::minutes;

    if (!hour_minute_second_ok(hour, minute, second))
    {
        return false;
    }

    const auto ymd = sh_year_month_day{ date::year(year), date::month(month), date::day(day) };
    if (!ymd.ok())
    {
        return false;
    }

    ls = local_days(ymd) + hours{ hour } + minutes{ minute } + seconds{ second };
    return true;
}

[[cpp11::register]]
doubles jdate_make_cpp(cpp11::list_of<cpp11::integers> fields) {
    date::days days_since_epoch;

    const integers year = fields[0];
    const integers month = fields[1];
    const integers day = fields[2];

    const R_xlen_t size = year.size();
    cpp11::writable::doubles out(size);
    sh_year_month_day ymd{};

    for (R_xlen_t i = 0; i < size; ++i) {
        if (year[i] == NA_INTEGER) {
            out[i] = NA_REAL;
            continue;
        }

        ymd = {date::year(year[i]), date::month(month[i]), date::day(day[i])};

        if (!ymd.ok())
        {
            out[i] = NA_REAL;
            continue;
        }

        days_since_epoch = local_days(ymd).time_since_epoch();
        out[i] = static_cast<double>(days_since_epoch.count());
    }

    return out;
}

doubles
jdatetime_make_impl(const integers& year, const integers& month, const integers& day,
                    const integers& hour, const integers& minute, const integers& second,
                    const date::time_zone* tz, const choose& c)
{
    const R_xlen_t size = year.size();
    cpp11::writable::doubles out(size);
    date::local_seconds ls;
    date::local_info info;

    for (R_xlen_t i = 0; i < size; ++i) {
        if (year[i] == NA_INTEGER) {
            out[i] = NA_REAL;
            continue;
        }

        if (!make_local_seconds(year[i], month[i], day[i], hour[i], minute[i], second[i], ls))
        {
            out[i] = NA_REAL;
            continue;
        }

        out[i] = jdatetime_from_local_seconds(ls, tz, info, c);
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
    date::local_seconds ls;
    date::local_info info;
    date::sys_seconds ss_ref;

    for (R_xlen_t i = 0; i < size; ++i) {
        if (year[i] == NA_INTEGER) {
            out[i] = NA_REAL;
            continue;
        }

        if (!make_local_seconds(year[i], month[i], day[i], hour[i], minute[i], second[i], ls))
        {
            out[i] = NA_REAL;
            continue;
        }

        ss_ref = sys_seconds_from_double(ref[i]);
        out[i] = jdatetime_from_local_seconds_with_reference(ls, tz, info, ss_ref);
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
