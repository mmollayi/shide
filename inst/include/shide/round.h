#ifndef ROUND_H
#define ROUND_H

#include <map>
#include <optional>
#include "shide/sh_year_month_day.h"
#include "shide/tzdb.h"
#include "shide/utils.h"
#include "shide/seq.h"

using date::local_days;
using date::local_seconds;

constexpr int floor_component1(const int x, const int n)
{
    return (x / n) * n;
}

constexpr int floor_component2(const int x, const int n)
{
    return ((x - 1) / n) * n + 1;
}

constexpr int ceiling_component1(const int x, const int n)
{
    return ((x / n) + 1) * n;
}
constexpr int ceiling_component2(const int x, const int n)
{
    return ((x - 1) / n + 1) * n + 1;
}

enum class Unit { second, minute, hour, day, week, month, quarter, year };

std::optional<Unit> string_to_unit(const std::string& unit_name) {
    static const std::map<std::string, Unit> unit_map{
        {"year", Unit::year},
        {"quarter", Unit::quarter},
        {"month", Unit::month},
        {"week", Unit::week},
        {"day", Unit::day},
        {"hour", Unit::hour},
        {"minute", Unit::minute},
        {"second", Unit::second}
    };

    auto it = unit_map.find(unit_name);
    if (it != unit_map.end()) {
        return it->second;
    }
    else {
        return {};
    }
}

inline
local_days
floor_jdate(const local_days& ld, const Unit& unit, const int n)
{
    sh_year_month_day ymd{ ld };
    sh_year_month_day ymd2{};
    int y, m, d;

    switch (unit)
    {
    case Unit::year:
        y = floor_component1(static_cast<int>(ymd.year()), n);
        ymd2 = sh_year_month_day{ date::year(y), date::month(1), date::day(1) };
        break;
    case Unit::quarter:
        m = floor_component2(static_cast<unsigned>(ymd.month()), n * 3);
        ymd2 = sh_year_month_day{ ymd.year(), date::month(m), date::day(1) };
        break;
    case Unit::month:
        m = floor_component2(static_cast<unsigned>(ymd.month()), n);
        ymd2 = sh_year_month_day{ ymd.year(), date::month(m), date::day(1) };
        break;
    case Unit::week:
        return ld - sh_wday(ld) + date::days{ 1 };
    case Unit::day:
        d = floor_component2(static_cast<unsigned>(ymd.day()), n);
        ymd2 = sh_year_month_day{ ymd.year(), ymd.month(), date::day(d) };
        break;
    default:
       return internal::nan_local_days;
    }

    return local_days{ ymd2 };
}

inline
sys_seconds
floor_jdatetime(const sys_seconds& tp, const date::time_zone* p_time_zone,
    const Unit& unit, const int n)
{
    const auto ls = to_local_seconds(tp, p_time_zone);
    const local_days ld{ date::floor<date::days>(ls) };
    const auto tod = hour_minute_second{ ls - ld };
    date::local_seconds ls_out{};
    int h, m, s;

    switch (unit)
    {
    case Unit::year:
    case Unit::quarter:
    case Unit::month:
    case Unit::week:
    case Unit::day:
        ls_out = date::local_seconds{ floor_jdate(ld, unit, n) };
        break;
    case Unit::hour:
        h = floor_component1(tod.hours().count(), n);
        ls_out = ld + std::chrono::hours{ h };
        break;
    case Unit::minute:
        m = floor_component1(tod.minutes().count(), n);
        ls_out = ld + tod.hours() + std::chrono::minutes{ m };
        break;
    case Unit::second:
        s = floor_component1(tod.seconds().count(), n);
        ls_out = ld + tod.hours() + tod.minutes() + std::chrono::seconds{ s };
        break;
    }

    return to_sys_seconds(ls_out, p_time_zone);
}

inline
date::local_days
ceiling_jdate(const local_days& ld, const Unit& unit, const int n)
{
    sh_year_month_day ymd{ ld };
    sh_year_month_day ymd2{};
    int y, m, d;

    switch (unit)
    {
    case Unit::year:
        y = ceiling_component1(static_cast<int>(ymd.year()), n);
        ymd2 = sh_year_month_day{ date::year(y), date::month(1), date::day(1) };
        break;
    case Unit::quarter:
        m = ceiling_component2(static_cast<unsigned>(ymd.month()), n * 3);
        ymd2 = sh_year_month_day{ ymd.year(), date::month(m), date::day(1) };
        break;
    case Unit::month:
        m = ceiling_component2(static_cast<unsigned>(ymd.month()), n);
        ymd2 = sh_year_month_day{ ymd.year(), date::month(m), date::day(1) };
        break;
    case Unit::week:
        return ld + (date::days{ 7 } - sh_wday(ld)) + date::days{ 1 };
    case Unit::day:
        d = ceiling_component2(static_cast<unsigned>(ymd.day()), n);
        ymd2 = sh_year_month_day{ ymd.year(), ymd.month(), date::day(d) };
        if (!ymd2.ok())
            ymd2 = first_day_next_month(ymd2);
        break;
    default:
        return internal::nan_local_days;
    }

    return local_days{ ymd2 };
}

inline
sys_seconds
ceiling_jdatetime(const sys_seconds& tp, const date::time_zone* p_time_zone,
    const Unit& unit, const int n)
{
    if (floor_jdatetime(tp, p_time_zone, unit, n) == tp)
        return tp;

    const auto ls = to_local_seconds(tp, p_time_zone);
    const local_days ld{ date::floor<date::days>(ls) };
    const auto tod = hour_minute_second{ ls - ld };
    date::local_seconds ls_out{};
    int h, m, s;

    switch (unit)
    {
    case Unit::year:
    case Unit::quarter:
    case Unit::month:
    case Unit::week:
    case Unit::day:
        ls_out = date::local_seconds{ ceiling_jdate(ld, unit, n) };
        break;
    case Unit::hour:
        h = ceiling_component1(tod.hours().count(), n);
        ls_out = ld + std::chrono::hours{ h };
        break;
    case Unit::minute:
        m = ceiling_component1(tod.minutes().count(), n);
        ls_out = ld + tod.hours() + std::chrono::minutes{ m };
        break;
    case Unit::second:
        s = ceiling_component1(tod.seconds().count(), n);
        ls_out = ld + tod.hours() + tod.minutes() + std::chrono::seconds{ s };
        break;
    }

    return to_sys_seconds(ls_out, p_time_zone);
}


#endif
