#ifndef MAKE_H
#define MAKE_H
#include <map>
#include <optional>
#include "sh_year_month_day.h"
#include <tzdb/tzdb.h>

using std::chrono::hours;
using std::chrono::seconds;
using std::chrono::minutes;
using date::sys_seconds;

enum class choose { earliest, latest, NA };

constexpr
std::optional<choose>
string_to_choose(const std::string& choose_str)
{
    constexpr std::array<std::pair<std::string_view, choose>, 3> choose_pair{ {
        {"earliest", choose::earliest},
        {"latest", choose::latest},
        {"NA", choose::NA},
        } };

    for (const auto& pair : choose_pair) {
        if (pair.first == choose_str) {
            return pair.second;
        }
    }

    return {};
}

choose sys_seconds_to_choose(const sys_seconds& tp, const date::time_zone* tz)
{
    date::sys_info info;
    tzdb::get_sys_info(tp, tz, info);
    const date::local_seconds ls_ref{ (tp + info.offset).time_since_epoch() };
    date::local_info info2;
    tzdb::get_local_info(ls_ref, tz, info2);

    if (info2.first.begin == info.begin)
    {
        return choose::earliest;
    }
    else if (info2.second.begin == info.begin)
    {
        return choose::latest;
    }
    else
    {
        return choose::NA;
    }
}

double jdatetime_from_local_seconds(const date::local_seconds& ls, const date::time_zone* tz,
    date::local_info& info, choose c, const sys_seconds* ss_ref = nullptr)
{
    tzdb::get_local_info(ls, tz, info);
    seconds s{};
    if (info.result == date::local_info::unique)
    {
        s = ls.time_since_epoch() - info.first.offset;
    }
    else if (info.result == date::local_info::ambiguous)
    {
        if (ss_ref)
            c = sys_seconds_to_choose(*ss_ref, tz);
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

constexpr
std::optional<date::local_seconds> make_local_seconds(const sh_fields& fds)
{
    if (!fds.tod.in_conventional_range())
        return {};

    if (!fds.ymd.ok())
        return {};

    return local_days(fds.ymd) + fds.tod.to_duration();
}

double make_jdatetime(const sh_fields& fds, const date::time_zone* tz,
    date::local_info& info, choose c = choose::earliest)
{
    auto ls = make_local_seconds(fds);
    if (!ls.has_value())
        return NA_REAL;

    return jdatetime_from_local_seconds(*ls, tz, info, c);
}

double make_jdatetime(const sh_fields& fds, const date::time_zone* tz,
    date::local_info& info, const sys_seconds& ss_ref)
{
    auto ls = make_local_seconds(fds);
    if (!ls.has_value())
        return NA_REAL;

    return jdatetime_from_local_seconds(*ls, tz, info, choose{}, &ss_ref);
}

double make_jdatetime(const sh_fields& fds, const std::string& tz_name,
    choose c=choose::earliest)
{
    const date::time_zone* tz{};
    if (!tzdb::locate_zone(tz_name, tz))
        return NA_REAL;

    date::local_info info;
    return make_jdatetime(fds, tz, info, c);
}

double make_jdatetime(const sh_fields& fds, const std::string& tz_name,
    const sys_seconds& ss_ref)
{
    const date::time_zone* tz{};
    if (!tzdb::locate_zone(tz_name, tz))
        return NA_REAL;

    date::local_info info;
    return make_jdatetime(fds, tz, info, ss_ref);
}

sh_fields make_sh_fields(const date::local_seconds& ls)
{
    const auto ld = date::floor<date::days>(ls);
    return sh_fields{ sh_year_month_day(ld), hour_minute_second(ls - ld)};
}

double jdate_from_local_days(const date::local_days& ld)
{
    return static_cast<double>(ld.time_since_epoch().count());
}

double make_jdate(const sh_year_month_day& ymd)
{
    if (!ymd.ok())
    {
        return NA_REAL;
    }

    return jdate_from_local_days(date::local_days(ymd));
}

#endif
