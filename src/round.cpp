#include "shide.h"
#include <map>
#include <stdlib.h>

sh_year_month_day first_day_next_month(const sh_year_month_day& ymd);
std::string get_current_tzone_cpp();
date::local_seconds to_local_seconds(const date::sys_seconds& tp,
                                     const date::time_zone* p_time_zone,
                                     date::sys_info& info);

date::sys_seconds to_sys_seconds(const date::local_seconds& tp,
                                 const date::time_zone* p_time_zone,
                                 date::local_info& info);

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

enum class Unit {year, quarter, month, week, day, hour, minute, second};

Unit string_to_unit(const std::string& unit_name) {
    static const std::map<std::string, Unit> unit_map{
        {"year", Unit::year},
        {"quarter", Unit::quarter},
        {"month", Unit::month},
        {"week", Unit::week},
        {"day", Unit::day},
        {"hour", Unit::hour},
        {"minute", Unit::minute},
        {"second", Unit::second},
    };

    auto it = unit_map.find(unit_name);
    if (it != unit_map.end()) {
        return it->second;
    }
    else {
        Rf_error("Invalid unit: (%s)", unit_name.c_str());
    }
}

date::local_days
jdate_ceiling(const date::local_days& ld, const Unit& unit, const int n)
{
    sh_year_month_day ymd{ld};
    sh_year_month_day ymd2{};
    date::local_days ld_out{ld};
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
        ld_out = ld + (date::days{7} - sh_wday(ld)) + date::days{ 1 };
        return ld_out;
    case Unit::day:
        d = ceiling_component2(static_cast<unsigned>(ymd.day()), n);
        ymd2 = sh_year_month_day{ ymd.year(), ymd.month(), date::day(d)};
        if (!ymd2.ok())
            ymd2 = first_day_next_month(ymd2);
        break;
    default:
        Rf_error("Invalid unit");
    }

    ld_out = date::local_days{ ymd2 };
    return ld_out;
}

date::local_days
jdate_floor(const date::local_days& ld, const Unit& unit, const int n)
{
    sh_year_month_day ymd{ ld };
    sh_year_month_day ymd2{};
    date::local_days ld_out{};
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
        ld_out = ld - sh_wday(ld) + date::days{ 1 };
        return ld_out;
    case Unit::day:
        d = floor_component2(static_cast<unsigned>(ymd.day()), n);
        ymd2 = sh_year_month_day{ ymd.year(), ymd.month(), date::day(d)};
        break;
    default:
        Rf_error("Invalid unit");
    }

    ld_out = date::local_days{ ymd2 };
    return ld_out;
}

[[cpp11::register]]
cpp11::writable::doubles
jdate_ceiling_cpp(const cpp11::sexp x, const std::string& unit_name, const int n)
{
    const auto unit{ string_to_unit(unit_name) };
    const cpp11::doubles xx = cpp11::as_cpp<cpp11::doubles>(x);
    const R_xlen_t size = xx.size();
    cpp11::writable::doubles out(size);
    date::days days_since_epoch;
    date::local_days ld;
    date::local_days ld_out;

    for (R_xlen_t i = 0; i < size; ++i)
    {
        if (std::isnan(xx[i]))
        {
            out[i] = NA_REAL;
            continue;
        }

        ld = date::local_days{ date::days(static_cast<int>(xx[i])) };
        ld_out = jdate_ceiling(ld, unit, n);
        days_since_epoch = ld_out.time_since_epoch();
        out[i] = static_cast<double>(days_since_epoch.count());
    }

    return out;
}

[[cpp11::register]]
cpp11::writable::doubles
jdate_floor_cpp(const cpp11::sexp x, const std::string& unit_name, const int n)
{
    const auto unit{ string_to_unit(unit_name) };
    const cpp11::doubles xx = cpp11::as_cpp<cpp11::doubles>(x);
    const R_xlen_t size = xx.size();
    cpp11::writable::doubles out(size);
    date::days days_since_epoch;
    date::local_days ld;
    date::local_days ld_out;

    for (R_xlen_t i = 0; i < size; ++i)
    {
        if (std::isnan(xx[i]))
        {
            out[i] = NA_REAL;
            continue;
        }

        ld = date::local_days{ date::days(static_cast<int>(xx[i])) };
        ld_out = jdate_floor(ld, unit, n);
        days_since_epoch = ld_out.time_since_epoch();
        out[i] = static_cast<double>(days_since_epoch.count());
    }

    return out;
}

date::local_seconds
jdatetime_floor(const date::local_seconds& ls, const Unit& unit, const int n)
{
    const date::local_days ld{ date::floor<date::days>(ls) };
    const auto tod = date::hh_mm_ss<std::chrono::seconds>{ ls - ld };
    date::local_seconds ls_out{};
    int h, m, s;

    switch (unit)
    {
    case Unit::year:
    case Unit::quarter:
    case Unit::month:
    case Unit::week:
    case Unit::day:
        ls_out = date::local_seconds{ jdate_floor(ld, unit, n) };
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
    default:
        Rf_error("Invalid unit");
    }

    return ls_out;
}

[[cpp11::register]]
cpp11::writable::doubles
jdatetime_floor_cpp(const cpp11::sexp x, const std::string& unit_name, const int n)
{
    const cpp11::strings tz_name_ =  cpp11::as_cpp<cpp11::strings>(x.attr("tzone"));
    std::string tz_name(tz_name_[0]);
    const date::time_zone* tz{};

    if (!tz_name.size())
    {
        tz_name = get_current_tzone_cpp();
    }

    if (!tzdb::locate_zone(tz_name, tz))
    {
        cpp11::stop(std::string(tz_name + " not found in timezone database").c_str());
    }

    const auto unit{ string_to_unit(unit_name) };
    const cpp11::doubles xx = cpp11::as_cpp<cpp11::doubles>(x);
    const R_xlen_t size = xx.size();
    cpp11::writable::doubles out(size);
    date::sys_seconds ss;
    date::sys_seconds ss2;
    date::local_seconds ls;
    date::sys_info info;
    date::local_info info2;

    for (R_xlen_t i = 0; i < size; ++i)
    {
        if (std::isnan(xx[i]))
        {
            out[i] = NA_REAL;
            continue;
        }

        ss = sys_seconds_from_double(xx[i]);
        ls = to_local_seconds(ss, tz, info);
        ss2 = to_sys_seconds(jdatetime_floor(ls, unit, n), tz, info2);
        out[i] = static_cast<double>(ss2.time_since_epoch().count());
    }

    return out;
}

date::local_seconds
jdatetime_ceiling(const date::local_seconds& ls, const Unit& unit, const int n)
{
    if (jdatetime_floor(ls, unit, n) == ls)
    {
        return ls;
    }

    const date::local_days ld{ date::floor<date::days>(ls) };
    const auto tod = date::hh_mm_ss<std::chrono::seconds>{ ls - ld };
    date::local_seconds ls_out{};
    int h, m, s;

    switch (unit)
    {
    case Unit::year:
    case Unit::quarter:
    case Unit::month:
    case Unit::week:
    case Unit::day:
        ls_out = date::local_seconds{ jdate_ceiling(ld, unit, n) };
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
    default:
        Rf_error("Invalid unit");
    }

    return ls_out;
}

[[cpp11::register]]
cpp11::writable::doubles
jdatetime_ceiling_cpp(const cpp11::sexp x, const std::string& unit_name, const int n)
{
    const cpp11::strings tz_name_ =  cpp11::as_cpp<cpp11::strings>(x.attr("tzone"));
    std::string tz_name(tz_name_[0]);
    const date::time_zone* tz{};

    if (!tz_name.size())
    {
        tz_name = get_current_tzone_cpp();
    }

    if (!tzdb::locate_zone(tz_name, tz))
    {
        cpp11::stop(std::string(tz_name + " not found in timezone database").c_str());
    }

    const auto unit{ string_to_unit(unit_name) };
    const cpp11::doubles xx = cpp11::as_cpp<cpp11::doubles>(x);
    const R_xlen_t size = xx.size();
    cpp11::writable::doubles out(size);
    date::sys_seconds ss;
    date::sys_seconds ss2;
    date::local_seconds ls;
    date::sys_info info;
    date::local_info info2;

    for (R_xlen_t i = 0; i < size; ++i)
    {
        if (std::isnan(xx[i]))
        {
            out[i] = NA_REAL;
            continue;
        }

        ss = sys_seconds_from_double(xx[i]);
        ls = to_local_seconds(ss, tz, info);
        ss2 = to_sys_seconds(jdatetime_ceiling(ls, unit, n), tz, info2);
        out[i] = static_cast<double>(ss2.time_since_epoch().count());
    }

    return out;
}

[[cpp11::register]]
cpp11::writable::list
parse_unit_cpp(const cpp11::strings& unit) {
    const std::string unit_(unit[0]);
    const char* unit_char{unit_.c_str()};
    char* end;
    double d{strtod(unit_char, &end)};

    if (unit_char == end)
    {
        d = 1;
    }

    const char* ws = " \t\n\r\f\v";
    std::string s{end};
    // trim from beginning of string
    s.erase(0, s.find_first_not_of(ws));
    // trim from end of string (right)
    s.erase(s.find_last_not_of(ws) + 1);

    cpp11::writable::list out({
        cpp11::writable::doubles{d},
        cpp11::writable::strings{s}
    });
    out.names() = {"n", "unit"};
    return out;
}
