#ifndef MAKE_H
#define MAKE_H

#include <optional>
#include <array>
#include "shide/sh_year_month_day.h"
#include "shide/tzdb.h"
#include "shide/utils.h"
#include "shide/macros.h"

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

inline
choose
sys_seconds_to_choose(const sys_seconds& tp, const date::time_zone* tz)
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

inline
double 
jdatetime_from_local_seconds(const date::local_seconds& ls, const date::time_zone* tz,
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
            return NAN_DOUBLE;
        }
    }
    else
    {
        return NAN_DOUBLE;
    }

    return static_cast<double>(s.count());
}

constexpr
std::optional<date::local_seconds>
make_local_seconds(const sh_fields& fds)
{
    if (!fds.tod.in_conventional_range())
        return {};

    if (!fds.ymd.ok())
        return {};

    return local_days(fds.ymd) + fds.tod.to_duration();
}

inline
std::optional<double>
make_jdatetime(const sh_fields& fds, const date::time_zone* tz,
    date::local_info& info, choose c = choose::earliest)
{
    auto ls = make_local_seconds(fds);
    if (!ls.has_value())
        return {};

    const auto dt = jdatetime_from_local_seconds(*ls, tz, info, c);
    if (std::isnan(dt))
        return {};

    return dt;
}

inline
std::optional<double>
make_jdatetime(const sh_fields& fds, const date::time_zone* tz,
    date::local_info& info, const sys_seconds& ss_ref)
{
    auto ls = make_local_seconds(fds);
    if (!ls.has_value())
        return {};

    const auto dt = jdatetime_from_local_seconds(*ls, tz, info, choose{}, &ss_ref);
    if (std::isnan(dt))
        return {};

    return dt;
}

inline
std::optional<double>
make_jdatetime(const sh_fields& fds, const std::string& tz_name,
    choose c=choose::earliest)
{
    const date::time_zone* tz{};
    if (!tzdb::locate_zone(tz_name, tz))
        return {};

    date::local_info info;
    return make_jdatetime(fds, tz, info, c);
}

inline
std::optional<double>
make_jdatetime(const sh_fields& fds, const std::string& tz_name,
    const sys_seconds& ss_ref)
{
    const date::time_zone* tz{};
    if (!tzdb::locate_zone(tz_name, tz))
        return {};

    date::local_info info;
    return make_jdatetime(fds, tz, info, ss_ref);
}

constexpr
sh_fields
make_sh_fields(const date::local_seconds& tp)
{
    const auto ld = date::floor<date::days>(tp);
    return sh_fields{ sh_year_month_day(ld), hour_minute_second(tp - ld)};
}

inline
sh_fields
make_sh_fields(const date::sys_seconds& tp, const std::string& tz_name)
{
    sh_fields fds{};
    const date::time_zone* tz{};
    if (!tzdb::locate_zone(tz_name, tz))
        return fds;

    return make_sh_fields(to_local_seconds(tp, tz));
}

constexpr
double 
jdate_from_local_days(const date::local_days& ld)
{
    return static_cast<double>(ld.time_since_epoch().count());
}

constexpr
double
make_jdate(const date::local_days& ld)
{
     return jdate_from_local_days(ld);
}

constexpr
std::optional<double>
make_jdate(const sh_year_month_day& ymd)
{
    if (!ymd.ok())
    {
        return {};
    }

    return jdate_from_local_days(date::local_days(ymd));
}

#endif